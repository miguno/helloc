/*
 * Requires https://github.com/Snaipe/Criterion
 *
 * Installation examples:
 * * macOS: `brew install criterion`
 * * Debian/Ubunto: `sudo apt-get install libcriterion-dev`
 *
 */
#include <assert.h>
#include <criterion/criterion.h>
#include <criterion/new/assert.h>
#include <limits.h>

#include "miguno.h"

// NOLINTBEGIN(readability-isolate-declaration)
// The previous line prevents clang-tidy from tiggering on `cr_assert(eq(...))`.
// Details about NOLINT at https://clang.llvm.org/extra/clang-tidy/

Test(miguno_suite, string_equality) {
  char *actual = "Hello";
  cr_assert(eq(str, actual, "Hello"));
}

Test(miguno_suite, pointer_equality) {
  int x = 1;
  int *expected = &x;
  int *actual = &x;
  cr_assert(eq(ptr, expected, actual));
}

Test(miguno_suite, verify_sum) {
  int a = 2;
  int b = 2;
  cr_assert(eq(i32, miguno_sum(a, b), 4), "2 + 2 should equal 4");

  // Verify overflow scenarios
  cr_assert(eq(i32, miguno_sum(INT_MAX, 1), INT_MAX),
            "INT_MAX + 1 should equal INT_MAX");
  cr_assert(eq(i32, miguno_sum(INT_MAX, INT_MAX), INT_MAX),
            "INT_MAX + INT_MAX should equal INT_MAX");

  // Verify underflow scenarios
  cr_assert(eq(i32, miguno_sum(INT_MIN, -1), INT_MIN),
            "INT_MIN + (-1) should equal INT_MIN");
  cr_assert(eq(i32, miguno_sum(INT_MIN, INT_MIN), INT_MIN),
            "INT_MIN + INT_MIN should equal INT_MIN");
}

// NOLINTEND(readability-isolate-declaration)
