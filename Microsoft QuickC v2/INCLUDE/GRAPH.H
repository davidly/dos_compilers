
/***
*graph.h - declare constants, functions, and macros for graphics library
*
*   Copyright (c) 1987 - 1989, Microsoft Corporation. All rights reserved.
*
*Purpose:
*   This file declares the graphics library functions and the
*   structures and manifest constants that are used with them.
*
***************************************************************************/


/* user-visible declarations for Quick-C Graphics Library */

#ifndef _VIDEOCONFIG_DEFINED
/* structure for _getvideoconfig() as visible to user */
struct videoconfig {
	short numxpixels;	/* number of pixels on X axis */
	short numypixels;	/* number of pixels on Y axis */
	short numtextcols;	/* number of text columns available */
	short numtextrows;	/* number of text rows available */
	short numcolors;	/* number of actual colors */
	short bitsperpixel;	/* number of bits per pixel */
	short numvideopages;	/* number of available video pages */
	short mode;		/* current video mode */
	short adapter;		/* active display adapter */
	short monitor;		/* active display monitor */
	short memory;		/* adapter video memory in K bytes */
};
#define _VIDEOCONFIG_DEFINED
#endif


#ifndef _XYCOORD_DEFINED
/* return value of _setvieworg(), etc. */
struct xycoord {
	short xcoord;
	short ycoord;
};
#define _XYCOORD_DEFINED
#endif


/* structure for text position */
#ifndef _RCCOORD_DEFINED
struct rccoord {
	short row;
	short col;
};
#define _RCCOORD_DEFINED
#endif


#ifndef NO_EXT_KEYS /* extensions enabled */
	#define _CDECL	cdecl
	#define _FAR	far
#else /* extensions not enabled */
    #ifdef M_I86LM /* large model */
	#define _CDECL
	#define _FAR
    #else
	#error -Za requires -AL when using graph.h
    #endif /* M_I86LM */
#endif /* NO_EXT_KEYS */


/* SETUP AND CONFIGURATION */

short _FAR _CDECL _setvideomode(short);
short _FAR _CDECL _setvideomoderows(short,short); /* return rows; 0 if error */

/* arguments to _setvideomode() */
#define _DEFAULTMODE	-1	/* restore screen to original mode */
#define _TEXTBW40	0	/* 40-column text, 16 grey */
#define _TEXTC40	1	/* 40-column text, 16/8 color */
#define _TEXTBW80	2	/* 80-column text, 16 grey */
#define _TEXTC80	3	/* 80-column text, 16/8 color */
#define _MRES4COLOR	4	/* 320 x 200, 4 color */
#define _MRESNOCOLOR	5	/* 320 x 200, 4 grey */
#define _HRESBW		6	/* 640 x 200, BW */
#define _TEXTMONO	7	/* 80-column text, BW */
#define _HERCMONO	8	/* 720 x 348, BW for HGC */
#define _MRES16COLOR	13	/* 320 x 200, 16 color */
#define _HRES16COLOR	14	/* 640 x 200, 16 color */
#define _ERESNOCOLOR	15	/* 640 x 350, BW */
#define _ERESCOLOR	16	/* 640 x 350, 4 or 16 color */
#define _VRES2COLOR	17	/* 640 x 480, BW */
#define _VRES16COLOR	18	/* 640 x 480, 16 color */
#define _MRES256COLOR	19	/* 320 x 200, 256 color */
#define _ORESCOLOR	64	/* 640 x 400, 1 of 16 colors (Olivetti) */

short _FAR _CDECL _setactivepage(short);
short _FAR _CDECL _setvisualpage(short);
short _FAR _CDECL _getactivepage(void);
short _FAR _CDECL _getvisualpage(void);

