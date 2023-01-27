/* miguno.h */

// Inclusion guard
#pragma once

// Long, prefixed names for the library API

/**
 * Compute the sum of two ints.
 *
 * @param a The first int
 * @param b The second int
 */
extern int miguno_sum(int a, int b);

// Short names for the library API
#ifdef MIGUNO_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum miguno_sum
// NOLINTEND(readability-identifier-naming)
#endif
