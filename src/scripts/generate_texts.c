#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h> // For strtol function

// Convert a string to SnakeCase with Txt suffix, keeping only alphanumeric chars
void toSnakeCase(char *dest, const char *src) {
    int i = 0;

    // Process the entire string
    for (int j = 0; src[j]; j++) {
        if (src[j] == ' ') {
            // If space, capitalize next character if it's alphanumeric
            if (src[j+1] && isalnum(src[j+1])) {
                dest[i++] = toupper(src[j+1]);
                j++; // Skip the next character as we've already processed it
            }
        } else if (isalnum(src[j])) {
            // Only include alphanumeric characters
            dest[i++] = (j == 0 || src[j-1] == ' ') ? toupper(src[j]) : src[j];
        }
    }

    // Add "Txt" suffix
    strcpy(dest + i, "Txt");
}

// Convert a character to its digit value according to the rules
unsigned char charToDigitValue(char c) {
    c = toupper(c);

    if (c == ' ') {
        // Space character
        return 63;
    }
    else if (isdigit(c)) {
        // Numbers stay the same
        return c - '0';
    } else if (isalpha(c)) {
        // Letters start at 10: A = 10, B = 11, etc.
        return c - 'A' + 10;
    } else if (c == '.') {
        return 37;
    } else if (c == ',') {
        return 38;
    } else if (c == '?') {
        return 39;
    } else if (c == '!') {
        return 40;
    }

    // Default for unknown characters
    return 0;
}

/*
 * Find all files ending with .txt and generate an assembly file
 * with converted text in SnakeCase format.
 */
int process_files(const char* dir_path, unsigned char hex_offset) {
    // Check if folder available for reading
    DIR *folder = opendir(dir_path);
    if (!folder) {
        printf("Failed to open folder: %s\n", dir_path);
        return 1;
    }

    // Create an index file to include all generated files
    char index_path[1024];
    strcpy(index_path, dir_path);
    strcat(index_path, "/index.s");
    FILE *index_file = fopen(index_path, "w");

    if (!index_file) {
        printf("Failed to create index file: %s\n", index_path);
        closedir(folder);
        return 1;
    }

    fprintf(index_file, "; Index of all generated text files\n");
    fprintf(index_file, "; DO NOT EDIT MANUALLY\n\n");

    // Iterate over files in folder
    struct dirent *entry;
    while ((entry = readdir(folder))) {
        const int is_txt = strstr(entry->d_name, ".txt") && entry->d_type == DT_REG;
        if (is_txt) {
            // Prepare input/output filenames
            char input_path[1024];
            char output_path[1024];
            char basename[256] = {0};

            // Get base name without extension
            strncpy(basename, entry->d_name, strlen(entry->d_name) - 4);

            strcpy(input_path, dir_path);
            strcat(input_path, "/");
            strcat(input_path, entry->d_name);

            strcpy(output_path, dir_path);
            strcat(output_path, "/");
            strcat(output_path, basename);
            strcat(output_path, ".s");

            // Open files
            FILE *in = fopen(input_path, "r");
            FILE *out = fopen(output_path, "w");

            if (!in || !out) {
                printf("Failed to open files for %s\n", entry->d_name);
                if (in) fclose(in);
                if (out) fclose(out);
                continue;
            }

            printf("Processing %s -> %s\n", input_path, output_path);

            // Add this file to the index
            fprintf(index_file, ".include \"%s.s\"\n", basename);

            // Write header comment
            fprintf(out, "; Generated from %s\n", entry->d_name);
            fprintf(out, "; DO NOT EDIT MANUALLY\n\n");

            // Process each line
            char line[1024];
            while (fgets(line, sizeof(line), in)) {
                // Trim the line
                char *start = line;
                char *end = line + strlen(line) - 1;

                // Trim leading whitespace
                while (*start && isspace(*start)) start++;

                // Trim trailing whitespace
                while (end > start && isspace(*end)) *end-- = '\0';

                // Skip empty lines
                if (strlen(start) == 0) continue;

                // Convert to SnakeCase with Txt suffix
                char snake_case[1024] = {0};
                toSnakeCase(snake_case, start);

                // Prefix with underscore if starts with a number
                if (isdigit(snake_case[0])) {
                    memmove(snake_case + 1, snake_case, strlen(snake_case) + 1);
                    snake_case[0] = '_';
                }

                // Start the assembly line
                fprintf(out, "%s: .byte ", snake_case);

                // Convert each character and write to output
                for (char *c = start; *c; c++) {
                    unsigned char value = charToDigitValue(*c);

                    // Apply hex offset to character value
                    value = (value + hex_offset) & 0xFF; // Apply offset with wraparound

                    // Write the value in hex format
                    fprintf(out, "$%02X", value);

                    // Add comma if not the last character
                    if (*(c+1)) {
                        fprintf(out, ", ");
                    }
                }

                // Add null terminator
                fprintf(out, ", 0\n");
            }

            fclose(in);
            fclose(out);
        }
    }

    fclose(index_file);
    closedir(folder);
    return 0;
}

int main(int argc, char *argv[]) {
    unsigned char hex_offset = 0;

    if (argc < 2 || argc > 3) {
        printf("Usage: %s <texts_folder> [hex_offset]\n", argv[0]);
        return 1;
    }

    if (argc == 3) {
        // Parse hexadecimal offset from command line
        char *endptr;
        long offset = strtol(argv[2], &endptr, 16); // Parse as hex

        if (*endptr != '\0' || offset < 0 || offset > 0xFF) {
            printf("Error: Invalid hexadecimal offset (must be 0-FF)\n");
            return 1;
        }

        hex_offset = (unsigned char)offset;
    }

    return process_files(argv[1], hex_offset);
}