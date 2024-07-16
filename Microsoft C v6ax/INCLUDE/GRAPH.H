/***
*graph.h - declare constants, functions, and macros for graphics library
*
*   Copyright (c) 1987 - 1990, Microsoft Corporation. All rights reserved.
*
*Purpose:
*   This file declares the graphics library functions and the
*   structures and manifest constants that are used with them.
*
***************************************************************************/


/* force word packing to avoid possible -Zp override */
#pragma pack(2)

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



/* ERROR HANDLING */
short _far _cdecl _grstatus(void);

/* Error Status Information returned by _grstatus() */

/* successful */
#define	_GROK                        0

/* errors */
#define _GRERROR                    (-1)
#define	_GRMODENOTSUPPORTED	    (-2)
#define	_GRNOTINPROPERMODE          (-3)
#define _GRINVALIDPARAMETER         (-4)
#define	_GRFONTFILENOTFOUND         (-5)
#define	_GRINVALIDFONTFILE          (-6)
#define _GRCORRUPTEDFONTFILE        (-7)
#define _GRINSUFFICIENTMEMORY       (-8)
#define _GRINVALIDIMAGEBUFFER       (-9)

/* warnings */
#define _GRNOOUTPUT                  1
#define _GRCLIPPED                   2
#define _GRPARAMETERALTERED          3


/* SETUP AND CONFIGURATION */

short _far _cdecl _setvideomode(short);
short _far _cdecl _setvideomoderows(short,short); /* return rows; 0 if error */

/* arguments to _setvideomode() */
#define _MAXRESMODE	(-3)	/* graphics mode with highest resolution */
#define _MAXCOLORMODE	(-2)	/* graphics mode with most colors */
#define _DEFAULTMODE	(-1)	/* restore screen to original mode */
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

short _far _cdecl _setactivepage(short);
short _far _cdecl _setvisualpage(short);
short _far _cdecl _getactivepage(void);
short _far _cdecl _getvisualpage(void);

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

struct videoconfig _far * _far _cdecl _getvideoconfig(struct videoconfig _far *);



/* COORDINATE SYSTEMS */

struct xycoord _far _cdecl _setvieworg(short, short);
#define _setlogorg _setvieworg		/* obsolescent */

struct xycoord _far _cdecl _getviewcoord(short, short);
#define _getlogcoord _getviewcoord	/* obsolescent */

struct xycoord _far _cdecl _getphyscoord(short, short);

void _far _cdecl _setcliprgn(short, short, short, short);
void _far _cdecl _setviewport(short, short, short, short);


/* OUTPUT ROUTINES */

/* control parameters for _ellipse, _rectangle, _pie and _polygon */
#define _GBORDER	2	/* draw outline only */
#define _GFILLINTERIOR	3	/* fill using current fill mask */

/* parameters for _clearscreen */
#define _GCLEARSCREEN	0
#define _GVIEWPORT	1
#define _GWINDOW	2

void _far _cdecl _clearscreen(short);

struct xycoord _far _cdecl _moveto(short, short);
struct xycoord _far _cdecl _getcurrentposition(void);

short _far _cdecl _lineto(short, short);
short _far _cdecl _rectangle(short, short, short, short, short);
short _far _cdecl _polygon(short, const struct xycoord _far *, short);
short _far _cdecl _arc(short, short, short, short, short, short, short, short);
short _far _cdecl _ellipse(short, short, short, short, short);
short _far _cdecl _pie(short, short, short, short, short, short, short, short, short);

short _far _cdecl _getarcinfo(struct xycoord _far *, struct xycoord _far *, struct xycoord _far *);

short _far _cdecl _setpixel(short, short);
short _far _cdecl _getpixel(short, short);
short _far _cdecl _floodfill(short, short, short);


/* PEN COLOR, LINE STYLE, WRITE MODE, FILL PATTERN */

