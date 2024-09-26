/*
 * DDS MICRO-C standard I/O definitions for MS-DOS
 *
 * Copyright 1988-1994 Dave Dunfield
 * All rights reserved.
 */
#define	_MICROC_

#define	FILE	unsigned	/* FILE = 16 bit value */
#define	EOF		-1			/* End of file indicator */
#define	NULL	0			/* General NULL indicator */

extern register printf(), fprintf(), sprintf(),
				scanf(), fscanf(), sscanf(),
				concat();
extern char		*fgets();
extern FILE		*fopen(), *stdin, *stdout, stderr[];
