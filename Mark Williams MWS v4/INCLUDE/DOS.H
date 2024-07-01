/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Definitions for accessing MS-DOS and 8086 functions.
 */

#ifndef DOS_H
#define DOS_H

#define L2RECSZ 9			/* log base 2 of record size */
#define RECSIZ	(1<<L2RECSZ)		/* Record size */
#define TTYSIZ	128			/* # of bytes, CON: line buffer */
#define BAD	0xFF			/* Bad status, open, make */

#define SOK	0x00			/* All ok */
#define SNOREC	0x01			/* Reading unwritten data */
#define SOVER	0x02			/* Disc buffer overflows segment */
#define SPART	0x03			/* Partial record read */

/*
 * DOS functions.
 */
#define EXIT	0x0000			/* Program terminate */
#define CONIN	0x0100			/* Console input */
#define CONOUT	0x0200			/* Console output */
#define RDRIN	0x0300			/* Get byte from reader */
#define AUXIN	0x0300			/* Alternative name */
#define PUNOUT	0x0400			/* Put byte to punch */
#define AUXOUT	0x0400			/* Alternative name */
#define LSTOUT	0x0500			/* Put byte to printer */
#define CONDIO	0x0600			/* Direct console I/O */
#define DIRCON	0x0600			/* Old synonym */
#define CONRAW	0x0700			/* Console input, no echo, no int */
#define CON_E	0x0800			/* Console input, no echo */
#define PUTSTR	0x0900			/* Put `$' delimited string */
#define BUFCON	0x0A00			/* Buffered console read */
#define CONSTAT 0x0B00			/* Console status */
#define CLRIN	0x0C01			/* Console clear then input */
#define CLRDIO	0x0C06			/* Console clear then direct I/O */
#define CLRRAW	0x0C07			/* Console clear then raw input */
#define CLR_E	0x0C08			/* Console clear then input no echo */
#define CLRBUF	0x0C0A			/* Console clear then buffered input*/
#define RESDSK	0x0D00			/* Reset disc system */
#define SELDSK	0x0E00			/* Select disc */
#define OPENF	0x0F00			/* Open file */
#define CLOSEF	0x1000			/* Close file */
#define FFIRST	0x1100			/* Find first */
#define FNEXT	0x1200			/* Find next */
#define DELETEF 0x1300			/* Delete file */
#define READS	0x1400			/* Read sequential */
#define WRITES	0x1500			/* Write sequential */
#define MAKEF	0x1600			/* Make file */
#define CREATEF 0x1600			/* Create file (synonym) */
#define RENAMEF 0x1700			/* Rename file */
#define GETDISK 0x1900			/* Get current disk */
#define SETDMAO 0x1A00			/* Set DMA offset */
#define SETDTA	0x1A00			/* Set disk transfer address */
#define GETALTI 0x1B00			/* Get allocation table info */
#define READR	0x2100			/* Read random */
#define WRITER	0x2200			/* Write random */
#define SIZEF	0x2300			/* Compute file size */
#define SETRREC 0x2400			/* Set random record */
#define SETINT	0x2500			/* Set interrupt vector */
#define PROGSEG 0x2600			/* Create program segment */
#define READB	0x2700			/* Random block read */
#define WRITEB	0x2800			/* Random block write */
#define GETDATE 0x2A00			/* Get date */
#define SETDATE 0x2B00			/* Set date */
#define GETTIME 0x2C00			/* Get time */
#define SETTIME 0x2D00			/* Set time */
#define VERIFY	0x2E00			/* Disk write verification */
#define GETDTA	0x2F00			/* Get address of disk transfer adr */
#define GETVER	0x3000			/* Get DOS version number */
#define TERMRES 0x3100			/* Terminate and remain resident */
#define CTLBCHK 0x3300			/* Ctrl-break check */
#define GETVEC	0x3500			/* Get interrupt vector */
#define GETFREE 0x3600			/* Get free disk space */
#define GETCDI	0x3800			/* Get country dependent info */
#define MKDIR	0x3900			/* Create a sub-directory */
#define RMDIR	0x3A00			/* Remove a sub-directory */
#define CHDIR	0x3B00			/* Change the current directory */
#define CREATH	0x3C00			/* Create a file */
#define OPENH	0x3D00			/* Open a file */
#define CLOSEH	0x3E00			/* Close a file */
#define READH	0x3F00			/* Read from a file or device */
#define WRITEH	0x4000			/* Write to a file or device */
#define DELETE	0x4100			/* Delete a file */
#define LSEEKH	0x4200			/* Move file read/write pointer */
#define CHMOD	0x4300			/* Change file mode */
#define IOCTLH	0x4400			/* I/O control for devices */
#define DUPH	0x4500			/* Duplicate a file handle */
#define FDUPH	0x4600			/* Force a duplicate of handle */
#define GETCDIR 0x4700			/* Get current directory */
#define ALLOC	0x4800			/* Allocate memory */
#define FREE	0x4900			/* Free allocated memory */
#define SETBLK	0x4A00			/* Modify allocated memory blocks */
#define EXEC	0x4B00			/* Load or execute a program */
#define NEXIT	0x4C00			/* Terminate a process */
#define WAIT	0x4D00			/* Get return code of subprocess */
#define NFFIRST 0x4E00			/* DOS 2.0 find first */
#define NFNEXT	0x4F00			/* DOS 2.0 find next */
#define GETVST	0x5400			/* Get verify state */
#define RENAME	0x5600			/* Rename a file */
#define GSDT	0x5700			/* Get/set a file's date and time */

