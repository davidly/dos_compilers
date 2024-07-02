/* i186.h - 80186 processor specific header file
 * $Version: 1.5 $
 * Copyright 1988, 89, 90 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I186_)
#define _I186_

#include <i86.h>

#pragma _builtin_("blockinbyte"==20)
void    blockinbyte(    unsigned short  port,
                        unsigned char   *destination,
                        unsigned int    count);

#pragma _builtin_("blockinword"==21)
void    blockinword(    unsigned short  port,
                        unsigned int    *destination,
                        unsigned int    count);

#pragma _builtin_("blockoutbyte"==22)
void    blockoutbyte(   unsigned short          port,
                        unsigned char const     *source,
                        unsigned int            count);

#pragma _builtin_("blockoutword"==23)
void    blockoutword(   unsigned short          port,
                        unsigned int const      *source,
                        unsigned int            count);

#endif
