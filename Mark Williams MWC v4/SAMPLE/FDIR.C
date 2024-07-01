/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * fdir.c
 * 5/8/87
 *
 * This program prints a formatted directory of its command line arguments.
 * Example command lines:
 *	fdir
 *	fdir -t
 *	fdir *.c
 *	fdir \test\*.c \source\*.*
 * It demonstrates some advanced features of MSDOS MWC86:
 *	(1)	The intcall() function, used to call MSDOS.
 *	(2)	The ptoreg() macro, used to pass a pointer to MSDOS
 *		using code which is independent of LARGE or SMALL model.
 *	(3)	Bit fields, used to reference the dates of the files.
 *	(4)	The qsort() function, used to sort files and directories.
 *	(5)	The ctype macros.
 *	(6)	Dynamic memory allocation.
 * The -t option sorts files by time, -s sorts by size;
 * otherwise, files within each directory are sorted alphabetically.
 * Directories are listed before other files.
 * The output is in the following format for each file:
 *	<attribute bits> <file length> <last modification date> <filename>
 */

/*
 * Header files.
 */
#include <stdio.h>			/* Standard I/O definitions */
#include <ctype.h>			/* Character type macros */
#include <dos.h>			/* MSDOS definitions */

/*
 * Predefined limits.
 */
#define FNLEN		80		/* Maximum filename length */
#define MAXFILES	512		/* Max number of files/directory */

/*
 * This macro returns the number of elements of its array argument.
 */
#define SIZE(x)		(sizeof(x)/sizeof(x[0]))

/*
 * File attributes.
 * Defined on page C-4 of the IBM-PC DOS 2.0 manual.
 */
#define A_RONLY		0x01		/* Read only file */
#define A_HIDDEN	0x02		/* Hidden file */
#define A_SYSTEM	0x04		/* System file */
#define A_DIRECTORY	0x10		/* Directory file */
#define A_ARCHIVE	0x20		/* Archive bit */

/*
 * Attribute structure, associating a name with each mask.
 */
static	 struct atr {
		 int a_mask;
		 int a_name;
} atr[] = {
	 A_DIRECTORY,	'd',		/* Directory file */
	 A_RONLY,	'r',		/* Read only file */
	 A_HIDDEN,	'h',		/* Hidden file */
	 A_SYSTEM,	's',		/* System file */
	 A_ARCHIVE,	'a'		/* Archive bit */
};

/*
 * Structure of MSDOS date/time bit fields.
 * Defined on page C-5 of the IBM-PC DOS 2.0 manual.
 */
struct date {
	unsigned d_sec	 : 5;		/* Time, 2 second intervals */
	unsigned d_min	 : 6;		/* Time, minutes */
	unsigned d_hour  : 5;		/* Time, hours */
	unsigned d_day	 : 5;		/* Date, day of month */
	unsigned d_month : 4;		/* Date, month of year */
	unsigned d_year  : 7;		/* Date, year since 1980 */
};

/*
 * Structure filled in by MSDOS for FINDFIRST and FINDNEXT calls.
 * Defined of page D-49 of the IBM-PC DOS 2.0 manual.
 */
#define	FNDINFO	21
#define	FNDNAME	13
struct find {
	char	 fnd_dosinfo[FNDINFO];	/* Reserved for dos */
	char	 fnd_attr;		/* File attribute */
	struct	 date fnd_date;		/* Date structure */
	long	 fnd_size;		/* File size */
	char	 fnd_name[FNDNAME];	/* File name less path */
};

/*
 * Routines which return values other than int.
 * All such routines should be declared before they are used.
 * Failure to do so could sacrifice portability between machines
 * or between LARGE and SMALL model.
 */
extern char *basename();
extern char *date();
extern void fatal();
extern char *malloc();
extern int  qscmp();
extern char *rindex();
extern char *strcpy();
extern char *strlower();

/*
 * Global data.
 */
int	aflag = 0;			/* Set if "-a" specified.	*/
int	howsort = 0;
int	filecount = 0;			/* Total number of files	*/
int	dircount = 0;			/* Total number of directories	*/
long	bytecount = 0L;			/* Total length of files in bytes */
char	path[FNLEN];			/* Filename path		*/
struct	find *fnd[MAXFILES];		/* Pointers to file structures	*/

main(argc, argv)
int argc;				/* Number of command line arguments */
char *argv[];				/* Array of pointers to arguments */
{
	register int i;
	register int count;		/* Number of files found */
	register char *file;		/* Command line argument */
	register int status;		/* Exit status */

	status = 0;

	/* "fdir -a" lists "." and "..", which are otherwise suppressed. */
	if (argc > 1 && *argv[1] == '-') {	/* options */
		while ((i = toupper(*++argv[1])) != '\0')
			if (i == 'A')
				aflag = 1;
			else
				howsort = i;
		++argv;
		--argc;
	}

	/* If no command line arguments, i.e. "fdir", fake argument "*.*". */
	if (argc == 1) {
		argc = 2;
		argv[1] = "*.*";
	}

	while (--argc) {			/* Loop for each argument */
		file = *++argv;			/* Grab next argument */
		i = basename(file) - file;	/* Find pathname length */
		if (i + FNDNAME > FNLEN)
			fatal("filename \"%s\" too long", file);
		strcpy(path, file);		/* Copy file to path[] */
		path[i] = '\0';			/* NUL-terminate pathname */
		strlower(path);			/* Convert pathname to lower case */
		count = dosfind(file);		/* Find matching files */
		if (!count) {			/* Issue error if no match */
			++status;
			fprintf(stderr, "fdir: cannot find \"%s\"\n", file);
		}
		qsort(fnd, count, sizeof(struct find *), qscmp); /* Sort */
		for (i=0; i < count; i++)	/* Loop for each matching file */
			printinfo(fnd[i]);	/* Print information */
	}

	/* Print totals. */
	if (dircount != 0 || filecount != 0 || bytecount != 0L)
		printf("\n");
	if (dircount != 0)
		printf("Directories: %6d\n", dircount);
	if (filecount != 0)
		printf("Files:       %6d\n", filecount);
	if (bytecount != 0L)
		printf("Total bytes: %6ld\n", bytecount);
	exit(status);
}

