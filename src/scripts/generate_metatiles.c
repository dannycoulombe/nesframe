#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 2048
#define MAX_DECODED_SIZE 65536  // Adjust size as needed

typedef struct {
    unsigned char* data;
    size_t size;
} DecodedData;

unsigned char hex_to_byte(const char *hex);

unsigned char hex_to_byte(const char *hex) {
    int value = 0;
    sscanf(hex, "%2x", &value);
    return (unsigned char)value;
}

DecodedData process_encoded_string(const char* encoded) {
    DecodedData result = {malloc(MAX_DECODED_SIZE), 0};

    int i = 0;
    while (encoded[i]) {
        char hex[3] = {0};
        int count = 1;

        if (isxdigit(encoded[i]) && isxdigit(encoded[i + 1])) {
            hex[0] = encoded[i];
            hex[1] = encoded[i + 1];
            i += 2;

            if (encoded[i] == '[') {
                i++;
                count = 0;
                char repeat_hex[9] = {0}; // Buffer for up to 8 hex digits
                int hex_pos = 0;

                while (isxdigit(encoded[i]) && hex_pos < 8) {
                    repeat_hex[hex_pos++] = encoded[i++];
                }
                sscanf(repeat_hex, "%x", &count);
                i++; // Skip closing bracket
            }

            unsigned char byte = hex_to_byte(hex);
            for (int j = 0; j < count; j++) {
                result.data[result.size++] = byte;
            }
        } else {
            i++;
        }
    }

    return result;
}


int process_file(const char* input_path, const char* output_path) {
    FILE* infile = fopen(input_path, "r");
    if (!infile) {
        printf("Failed to open input file: %s\n", input_path);
        return 0;
    }

    FILE* outfile = fopen(output_path, "wb");
    if (!outfile) {
        printf("Failed to create output file: %s\n", output_path);
        fclose(infile);
        return 0;
    }

    char line[MAX_LINE_LENGTH];
    DecodedData id_data = {NULL, 0};
    DecodedData props_data = {NULL, 0};

    // Read and decode lines
    while (fgets(line, sizeof(line), infile)) {
        line[strcspn(line, "\n")] = 0;

        if (strncmp(line, "MetatileSet_2x2_id=", strlen("MetatileSet_2x2_id=")) == 0) {
            id_data = process_encoded_string(line + strlen("MetatileSet_2x2_id="));
        }
        else if (strncmp(line, "MetatileSet_2x2_props=", strlen("MetatileSet_2x2_props=")) == 0) {
            props_data = process_encoded_string(line + strlen("MetatileSet_2x2_props="));
        }
    }

    // Write combined data to output file
    if (id_data.data && props_data.data) {
        size_t props_index = 2;

        for (size_t i = 0; i < id_data.size; i += 4) {
            // Write 4 bytes from id_data
            for (size_t j = 0; j < 4 && (i + j) < id_data.size; j++) {
                fwrite(&id_data.data[i + j], 1, 1, outfile);
            }

            // Write 1 byte from props_data if available
            if (props_index < props_data.size) {
                fwrite(&props_data.data[props_index], 1, 1, outfile);
                props_index += 4; // Move 4 bytes forward (1 used + 3 skipped)
            }

            fwrite("\0\0\0", 1, 3, outfile);
        }
    } else {
        printf("Failed to find all required data lines\n");
        remove(output_path);
        fclose(infile);
        fclose(outfile);
        return 0;
    }

    // Clean up
    free(id_data.data);
    free(props_data.data);
    fclose(infile);
    fclose(outfile);

    return 1;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input_mtt2_file> <output_meta_file>\n", argv[0]);
        printf("Example: %s tiles.mtt2 tiles.meta\n", argv[0]);
        return 1;
    }

    if (process_file(argv[1], argv[2])) {
        printf("Successfully processed %s and saved to %s\n", argv[1], argv[2]);
        return 0;
    } else {
        return 1;
    }
}
