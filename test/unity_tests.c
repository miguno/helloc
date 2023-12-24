/*
 * Requires https://github.com/ThrowTheSwitch/Unity
 *
 * Installed in this project by manually copying a Unity release (C and header
 * files) into the top-level `external/` folder.
 */

#include <limits.h>

// Allows us to use shortened names of functions in helloc.h in addition to
// their long, prefixed names.
#define HELLOC_SHORT_NAMES

#include "helloc.h"
#include "unity.h"

void setUp(void) {
    // set stuff up here
}

void tearDown(void) {
    // clean stuff up here
}

void string_equality(void) {
    char *actual = "Hello";
    TEST_ASSERT_EQUAL_STRING("Hello", actual);
}

void pointer_equality(void) {
    int x = 1;
    int *expected = &x;
    int *actual = &x;
    TEST_ASSERT_EQUAL_PTR(expected, actual);
}

void verify_sum(void) {
    // Because we defined the macro HELLOC_SHORT_NAMES before including
    // helloc.h, we can now use the shortened name of `sum()`.
    TEST_ASSERT_EQUAL(4, sum(2, 2));
    TEST_ASSERT_EQUAL(0, sum(-2, 2));

    // Verify overflow scenarios
    TEST_ASSERT_EQUAL(INT_MAX, sum(INT_MAX, 1));
    TEST_ASSERT_EQUAL(INT_MAX, sum(INT_MAX, INT_MAX));

    // Verify underflow scenarios
    TEST_ASSERT_EQUAL(INT_MIN, sum(INT_MIN, -1));
    TEST_ASSERT_EQUAL(INT_MIN, sum(INT_MIN, INT_MIN));
}

int main(void) {
    // NOLINTBEGIN(misc-include-cleaner)
    UNITY_BEGIN();
    RUN_TEST(string_equality);
    RUN_TEST(pointer_equality);
    RUN_TEST(verify_sum);
    return UNITY_END();
    // NOLINTEND(misc-include-cleaner)
}
