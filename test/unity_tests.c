/*
 * Requires https://github.com/ThrowTheSwitch/Unity
 *
 * Installed in this project by manually copying a Unity release (C and header
 * files) to the top-level `external/` folder.
 */
#include "miguno.h"
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
  int a = 2;
  int b = 2;
  TEST_ASSERT_EQUAL(4, mgn_sum(a, b));
}

// not needed when using generate_test_runner.rb
int main(void) {
  UNITY_BEGIN();
  RUN_TEST(string_equality);
  RUN_TEST(pointer_equality);
  RUN_TEST(verify_sum);
  return UNITY_END();
}
