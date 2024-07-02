/*	conio.h

	Direct MSDOS console input/output.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/
#if	!defined(__VIDEO)
#define __VIDEO

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

#define _NOCURSOR      0
#define _SOLIDCURSOR   1
#define _NORMALCURSOR  2

struct text_info {
	unsigned char winleft;
	unsigned char wintop;
	unsigned char winright;
	unsigned char winbottom;
	unsigned char attribute;
	unsigned char normattr;
	unsigned char currmode;
	unsigned char screenheight;
	unsigned char screenwidth;
	unsigned char curx;
	unsigned char cury;
};

enum text_modes { LASTMODE=-1, BW40=0, C40, BW80, C80, MONO=7, C4350=64 };

#if	!defined(__COLORS)
#define __COLORS

enum COLORS {
	BLACK,			/* dark colors */
	BLUE,
	GREEN,
	CYAN,
	RED,
	MAGENTA,
	BROWN,
	LIGHTGRAY,
	DARKGRAY,		/* light colors */
	LIGHTBLUE,
	LIGHTGREEN,
	LIGHTCYAN,
	LIGHTRED,
	LIGHTMAGENTA,
	YELLOW,
	WHITE
};
#endif

#define BLINK		128	/* blink bit */

extern	 int _Cdecl directvideo;
extern	 int _Cdecl _wscroll;

#ifdef __cplusplus
extern "C" {
#endif
void 	 _Cdecl clreol		(void);
void 	 _Cdecl clrscr		(void);
void 	 _Cdecl delline		(void);
int	 _Cdecl gettext		(int __left, int __top, int __right, int __bottom,
				 void *__destin);
void	 _Cdecl gettextinfo	(struct text_info *__r);
void 	 _Cdecl gotoxy		(int __x, int __y);
void	 _Cdecl highvideo	(void);
void 	 _Cdecl insline		(void);
void	 _Cdecl lowvideo	(void);
int	 _Cdecl movetext	(int __left, int __top, int __right, int __bottom,
				 int __destleft, int __desttop);
void	 _Cdecl normvideo	(void);
int	 _Cdecl puttext		(int __left, int __top, int __right, int __bottom,
				 void *__source);
void	 _Cdecl textattr	(int __newattr);
void 	 _Cdecl textbackground	(int __newcolor);
void 	 _Cdecl textcolor	(int __newcolor);
void 	 _Cdecl textmode	(int __newmode);
int  	 _Cdecl wherex		(void);
int  	 _Cdecl wherey		(void);
void 	 _Cdecl window		(int __left, int __top, int __right, int __bottom);

void	 _Cdecl _setcursortype	(int __cur_t);
char	*_Cdecl cgets		(char *__str);
int  	 _Cdecl cprintf		(const char *__format, ...);
int	 _Cdecl cputs		(const char *__str);
int	 _Cdecl cscanf		(const char *__format, ...);
int	 _Cdecl getch		(void);
int	 _Cdecl getche		(void);
char	*_Cdecl getpass		(const char *__prompt);
int	 _Cdecl kbhit		(void);
int	 _Cdecl putch		(int __c);
int	 _Cdecl ungetch		(int __ch);
#ifdef __cplusplus
}
#endif
#endif
