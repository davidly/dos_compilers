/* Copyright Manx Software Systems, Inc. 1990.  All rights reserved */

#ifndef __SGTTY_H
#define __SGTTY_H

#define TIOCGETP	0		/* read contents of tty control structure */
#define TIOCSETP	1		/* set contents of tty control structure */
#define TIOCSETN	1		/* ditto only don't wait for output to flush */

struct sgttyb {
	char sg_erase;		/* ignored */
	char sg_kill;		/* ignored */
	short sg_flags;		/* control flags */
};

/* settings for flags */
#define _VALID	0x3a
#define RAW		0x20	/* no echo or mapping of input/output BDOS(6) */
#define CRMOD	0x10	/* map input CR to NL, output NL to CR LF */
#define ECHO	0x08	/* ignored unless CBREAK is set */
#define CBREAK	0x02	/* input using BDOS(1), unless echo off then */
						/* same as RAW */

#if 0	/* Not yet implemented */
#define	TIOCNTLC	3	/* check for control C */
#define TIOCGETC	4	/* get tchars structure */
#define TIOCSETC	5	/* set tchars structure */
#define TIOCFLUSH	6	/* flush input/typeahead queues */

/* settings for flags */
#define	TABSIZ	0x000f	/* size of tab if XTABS is set */
#define	XTABS	0x0010	/* convert tabs to spaces on output */
#define	CRMOD	0x0020	/* CR -> LF on input, LF -> CR/LF on output */
#define	ECHO	0x0040	/* echo input to output */
#define	ECHOE	0x0080	/* follow erase character by space, BS */
#define	CBREAK	0x0100	/* don't wait for the whole line */
#define	NODELAY	0x0200	/* return even if no characters */
#define RAW		0x0400	/* no input or output mapping at all */
#define	CHKKEY	0x0800	/* check for keyboard characters during output */
#define	ERASE	0x1000	/* erase character space before drawing */

struct tchars {
	char t_intrc;		/* interrupt - ^C (not [yet] implemented) */
	char t_quitc;		/* quit - ^\ (not [yet] implemented) */
/*	char t_startc;		/* start output (not supported) */
/*	char t_stop;		/* stop output (not supported) */
	char t_eofc;		/* end-of-file - ^D */
/*	char t_brck;		/* input delimiter (like nl) (not supported) */
};
#endif

#endif