/*
 * Return a pointer to the beginning of the filename (past pathname, if any).
 */
char *basename(name) char *name;
{
	register char *p;

	if ((p = rindex(name, '\\')) != NULL || (p = rindex(name, ':')) != NULL)
		return(++p);
	return(name);
}

/*
 * Given a pointer to a date structure, return a pointer to an ASCII date.
 * The buffer for the return value is statically allocated.
 */
char *date(dp) register struct date *dp;
{
	static char ad[21];
	static char *month[] = {
		"Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	};

	sprintf(ad, "%s %2d %02d:%02d:%02d %4d",
		month[dp->d_month - 1], dp->d_day,
		dp->d_hour, dp->d_min, dp->d_sec * 2,
		dp->d_year + 1980);
	return(ad);
}

/*
 * Expand filename 'file' possibly containing wildcard characters.
 * Initialize global array fnd[] with pointers to matching filenames and
 * return the number of matches found.
 */
int dosfind(file) char *file;
{
	register int count;			/* Number of files found */
	struct	 find f;			/* Filename return data from MSDOS */
	struct	 reg r;				/* Register values for intcall() */

	/*
	 * Call MSDOS to set the disk transfer address (DTA) to &f.
	 * Macro ptoreg() stores the segment:offset of f
	 * in r.r_ds and r.r_dx in a model independent manner.
	 */
	r.r_ax = SETDTA;			/* Function code to AX */
	ptoreg(dsreg, r.r_dx, r.r_ds, &f);	/* Seg:off of f to DS:DX */
	intcall(&r, &r, DOSINT);		/* Call MSDOS */

	/* Call MSDOS to find the first matching filename. */
	r.r_ax = NFFIRST;			/* Function code to AX*/
	r.r_cx = A_HIDDEN | A_SYSTEM | A_DIRECTORY | A_RONLY | A_ARCHIVE;
						/* Attributes to CX */
	ptoreg(dsreg, r.r_dx, r.r_ds, file);	/* Seg:off of file to DS:DX */
	intcall(&r, &r, DOSINT);		/* Call MSDOS */

	/*
	 * Loop for each matching filename.
	 * Carry flag set indicates no more matching files.
	 */
	for (count = 0; (r.r_flags & F_CF) == 0; count++) {

		/* Do not exceed maximum number of matching files. */
		if (count >= MAXFILES)
			fatal("too many matching files");

		/* Dynamically allocate memory for a find structure. */
		if ((fnd[count] = (struct find *)malloc(sizeof(struct find))) == NULL)
			fatal("out of memory");

		/* Copy the structure to the allocated space. */
		*fnd[count] = f;		/* Structure assignment. */

		/* Find the next matching filename. */
		r.r_ax = NFNEXT;		/* Find next function */
		intcall(&r, &r, DOSINT);	/* Call MSDOS */
	}
	return(count);
}

/*
 * Fatal error.
 * The "%r" (recursive) format specifier is non-portable.
 */
void fatal(p) char *p;
{
	fprintf(stderr, "fdir: %r\n", &p);
	exit(1);
}

/*
 * Print a line of information about a file.
 * Update running totals.
 */
printinfo(fndp) register struct fnd *fndp;
{
	register int i, attr;

	attr = fndp->fnd_attr;
	if (attr&A_DIRECTORY) {
		/* Suppress "." and ".." unless "-a" specified. */
		if (!aflag && (strcmp(fndp->fnd_name, ".") == 0
			    || strcmp(fndp->fnd_name, "..") == 0))
			return;
		++dircount;
	}
	else
		++filecount;
	bytecount += fndp->fnd_size;

	/* Print attributes (name if bit is set, '-' if not). */
	for (i = 0; i < SIZE(atr); i++)
		putchar((atr[i].a_mask & attr) ? atr[i].a_name : '-');

	/* Print size, date, name. */
	printf(" %10D  %s  %s%s\n",
		fndp->fnd_size, date(&(fndp->fnd_date)), path, strlower(fndp->fnd_name));

	/* Free allocated structure. */
	free(fndp);
}

/*
 * Compare routine for qsort().
 * Called by qsort(), passed two pointers to find structure pointers.
 * Only the pointers to the find structures are actually sorted.
 */
int qscmp(fpp1, fpp2) struct find **fpp1, **fpp2;
{
	register struct find *f1;
	register struct find *f2;
	register int i;

	f1 = *fpp1;
	f2 = *fpp2;
	if (i = (f2->fnd_attr&A_DIRECTORY) - (f1->fnd_attr&A_DIRECTORY))
		return(i);			/* Exactly one is directory */
	if (howsort == 'T') {		/* take advantage of form of date */
		if (*(unsigned long *)&f1->fnd_date
			 < *(unsigned long *)&f2->fnd_date)
			return(1);
		else
			return(-1);
	} else if (howsort == 'S') {
		if( f1->fnd_size < f2->fnd_size)
			return(1);
		else
			return(-1);
	} else
		return (strcmp(f1->fnd_name, f2->fnd_name));
}

/*
 * Convert string 'str' to lower case (in-place) and return a pointer to it.
 */
char *strlower(str) char *str;
{
	register int c;
	register char *s;

	s = str;
	while (c = *s)
		*s++ = tolower(c);
	return(str);
}

/* end of fdir.c */