short _far _cdecl _setcolor(short);
short _far _cdecl _getcolor(void);

void _far _cdecl _setlinestyle(unsigned short);
unsigned short _far _cdecl _getlinestyle(void);

short _far _cdecl _setwritemode(short);
short _far _cdecl _getwritemode(void);

void _far _cdecl _setfillmask(const unsigned char _far *);
unsigned char _far * _far _cdecl _getfillmask(unsigned char _far *);

/* COLOR SELECTION */

long _far _cdecl _setbkcolor(long);
long _far _cdecl _getbkcolor(void);

long _far _cdecl _remappalette(short, long);
short _far _cdecl _remapallpalette(const long _far *);
short _far _cdecl _selectpalette(short);


/* TEXT */
/* parameters for _displaycursor */
#define _GCURSOROFF	0
#define _GCURSORON	1

/* parameters for _wrapon */
#define _GWRAPOFF	0
#define _GWRAPON	1


/* direction parameters for _scrolltextwindow */
#define _GSCROLLUP	1
#define _GSCROLLDOWN	(-1)

/* request maximum number of rows in _settextrows and _setvideomoderows */
#define _MAXTEXTROWS	(-1)

short _far _cdecl _settextrows(short); /* returns # rows set; 0 if error */
void _far _cdecl _settextwindow(short, short, short, short);
void _far _cdecl _gettextwindow(short _far *, short _far *, short _far *, short _far *);
void _far _cdecl _scrolltextwindow(short);
void _far _cdecl _outmem(const unsigned char _far *, short);
void _far _cdecl _outtext(const unsigned char _far *);
short _far _cdecl _wrapon(short);

short _far _cdecl _displaycursor(short);
short _far _cdecl _settextcursor(short);
short _far _cdecl _gettextcursor(void);

struct rccoord _far _cdecl _settextposition(short, short);
struct rccoord _far _cdecl _gettextposition(void);

short _far _cdecl _settextcolor(short);
short _far _cdecl _gettextcolor(void);


/* SCREEN IMAGES */

void _far _cdecl _getimage(short, short, short, short, char _huge *);
void _far _cdecl _putimage(short, short, char _huge *, short);
long _far _cdecl _imagesize(short, short, short, short);

/* "action verbs" for _putimage() and _setwritemode() */
#define _GPSET		3
#define _GPRESET	2
#define _GAND		1
#define _GOR		0
#define _GXOR		4


/* Color values are used with _setbkcolor in graphics modes and also by
   _remappalette and _remapallpalette.  Also known as palette colors.
   Not to be confused with color indices (aka. color attributes).  */

/* universal color values (all color modes): */
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
#define _YELLOW		0x153f3fL
#define _BRIGHTWHITE	0x3f3f3fL

/* the following is obsolescent and defined only for backward compatibility */
#define _LIGHTYELLOW	_YELLOW

/* mono mode F (_ERESNOCOLOR) color values: */
#define _MODEFOFF	0L
#define _MODEFOFFTOON	1L
#define _MODEFOFFTOHI	2L
#define _MODEFONTOOFF	3L
#define _MODEFON	4L
#define _MODEFONTOHI	5L
#define _MODEFHITOOFF	6L
#define _MODEFHITOON	7L
#define _MODEFHI	8L

/* mono mode 7 (_TEXTMONO) color values: */
#define _MODE7OFF	0L
#define _MODE7ON	1L
#define _MODE7HI	2L


/* Warning:  these '_xy' entrypoints are undocumented.
   They may or may not be supported in future versions. */
