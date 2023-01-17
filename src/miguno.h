/* miguno.h */

// Inclusion guard
#ifndef MIGUNO_H_UUID48A2FAFB_0125_4503_9F32_2956F0350946
#define MIGUNO_H_UUID48A2FAFB_0125_4503_9F32_2956F0350946

// Long, prefixed names for the library API
extern int miguno_sum(int a, int b);

// Short names for the library API
#ifdef MIGUNO_SHORT_NAMES
// NOLINTBEGIN(readability-identifier-naming)
#define sum miguno_sum
// NOLINTEND(readability-identifier-naming)
#endif

#endif  // MIGUNO_H_UUID48A2FAFB_0125_4503_9F32_2956F0350946
