/// @file helloc.h
/// @brief Provides string-related functions plus some toy functions.

// Inclusion guard
#ifndef HELLOC_H
#define HELLOC_H

#include <assert.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>

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

/// @brief Success and error codes used throughout this library.
typedef enum {
    /// On success.
    E_SUCCESS = 0,
    /// When the caller provided invalid input argument(s).
    E_INVALID_INPUT = 1,
    /// When memory allocation failed within a function.
    E_MEMORY_ALLOCATION_FAILED = 2
} Result;

/// @brief Returns the version of the linked helloc library.
///
/// Example return value: "0.1.0-0"
///
/// @returns The library version.
const char *helloc_library_version(void);

/// @brief Create an owned copy of the string.
///
/// See also the
/// <a href="https://www.open-std.org/jtc1/sc22/wg14/www/docs/n2353.htm">C2x
/// strdup() proposal</a>.
///
/// Example:
/// ```
/// char *s = "Hello, World";
/// char *copy = strdup(s);
/// free(copy);
/// ```
///
/// @returns An owned copy of the string.  That is, the ownership (e.g., to
/// `free()`) is passed to the caller.
/// @returns NULL if memory allocation failed.
char *helloc_str_dup(const char *s);

/// @brief Split the string at the first occurrence of the delimiter.
///
/// @param[in] s The input string to be split.  Must not be NULL.
/// @param[in] delim The delimiter by which to split.
/// @param[out] lout The output buffer that stores the left part of the split
/// string.  Is a copy of the input string when the delimiter was not found.
/// The helloc_str_split_once() function allocates sufficient memory for a copy
/// of the left part of the split string, does the copy, and stores the pointer
/// in lout.  The ownership (e.g., to `free()` the buffer) is passed to the
/// caller.
/// @param[out] rout The output buffer that stores the right part of the split
/// string.  Is NULL when the delimiter was not found.
/// The helloc_str_split_once() function allocates sufficient memory for a copy
/// of the right part of the split string, does the copy, and stores the pointer
/// in rout.  The ownership (e.g., to `free()` the buffer) is passed to the
/// caller.
///
/// Example:
///
/// ```
/// char *lout = NULL;
/// char *rout = NULL;
/// Result_t res = helloc_str_split_once("foo:bar", ':', &lout, &rout);
/// free(lout);
/// free(rout);
/// ```
///
/// @returns E_SUCCESS if successful.
/// @returns E_INVALID_INPUT if s is NULL.
/// @returns E_MEMORY_ALLOCATION_FAILED
Result helloc_str_split_once(const char *s, char delim, char **lout,
                             char **rout);

/// @brief Trims leading and trailing whitespace from a string.
///
/// Stores a copy of the trimmed input string into the given output buffer,
/// which must be large enough to store the result.  If it is too small, the
/// output is truncated.
///
/// @param[in] s The input string to be trimmed.
/// @param[out] out The output buffer, provided by the caller, that stores the
/// trimmed string.
/// @param[in] out_len The length (size) of the output buffer.
///
/// Example:
///
/// ```
/// char *s = "  foo \t\n  ";
/// size_t out_len = strlen(s) + 1;
/// char *out = (char *)malloc(out_len);
/// if (out != NULL) {
///     size_t trimmed_len = helloc_str_trim(s, out, out_len);
///     // ...do something with `out`...
///     free(out);
/// }
/// ```
/// @returns The length of the trimmed string stored in the output buffer,
///          with the invariant 0 <= trimmed length <= out_len.
size_t helloc_str_trim(const char *s, char *out, size_t out_len);

/// @brief Computes the sum of two ints.
///
/// Integer overflows result in a return value of INT_MAX.
/// Integer underflows result in a return value of INT_MIN.
///
/// @param a The first int
/// @param b The second int
///
/// @returns The sum of the inputs.
int helloc_sum(int a, int b);

// Short names for the library API
#ifdef HELLOC_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum helloc_sum
#define str_dup helloc_str_dup
#define str_split_once helloc_str_split_once
#define str_trim helloc_str_trim
// NOLINTEND(readability-identifier-naming)
#endif // HELLOC_SHORT_NAMES

#endif // HELLOC_H