struct xycoord _far _cdecl _moveto_xy(struct xycoord);
short _far _cdecl _lineto_xy(struct xycoord);
short _far _cdecl _rectangle_xy(short,struct xycoord,struct xycoord);
short _far _cdecl _arc_xy(struct xycoord, struct xycoord, struct xycoord, struct xycoord);
short _far _cdecl _ellipse_xy(short, struct xycoord, struct xycoord);
short _far _cdecl _pie_xy(short, struct xycoord, struct xycoord, struct xycoord, struct xycoord);
short _far _cdecl _getpixel_xy(struct xycoord);
short _far _cdecl _setpixel_xy(struct xycoord);
short _far _cdecl _floodfill_xy(struct xycoord, short);
void _far _cdecl _getimage_xy(struct xycoord,struct xycoord, char _huge *);
long _far _cdecl _imagesize_xy(struct xycoord,struct xycoord);
void _far _cdecl _putimage_xy(struct xycoord, char _huge *, short);


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
short _far _cdecl _setwindow(short,double,double,double,double);

/* convert from view to window coordinates */
struct _wxycoord _far _cdecl _getwindowcoord(short,short);
struct _wxycoord _far _cdecl _getwindowcoord_xy(struct xycoord);

/* convert from window to view coordinates */
struct xycoord _far _cdecl _getviewcoord_w(double,double);
struct xycoord _far _cdecl _getviewcoord_wxy(const struct _wxycoord _far *);

/*	return the window coordinates of the current graphics output
	position as an _wxycoord structure. no error return. */
struct _wxycoord _far _cdecl _getcurrentposition_w(void);


/* window coordinate entry points for graphics output routines */

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _arc_w(double, double, double, double, double, double, double, double);
short _far _cdecl _arc_wxy(const struct _wxycoord _far *, const struct _wxycoord _far *, const struct _wxycoord _far *, const struct _wxycoord _far *);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _ellipse_w(short, double, double, double, double);
short _far _cdecl _ellipse_wxy(short, const struct _wxycoord _far *, const struct _wxycoord _far *);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _floodfill_w(double, double, short);

/*	returns pixel value at given point; -1 if unsuccessful. */
short _far _cdecl _getpixel_w(double, double);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _lineto_w(double, double);

/*	returns the view coordinates of the previous output
	position as an _xycoord structure. no error return */
struct _wxycoord _far _cdecl _moveto_w(double, double);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _pie_w(short, double, double, double, double, double, double, double, double);
short _far _cdecl _pie_wxy(short, const struct _wxycoord _far *, const struct _wxycoord _far *, const struct _wxycoord _far *, const struct _wxycoord _far *);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _rectangle_w(short, double, double, double, double);
short _far _cdecl _rectangle_wxy(short, const struct _wxycoord _far *, const struct _wxycoord _far *);

/*	returns nonzero if successful; otherwise 0	*/
short _far _cdecl _polygon_w(short, const double _far *, short);
short _far _cdecl _polygon_wxy(short, const struct _wxycoord _far *, short);

/*	returns previous color; -1 if unsuccessful */
short _far _cdecl _setpixel_w(double, double);


/* window coordinate image routines */

/*	no return value */
void _far _cdecl _getimage_w(double, double, double, double, char _huge *);
void _far _cdecl _getimage_wxy(const struct _wxycoord _far *, const struct _wxycoord _far *, char _huge *);

/*	returns the image's storage size in bytes */
long _far _cdecl _imagesize_w(double, double, double, double);
long _far _cdecl _imagesize_wxy(const struct _wxycoord _far *, const struct _wxycoord _far *);

/*	no return value */
void _far _cdecl _putimage_w(double, double ,char _huge * ,short);


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
short	_far _cdecl	_registerfonts( const unsigned char _far *);
void	_far _cdecl	_unregisterfonts( void );
short	_far _cdecl	_setfont( const unsigned char _far * );
short	_far _cdecl	_getfontinfo( struct _fontinfo _far * );
void	_far _cdecl	_outgtext( const unsigned char _far * );
short	_far _cdecl	_getgtextextent( const unsigned char _far * );
struct xycoord _far _cdecl _setgtextvector( short, short );
struct xycoord _far _cdecl _getgtextvector(void);

/* restore default packing */
#pragma pack()
