/* i8086.h - 8086 processor specific only header file
 * $Version: 1.6 $
 * Copyright 1988, 89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I8086_)
#define _I8086_

#include <i86.h>

#pragma _builtin_("setinterrupt"==1)
void    setinterrupt(const unsigned char number, void far (*handler)(void));

#endif
