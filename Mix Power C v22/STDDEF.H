/*$no list*//*$no trace <<< stddef.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !defined(NULL)
   #define NULL ((void *)0)
#endif
#if !defined(FARNULL)
   #define FARNULL ((void far *)0)
#endif
#if !Defined(size_t)
typedef unsigned size_t;
#endif
#define offsetof(stype, member) (size_t)&(((stype *)0)->member)
#if !Defined(ptrdiff_t)
   #if defined(M_I86LM)
      typedef long ptrdiff_t;
   #else
      typedef int ptrdiff_t;
   #endif
#endif
extern int errno;

/*$list*//*$trace       <<< stddef.h >>> */
