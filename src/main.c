#include <stdio.h>

#include "miguno.h"

// stb_ds: to import, only add the next two lines to *one* C or C++ file
#define STB_DS_IMPLEMENTATION
#include "stb_ds.h"

int main(void) {
  printf("Zwei plus zwei ist %d. Immer und überall!\n", miguno_sum(2, 2));

  // Play around with stb_ds to showcase that its import worked
  struct {
    int key;
    char value;
  } *hash = NULL;
  hmput(hash, 3, 'h');
  hmput(hash, 20, 'e');
  hmput(hash, 500, 'l');

  printf("========== Iterate through hash table\n");
  for (int i = 0; i < hmlen(hash); ++i) {
    printf("%3d => %c\n", hash[i].key, hash[i].value);
  }
  printf("========== Get a single key\n");
  int key = 20;
  printf("%3d => %c\n", key, hmget(hash, key));

  hmfree(hash);

  return 0;
}
