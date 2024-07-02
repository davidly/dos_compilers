/*_ stdarg.h   Tue Feb 20 1990   Modified by: Walter Bright */
/* ANSI C style variable arguments	*/

#ifndef __STDARG_H
#define __STDARG_H	1

#if M_I386 || M_I486
#define __VA_ALIGN	3
#else
#define __VA_ALIGN	1
#endif

/* Aligned size on stack */
#define __va_size(type) ((sizeof(type) + __VA_ALIGN) & ~__VA_ALIGN)

typedef char __ss *va_list;
#define va_start(ap,parmn) ((void)((ap) = (va_list)&(parmn)+__va_size(parmn)))
/* #define va_arg(ap,type) (*((type __ss *)(ap))++) */
#define va_arg(ap,type)	   (*(type __ss *)(((ap)+=__va_size(type))-(__va_size(type))))
#define va_end(ap)	   ((void)0)

#endif /* __STDARG_H */
