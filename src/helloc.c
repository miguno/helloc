/// @file helloc.c
/// @brief Implementation of the helloc library.

#include "helloc.h"

#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

//---------------------------------------------------------------------------//
// EXPERIMENT: Playing with typedefs and macros described at
// https://nullprogram.com/blog/2023/10/08/
// https://github.com/skeeto/scratch/blob/master/misc/wordhist.c
//---------------------------------------------------------------------------//
// NOLINTBEGIN(readability-identifier-naming)
typedef uint8_t u8; // "octet", usually UTF-8 data
// typedef char16_t  c16; // 16-bit char (UTF-16), mostly for Win32 (uchar.h)
typedef int32_t b32; // 32-bit boolean
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
// Will fail at compile-time if float is not 32 bits.
//
// Alternatively, we could also use this trick:
// typedef char assert_float_size[(sizeof(float) * CHAR_BIT == 32) ? 1 : -1];
static_assert(sizeof(float) * CHAR_BIT == 32, "foo");
typedef float f32;
// Will fail at compile-time if double is not 64 bits.
//
// Alternatively, we could also use this trick:
// typedef char assert_double_size[(sizeof(double) * CHAR_BIT == 64) ? 1 : -1];
static_assert(sizeof(double) * CHAR_BIT == 64, "foo");
typedef double f64;
typedef uintptr_t uptr;
typedef char byte; // raw memory
typedef ptrdiff_t size;
typedef size_t usize;

typedef struct {
    u8 *data;
    size len;
} s8; // String literal, with "s" for string and "8" for UTF-8 (or u8).

// Wrap a C string literal as s8.
#define s8(s)                                                                  \
    (s8) { (u8 *)(s), lengthof(s) }
// NOLINTEND(readability-identifier-naming)

#define SIZEOF(x) ((size)(sizeof(x)))
#define ALIGNOF(x) ((size)(_Alignof(x)))
#define COUNTOF(...) ((size)(sizeof(__VA_ARGS__) / sizeof(*__VA_ARGS__)))
#define LENGTHOF(s) ((countof(s)) - 1)
#define NEW(a, t, n) ((t *)(alloc(a, (sizeof(t)), (alignof(t)), (n))))

// To enable assertions in release builds, put UBSan in trap mode with
// ``-fsanitize-trap` and then enable at least `-fsanitize=unreachable`.
#define ASSERT(c)                                                              \
    while (!(c))                                                               \
    __builtin_unreachable()
//---------------------------------------------------------------------------//

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
