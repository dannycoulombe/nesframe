#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>

// Function to process a single .map file
void process_map_file(const char *map_path, const char *meta_path) {
    FILE *map_file = fopen(map_path, "rb");
    FILE *meta_file = fopen(meta_path, "rb");

    if (!map_file || !meta_file) {
        printf("Error opening files\n");
        return;
    }

    // Create output filename by replacing .map with .2x2
    char output_path[1024];
    strcpy(output_path, map_path);
    char *ext = strstr(output_path, ".map");
    if (ext) {
        strcpy(ext, ".2x2");
    }

    FILE *output_file = fopen(output_path, "wb");
    if (!output_file) {
        printf("Error creating output file: %s\n", output_path);
        fclose(map_file);
        fclose(meta_file);
        return;
    }

    // Get file sizes
    fseek(map_file, 0, SEEK_END);
    long map_size = ftell(map_file);
    fseek(map_file, 0, SEEK_SET);

    // Adjust map_size to skip last 60 bytes
    long processed_map_size = map_size - 60;
    if (processed_map_size < 0) {
        printf("Error: Map file too small\n");
        fclose(map_file);
        fclose(meta_file);
        fclose(output_file);
        return;
    }

    fseek(meta_file, 0, SEEK_END);
    long meta_size = ftell(meta_file);
    fseek(meta_file, 0, SEEK_SET);

    // Read map file
    unsigned char *map_data = malloc(map_size);
    fread(map_data, 1, map_size, map_file);

    // Read meta file
    unsigned char *meta_data = malloc(meta_size);
    fread(meta_data, 1, meta_size, meta_file);

    printf("Map bytes to process: %ld\n", processed_map_size);

    // Process map file in 4-byte groups
    for (long i = 0; i < processed_map_size; i += 2) {
        unsigned char bytes[4] = {
            map_data[i],
            map_data[i + 1],
            map_data[i + 32],
            map_data[i + 33]
        };

        // Search in metatile reference
        for (long j = 0; j < meta_size; j += 8) {
            if (memcmp(bytes, &meta_data[j], 4) == 0) {
                // Found a match, write the metatile index
                unsigned char metatile_index = j / 8;
                fwrite(&metatile_index, 1, 1, output_file);
                break;
            } else if (j == meta_size - 1) {
              printf("Missing metatile: #%ld: %02X %02X %02X %02X\n", i / 4, map_data[i], map_data[i + 1], map_data[i + 32], map_data[i + 33]);
            }
        }

        // After processing 32 bytes (8 iterations since i += 4), skip another 32 bytes
        if ((i + 2) % 32 == 0) {
            i += 32;
        }
    }

    // Cleanup
    free(map_data);
    free(meta_data);
    fclose(map_file);
    fclose(meta_file);
    fclose(output_file);

    printf("Processed: %s\n", map_path);
}

// Function to recursively process directories
void process_directory(const char *dir_path, const char *meta_path) {
    DIR *dir = opendir(dir_path);
    if (!dir) {
        printf("Error opening directory: %s\n", dir_path);
        return;
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_name[0] == '.') continue; // Skip hidden files and . ..

        char path[1024];
        snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);

        struct stat path_stat;
        stat(path, &path_stat);

        if (S_ISDIR(path_stat.st_mode)) {
            // Recursively process subdirectories
            process_directory(path, meta_path);
        } else if (S_ISREG(path_stat.st_mode)) {
            // Process .map files
            const char *ext = strrchr(entry->d_name, '.');
            if (ext && strcmp(ext, ".map") == 0) {
                process_map_file(path, meta_path);
            }
        }
    }

    closedir(dir);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <folder_path> <meta_file_path>\n", argv[0]);
        return 1;
    }

    process_directory(argv[1], argv[2]);
    return 0;
}