/* videoconfig adapter values */
/* these manifest constants can be used to determine the type of the active  */
/* adapter, using either simple comparisons or the bitwise-AND operator (&)  */
#define _MDPA		0x0001	/* Monochrome Display Adapter	      (MDPA) */
#define _CGA		0x0002	/* Color Graphics Adapter	      (CGA)  */
#define _EGA		0x0004	/* Enhanced Graphics Adapter	      (EGA)  */
#define _VGA		0x0008	/* Video Graphics Array		      (VGA)  */
#define _MCGA		0x0010	/* MultiColor Graphics Array	      (MCGA) */
#define _HGC		0x0020	/* Hercules Graphics Card	      (HGC)  */
#define _OCGA		0x0042	/* Olivetti Color Graphics Adapter    (OCGA) */
#define _OEGA		0x0044	/* Olivetti Enhanced Graphics Adapter (OEGA) */
#define _OVGA		0x0048	/* Olivetti Video Graphics Array      (OVGA) */

/* videoconfig monitor values */
/* these manifest constants can be used to determine the type of monitor in */
/* use, using either simple comparisons or the bitwise-AND operator (&) */
#define _MONO		0x0001	/* Monochrome */
#define _COLOR		0x0002	/* Color (or Enhanced emulating color) */
#define _ENHCOLOR	0x0004	/* Enhanced Color */
#define _ANALOGMONO	0x0008	/* Analog Monochrome only */
#define _ANALOGCOLOR	0x0010	/* Analog Color only */
#define _ANALOG		0x0018	/* Analog Monochrome and Color modes */

struct videoconfig _FAR * _FAR _CDECL _getvideoconfig(struct videoconfig _FAR *);



/* COORDINATE SYSTEMS */

struct xycoord _FAR _CDECL _setvieworg(short, short);
struct xycoord _FAR _CDECL _setlogorg(short, short); /* obsolescent */

struct xycoord _FAR _CDECL _getviewcoord(short, short);
struct xycoord _FAR _CDECL _getlogcoord(short, short); /* obsolescent */

struct xycoord _FAR _CDECL _getphyscoord(short, short);

void _FAR _CDECL _setcliprgn(short, short, short, short);
void _FAR _CDECL _setviewport(short, short, short, short);


/* OUTPUT ROUTINES */

/* control parameters for Rectangle, Ellipse and Pie */
#define _GBORDER	2	/* draw outline only */
#define _GFILLINTERIOR	3	/* fill using current fill mask */

#define _GCLEARSCREEN	0
#define _GVIEWPORT	1
#define _GWINDOW	2

void _FAR _CDECL _clearscreen(short);

struct xycoord _FAR _CDECL _moveto(short, short);
struct xycoord _FAR _CDECL _getcurrentposition(void);

short _FAR _CDECL _lineto(short, short);
short _FAR _CDECL _rectangle(short, short, short, short, short);
short _FAR _CDECL _ellipse(short, short, short, short, short);
short _FAR _CDECL _arc(short, short, short, short, short, short, short, short);
short _FAR _CDECL _pie(short, short, short, short, short, short, short, short, short);

short _FAR _CDECL _setpixel(short, short);
short _FAR _CDECL _getpixel(short, short);
short _FAR _CDECL _floodfill(short, short, short);


/* PEN COLOR, LINE STYLE, FILL PATTERN */

short _FAR _CDECL _setcolor(short);
short _FAR _CDECL _getcolor(void);

void _FAR _CDECL _setlinestyle(unsigned short);
unsigned short _FAR _CDECL _getlinestyle(void);

void _FAR _CDECL _setfillmask(unsigned char _FAR *);
unsigned char _FAR * _FAR _CDECL _getfillmask(unsigned char _FAR *);

/* COLOR SELECTION */

long _FAR _CDECL _setbkcolor(long);
long _FAR _CDECL _getbkcolor(void);

long _FAR _CDECL _remappalette(short, long);
short _FAR _CDECL _remapallpalette(long _FAR *);
short _FAR _CDECL _selectpalette(short);


/* TEXT */
#define _GCURSOROFF	0
#define _GCURSORON	1

#define _GWRAPOFF	0
#define _GWRAPON	1

short _FAR _CDECL _settextrows(short); /* returns # rows set; 0 if error */
void _FAR _CDECL _settextwindow(short, short, short, short);
void _FAR _CDECL _outtext(unsigned char _FAR *);
short _FAR _CDECL _wrapon(short);

short _FAR _CDECL _displaycursor(short);
short _FAR _CDECL _settextcursor(short);
short _FAR _CDECL _gettextcursor(void);

