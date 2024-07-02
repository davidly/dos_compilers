/*	conio.h

	Direct MSDOS console input/output.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if	!defined(__VIDEO)
#define __VIDEO

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef	__OLDCONIO__

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

enum text_modes { LASTMODE=-1, BW40=0, C40, BW80, C80, MONO=7 };

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

void 	 _Cdecl clreol		(void);
void 	 _Cdecl clrscr		(void);
void 	 _Cdecl delline		(void);
int	 _Cdecl gettext		(int left, int top, int right, int bottom,
				 void *destin);
void	 _Cdecl gettextinfo	(struct text_info *r);
void 	 _Cdecl gotoxy		(int x, int y);
void	 _Cdecl highvideo	(void);
void 	 _Cdecl insline		(void);
void	 _Cdecl lowvideo	(void);
int	 _Cdecl movetext	(int left, int top, int right, int bottom, 
				 int destleft, int desttop);
void	 _Cdecl normvideo	(void);
int	 _Cdecl puttext		(int left, int top, int right, int bottom,
				 void *source);
void	 _Cdecl textattr	(int newattr);
void 	 _Cdecl textbackground	(int newcolor);
void 	 _Cdecl textcolor	(int newcolor);
void 	 _Cdecl textmode	(int newmode);
int  	 _Cdecl wherex		(void);
int  	 _Cdecl wherey		(void);
void 	 _Cdecl window		(int left, int top, int right, int bottom);
#endif

char	*_Cdecl cgets		(char *str);
int  	 _Cdecl cprintf		(const char *format, ...);
int	 _Cdecl cputs		(const char *str);
int	 _Cdecl cscanf		(const char *format, ...);
int	 _Cdecl getch		(void);
int	 _Cdecl getche		(void);
char	*_Cdecl getpass		(const char *prompt);
int	 _Cdecl kbhit		(void);
int	 _Cdecl putch		(int c);
int	 _Cdecl ungetch		(int ch);

#endif
