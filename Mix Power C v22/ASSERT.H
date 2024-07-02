/*$no list*//*$no trace <<< assert.h >>> */
/*   Copyright (c) Mix Software 1988     */

#undef assert
#if !defined(NDEBUG)
   #if !Defined(_assert_fail)
      void _assert_fail(char *filename, int line);
   #endif
   #define assert(exp) (void)( (!(exp)) ? _assert_fail(__FILE__, __LINE__) : 0)
#else
#define assert(exp) (void)0
#endif

/*$list*//*$trace       <<< assert.h >>> */
