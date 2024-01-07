/* helloc.h */

// Inclusion guard
#ifndef HELLOC_H
#define HELLOC_H

#include <stddef.h>

// Long, prefixed names for the library API

typedef enum {
    E_SUCCESS = 0,
    E_INVALID_INPUT = 1,
    E_MEMORY_ALLOCATION_FAILED = 2
} Result_t;

/**
 * Returns the version of the linked helloc library.
 *
 * Example return value: "0.1.0-0"
 *
 * @return The library version.
 */
const char *helloc_library_version(void);

/**
 * Computes the sum of two ints.
 *
 * Integer overflows result in a return value of INT_MAX.
 * Integer underflows result in a return value of INT_MIN.
 *
 * @param a The first int
 * @param b The second int
 *
 * @return The sum of the inputs.
 */
int helloc_sum(int a, int b);

/**
 * Trims leading and trailing whitespace from a string.
 *
 * Stores a copy of the trimmed input string into the given output buffer,
 * which must be large enough to store the result.  If it is too small, the
 * output is truncated.
 *
 * @param[in] s The input string to be trimmed.
 * @param[out] out The output buffer, provided by the caller, that stores the
 * trimmed string.
 * @param[in] out_len The length (size) of the output buffer.
 *
 * @return The length of the trimmed string stored in the output buffer.
 */
size_t helloc_str_trim(const char *s, char *out, size_t out_len);

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
/// @code{c}
/// char *lout = NULL;
/// char *rout = NULL;
/// Result_t res = helloc_str_split_once("foo:bar", ':', &lout, &rout);
/// free(lout);
/// free(rout);
/// @endcode
///
/// @return E_SUCCESS if successful.
/// @return E_INVALID_INPUT if s is NULL.
/// @return E_MEMORY_ALLOCATION_FAILED
Result_t helloc_str_split_once(const char *s, char delim, char **lout,
                               char **rout);

// Short names for the library API
#ifdef HELLOC_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum helloc_sum
#define str_trim helloc_str_trim
#define str_split_once helloc_str_split_once
// NOLINTEND(readability-identifier-naming)
#endif

#endif // HELLOC_H
