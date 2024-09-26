/*
 * DDS MICRO-C MS-DOS File system definitions
 *
 * Copyright 1989-1994 Dave Dunfield
 * All rights reserved.
 */

#define	PATH_SIZE	65		/* Max. size of pathname (64 + Z) */

/* File attribute bits in directory entry */
#define	READONLY	0x01	/* File cannot be written */
#define	HIDDEN		0x02	/* File skipped in normal searches */
#define	SYSTEM		0x04	/* File is considered part of system */
#define	VOLUME		0x08	/* Directory entry is volume label */
#define DIRECTORY	0x10	/* File is a directory */
#define	ARCHIVE		0x20	/* File has been modified */

/* Attribute bits in the file control block */
#define	F_READ		0x01	/* File is opened for READ */
#define F_WRITE		0x02	/* File is opened for WRITE */
#define	F_APPEND	0x04	/* Append to file opened for WRITE */
#define	F_BINARY	0x10	/* Inhibit TEXT translations */
#define	F_VERB		0x40	/* Issue error message if failure */
#define	F_QUIT		0x80	/* Terminate execution if failure */

/* Low level "standard" I/O streams */
#define	HANDLE		int		/* Type for DOS file handles */
#define	L_stdin		0		/* Low Level standard INPUT */
#define	L_stdout	1		/* Low Level standard OUTPUT */
#define	L_stderr	2		/* Low Level standard ERROR */

/* Structure used for buffered file I/O */
struct FILE_structure {
	char FILE_options;		/* Open options */
	int  FILE_handle;		/* DOS file handle */
	int  FILE_iob_size;		/* Size of FILE_buffer */
	int  FILE_io_ptr;		/* Access pointer into buffer */
	int  FILE_io_top;		/* Amount of buffer used */
	char FILE_buffer[]; };	/* I/O data buffer */

extern register lprintf();	/* Low level 'printf' */
extern unsigned IOB_size;	/* Default I/O buffer size */
