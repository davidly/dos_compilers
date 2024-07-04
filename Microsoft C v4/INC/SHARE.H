/*
 * share.h
 *
 * file sharing modes for sopen
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

#define SH_COMPAT	0x00	/* compatibility mode */
#define SH_DENYRW	0x10	/* deny read/write mode */
#define SH_DENYWR	0x20	/* deny write mode */
#define SH_DENYRD	0x30	/* deny read mode */
#define SH_DENYNO	0x40	/* deny none mode */