struct rccoord _FAR _CDECL _settextposition(short, short);
struct rccoord _FAR _CDECL _gettextposition(void);

short _FAR _CDECL _settextcolor(short);
short _FAR _CDECL _gettextcolor(void);


/* SCREEN IMAGES */

void _FAR _CDECL _getimage(short, short, short, short, char _FAR *);
void _FAR _CDECL _putimage(short, short, char _FAR *, short);
long _FAR _CDECL _imagesize(short, short, short, short);

/* "action verbs" for _putimage() */
#define _GPSET		3
#define _GPRESET	2
#define _GAND		1
#define _GOR		0
#define _GXOR		4

/* universal color values: */
#define _BLACK		0x000000L
#define _BLUE		0x2a0000L
#define _GREEN		0x002a00L
#define _CYAN		0x2a2a00L
#define _RED		0x00002aL
#define _MAGENTA	0x2a002aL
#define _BROWN		0x00152aL
#define _WHITE		0x2a2a2aL
#define _GRAY		0x151515L
#define _LIGHTBLUE	0x3F1515L
#define _LIGHTGREEN	0x153f15L
#define _LIGHTCYAN	0x3f3f15L
#define _LIGHTRED	0x15153fL
#define _LIGHTMAGENTA	0x3f153fL
#define _LIGHTYELLOW	0x153f3fL
#define _BRIGHTWHITE	0x3f3f3fL

/* mono mode F color values: */
#define _MODEFOFF	0L
#define _MODEFOFFTOON	1L
#define _MODEFOFFTOHI	2L
#define _MODEFONTOOFF	3L
#define _MODEFON	4L
#define _MODEFONTOHI	5L
#define _MODEFHITOOFF	6L
#define _MODEFHITOON	7L
#define _MODEFHI	8L

/* mono mode 7 color values: */
#define _MODE7OFF	0L
#define _MODE7ON	1L
#define _MODE7HI	2L


/* WINDOW COORDINATE SYSTEM */

#ifndef _WXYCOORD_DEFINED
/* structure for window coordinate pair */
struct _wxycoord {
	double wx;	/* window x coordinate */
	double wy;	/* window y coordinate */
	};
#define _WXYCOORD_DEFINED
#endif


/* define real coordinate window - returns non-zero if successful */
short _FAR _CDECL _setwindow(short,double,double,double,double);

/* convert from view to window coordinates */
struct _wxycoord _FAR _CDECL _getwindowcoord(short,short);
struct _wxycoord _FAR _CDECL _getwindowcoord_xy(struct xycoord);

/* convert from window to view coordinates */
struct xycoord _FAR _CDECL _getviewcoord_w(double,double);
struct xycoord _FAR _CDECL _getviewcoord_wxy(struct _wxycoord _FAR *);

/*	return the window coordinates of the current graphics output
	position as an _wxycoord structure. no error return. */
struct _wxycoord _FAR _CDECL _getcurrentposition_w(void);


/* window coordinate entry points for graphics output routines */

#define _arc_wxy(pwxy1, pwxy2, pwxy3, pwxy4) \
	_arc_xy(_getviewcoord_wxy(pwxy1), _getviewcoord_wxy(pwxy2), \
		_getviewcoord_wxy(pwxy3), _getviewcoord_wxy(pwxy4))

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _arc_xy(struct xycoord,struct xycoord,struct xycoord,struct xycoord);


#define _ellipse_w(control, wx1, wy1, wx2, wy2) _ellipse_xy(control, \
		_getviewcoord_w(wx1,wy1), _getviewcoord_w(wx2,wy2))

#define _ellipse_wxy(control, pwxy1, pwxy2) _ellipse_xy(control, \
	_getviewcoord_wxy(pwxy1), _getviewcoord_wxy(pwxy2))

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _ellipse_xy(short,struct xycoord,struct xycoord);


#define _floodfill_w(wx, wy, boundary) \
	_floodfill_xy(_getviewcoord_w(wx,wy), boundary)

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _floodfill_xy(struct xycoord, short);


#define _getpixel_w(wx, wy) \
	_getpixel_xy(_getviewcoord_w(wx,wy))

