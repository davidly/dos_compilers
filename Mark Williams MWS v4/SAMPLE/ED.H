/*
 * This file is the general header file for
 * all parts of the MicroEMACS display editor. It contains
 * definitions used by everyone, and it contains the stuff
 * you have to edit to create a version of the editor for
 * a specific operating system and terminal.
 */
#ifdef	COHERENT
#define	V7	1			/* V7 UN*X or Coherent		*/
#define	VMS	0			/* VAX/VMS			*/
#define	CPM	0			/* CP/M-86			*/
#define	MSDOS	0			/* MS-DOS			*/
#define	GEM	0			/* GEMDOS			*/
#define	PROMPT	" Coherent MicroEMACS -- "
#endif

#ifdef	GEMDOS
#define	V7	0			/* V7 UN*X or Coherent		*/
#define	VMS	0			/* VAX/VMS			*/
#define	CPM	0			/* CP/M-86			*/
#define	MSDOS	0			/* MS-DOS			*/
#define	GEM	1			/* GEMDOS			*/
#define	UPPERNM	0			/* if 0 names in all lower case	*/
#define	PROMPT	" ST MicroEMACS V1.6 -- "
#endif

#ifdef	MSDOS
#define	V7	0			/* V7 UN*X or Coherent		*/
#define	VMS	0			/* VAX/VMS			*/
#define	CPM	0			/* CP/M-86			*/
#define	GEM	0			/* GEMDOS			*/
#define	PROMPT	" DOS MicroEMACS V4.0.12 -- "
#endif

#ifdef	COHERENT
#define ANSI	0
#define VT52	0			/* VT52 terminal (Zenith).	*/
#define	VT100	0			/* Handle VT100 style keypad.	*/
#define	LK201	0			/* Handle LK201 style keypad.	*/
#define	RAINBOW	0			/* Use Rainbow fast video.	*/
#define TERMCAP 1			/* Use TERMCAP			*/
#endif

#ifdef	GEMDOS
#define ANSI	0
#define VT52	1			/* VT52 terminal (Zenith).	*/
#define	VT100	0			/* Handle VT100 style keypad.	*/
#define	LK201	0			/* Handle LK201 style keypad.	*/
#define	RAINBOW	0			/* Use Rainbow fast video.	*/
#define TERMCAP 0			/* Use TERMCAP			*/
#endif

#ifdef	MSDOS
#ifndef IBM
#define ANSI	1			/* Use ANSI.SYS			*/
#else
#define ANSI	0
#endif
#define VT52	0			/* VT52 terminal (Zenith).	*/
#define	VT100	0			/* Handle VT100 style keypad.	*/
#define	LK201	0			/* Handle LK201 style keypad.	*/
#define	RAINBOW	0			/* Use Rainbow fast video.	*/
#define TERMCAP 0			/* Use TERMCAP			*/
#endif

#ifndef	PROMPT
#define	PROMPT	" MicroEMACS -- "
#endif

#define	CVMVAS	1			/* C-V, M-V arg. in screens.	*/

#define	NCFILES	5			/* Max # of files on command line */
#define	NFILEN	80			/* # of bytes, file name	*/
#define	NBUFN	16			/* # of bytes, buffer name	*/
#define	NLINE	256			/* # of bytes, line		*/
#define	NKBDM	256			/* # of strokes, keyboard macro	*/
#define	NPAT	80			/* # of bytes, pattern		*/
#define	HUGE	1000			/* Huge number			*/
#define	NSRCH	128			/* undoable search command len	*/
#define	ERRLINES 3			/* error window lines displayed	*/

#define	AGRAVE	0x60			/* M- prefix,   Grave (LK201)	*/
#define	METACH	0x1B			/* M- prefix,   Control-[, ESC	*/
#define	CTMECH	0x1C			/* C-M- prefix, Control-\	*/
#define	EXITCH	0x1D			/* Exit level,  Control-]	*/
#define	CTRLCH	0x1E			/* C- prefix,	Control-^	*/
#define	HELPCH	0x1F			/* Help key,    Control-_	*/

#define	CTRL	0x0100			/* Control flag, or'ed in	*/
#define	META	0x0200			/* Meta flag, or'ed in		*/
#define	CTLX	0x0400			/* ^X flag, or'ed in		*/

