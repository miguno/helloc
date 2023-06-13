#include <stdio.h>

#include "helloc.h"

/**
 * The main function of the application.
 *
 * This comment demonstrates the use of doxygen for documenting your code.
 */
int main(void) {
    printf("Project version via preprocessor definition: %s\n", HELLOC_VERSION);
    printf("Project version via function call: %s\n", helloc_library_version());
    printf("Two plus two is %d. Always and everywhere!\n", helloc_sum(2, 2));
    return 0;
}
