/// @file unity_tests.c
/// @brief Unit tests for the helloc library.
///
/// Requires https://github.com/ThrowTheSwitch/Unity,
/// which is installed in this project by manually copying a Unity release (C
/// and header files) into the top-level `external/` folder.

#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

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

void verify_helloc_str_dup(void) {
    char *s = "foo";
    char *actual = helloc_str_dup(s);
    TEST_ASSERT_EQUAL_STRING(s, actual);
    free(actual);

    s = "";
    actual = helloc_str_dup(s);
    TEST_ASSERT_EQUAL_STRING(s, actual);
    free(actual);
}

void verify_helloc_str_split_once(void) {
    char *s = "foo:bar";
    char *expected_left = "foo";
    char *expected_right = "bar";
    char *actual_left = nullptr;
    char *actual_right = nullptr;
    Result res = helloc_str_split_once(s, ':', &actual_left, &actual_right);
    TEST_ASSERT_EQUAL_STRING(expected_left, actual_left);
    TEST_ASSERT_EQUAL_STRING(expected_right, actual_right);
    TEST_ASSERT_EQUAL_INT(E_SUCCESS, res);
    free(actual_left);
    free(actual_right);

    s = ":";
    expected_left = "";
    expected_right = "";
    actual_left = nullptr;
    actual_right = nullptr;
    res = helloc_str_split_once(s, ':', &actual_left, &actual_right);
    TEST_ASSERT_EQUAL_STRING(expected_left, actual_left);
    TEST_ASSERT_EQUAL_STRING(expected_right, actual_right);
    TEST_ASSERT_EQUAL_INT(E_SUCCESS, res);
    free(actual_left);
    free(actual_right);

    s = "::";
    expected_left = "";
    expected_right = ":";
    actual_left = nullptr;
    actual_right = nullptr;
    res = helloc_str_split_once(s, ':', &actual_left, &actual_right);
    TEST_ASSERT_EQUAL_STRING(expected_left, actual_left);
    TEST_ASSERT_EQUAL_STRING(expected_right, actual_right);
    TEST_ASSERT_EQUAL_INT(E_SUCCESS, res);
    free(actual_left);
    free(actual_right);

    s = "";
    expected_left = "";
    expected_right = nullptr;
    actual_left = nullptr;
    actual_right = nullptr;
    res = helloc_str_split_once(s, ':', &actual_left, &actual_right);
    TEST_ASSERT_EQUAL_STRING(expected_left, actual_left);
    TEST_ASSERT_EQUAL_STRING(expected_right, actual_right);
    TEST_ASSERT_EQUAL_INT(E_SUCCESS, res);
    free(actual_left);
    free(actual_right);

    s = nullptr;
    expected_left = nullptr;
    expected_right = nullptr;
    actual_left = nullptr;
    actual_right = nullptr;
    res = helloc_str_split_once(s, ':', &actual_left, &actual_right);
    TEST_ASSERT_EQUAL_STRING(expected_left, actual_left);
    TEST_ASSERT_EQUAL_STRING(expected_right, actual_right);
    TEST_ASSERT_EQUAL_INT(E_INVALID_INPUT, res);
}

void verify_helloc_str_trim(void) {
    char *s = "   foo ";
    char *expected = "foo";
    char *actual = helloc_str_dup(s);
    size_t actual_len = helloc_str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "    ";
    expected = "";
    actual = helloc_str_dup(s);
    actual_len = helloc_str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "";
    expected = "";
    actual = helloc_str_dup(s);
    actual_len = helloc_str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "    foo \t bar \n lorem ";
    expected = "foo \t bar \n lorem";
    actual = helloc_str_dup(s);
    actual_len = helloc_str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(strlen(expected), actual_len);
    free(actual);

    s = "case: null output buffer";
    expected = nullptr;
    actual = nullptr;
    actual_len = helloc_str_trim(s, actual, 12345);
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);

    s = "case: zero output buffer length";
    actual = "";
    expected = actual; // actual will not be modified in this case
    actual_len = helloc_str_trim(s, actual, strlen(actual));
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);

    s = "case: non-zero output buffer length, but zero out_len parameter";
    actual = "irrelevant";
    expected = actual; // actual will not be modified in this case
    actual_len =
        helloc_str_trim(s, actual, 0); // caller mistakenly set out_len to 0
    TEST_ASSERT_EQUAL_STRING(expected, actual);
    TEST_ASSERT_EQUAL_size_t(0, actual_len);
}

int main(void) {
    // NOLINTBEGIN(misc-include-cleaner)
    UNITY_BEGIN();
    RUN_TEST(string_equality);
    RUN_TEST(pointer_equality);
    RUN_TEST(verify_sum);
    RUN_TEST(verify_helloc_str_dup);
    RUN_TEST(verify_helloc_str_split_once);
    RUN_TEST(verify_helloc_str_trim);
    return UNITY_END();
    // NOLINTEND(misc-include-cleaner)
}
