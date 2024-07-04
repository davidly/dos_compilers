/* search.h - searching and sorting function prototypes
 * $Version: 1.14 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _searchh
#define _searchh
/*lint -library */

#pragma fixedparams("lfind", "lsearch")

/*
 * Function prototypes:
 */
void *lfind(const void *, const void *, unsigned *, unsigned, 
        int (*)(const void *, const void *));
void *lsearch(const void *, void *, unsigned *, unsigned, 
        int (*)(const void *, const void *));

#endif /* _searchh */

