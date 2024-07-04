/* _alloc.h - alloc and free header definitions
 * $Version: 1.20 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef __alloch
#define __alloch
/*lint -library */ 

#ifndef _limitsh
#include <limits.h>
#endif

#pragma fixedparams("_malloc_find", "_merge_free_blocks")
#pragma fixedparams("_merge_free_lists", "_malloc_take", "_free")

#ifndef _free_list_item_t
#define _free_list_item_t
#pragma align (free_list_item)
struct free_list_item {
    struct free_list_item *next;
    unsigned               length;
};
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#define _FREE_LIST_SIZE   20
#define FH_SIZE           sizeof(struct free_list_item)
#define INTSIZE           sizeof(int)
#define MIN_ALLOC         sizeof(int)
#define MAX_ALLOC         (UINT_MAX - FH_SIZE)

void _merge_free_lists(void);
int  _merge_free_blocks(struct free_list_item *);
void _malloc_take(struct free_list_item *, unsigned);
struct free_list_item *_malloc_find(unsigned);
void _free(struct free_list_item *);

#endif /* __alloch */

