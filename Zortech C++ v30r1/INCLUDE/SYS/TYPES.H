/*_ types.h   Tue May  9 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All rights reserved					*/
/* Written by Walter Bright				*/

#ifndef __TYPES_H
#define __TYPES_H	1

/* This file is for compatibility with unix. I'd recommend avoiding it,	*/
/* as it is non-standard.						*/

#ifndef __TIME_H			/* time.h defines it too	*/
typedef long time_t;
#endif

#endif /* __TYPES_H */
