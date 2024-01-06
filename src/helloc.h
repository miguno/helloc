/* helloc.h */

// Inclusion guard
#ifndef HELLOC_H
#define HELLOC_H

#include <stddef.h>

// Long, prefixed names for the library API

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

// Short names for the library API
#ifdef HELLOC_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum helloc_sum
#define str_trim helloc_str_trim
// NOLINTEND(readability-identifier-naming)
#endif

#endif // HELLOC_H
