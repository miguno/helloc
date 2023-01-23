#include <stdio.h>

#include "miguno.h"
#include "utf8h/utf8.h"

int main(void) {
  printf("Zwei plus zwei ist %d. Immer und überall!\n", miguno_sum(2, 2));

  // Test-drive utf8.h to show that its import was successful.
  // https://github.com/sheredom/utf8.h
  char* s = "ÄÖÜäöüßèéêëô";
  size_t l = utf8len(s);
  printf("len('%s') = %zu\n", s, l);

  return 0;
}
