/*
 * DDS MICRO-C IBM/PC Window Library definitions
 *
 * Copyright 1990-1994 Dave Dunfield
 * All rights reserved.
 */

/* General keys */
#define _KUA	0xff80			/* Up    arrow	*/
#define _KDA	0xff81			/* Down  arrow	*/
#define _KLA	0xff82			/* Left  arrow	*/
#define _KRA	0xff83			/* Right arrow	*/
#define _KPU	0xff84			/* PgUp			*/
#define _KPD	0xff85			/* PgDn			*/
#define _KHO	0xff86			/* Home			*/
#define _KEN	0xff87			/* End			*/
#define _KKP	0xff88			/* Keypad '+'	*/
#define _KKM	0xff89			/* Keypad '-'	*/
#define _KIN	0xff8a			/* Insert key	*/
#define _KDL	0xff8b			/* Delete key	*/
#define _KBS	0xff8c			/* Backspace	*/
/* Functions keys */
#define _K1		0xff8d			/* Function 1	*/
#define _K2		0xff8e			/* Function 2	*/
#define _K3		0xff8f			/* Function 3	*/
#define _K4		0xff90			/* Function 4	*/
#define _K5		0xff91			/* Function 5	*/
#define _K6		0xff92			/* Function 6	*/
#define _K7		0xff93			/* Function 7	*/
#define _K8		0xff94			/* Function 8	*/
#define _K9		0xff95			/* Function 9	*/
#define _K10	0xff96			/* Function 10	*/
/* Special control keys */
#define _CPU	0xff97			/* Control PgUp */
#define _CPD	0xff98			/* Control PgDn */
#define _CHO	0xff99			/* Control Home */
#define _CEN	0xff9a			/* Control End  */
#define	_CLA	0xff9b			/* Control Left arrow */
#define	_CRA	0xff9c			/* Control Right arrow */

/*
 * Window open attributes
 */
#define	WSAVE		0x8000		/* Save/Restore screen */
#define	WBOX1		0x4000		/* Enable enclosing BORDER type 1 */
#define	WBOX2		0x2000		/* Enable enclosing BORDER type 2 */
#define	WBOX3		0x6000		/* Enable enclosing BORDER type 3 */
#define	WCOPEN		0x1000		/* Clear window when opened */
#define	WCCLOSE		0x0800		/* Clear window when closed */
#define	WLF			0x0400		/* Disable NEWLINE, LF only */
#define	WSCROLL		0x0200		/* Enable scrolling */
#define	WWRAP		0x0100		/* Enable line=wrap */

/*
 * Video attribute bit definitions
 */
#define BLINK		0x80		/* Blinking video modes */
#define INTENSE		0x08		/* Intensity control */

/*
 * Color video attribute bits (Color adapters only).
 * The individual RED, GREEN and BLUE bits may be combined
 * to provide 8 distinct foreground and background colors.
 * Note: INTENSE bit affects foreground colors only.
 */
#define F_RED		0x04		/* Foreground RED */
#define F_GREEN		0x02		/* Foreground GREEN */
#define F_BLUE		0x01		/* Foreground BLUE */
#define B_RED		0x40		/* Background RED */
#define B_GREEN		0x20		/* Background GREEN */
#define B_BLUE		0x10		/* Background BLUE */

/* Monochrome video attributes (Monochrome adapters only) */
#define	NORMAL		0x07		/* Monochrome normal video */
#define REVERSE		0x70		/* Monochrome reverse video */
#define UNDERLINE	0x01		/* Monochrome underline video */

/*
 * Structure of window control block
 */
struct WINDOW {
	unsigned int		WINattr;
	unsigned char		WINorgx, WINorgy;
	unsigned char		WINwidth, WINheight;
	unsigned char		WINcurx, WINcury;
	struct	 WINDOW		*WINprevious;
	unsigned char		WINpcure, WINpcurs;
	unsigned char	 	WINpcurx, WINpcury;
	char				WINdata[]; };

/*
 * External definitions in windowing library
 */
extern int				W_BASE;
extern struct WINDOW	*W_OPEN;
extern register			wform(), wprintf(), w_printf();
