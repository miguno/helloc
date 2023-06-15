#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

/**
 * @file malloc-tutorial.c
 *
 * @brief DIY-implementation of malloc() and free() for educational purposes.
 * Heavily inspired by https://danluu.com/malloc-tutorial/
 *
 * WARNING:
 * This code is for educational purposes only.  DO NOT use it in production!
 *
 * ## Requirements
 *
 * * `-Wno-deprecated-declarations` compiler option to allow the use of
 *   sbrk, which is deprecated (on macOS at least).
 *
 * ## Notes
 *
 * You can display your system's page size (in bytes) with:
 *
 * ```
 * $ getconf PAGE_SIZE
 * 16384
 * ```
 *
 * Common values are 4096 on x86_64 and 16,384 on arm64, such as macOS.
 */

/**
 * @brief Metadata for a block of allocated memory.
 */
struct block_meta {          // 24 bytes total
    size_t size;             // 8 bytes
    struct block_meta *next; // 8 bytes (pointer)
    int free;                // 4 bytes
    int magic;               // For debugging only. TODO: remove this in non-debug mode.
};
#define META_BLOCK_SIZE sizeof(struct block_meta)

// NOLINTBEGIN(cppcoreguidelines-avoid-non-const-global-variables,cppcoreguidelines-avoid-non-const-global-variables)
void *global_base = NULL;
// NOLINTEND(cppcoreguidelines-avoid-non-const-global-variables,cppcoreguidelines-avoid-non-const-global-variables)

void block_to_string(struct block_meta *block, char **s) {
    int result = asprintf(s, "address=%p { size=%zu, free=%d, magic=%d, next=%p }", (void *)block, block->size,
                          block->free, block->magic, (void *)(block->next));
    if (result == -1) {
        errno = ENOMEM;
    }
}

struct block_meta *find_free_block(struct block_meta **last, size_t size) {
    struct block_meta *current = global_base;
    while (current && !(current->free && current->size >= size)) {
        *last = current;
        current = current->next;
    }
    return current;
}

enum { kMagicBlockCreated = 0x12345678, kMagicBlockReused = 0x7777777, kMagicBlockFreed = 0x55555555 };

struct block_meta *request_space(struct block_meta *last, size_t size) {
    struct block_meta *block = sbrk(0);
    void *request = sbrk((int)(size + META_BLOCK_SIZE));
    assert((void *)block == request); // not thread-safe
    if (request == (void *)-1) {      // NOLINT(performance-no-int-to-ptr)
        return NULL;                  // sbrk failed
    }

    if (last) { // NULL on first request
        last->next = block;
    }
    block->size = size;
    block->next = NULL;
    block->free = 0;
    block->magic = kMagicBlockCreated;
    return block;
}

// CHAR_BIT is defined in limits.h
const size_t kWordSizeBits = sizeof(int *) * CHAR_BIT;
const size_t kAlignmentBoundaryBytes = kWordSizeBits / CHAR_BIT;

size_t get_aligned_size(size_t size) {
    if (size == 0) {
        return 0;
    }
    size_t quotient = size / kAlignmentBoundaryBytes;
    size_t remainder = size % kAlignmentBoundaryBytes;
    size_t aligned_size = 0;
    if (quotient < 1) {
        aligned_size = kAlignmentBoundaryBytes;
    } else if (remainder != 0) {
        aligned_size = (quotient + 1) * kAlignmentBoundaryBytes;
    } else {
        aligned_size = size;
    }
    return aligned_size;
}

void *my_malloc(size_t size) {
    // Memory must be aligned, e.g. to 8-byte boundaries on most 64-bit systems
    size_t aligned_size = get_aligned_size(size);

    struct block_meta *block = NULL;
    if (!global_base) { // first call
        block = request_space(NULL, aligned_size);
        if (!block) {
            return NULL;
        }
        global_base = block;
    } else {
        struct block_meta *last = global_base;
        block = find_free_block(&last, aligned_size);
        if (!block) { // failed to find free block
            block = request_space(last, aligned_size);
            if (!block) {
                return NULL;
            }
        } else { // found free block
            // TODO(miguno): consider splitting block here.
            block->free = 0;
            block->magic = kMagicBlockReused;
        }
    }
    return (block + 1);
}

