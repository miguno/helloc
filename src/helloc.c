/// @file helloc.c
/// @brief Implementation of the helloc library.

#include "helloc.h"

#include <ctype.h>
#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

const char *helloc_library_version(void) { return PROJECT_VERSION; }

char *helloc_str_dup(const char *s) {
    size_t size = strlen(s) + 1;
    char *p = malloc(size);
    if (p != NULL) {
        memcpy(p, s, size);
    }
    return p;
}

Result helloc_str_split_once(const char *s, const char delim, char **lout,
                             char **rout) {
    if (s == NULL) {
        return E_INVALID_INPUT;
    }
    const char *colon_pos = strchr(s, delim);
    if (colon_pos != NULL) {
        // Calculate the length of the left part.
        size_t lout_len = colon_pos - s;

        // Allocate memory for the left part and copy the characters.
        *lout = malloc(lout_len + 1);
        if (*lout == NULL) {
            return E_MEMORY_ALLOCATION_FAILED;
        }
        strncpy(*lout, s, lout_len);
        (*lout)[lout_len] = 0; // Null-terminate the left part.

        // Allocate memory for the right part and copy the characters.
        *rout = helloc_str_dup(colon_pos + 1);
        if (*rout == NULL) {
            return E_MEMORY_ALLOCATION_FAILED;
        }
    } else {
        // No delimiter found.
        *lout = helloc_str_dup(s);
        *rout = NULL;
    }
    return E_SUCCESS;
}

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
