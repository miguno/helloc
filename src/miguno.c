/* miguno.c */

#include "miguno.h"

#include <limits.h>

int miguno_sum(const int a, const int b) {
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
