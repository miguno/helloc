/* helloc.c */

#include "helloc.h"

#include <ctype.h>
#include <limits.h>
#include <stddef.h>
#include <string.h>

int helloc_sum(int a, int b) {
    if (a >= 0) {
        if (b > INT_MAX - a) {
            // Integer overflow
            return INT_MAX;
        }
        return a + b;
    }
    if (b < INT_MIN - a) {
        // Integer underflow
        return INT_MIN;
    }
    return a + b;
}

const char *helloc_library_version(void) { return PROJECT_VERSION; }

size_t helloc_str_trim(const char *s, char *out, size_t out_len) {
    if (out == NULL || out_len == 0) {
        return 0;
    }

    // Trim leading space
    while (isspace((unsigned char)*s)) {
        s++;
    }

    // All spaces?
    if (s == 0) {
        out = NULL;
        return 0;
    }

    // Trim trailing space
    const char *end = s + strlen(s) - 1;
    while (end > s && isspace((unsigned char)*end)) {
        end--;
    }
    end++;

    size_t trimmed_size = (end - s) < out_len - 1 ? (end - s) : out_len - 1;
    memcpy(out, s, trimmed_size);
    out[trimmed_size] = 0;
    return trimmed_size;
}
