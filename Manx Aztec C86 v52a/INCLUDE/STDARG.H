/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __STDARG_H
#define __STDARG_H

typedef char *va_list;
#define va_start(ap, parmN) ((ap) = (char *)(&parmN + 1))
#define va_arg(ap, type) ((ap) += sizeof(type), ((type *)(ap))[-1])
#define va_end(ap)

#endif
