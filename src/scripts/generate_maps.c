#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <ctype.h>
#include <sys/stat.h>
#include <cjson/cJSON.h>
#include <glob.h>
#include <stdint.h>
#include <tgmath.h>
#include <unistd.h>  // for access()

#define MAX_PATH 256
#define MAX_TYPES 256

// Structure to store object types for indexing
typedef struct {
    char* types[MAX_TYPES];
    int count;
} TypeIndex;

// Helper function to get file name without extension
char* get_filename_without_ext(const char* filename) {
    char* name = strdup(filename);
    char* dot = strrchr(name, '.');
    if (dot) *dot = '\0';
    return name;
}

// Helper function to create directory if not exists
void ensure_directory_exists(const char* path) {
    struct stat st = {0};
    if (stat(path, &st) == -1) {
        #ifdef _WIN32
            mkdir(path);
        #else
            mkdir(path, 0700);
        #endif
    }
}

// Helper function to find or add type to type index
int get_type_index(TypeIndex* typeIndex, const char* type) {
    for (int i = 0; i < typeIndex->count; i++) {
        if (strcmp(typeIndex->types[i], type) == 0) {
            return i;
        }
    }
    if (typeIndex->count < MAX_TYPES) {
        typeIndex->types[typeIndex->count] = strdup(type);
        return typeIndex->count++;
    }
    return -1;
}

