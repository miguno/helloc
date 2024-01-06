/*
 * Requires https://github.com/ThrowTheSwitch/Unity
 *
 * Installed in this project by manually copying a Unity release (C and header
 * files) into the top-level `external/` folder.
 */

#include <limits.h>
#include <stdlib.h>
#include <string.h>

// On Linux, we manually define `strdup()`, which is not in the C standard.
// (On macOS, the function is available simply by including `string.h`.)
//
// A second option is to declare (but not define) the function so that, given
// that we include `string.h`, the function can and will be linked then.
//
//    char *strdup(const char *s);
//
// A third option is to define `_GNU_SOURCE 1` before the #include directives.
#if defined(__linux__)
char *strdup(const char *s) {
    size_t size = strlen(s) + 1;
    char *p = malloc(size);
    if (p) {
        memcpy(p, s, size);
    }
    return p;
}
#endif

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

void verify_str_trim(void) {
    char *s = "   foo ";
    char *expected = "foo";
    char *actual = strdup(s);
    size_t actual_len = str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "    ";
    expected = "";
    actual = strdup(s);
    actual_len = str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "";
    expected = "";
    actual = strdup(s);
    actual_len = str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "    foo \t bar \n lorem ";
    expected = "foo \t bar \n lorem";
    actual = strdup(s);
    actual_len = str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "case: NULL output buffer";
    expected = NULL;
    actual = NULL;
    actual_len = str_trim(s, actual, 12345);
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);

    s = "case: zero output buffer length";
    actual = "";
    expected = actual; // actual will not be modified in this case
    actual_len = str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);

    s = "case: non-zero output buffer length, but zero out_len parameter";
    actual = "irrelevant";
    expected = actual; // actual will not be modified in this case
    actual_len = str_trim(s, actual, 0); // caller mistakenly set out_len to 0
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);
}

int main(void) {
    // NOLINTBEGIN(misc-include-cleaner)
    UNITY_BEGIN();
    RUN_TEST(string_equality);
    RUN_TEST(pointer_equality);
    RUN_TEST(verify_sum);
    RUN_TEST(verify_str_trim);
    return UNITY_END();
    // NOLINTEND(misc-include-cleaner)
}