/*	returns pixel value at given point; -1 if unsuccessful. */
short _FAR _CDECL _getpixel_xy(struct xycoord);


#define _lineto_w(wx, wy) \
	_lineto_xy(_getviewcoord_w(wx,wy))

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _lineto_xy(struct xycoord);


#define _moveto_w(wx, wy) \
	_getwindowcoord_xy(_moveto_xy(_getviewcoord_w(wx,wy)))

/*	returns the view coordinates of the previous output
	position as an _xycoord structure. no error return */
struct xycoord _FAR _CDECL _moveto_xy(struct xycoord);


#define _pie_wxy(control, pwxy1, pwxy2, pwxy3, pwxy4) _pie_xy(control, \
		_getviewcoord_wxy(pwxy1), _getviewcoord_wxy(pwxy2), \
		_getviewcoord_wxy(pwxy3), _getviewcoord_wxy(pwxy4))

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _pie_xy(short,struct xycoord,struct xycoord,struct xycoord,struct xycoord);


#define _rectangle_w(control, wx1, wy1, wx2, wy2) _rectangle_xy(control, \
		_getviewcoord_w(wx1,wy1), _getviewcoord_w(wx2,wy2))

#define _rectangle_wxy(control, pwxy1, pwxy2) _rectangle_xy(control, \
		_getviewcoord_wxy(pwxy1), _getviewcoord_wxy(pwxy2))

/*	returns nonzero if successful; otherwise 0	*/
short _FAR _CDECL _rectangle_xy(short,struct xycoord,struct xycoord);


#define _setpixel_w(wx, wy) \
	_setpixel_xy(_getviewcoord_w(wx,wy))

/*	returns previous color; -1 if unsuccessful */
short _FAR _CDECL _setpixel_xy(struct xycoord);


/* window coordinate image routines */
#define _getimage_w( wx1, wy1, wx2, wy2, buffer) \
		_getimage_xy( _getviewcoord_w(wx1,wy1), \
		_getviewcoord_w(wx2,wy2), buffer)

#define _getimage_wxy( pwxy1, pwxy2, buffer) \
		_getimage_xy( _getviewcoord_wxy(pwxy1), \
		_getviewcoord_wxy(pwxy2), buffer)

/*	no return value */
void _FAR _CDECL _getimage_xy(struct xycoord,struct xycoord, char _FAR *);


#define _imagesize_w( wx1, wy1, wx2, wy2) _imagesize_xy( \
		_getviewcoord_w(wx1,wy1), _getviewcoord_w(wx2,wy2))

#define _imagesize_wxy( pwxy1, pwxy2) _imagesize_xy( \
		_getviewcoord_wxy(pwxy1), _getviewcoord_wxy(pwxy2))

/*	returns the image's storage size in bytes */
long _FAR _CDECL _imagesize_xy(struct xycoord,struct xycoord);


#define _putimage_w(wx, wy, image, action) \
	_putimage_xy(_getviewcoord_w(wx,wy), image, action)

/*	no return value */
void _FAR _CDECL _putimage_xy(struct xycoord,char _FAR *,short);


/* FONTS */

#ifndef _FONTINFO_DEFINED
/* structure for _getfontinfo() */
struct _fontinfo {
	int	type;		/* b0 set = vector,clear = bit map	*/
	int	ascent;		/* pix dist from top to baseline	*/
	int	pixwidth;	/* character width in pixels, 0=prop	*/
	int	pixheight;	/* character height in pixels		*/
	int	avgwidth;	/* average character width in pixels	*/
	char	filename[81];	/* file name including path		*/
	char	facename[32];	/* font name				*/
};
#define _FONTINFO_DEFINED
#endif


/* font function prototypes */
short	_FAR _CDECL	_registerfonts( unsigned char _FAR *);
void	_FAR _CDECL	_unregisterfonts( void );
short	_FAR _CDECL	_setfont( unsigned char _FAR * );
short	_FAR _CDECL	_getfontinfo( struct _fontinfo _FAR * );
void	_FAR _CDECL	_outgtext( unsigned char _FAR * );
short	_FAR _CDECL	_getgtextextent( unsigned char _FAR * );
