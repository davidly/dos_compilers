/* assert.h - define the assert macro
 * $Version: 1.9 $
 * Copyright (c) 1984, 85 Computer Innovations Inc, ALL RIGHTS RESERVED.
 * Copyright (c) 1988, 89 Intel Corporation, ALL RIGHTS RESERVED.
 */

#undef assert

#ifndef NDEBUG

#ifndef _stdioh 
#include <stdio.h>
#endif
#ifndef _stdlibh
#include <stdlib.h>
#endif

#define assert(_exp_) { \
  if (!(_exp_)) { \
    fprintf(stderr, "Assertion failed: %s, file %s, line %d\n", \
            #_exp_, __FILE__, __LINE__); \
    abort(); \
  } \
}

#else

#define assert(ignore)

#endif /* NDEBUG */

