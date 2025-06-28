#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENGTH 2048
#define MAX_DECODED_SIZE 65536

typedef struct {
    unsigned char* data;
    size_t size;
} DecodedData;

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
                char repeat_hex[9] = {0};
                int hex_pos = 0;

                while (isxdigit(encoded[i]) && hex_pos < 8) {
                    repeat_hex[hex_pos++] = encoded[i++];
                }
                sscanf(repeat_hex, "%x", &count);
                i++;
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

int process_file(const char* input_path, const char* bin_output_path, const char* props_output_path) {
    FILE* infile = fopen(input_path, "r");
    if (!infile) {
        printf("Failed to open input file: %s\n", input_path);
        return 0;
    }

    FILE* tiles_outfile = fopen(bin_output_path, "wb");
    if (!tiles_outfile) {
        printf("Failed to create tiles output file: %s\n", bin_output_path);
        fclose(infile);
        return 0;
    }

    FILE* props_outfile = fopen(props_output_path, "wb");
    if (!props_outfile) {
        printf("Failed to create props output file: %s\n", props_output_path);
        fclose(infile);
        fclose(tiles_outfile);
        return 0;
    }

    char line[MAX_LINE_LENGTH];
    DecodedData id_data = {NULL, 0};
    DecodedData props_data = {NULL, 0};
    DecodedData pal_data = {NULL, 0};

    while (fgets(line, sizeof(line), infile)) {
        line[strcspn(line, "\n")] = 0;

        if (strncmp(line, "MetatileSet_2x2_id=", strlen("MetatileSet_2x2_id=")) == 0) {
            id_data = process_encoded_string(line + strlen("MetatileSet_2x2_id="));
        }
        else if (strncmp(line, "MetatileSet_2x2_props=", strlen("MetatileSet_2x2_props=")) == 0) {
            props_data = process_encoded_string(line + strlen("MetatileSet_2x2_props="));
        }
        else if (strncmp(line, "MetatileSet_2x2_pal=", strlen("MetatileSet_2x2_pal=")) == 0) {
            pal_data = process_encoded_string(line + strlen("MetatileSet_2x2_pal="));
        }
    }

    if (id_data.data && props_data.data && pal_data.data) {
        size_t props_index = 2;
        size_t pal_index = 0;

        for (size_t i = 0; i < id_data.size; i += 4) {
            // Write 4 bytes of tile data
            for (size_t j = 0; j < 4 && (i + j) < id_data.size; j++) {
                fwrite(&id_data.data[i + j], 1, 1, tiles_outfile);
            }

            // Write props and palette data (4 bytes)
            if (props_index < props_data.size && pal_index < pal_data.size) {
                // Write the props byte (first byte)
                fwrite(&props_data.data[props_index], 1, 1, props_outfile);

                // Write the palette byte (second byte)
                fwrite(&pal_data.data[pal_index], 1, 1, props_outfile);

                // Write 2 zeros to fill the remaining bytes
                unsigned char zeros[2] = {0};
                fwrite(zeros, 1, 2, props_outfile);

                props_index += 4; // Move to next props entry
                pal_index += 4;   // Move to next palette entry
            } else {
                // Write 4 zeros if no more props/palette data available
                unsigned char zeros[4] = {0};
                fwrite(zeros, 1, 4, props_outfile);
            }
        }
    } else {
        printf("Failed to find all required data lines\n");
        remove(bin_output_path);
        remove(props_output_path);
        fclose(infile);
        fclose(tiles_outfile);
        fclose(props_outfile);
        return 0;
    }

    free(id_data.data);
    free(props_data.data);
    free(pal_data.data);
    fclose(infile);
    fclose(tiles_outfile);
    fclose(props_outfile);

    return 1;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf("Usage: %s <input_mtt2_file> <output_bin_file> <output_props_file>\n", argv[0]);
        printf("Example: %s tiles.mtt2 tiles.bin tiles.props\n", argv[0]);
        return 1;
    }

    if (process_file(argv[1], argv[2], argv[3])) {
        printf("Successfully processed %s and saved to %s and %s\n", argv[1], argv[2], argv[3]);
        return 0;
    } else {
        return 1;
    }
}
