/*_ varargs.h   Tue May 15 1990   Modified by: Walter Bright */
/* Unix C style variable arguments	*/

#ifndef __VARARGS_H
#define __VARARGS_H	1

#if M_I386 || M_I486
#define __VA_ALIGN	3
#else
#define __VA_ALIGN	1
#endif

/* Aligned size on stack */
#define __va_size(type) ((sizeof(type) + __VA_ALIGN) & ~__VA_ALIGN)

typedef void __ss *va_list;
#define va_dcl		int va_alist;
#define va_start(ap)	((ap) = (va_list)&(va_alist))
#define va_arg(ap,type)	(*(type __ss *)(((char __ss *)(ap)+=__va_size(type))-(__va_size(type))))
#define va_end(ap)	((void)0)

#endif /* __VARARGS_H */

