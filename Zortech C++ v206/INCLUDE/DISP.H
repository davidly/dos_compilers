/*_ disp.h   Fri Aug 18 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All rights reserved					*/
/* Written by Walter Bright				*/

#ifndef DISP_H
#define DISP_H	1		/* prevent multiple #include's		*/

#if __cplusplus
extern "C" {
#endif

extern	int disp_numrows,disp_numcols,disp_cursorrow,disp_cursorcol;

extern	int
	cdecl disp_printf(char *,...),
	cdecl disp_getmode(void),
	cdecl disp_getattr(void),
	cdecl disp_putc(int);
extern	void
	cdecl disp_open(void),
	cdecl disp_puts(const char *),
	cdecl disp_box(int,int,unsigned,unsigned,unsigned,unsigned),
	cdecl disp_close(void),
	cdecl disp_usebios(void),
	cdecl disp_move(int,int),
	cdecl disp_flush(void),
	cdecl disp_eeol(void),
	cdecl disp_eeop(void),
	cdecl disp_startstand(void),
	cdecl disp_endstand(void),
	cdecl disp_setattr(int),
	cdecl disp_setcursortype(int),
	cdecl disp_pokew(int,int,unsigned),
	cdecl disp_scroll(int,unsigned,unsigned,unsigned,unsigned,unsigned),
	cdecl disp_setmode(unsigned char),
	cdecl disp_peekbox(unsigned *,unsigned,unsigned,unsigned,unsigned),
	cdecl disp_pokebox(unsigned *,unsigned,unsigned,unsigned,unsigned),
	cdecl disp_set43(void),
	cdecl disp_reset43(void),
	cdecl disp_fillbox(unsigned,unsigned,unsigned,unsigned,unsigned),
	cdecl disp_hidecursor(void),
	cdecl disp_showcursor(void);
extern	unsigned cdecl disp_peekw(int,int);

/* Globals for IBM PC displays (read only):	*/
extern	unsigned char disp_mono,disp_snowycga,disp_mode,disp_inited,disp_ega;
extern	unsigned disp_base;

/***************************
 * Some attributes for the text display adapters for disp_setattr():
 */

#define DISP_REVERSEVIDEO	0x70
#define DISP_NORMAL		0x07
#define DISP_UNDERLINE		0x01
#define DISP_NONDISPLAY		0x00

/* The following attribute bits should be OR'ed in:	*/
#define DISP_INTENSITY		0x08
#define DISP_BLINK		0x80

/*****************************
 * Values for disp_setcursortype():
 */

#define DISP_CURSORBLOCK (disp_mono ? 0x000C : 0x0007)	/* block cursor	    */
#define DISP_CURSORHALF	 (disp_mono ? 0x060C : 0x0307)	/* half-size cursor */
#define DISP_CURSORUL	 (disp_mono ? 0x0B0C : 0x0707)	/* underline cursor */

#if __cplusplus
}
#endif

#endif /* DISP_H */