void process_json_file(const char* json_path, const char* maps_directory, const char* handler_directory) {
    // Read JSON file
    FILE* file = fopen(json_path, "r");
    if (!file) {
        printf("Failed to open %s\n", json_path);
        return;
    }

    // Get file size and read content
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);

    char* content = (char*)malloc(size + 1);
    fread(content, 1, size, file);
    content[size] = '\0';
    fclose(file);

    // Parse JSON
    cJSON* json = cJSON_Parse(content);
    free(content);

    if (!json) {
        printf("Failed to parse JSON: %s\n", json_path);
        return;
    }

    // Get filename without extension for output
    char* base_name = get_filename_without_ext(strrchr(json_path, '/') ? strrchr(json_path, '/') + 1 : json_path);

    // Create output directory
    char output_dir[MAX_PATH];
    snprintf(output_dir, MAX_PATH, "%s/%s", maps_directory, base_name);
    ensure_directory_exists(output_dir);

    // Process background layer chunks
    cJSON* layers = cJSON_GetObjectItem(json, "layers");
    if (layers && cJSON_IsArray(layers)) {
        cJSON* bg_layer = cJSON_GetArrayItem(layers, 0);
        if (bg_layer) {
            cJSON* chunks = cJSON_GetObjectItem(bg_layer, "chunks");
            if (chunks && cJSON_IsArray(chunks)) {
                int chunk_count = cJSON_GetArraySize(chunks);
                for (int i = 0; i < chunk_count; i++) {
                    cJSON* chunk = cJSON_GetArrayItem(chunks, i);
                    cJSON* data = cJSON_GetObjectItem(chunk, "data");

                    if (data && cJSON_IsArray(data)) {
                        char chunk_file[MAX_PATH];
                        snprintf(chunk_file, MAX_PATH, "%s/%s_%d.2x2", output_dir, base_name, i);

                        FILE* chunk_out = fopen(chunk_file, "wb");
                        if (chunk_out) {
                            int data_size = cJSON_GetArraySize(data);
                            for (int j = 0; j < data_size; j++) {
                                unsigned char byte = ((unsigned char)cJSON_GetArrayItem(data, j)->valueint - 1) * 4;
                                fwrite(&byte, 1, 1, chunk_out);
                            }
                            fclose(chunk_out);
                        }
                    }
                }
            }
        }

        // Process object layer
        cJSON* obj_layer = cJSON_GetArrayItem(layers, 1);
        if (obj_layer) {
            cJSON* objects = cJSON_GetObjectItem(obj_layer, "objects");
            if (objects && cJSON_IsArray(objects)) {
                // First pass: collect unique types
                TypeIndex typeIndex = {0};
                int obj_count = cJSON_GetArraySize(objects);

                for (int i = 0; i < obj_count; i++) {
                    cJSON* obj = cJSON_GetArrayItem(objects, i);
                    cJSON* type = cJSON_GetObjectItem(obj, "type");
                    if (type && cJSON_IsString(type)) {
                        get_type_index(&typeIndex, type->valuestring);
                    }
                }

                // Create all object files (empty ones too)
                for (int i = 0; i < 8; i++) {
                    char obj_file[MAX_PATH];
                    snprintf(obj_file, MAX_PATH, "%s/%s_%d.obj", output_dir, base_name, i);
                    FILE* obj_out = fopen(obj_file, "wb");  // Create empty file
                    if (obj_out) {
                        fclose(obj_out);
                    }
                }

                // Second pass: write object data
                for (int i = 0; i < obj_count; i++) {
                    cJSON* obj = cJSON_GetArrayItem(objects, i);
                    unsigned char bytes[8] = {0};

                    // Object type
                    cJSON* type = cJSON_GetObjectItem(obj, "type");
                    if (type && cJSON_IsString(type)) {
                        bytes[0] = get_type_index(&typeIndex, type->valuestring);
                    }

                    // Flags (visibility)
                    cJSON* visible = cJSON_GetObjectItem(obj, "visible");
                    bytes[1] = (visible && visible->valueint) ? 0x80 : 0;

                    // Position X and Y
                    cJSON* x = cJSON_GetObjectItem(obj, "x");
                    cJSON* y = cJSON_GetObjectItem(obj, "y");
                    int index = 0;
                    if (x && y) {
                        int map_width = 256;
                        int map_height = 208;
                        int abs_pos_x = x->valueint;
                        int abs_pos_y = y->valueint;
                        int rel_pos_x = x->valueint % map_width;
                        int rel_pos_y = y->valueint % map_height;
                        int rel_nam_pos_y = y->valueint % map_height + 32;

                        bytes[2] = rel_pos_x;
                        bytes[3] = rel_nam_pos_y;

                        // Calculate index for the file
                        index = (abs_pos_x / map_width) + ((abs_pos_y / map_height) * 4);

                        // Calculate metatile index of the nametable (same as data_index calculation)
                        int metatile_index = rel_nam_pos_y + (rel_pos_x / 16);
                        bytes[4] = metatile_index;

                        // If metatile, override X/Y position with PPU_ADDR
                        cJSON* gid = cJSON_GetObjectItem(obj, "gid");
                        if (gid) {
                            int rows = floor(metatile_index / 16);
                            int columns = metatile_index - (rows * 16);
                            int metatileAddr = ((rows * 16 * 4) + (columns * 2));
                            uint16_t addr = 0x2000 + metatileAddr;
                            bytes[3] = (addr >> 8) & 0xFF;
                            bytes[2] = addr & 0xFF;
                        }
                    }

                    // Custom properties (3 bytes)
                    cJSON* properties = cJSON_GetObjectItem(obj, "properties");
                    if (properties && cJSON_IsArray(properties)) {
                        int prop_count = cJSON_GetArraySize(properties);
                        for (int j = 0; j < 3 && j < prop_count; j++) {
                            cJSON* prop = cJSON_GetArrayItem(properties, j);
                            cJSON* value = cJSON_GetObjectItem(prop, "value");
                            if (value >= 0) {
                                bytes[5 + j] = value->valueint;
                            }
                        }
                    }

                    // Save to object file
                    char obj_file[MAX_PATH];
                    snprintf(obj_file, MAX_PATH, "%s/%s_%d.obj", output_dir, base_name, index);
                    FILE* obj_out = fopen(obj_file, "ab");  // append mode to handle multiple objects in same index
                    if (obj_out) {
                        fwrite(bytes, 1, 8, obj_out);
                        fclose(obj_out);
                    }
                }

                // Third pass: handle objects with gid property (tile overrides)
                for (int i = 0; i < obj_count; i++) {
                    cJSON* obj = cJSON_GetArrayItem(objects, i);
                    cJSON* gid = cJSON_GetObjectItem(obj, "gid");
                    
                    if (gid && cJSON_IsNumber(gid)) {
                        // Get position
                        cJSON* x = cJSON_GetObjectItem(obj, "x");
                        cJSON* y = cJSON_GetObjectItem(obj, "y");
                        
                        if (x && y) {
                            int pos_x = x->valueint;
                            int pos_y = y->valueint;
                            
                            // Calculate chunk index
                            int chunk_index = (pos_x / 256) + ((pos_y / 208) * 4);
                            
                            // Calculate data index within the chunk
                            int data_index = pos_y + (pos_x / 16);
                            
                            // Find the corresponding chunk file and modify it
                            char chunk_file[MAX_PATH];
                            snprintf(chunk_file, MAX_PATH, "%s/%s_%d.2x2", output_dir, base_name, chunk_index);
                            
                            // Read existing chunk data
                            FILE* chunk_in = fopen(chunk_file, "rb");
                            if (chunk_in) {
                                // Get file size
                                fseek(chunk_in, 0, SEEK_END);
                                long file_size = ftell(chunk_in);
                                fseek(chunk_in, 0, SEEK_SET);
                                
                                // Read all data
                                unsigned char* chunk_data = malloc(file_size);
                                fread(chunk_data, 1, file_size, chunk_in);
                                fclose(chunk_in);
                                
                                // Modify the specific data index if within bounds
                                if (data_index < file_size) {
                                    chunk_data[data_index] = ((unsigned char)(gid->valueint - 1)) * 4;
                                    
                                    // Write back to file
                                    FILE* chunk_out = fopen(chunk_file, "wb");
                                    if (chunk_out) {
                                        fwrite(chunk_data, 1, file_size, chunk_out);
                                        fclose(chunk_out);
                                    }
                                }
                                
                                free(chunk_data);
                            }
                        }
                    }
                }
                
                // After writing the .obj file and before the cleanup of typeIndex...
                // After writing all object files, add this code to generate index.s
                // Generate index.s in output directory
                char index_file[MAX_PATH];
                snprintf(index_file, MAX_PATH, "%s/index.s", output_dir);
                FILE* index_out = fopen(index_file, "w");

                if (index_out) {
                    // Capitalize first letter of base_name for labels
                    char capitalized_name[MAX_PATH];
                    snprintf(capitalized_name, MAX_PATH, "%c%s", toupper(base_name[0]), base_name + 1);

                    // Map Table
                    fprintf(index_out, "; --------------------------------------\n");
                    fprintf(index_out, "; Map Table\n");
                    fprintf(index_out, "%s_MapTable:\n", capitalized_name);
                    for (int i = 0; i < 8; i++) {
                        fprintf(index_out, "  .word %s_Map%d\n", capitalized_name, i);
                    }
                    fprintf(index_out, "\n");

                    // Object Table
                    fprintf(index_out, "; --------------------------------------\n");
                    fprintf(index_out, "; Object Table\n");
                    fprintf(index_out, "%s_ObjTable:\n", capitalized_name);
                    for (int i = 0; i < 8; i++) {
                        fprintf(index_out, "  .word %s_Obj%d\n", capitalized_name, i);
                    }
                    fprintf(index_out, "\n");

                    // Calculate object amounts per nametable
                    fprintf(index_out, "; --------------------------------------\n");
                    fprintf(index_out, "; Total amount of objects per nametable\n");
                    fprintf(index_out, "%s_ObjAmountTable:\n", capitalized_name);
                    
                    // Count objects per nametable
                    unsigned char obj_amounts[8] = {0};
                    for (int i = 0; i < obj_count; i++) {
                        cJSON* obj = cJSON_GetArrayItem(objects, i);
                        cJSON* x = cJSON_GetObjectItem(obj, "x");
                        cJSON* y = cJSON_GetObjectItem(obj, "y");
                        if (x && y) {
                            int pos_x = x->valueint;
                            int pos_y = y->valueint;
                            int index = (pos_x / 256) + ((pos_y / 208) * 4);
                            if (index >= 0 && index < 8) {
                                obj_amounts[index]++;
                            }
                        }
                    }

                    // Write object amounts
                    for (int i = 0; i < 8; i++) {
                        fprintf(index_out, "  .byte %d\n", obj_amounts[i]);
                    }
                    fprintf(index_out, "\n");

                    // Objects data section
                    fprintf(index_out, "; --------------------------------------\n");
                    fprintf(index_out, "; Objects data\n");
                    for (int i = 0; i < 8; i++) {
                        fprintf(index_out, "%s_Obj%d: .incbin \"%s_%d.obj\"\n",
                                capitalized_name, i, base_name, i);
                    }
                    fprintf(index_out, "\n");

                    // Maps data section
                    fprintf(index_out, "; --------------------------------------\n");
                    fprintf(index_out, "; Maps data\n");
                    for (int i = 0; i < 8; i++) {
                        fprintf(index_out, "%s_Map%d: .incbin \"%s_%d.2x2\"\n",
                                capitalized_name, i, base_name, i);
                    }

                    fclose(index_out);
                }

                // Generate the assembly file
                char handler_index[MAX_PATH];
                snprintf(handler_index, MAX_PATH, "%s/index.s", handler_directory);
                FILE* asm_out = fopen(handler_index, "w");

                if (asm_out) {

                    // Write object includes
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type) {
                            fprintf(asm_out, ".include \"%s%s.s\"\n",
                                toupper(type[0]) == type[0] ? "" : "", type);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectMountedMap jump table
                    fprintf(asm_out, "ObjectMountedTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Mounted\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectFrameMap jump table
                    fprintf(asm_out, "ObjectFrameTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Frame\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectNMIMap jump table
                    fprintf(asm_out, "ObjectNMITable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_NMI\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectNMIOnceMap jump table
                    fprintf(asm_out, "ObjectNMIOnceTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_NMIOnce\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectInteractionMap jump table
                    fprintf(asm_out, "ObjectInteractionTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Interaction\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectPushedMap jump table
                    fprintf(asm_out, "ObjectPushedTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Pushed\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectCollisionMap jump table
                    fprintf(asm_out, "ObjectCollisionTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Collision\n", capitalizedType);
                        }
                    }
                    fprintf(asm_out, "\n");

                    // Write ObjectDetroyedMap jump table
                    fprintf(asm_out, "ObjectDestroyedTable:\n");
                    for (int i = 0; i < typeIndex.count; i++) {
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            char capitalizedType[MAX_PATH];
                            snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                            fprintf(asm_out, "  .word %sObject_Destroyed\n", capitalizedType);
                        }
                    }
                    
                    fclose(asm_out);

                    // Create output directory
                    char object_dir[MAX_PATH];
                    snprintf(object_dir, MAX_PATH, "%s", handler_directory);
                    ensure_directory_exists(object_dir);

                    // Create individual handler files if they don't exist
                    for (int i = 0; i < typeIndex.count; i++) {
                        char handler_file[MAX_PATH];
                        char* type = typeIndex.types[i];
                        if (*type != '\0') {
                            snprintf(handler_file, MAX_PATH, "%s/%s.s", object_dir, type);

                            // Check if file exists
                            if (access(handler_file, F_OK) != 0) {
                                FILE* handler_out = fopen(handler_file, "w");
                                if (handler_out) {
                                    char capitalizedType[MAX_PATH];
                                    snprintf(capitalizedType, sizeof(capitalizedType), "%c%s", toupper(type[0]), type + 1);
                                    fprintf(handler_out, "%sObject_Mounted:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_Frame:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_NMI:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_NMIOnce:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_Interaction:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_Pushed:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_Collision:\n  rts\n\n", capitalizedType);
                                    fprintf(handler_out, "%sObject_Destroyed:\n  rts\n", capitalizedType);
                                    fclose(handler_out);
                                }
                            }
                        }
                    }
                }

                // Cleanup type index
                for (int i = 0; i < typeIndex.count; i++) {
                    free(typeIndex.types[i]);
                }
            }
        }
    }

    free(base_name);
    cJSON_Delete(json);
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        printf("Usage: %s <tiled_json_directory> <maps_directory> <object_handler_directory>\n", argv[0]);
        return 1;
    }

    const char* json_pattern = argv[1];
    const char* maps_directory = argv[2];
    const char* handler_directory = argv[3];

    // Create maps directory if it doesn't exist
    ensure_directory_exists(maps_directory);

    glob_t glob_result;
    int glob_ret = glob(json_pattern, GLOB_TILDE, NULL, &glob_result);

    if (glob_ret != 0) {
        if (glob_ret == GLOB_NOMATCH) {
            printf("No files found matching pattern: %s\n", json_pattern);
        } else {
            printf("Failed to read files with pattern: %s\n", json_pattern);
        }
        return 1;
    }

    for (size_t i = 0; i < glob_result.gl_pathc; i++) {
        const char* json_path = glob_result.gl_pathv[i];
        process_json_file(json_path, maps_directory, handler_directory);
    }

    globfree(&glob_result);
    return 0;
}