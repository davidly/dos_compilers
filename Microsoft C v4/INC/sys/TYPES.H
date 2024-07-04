/*
 * sys/types.h
 *
 * defines types used in defining values returned by system level calls for
 * file status and time information.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

typedef unsigned short ino_t;           /* i-node number (not used on DOS) */

#ifndef	TIME_T_DEFINED
typedef long time_t;			/* time value */
#define	TIME_T_DEFINED			/* avoid multiple def's of time_t */
#endif

typedef short dev_t;                    /* device code */
typedef long off_t;                     /* file offset value */
