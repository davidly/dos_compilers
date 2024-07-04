/*
 * types.h
 *
 * defines types used in defining values returned by system level calls for
 * file status and time information.
 *
 * Copyright (C) Microsoft Corporation, 1984
 */

typedef unsigned short ino_t;           /* i-node number (not used on DOS) */
typedef long time_t;                    /* time value */
typedef short dev_t;                    /* device code */
typedef long off_t;                     /* file offset value */
