/* miguno.h */

// Inclusion guard
#ifndef MIGUNO_H_
#define MIGUNO_H_

// Long, prefixed names for the library API
extern int mgn_sum(int a, int b);

// Short names for the library API
#ifdef MIGUNO_SHORT_NAMES
#define sum mgn_sum
#endif

#endif