#define	FALSE	0			/* False, no, bad, etc.		*/
#define	TRUE	1			/* True, yes, good, etc.	*/
#define	ABORT	2			/* Death, ^G, abort, etc.	*/

#define	FIOSUC	0			/* File I/O, success.		*/
#define	FIOFNF	1			/* File I/O, file not found.	*/
#define	FIOEOF	2			/* File I/O, end of file.	*/
#define	FIOERR	3			/* File I/O, error.		*/

#define	CFCPCN	0x0001			/* Last command was C-P, C-N	*/
#define	CFKILL	0x0002			/* Last command was a kill	*/

/*
 * There is a window structure allocated for
 * every active display window. The windows are kept in a
 * big list, in top to bottom screen order, with the listhead at
 * "wheadp". Each window contains its own values of dot and mark.
 * The flag field contains some bits that are set by commands
 * to guide redisplay; although this is a bit of a compromise in
 * terms of decoupling, the full blown redisplay is just too
 * expensive to run for every input character. 
 */
typedef	struct	WINDOW {
	struct	WINDOW *w_wndp;		/* Next window			*/
	struct	BUFFER *w_bufp;		/* Buffer displayed in window	*/
	struct	LINE *w_linep;		/* Top line in the window	*/
	struct	LINE *w_dotp;		/* Line containing "."		*/
	short	w_doto;			/* Byte offset for "."		*/
	struct	LINE *w_markp;		/* Line containing "mark"	*/
	short	w_marko;		/* Byte offset for "mark"	*/
	char	w_toprow;		/* Origin 0 top row of window	*/
	char	w_ntrows;		/* # of rows of text in window	*/
	char	w_force;		/* If NZ, forcing row.		*/
	char	w_flag;			/* Flags.			*/
}	WINDOW;

#define	WFFORCE	0x01			/* Window needs forced reframe	*/
#define	WFMOVE	0x02			/* Movement from line to line	*/
#define	WFEDIT	0x04			/* Editing within a line	*/
#define	WFHARD	0x08			/* Better to a full display	*/
#define	WFMODE	0x10			/* Update mode line.		*/

/*
 * Text is kept in buffers. A buffer header, described
 * below, exists for every buffer in the system. The buffers are
 * kept in a big list, so that commands that search for a buffer by
 * name can find the buffer header. There is a safe store for the
 * dot and mark in the header, but this is only valid if the buffer
 * is not being displayed (that is, if "b_nwnd" is 0). The text for
 * the buffer is kept in a circularly linked list of lines, with
 * a pointer to the header line in "b_linep".
 */
typedef	struct	BUFFER {
	struct	BUFFER *b_bufp;		/* Link to next BUFFER		*/
	struct	LINE *b_dotp;		/* Link to "." LINE structure	*/
	short	b_doto;			/* Offset of "." in above LINE	*/
	struct	LINE *b_markp;		/* The same as the above two,	*/
	short	b_marko;		/* but for the "mark"		*/
	struct	LINE *b_linep;		/* Link to the header LINE	*/
	char	b_nwnd;			/* Count of windows on buffer	*/
	char	b_flag;			/* Flags			*/
	char	b_fname[NFILEN];	/* File name			*/
	char	b_bname[NBUFN];		/* Buffer name			*/
}	BUFFER;

#define	BFTEMP	0x01			/* Internal temporary buffer	*/
#define	BFCHG	0x02			/* Changed since last write	*/
#define	BFERROR	0x04			/* Error file buffer		*/
#define	BFNOWRT	0x08			/* Don't write this buffer	*/
#define	BFBACKP	0x10			/* Rename file before write	*/
#define	BFWRITE	0x20			/* Written since read		*/
#define	BFTRUNC	0x40			/* File truncated		*/

/*
 * The starting position of a
 * region, and the size of the region in
 * characters, is kept in a region structure.
 * Used by the region commands.
 */
typedef	struct	{
	struct	LINE *r_linep;		/* Origin LINE address.		*/
	short	r_offset;		/* Origin LINE offset.		*/
	short	r_size;			/* Length in characters.	*/
}	REGION;

