#include <dirent.h>
#include <stdio.h>
#include <string.h>

/*
 * Find all files ending with .;pal and generate a dimmed
 * version of all its color bytes.
 */
int process_files(const char* dir_path) {

    // Check if folder available for writing
    DIR *folder = opendir(dir_path);
    if (!folder) {
        printf("Failed to open folder: %s\n", dir_path);
        return 1;
    }

    // Iterate over files in folder
    struct dirent *entry;
    while ((entry = readdir(folder))) {
        const int is_pal = strstr(entry->d_name, ".pal") && entry->d_type == DT_REG;
        const int is_dim_pal = strstr(entry->d_name, "-dim") && entry->d_type == DT_REG;
        if (is_pal && !is_dim_pal) {

            // Generate 3 dimed versions
            for (int i = 1; i <= 3; i++) {

                // Prepare input/output filenames
                char si[1];
                char output_path[1024];
                char input_path[1024];
                char new_ext[9] = "-dim";
                strcpy(input_path, dir_path);
                strcat(input_path, "/");
                strcat(input_path, entry->d_name);
                strcpy(output_path, input_path);
                sprintf(si, "%d", i);
                strcat(new_ext, si);
                strcat(new_ext, ".pal");
                char *ext = strstr(output_path, ".pal");
                if (ext) strcpy(ext, new_ext);

                // Allocate file streams
                FILE *in = fopen(input_path, "rb"),
                     *out = fopen(output_path, "wb");

                // Dim all color bytes to output file
                int b;
                while ((b = fgetc(in)) != EOF) {
                    b = b <= (0x0F * i) ? 0x0F : b - (0x10 * i);
                    fputc(b, out);
                }

                fclose(in);
                fclose(out);
            }
        }
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <palette_folder>\n", argv[0]);
        return 1;
    }
    return process_files(argv[1]);
}