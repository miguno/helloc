#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"

extern "C" {
#include "miguno.h"
}

TEST_CASE("verify sum") {
  int a = 2;
  int b = 2;
  CHECK(miguno_sum(a, b) == 4);
}
