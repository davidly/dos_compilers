/*
 * The routines in this file
 * read and write ASCII files from the
 * disk. All of the knowledge about files
 * are here. A better message writing
 * scheme should be used.
 */
#include	<stdio.h>
#include	"ed.h"

FILE	*ffp;				/* File pointer, all functions.	*/

/*
 * Open a file for reading.
 */
ffropen(fn)
char	*fn;
{
	if ((ffp=fopen(fn, "r")) == NULL)
		return (FIOFNF);
	return (FIOSUC);
}

/*
 * Open a file for writing.
 * Return TRUE if all is well, and
 * FALSE on error (cannot create).
 */
ffwopen(fn)
char	*fn;
{
#if	VMS
	register int	fd;

	if ((fd=creat(fn, 0666, "rfm=var", "rat=cr")) < 0
	|| (ffp=fdopen(fd, "w")) == NULL) {
#else
	if ((ffp=fopen(fn, "w")) == NULL) {
#endif
		mlwrite("Cannot open file for writing");
		return (FIOERR);
	}
	return (FIOSUC);
}

/*
 * Close a file.
 * Should look at the status in all systems.
 */
ffclose()
{
#if	V7
	if (fclose(ffp) != FALSE) {
		mlwrite("Error closing file");
		return(FIOERR);
	}
	return(FIOSUC);
#endif
	fclose(ffp);
	return (FIOSUC);
}

/*
 * Write a line to the already
 * opened file. The "buf" points to the
 * buffer, and the "nbuf" is its length, less
 * the free newline. Return the status.
 * Check only at the newline.
 */
ffputline(buf, nbuf)
register char	buf[];
{
	register int	i;

	for (i=0; i<nbuf; ++i)
		putc(buf[i]&0xFF, ffp);
	putc('\n', ffp);
	if (ferror(ffp) != FALSE) {
		mlwrite("Write I/O error");
		return (FIOERR);
	}
	return (FIOSUC);
}

/*
 * Read a line from a file,
 * and store the bytes in the supplied
 * buffer. The "nbuf" is the length of the
 * buffer. Complain about long lines and lines
 * at the end of the file that don't have a
 * newline present. Check for I/O errors
 * too. Return status.
 */
ffgetline(buf, nbuf)
register char	buf[];
{
	register int	c;
	register int	i;

	i = 0;
	while ((c=getc(ffp))!=EOF && c!='\n') {
		if (i >= nbuf-1) {
			mlwrite("File has long line");
#if	GEM
			buf[i] = 0;
			ungetc(c, ffp);
			return (FIOSUC);	/* Make long lines load	*/
#endif
			return (FIOERR);
		}
		buf[i++] = c;
	}
	if (c == EOF) {
		if (ferror(ffp) != FALSE) {
			mlwrite("File read error");
			return (FIOERR);
		}
		if (i != 0) {
			mlwrite("File has funny line at EOF");
#if	GEM
			buf[i]=0;		/* Make funny line show up. */
			return (FIOSUC);
#else
			return (FIOERR);
#endif
		}
		return (FIOEOF);
	}
	buf[i] = 0;
	return (FIOSUC);
}
