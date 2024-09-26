/*
 * Compatibility definitions for the "CONSOLE" interface.
 *
 * The "CONSOLE" interface has been renamed to "VIDEO", and the function
 * names renamed to be consistant with the "WINDOW" library. This header
 * file maps the "VIDEO" functions back to the "CONSOLE" names, and allows
 * previously written MICRO-C programs, which use that interface to compile
 * correctly.
 *
 * When coding a program for the first time under MICRO-C, DO NOT USE THIS
 * FILE. Learn the "VIDEO" functions, since they are now standard.
 *
 * Copyright 1990-1994 Dave Dunfield
 * All rights reserved.
 */

/* Low level CONSOLE functions */
#define	video_init	vopen
#define	chkkey		vtstc
#define	getkey		vgetc
#define	putchr		vputc
#define	clear_scr	vclscr
#define	clear_eos	vcleos
#define	clear_eol	vcleol
#define	gotoxy		vgotoxy
#define	updatexy	vupdatexy
#define	cursor_off	vcursor_off
#define	cursor_on	vcursor_line

/* High level CONSOLE functions */
#define	draw_box	vdraw_box
#define	clear_box	vclear_box

#include \mc\video.h
