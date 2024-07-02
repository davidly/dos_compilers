/*$no list*//*$no trace <<< stdarg.h >>> */
/*   Copyright (c) Mix Software 1988     */

#if !Defined(va_list)
typedef char *va_list;
#endif

#define va_start(argp, last) (void)(argp = (va_list) &last + sizeof(last))
#define va_arg(argptr, type) (*(((type*)argptr)++))
#define va_end(argptr) (void)(argptr = 0)

/*$list*//*$trace       <<< stdarg.h >>> */
