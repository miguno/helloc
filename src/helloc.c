/* helloc.c */

#include "helloc.h"

#include <limits.h>

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
