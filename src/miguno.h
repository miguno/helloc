/* miguno.h */

// Inclusion guard
#ifndef MIGUNO_H
#define MIGUNO_H

// Long, prefixed names for the library API
extern int miguno_sum(int a, int b);

// Short names for the library API
#ifdef MIGUNO_SHORT_NAMES
#define sum miguno_sum
#endif

#endif