#define ON	1			/* for verify */
#define OFF	0			/* for verify */

/*
 * Function declarations for DOS functions.
 * Functions dos(), dosb(), dosc(), and dosd() have been replaced
 * by the more generalized function intcall().  The old functions
 * are retained in the library but will be retracted in a future release.
 * If you use an old DOS call, you must declare it.
 */
#define DOSINT	0x21			/* DOS interrupt */
/*
extern	int	dos();
extern	int	dosb();
extern	long	dosc();
extern	long	dosd();
*/

/*
 * Type definition for DOS file control block.
 * Assumes all elements get byte alignment.
 * FCBs are no longer necessary with DOS 2.0;
 * they are replaced by file handles.
 */
typedef struct	fcb_t	{
	unsigned char	f_drive;	/* drive code */
	char		f_name[8],	/* name */
			f_ext[3];	/* extension */
	unsigned short	f_block;	/* current block (=128 records) */
	unsigned short	f_recsz;	/* record size in bytes (=1) */
	unsigned long	f_size; 	/* file size in bytes (system) */
	unsigned int	f_date; 	/* modification date (system) */
	char		f_sys[10];	/* for system use */
	unsigned char	f_rec;		/* current record in block */
	unsigned long	f_seek; 	/* random record position */
} fcb_t;

/*
 * The following masks test the state of the processor carry or zero flags.
 */
#define F_CF	0x0001			/* Carry flag mask */
#define F_ZF	0x0040			/* Zero flag mask */

/*
 * A structure of this type is passed to intcall().
 */
#ifndef CSD
struct reg {
	unsigned r_ax;
	unsigned r_bx;
	unsigned r_cx;
	unsigned r_dx;
	unsigned r_si;
	unsigned r_di;
	unsigned r_ds;
	unsigned r_es;
	unsigned r_flags;
};
#endif

/*
 * These macros can be used to store or extract pointers
 * from a reg structure (defined above).
 * These are LARGE/SMALL model independent.
 */
#ifdef LARGE
#define PTR(x)			 (x)
#define ptoreg(t, off, seg, ptr) ((off)=(long)(ptr),(seg)=((long)ptr)>>16)
#define regtop(off, seg, ptr)  ((ptr)=(char *)((long)(off)+((long)(seg)<<16)))
#else
extern unsigned dsreg(), esreg(), csreg(), ssreg();
#define PTR(x)			 (x), dsreg()
#define ptoreg(t, off, seg, ptr) ((off)=(int)(ptr),(seg)=(t)())
#define regtop(off, seg, ptr)	 ((ptr)=(char *)(off))
#endif

#endif
