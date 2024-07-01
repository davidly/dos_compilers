/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/*
 * Standard I/O library, msdos
 */

#ifndef	STDIO_H
#define	STDIO_H

typedef struct	FILE {
	unsigned char	*_cp,		/* current character ptr */
			*_dp,		/* ptr to start of data in buffer */
			*_bp;		/* buffer pointer */
	int	_cc;			/* character count */
	int	(*_gt)(),		/* getc function */
		(*_pt)();		/* putc function */
	int	_ff;			/* flags; see below */
	char	_fd;			/* file descriptor (reqd by reopen) */
	int	_uc;			/* ungot char */
}	FILE;
#endif

#define	NULL	((char *)0)
#define	EOF	(-1)
#define	BUFSIZ	(1<<9)
#define CTRLZ	26
#define	_NFILE	30

extern	FILE	_stdin, _stdout, _stderr, _stdaux, _stdprn, *_fp[_NFILE];

/* Flags in _ff */
#define	_FINUSE	0x01
#define	_FSTBUF	0x02		/* setbuf was called */
#define	_FUNGOT	0x04		/* ungotten char present */
#define	_FEOF	0x08
#define	_FERR	0x10
#define _FASCII	0x20		/* Ascii mode (default) */
#define _FWRITE 0x40		/* File is opened for writing */
#define _FDONTC	0x80		/* Don't close */

#define	_ep(fp)		((fp)->_bp+BUFSIZ)
#define _isdev(fd)	(_devinfo(fd)&0x80)
#define	_setbinary(fp)	((fp)->_ff &= ~_FASCII)

char	*gets();
char	*fgets();
FILE	*fopen();
FILE	*freopen();
FILE	*fdopen();
FILE	*popen();
FILE	*_stropen();
long	ftell();
void	puts();
void	fputs();
void	setbuf();
char	*malloc();
char	*sbrk();

#define	getchar()	getc(stdin)
#define	getc(fp)	((*(fp)->_gt)(fp))
#define	putchar(c)	putc(c, stdout)
#define	putc(c,fp)	((*(fp)->_pt)(c,fp))
#define	getw(fp)	(fgetw(fp))
#define	putw(w,fp)	(fputw(w,fp))
#define	feof(fp)	((fp)->_ff&(_FEOF|_FERR))
#define	ferror(fp)	((fp)->_ff&_FERR)
#define	clearerr(fp)	((fp)->_ff &= ~(_FERR|_FEOF))
#define	fileno(fp)	((fp)->_fd)
#define	wdleng()	(16)

#define	stdin	(&_stdin)
#define	stdout	(&_stdout)
#define	stderr	(&_stderr)
#define stdaux	(&_stdaux)
#define stdprn	(&_stdprn)

/* The following definitions are for S-V style tmpnam() and tempnam(). */
#define	L_tmpnam	64
#define	P_tmpdir	"\\tmp"
