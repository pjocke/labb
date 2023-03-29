#include <stdio.h>
#include <sys/stat.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    struct stat sb;
    if (stat(argv[1], &sb) == -1) {
        printf("%s: %s.\n", argv[1], strerror(errno));
        exit(EXIT_FAILURE);
    }

    if (S_ISREG(sb.st_mode)) {
        printf("Found regular file with permissions %o.\n", sb.st_mode & 00777);
        if ((sb.st_mode & S_IROTH) == S_IROTH) {
            printf("File is world readable.\n");
        } else {
            printf("File is NOT world readable.\n");
        }
        if ((sb.st_mode & S_IXOTH) == S_IXOTH) {
            printf("File is world executable.\n");
        } else {
            printf("File is NOT world executable.\n");
        }
    }

    exit(EXIT_SUCCESS);
}