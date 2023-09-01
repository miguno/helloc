/* gui.c */

#include <stdio.h>

// This example uses https://github.com/zpl-c/zpl to demonstrate working with
// header-only libraries.

#define ZPL_IMPLEMENTATION
#define ZPL_NANO
#include "zpl.h"

void print_item(const zpl_list item) {
    printf("[%s <- %s -> %s]\n", item.prev ? cast(char *) item.prev->ptr : "N/A",
           item.ptr ? cast(char *) item.ptr : "N/A", item.next ? cast(char *) item.next->ptr : "N/A");
}

// For more zpl examples, see
// https://github.com/zpl-c/zpl/tree/master/code/apps/examples
int main(void) {
    // Showcase the use of zpl's list data structure, which is a doubly-linked list.
    // Adapted from https://github.com/zpl-c/zpl/blob/7b27bd98a91722284cd1b75b3f4435cafd0dbd9e/code/apps/examples/list.c
    zpl_list *head = NULL;
    zpl_list *cursor = NULL;

    // Initialize the list
    zpl_list a;
    zpl_list_init(&a, "First");
    head = cursor = &a;

    // Append more items to the list
    zpl_list b = {"Second"};
    cursor = zpl_list_add(cursor, &b);
    zpl_list c = {"Third"};
    cursor = zpl_list_add(cursor, &c);
    zpl_list d = {"Last"};
    cursor = zpl_list_add(cursor, &d);

    // Print the full list
    for (zpl_list *item = head; item; item = item->next) {
        zpl_printf("%s -> ", cast(char *) item->ptr);
    }
    zpl_printf("\n");

    // Given an item, print its previous and next items
    print_item(c);

    return 0;
}
