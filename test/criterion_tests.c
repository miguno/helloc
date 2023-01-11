/*
 * Requires https://github.com/Snaipe/Criterion
 *
 * Installation examples:
 * * macOS: `brew install criterion`
 * * Debian/Ubunto: `sudo apt-get install libcriterion-dev`
 *
 */
#include <criterion/criterion.h>
#include <criterion/new/assert.h>

#include "miguno.h"

// NOLINTBEGIN(readability-isolate-declaration)
// Prevent clang-tidy from tiggering on `cr_assert(eq(...))`.
// Details about NOLINT at https://clang.llvm.org/extra/clang-tidy/
Test(miguno_suite, sum) {
  int a = 2;
  int b = 2;
  cr_assert(eq(i32, miguno_sum(a, b), 4), "2 + 2 should equal 4");
}

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
// NOLINTEND(readability-isolate-declaration)
