/*
 * dos.h
 *
 * Defines the structs and unions used to handle the input and output
 * registers for the DOS interface routines defined in the V2.0 to V3.0
 * compatability package.  It also includes macros to access the segment
 * and offset values of MS C "far" pointers, so that they may be used by
 * these routines.
 *
 * Copyright (C) Microsoft Corporation, 1984, 1985, 1986
 *
 */

/* word registers */

struct WORDREGS {
	unsigned int ax;
	unsigned int bx;
	unsigned int cx;
	unsigned int dx;
	unsigned int si;
	unsigned int di;
	unsigned int cflag;
	};

/* byte registers */

struct BYTEREGS {
	unsigned char al, ah;
	unsigned char bl, bh;
	unsigned char cl, ch;
	unsigned char dl, dh;
	};

/* general purpose registers union - overlays the corresponding word and
 * byte registers.
 */

union REGS {
	struct WORDREGS x;
	struct BYTEREGS h;
	};

/* segment registers */

struct SREGS {
	unsigned int es;
	unsigned int cs;
	unsigned int ss;
	unsigned int ds;
	};

/* dosexterror struct */

struct DOSERROR {
	int exterror;
	char class;
	char action;
	char locus;
	};

/* macros to break MS C "far" pointers into their segment and offset
 * components
 */

#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))

/* function declarations for those who want strong type checking
 * on arguments to library function calls
 */

#ifdef LINT_ARGS	/* argument checking enabled */

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl bdos(int, unsigned int, unsigned int);
int cdecl dosexterr(struct DOSERROR *);
int cdecl intdos(union REGS *, union REGS *);
int cdecl intdosx(union REGS *, union REGS *, struct SREGS *);
int cdecl int86(int, union REGS *, union REGS *);
int cdecl int86x(int, union REGS *, union REGS *, struct SREGS *);
void cdecl segread(struct SREGS *);
#else			/* extended keywords not enabled */
int bdos(int, unsigned int, unsigned int);
int dosexterr(struct DOSERROR *);
int intdos(union REGS *, union REGS *);
int intdosx(union REGS *, union REGS *, struct SREGS *);
int int86(int, union REGS *, union REGS *);
int int86x(int, union REGS *, union REGS *, struct SREGS *);
void segread(struct SREGS *);
#endif	/* NO_EXT_KEYS */

#else

#ifndef NO_EXT_KEYS	/* extended keywords are enabled */
int cdecl bdos();
int cdecl dosexterr();
int cdecl intdos();
int cdecl intdosx();
int cdecl int86();
int cdecl int86x();
void cdecl segread();
#else			/* extended keywords not enabled */
void segread();
#endif	/* NO_EXT_KEYS */

#endif	/* LINT_ARGS */
