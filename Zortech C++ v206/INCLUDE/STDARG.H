/*_ stdarg.h   Mon Jan 19 1987   Modified by: Walter Bright */
/* ANSI C style variable arguments	*/

#ifndef STDARG_H
#define STDARG_H	1

typedef char *va_list;

#define va_start(ap,parmn)	((ap) = (va_list)&(parmn) + sizeof(parmn))

#define va_arg(ap,type)	(*((type *)ap)++)

#define va_end(ap)

#endif /* STDARG_H */
