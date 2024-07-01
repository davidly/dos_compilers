/*$no list*//*$no trace	<<< stdarg.h >>> */
/*   Copyright (c) Mix Software	1988	 */

#if !defined(va_list)
typedef	char *va_list;
#endif

#define	va_start(argptr, lastarg) argptr = (va_list) &lastarg +	sizeof(lastarg)
#define	va_arg(argptr, type) (*(((type*)argptr)++))
#define	va_end(argptr) argptr =	0

/*$list*//*$trace	<<< stdarg.h >>> */
