/*_ varargs.h   Tue Feb  7 1989   Modified by: Walter Bright */
/* Unix C style variable arguments	*/

#ifndef VARARGS_H
#define VARARGS_H	1

typedef void *va_list;
#define va_dcl		int va_alist;
#define va_start(ap)	((ap) = (va_list)&(va_alist))
#define va_arg(ap,type)	(*((type *)ap)++)
#define va_end(ap)

#endif /* VARARGS_H */

