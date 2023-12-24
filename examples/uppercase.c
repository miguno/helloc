#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Include ctype.h at the end so that, at least on macOS, its `size_t`
// definition does not override stddef.h's.  (If this include is added to the
// block of includes above, then your code editor might auto-sort the ctype.h
// include to the beginning of the list, which is not what we want.)
#include <ctype.h>

void nuppercase(const char *src, char *dst, size_t n) {
    for (size_t i = 0; i < n; i++) {
        if (src[i] == '\0') {
            dst[i] = '\0';
            return;
        }
        dst[i] = (char)toupper(src[i]);
    }
    dst[n] = '\0';
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <string>\n", argv[0]);
        return EXIT_FAILURE;
    }
    const char *original = argv[1];
    size_t uppercased_len = strlen(original);
    char *uppercased = (char *)malloc(uppercased_len + 1);
    if (uppercased) {
        nuppercase(original, uppercased, uppercased_len);
        printf("Original:   %s\n", original);
        printf("Uppercased: %s\n", uppercased);
        free(uppercased);
        uppercased = NULL;
        return EXIT_SUCCESS;
    }
    return EXIT_FAILURE;
}