struct block_meta *get_block_ptr(void *ptr) { return (struct block_meta *)ptr - 1; }

void my_free(void *ptr) {
    if (!ptr) {
        return;
    }

    // TODO(miguno): consider merging blocks once splitting blocks is implemented.
    struct block_meta *block_ptr = get_block_ptr(ptr);
    assert(block_ptr->free == 0);
    assert(block_ptr->magic == kMagicBlockReused || block_ptr->magic == kMagicBlockCreated);
    block_ptr->free = 1;
    block_ptr->magic = kMagicBlockFreed;
}

// NOLINTBEGIN(cppcoreguidelines-avoid-magic-numbers)
int main(void) {
    printf("===============================================================\n");
    printf("System-dependent settings:\n");
    printf("---------------------------------------------------------------\n");
    printf("CHAR_BIT: %d bits (number of bits in a byte)\n", CHAR_BIT);
    printf("word size (best guess): %2zu bits\n", kWordSizeBits);
    printf("boundary for alignment: %zu bytes\n", kAlignmentBoundaryBytes);
    printf("sizeof(size_t): %zu bytes\n", sizeof(size_t));
    printf("sizeof(void *): %zu bytes\n", sizeof(void *)); // pointer size

    size_t n1 = 4;
    int *ptr1 = my_malloc(sizeof(*ptr1) * n1);
    size_t n2 = 3;
    int *ptr2 = my_malloc(sizeof(*ptr1) * n2);

    printf("sizeof(*ptr): %zu bytes\n", sizeof(*ptr1));
    printf("sizeof(struct block_meta): %zu bytes\n", sizeof(struct block_meta));

    if (ptr1 && ptr2) {
        // Play around and modify a few values!
        *ptr1 = 1111;
        *(ptr1 + 1) = 2222;
        *(ptr1 + 2) = 3333;
        *ptr2 = 4004;
        *(ptr2 + 1) = 5005;
        *(ptr2 + 2) = 6006;
        // Given how the custom memory allocation is implemented here, we can
        // overwrite the block_meta struct of the second allocated memory with the
        // statements below:
        //
        //  block->size: ptr1[4-5]
        //  block->next: ptr1[6-7]
        //  block->free: ptr1[8]
        //  block->magic: ptr1[9]
        //
        // Examples:
        //  ptr1[4] = 12345;
        //  ptr1[8] = 67890;
        printf("===============================================================\n");
        printf("ptr1 data:\n");
        printf("---------------------------------------------------------------\n");
        size_t beyond_elements = 10;
        for (size_t i = 0; i < n1 + beyond_elements; i++) {
            char *s = i < n1 ? "" : " <== beyond what was malloc'd for ptr1";
            printf("ptr1[%2zu]: %10d [%p]%s\n", i, *(ptr1 + i), (void *)(ptr1 + i), s);
        }
        printf("===============================================================\n");
        printf("ptr2 data:\n");
        printf("---------------------------------------------------------------\n");
        for (size_t i = 0; i < n2 + beyond_elements; i++) {
            char *s = i < n2 ? "" : " <== beyond what was malloc'd for ptr2";
            printf("ptr2[%2zu]: %10d [%p]%s\n", i, *(ptr2 + i), (void *)(ptr2 + i), s);
        }

        printf("===============================================================\n");
        printf("Allocated blocks:\n");
        printf("---------------------------------------------------------------\n");
        size_t i = 0;
        struct block_meta *current = global_base;
        while (current) {
            char *s = NULL;
            block_to_string(current, &s);
            if (s) {
                printf("%zu: %s\n", i, s);
                free(s);
            }
            current = current->next;
            ++i;
        }

        my_free(ptr1);
        my_free(ptr2);
    }
    return EXIT_SUCCESS;
}
// NOLINTEND(cppcoreguidelines-avoid-magic-numbers)
