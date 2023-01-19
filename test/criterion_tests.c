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
}

Test(miguno_suite, c_weirdness) {
  // Example: unintuitive effects of implicit integer casts and promotion
  //
  // NOTE: gcc catches this mistake!
  // error: comparison of integer expressions of different signedness:
  // 'int' and 'unsigned int' [-Werror=sign-compare]
  static_assert(-1 > 0U, "");
}

// NOLINTEND(readability-isolate-declaration)
