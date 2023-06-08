/* helloc.h */

// Inclusion guard
#ifndef HELLOC_H
#define HELLOC_H

// Long, prefixed names for the library API

/**
 * Compute the sum of two ints.
 *
 * Integer overflows result in a return value of INT_MAX.
 * Integer underflows result in a return value of INT_MIN.
 *
 * @param a The first int
 * @param b The second int
 */
int helloc_sum(int a, int b);

/**
 * Returns the version of the linked helloc library, with a version postfix
 * for dev versions.
 *
 * Example return value: "0.1.0-0"
 */
const char *helloc_library_version(void);

// Short names for the library API
#ifdef HELLOC_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum helloc_sum
// NOLINTEND(readability-identifier-naming)
#endif

#endif // HELLOC_H