/*
 * All text is kept in circularly linked
 * lists of "LINE" structures. These begin at the
 * header line (which is the blank line beyond the
 * end of the buffer). This line is pointed to by
 * the "BUFFER". Each line contains a the number of
 * bytes in the line (the "used" size), the size
 * of the text array, and the text. The end of line
 * is not stored as a byte; it's implied. Future
 * additions will include update hints, and a
 * list of marks into the line.
 */
typedef	struct	LINE {
	struct	LINE *l_fp;		/* Link to the next line	*/
	struct	LINE *l_bp;		/* Link to the previous line	*/
	short	l_size;			/* Allocated size		*/
	short	l_used;			/* Used size			*/
	long	l_lnumber;		/* Line number in original file	*/
	char	l_text[];		/* A bunch of characters.	*/
}	LINE;

#define	lforw(lp)	((lp)->l_fp)
#define	lback(lp)	((lp)->l_bp)
#define	lgetc(lp, n)	((lp)->l_text[(n)]&0xFF)
#define	lputc(lp, n, c)	((lp)->l_text[(n)]=(c))
#define	llength(lp)	((lp)->l_used)
#define	l_number(lp)	((lp)->l_lnumber)
/*
 * The editor communicates with the display
 * using a high level interface. A "TERM" structure
 * holds useful variables, and indirect pointers to
 * routines that do useful operations. The low level get
 * and put routines are here too. This lets a terminal,
 * in addition to having non standard commands, have
 * funny get and put character code too. The calls
 * might get changed to "termp->t_field" style in
 * the future, to make it possible to run more than
 * one terminal type.
 */  
typedef	struct	{
	short	t_nrow;			/* Number of rows.		*/
	short	t_ncol;			/* Number of columns.		*/
	int	(*t_open)();		/* Open terminal at the start.	*/
	int	(*t_close)();		/* Close terminal at end.	*/
	int	(*t_getchar)();		/* Get character from keyboard.	*/
	int	(*t_putchar)();		/* Put character to display.	*/
	int	(*t_flush)();		/* Flush output buffers.	*/
	int	(*t_move)();		/* Move the cursor, origin 0.	*/
	int	(*t_eeol)();		/* Erase to end of line.	*/
	int	(*t_eeop)();		/* Erase to end of page.	*/
	int	(*t_beep)();		/* Beep.			*/
}	TERM;

/* Command line switch flags	*/
#define	CF_ERROR	(0x0001)	/* Error edit switch specified	*/
#define	CF_BACKUP	(0x0002)	/* Rename file before write sw	*/
#define	CF_WARN		(0x0004)	/* Warn user before overwrite	*/
#define	CF_DEBUG	(0x8000)	/* Debugging flag		*/

extern	int	fillcol;		/* Fill column			*/
extern	int	currow;			/* Cursor row			*/
extern	int	curcol;			/* Cursor column		*/
extern	int	thisflag;		/* Flags, this command		*/
extern	int	lastflag;		/* Flags, last command		*/
extern	int	curgoal;		/* Goal for C-P, C-N		*/
extern	int	mpresf;			/* Stuff in message line	*/
extern	int	sgarbf;			/* State of screen unknown	*/
extern	int	runswitch;		/* Switch flags			*/
extern	WINDOW	*curwp;			/* Current window		*/
extern	BUFFER	*curbp;			/* Current buffer		*/
extern	WINDOW	*wheadp;		/* Head of list of windows	*/
extern	BUFFER	*bheadp;		/* Head of list of buffers	*/
extern	BUFFER	*blistp;		/* Buffer for C-X C-B		*/
extern	BUFFER	*errbp;			/* Error file buffer		*/
extern	short	kbdm[];			/* Holds kayboard macro data	*/
extern	short	*kbdmip;		/* Input pointer for above	*/
extern	short	*kbdmop;		/* Output pointer for above	*/
extern	char	pat[];			/* Search pattern		*/
extern	TERM	term;			/* Terminal information.	*/
extern	char	*ufiles[];		/* command-line specified files	*/
extern	int	ffold;			/* Fold in search flag.		*/
extern	char	errfile[];		/* error file name		*/

extern	BUFFER	*bfind();		/* Lookup a buffer by name	*/
extern	WINDOW	*wpopup();		/* Pop up window creation	*/
extern	LINE	*lalloc();		/* Allocate a line		*/
