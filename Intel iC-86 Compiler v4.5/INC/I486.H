/* i486.h - 80486 processor specific header file
 * $Version: 1.6 $
 * Copyright 1990 Intel Corporation, ALL RIGHTS RESERVED.
 */

#if !defined(_I486_)
#define _I486_

#include <i386.h>

#define FLAG_ALIGNCHECK	0x40000

#pragma _builtin_("byteswap"==47)
unsigned int	byteswap(unsigned int);

#pragma _builtin_("invalidatedatacache"==48)
void	invalidatedatacache(void);

#pragma _builtin_("wbinvalidatedatacache"==49)
void	wbinvalidatedatacache(void);

#pragma _builtin_("invalidatetlbentry"==50)
void	invalidatetlbentry(void far *);

#endif
