/***
*pgchart.h - Declare constants, functions and macros for charting library.
*
*  Copyright (c) 1988-1990, Microsoft Corporation, All rights reserved.
*
*Purpose:
*  This file declares the presentation graphics library functions and
*  the structures and manifest constants that are used with them.
*
***************************************************************************/

/* Force word alignment to avoid possible -Zp override */
#pragma	pack(2)

/* Required for the missing value definition */
#ifndef	FLT_MAX
#define FLT_MAX			3.402823466e+38F	/* max value */
#endif

#define _PG_PALETTELEN		16	/* Number of entries in internal palette */
#define _PG_MAXCHARTTYPE	5	/* Maximum available chart type */
#define _PG_MAXCHARTSTYLE	2	/* Maximum chart style */
#define _PG_TITLELEN		70	/* Maximum title text length */

#define _PG_LEFT		1	/* Positions used for titles and legends */
#define _PG_CENTER		2
#define _PG_RIGHT		3
#define _PG_BOTTOM		4
#define _PG_OVERLAY		5

#define _PG_LINEARAXIS		1	/* Used to specify axis types */
#define _PG_LOGAXIS		2

#define _PG_DECFORMAT		1	/* Used to specify tic mark label format */
#define _PG_EXPFORMAT		2

#define _PG_BARCHART		1	/* Charttype for a bar chart */
#define _PG_COLUMNCHART		2	/* Charttype for a column chart */
#define  _PG_PLAINBARS		1	/* Styles for bar and column charts */
#define  _PG_STACKEDBARS	2

#define _PG_LINECHART		3	/* Charttype for a line chart */
#define _PG_SCATTERCHART	4	/* Charttype for a scatter chart */
#define _PG_POINTANDLINE	1	/* Styles for line and scatter charts */
#define _PG_POINTONLY		2

#define _PG_PIECHART		5	/* Charttype for pie chart */
#define _PG_PERCENT		1	/* Styles for pie charts */
#define _PG_NOPERCENT		2

#define _PG_MISSINGVALUE	(-FLT_MAX)  /* Indicates missing data values */

/* Error codes	*/

/* Numbers greater than 100 will terminate chart routine, others will cause
 * default values to be used
 */
#define	_PG_NOTINITIALIZED	102	/* If library not initialized */
#define	_PG_BADSCREENMODE	103	/* Graphics mode not set before charting */
#define	_PG_BADCHARTSTYLE	04	/* Chart style invalid */
#define	_PG_BADCHARTTYPE	104	/* Chart type invalid */
#define	_PG_BADLEGENDWINDOW	105	/* Invalid legend window specified */
#define	_PG_BADCHARTWINDOW	07	/* x1=x2 or y1=y2 in chart window spec. */
#define	_PG_BADDATAWINDOW	107	/* If chart window is too small */
#define	_PG_NOMEMORY		108	/* Not enough memory for data arrays */
#define	_PG_BADLOGBASE		05	/* Log base <= 0 */
#define	_PG_BADSCALEFACTOR	06	/* Scale factor = 0 */
#define	_PG_TOOSMALLN		109	/* Number of data points <= 0 */
#define	_PG_TOOFEWSERIES	110	/* Number of series <= 0 */

/* Typedefs	*/

/* Typedef for chart title */
#ifndef _TITLETYPE_DEFINED
typedef	struct	{
	char	title[_PG_TITLELEN];	/* Title text */
	short	titlecolor;		/* Internal palette color for title text */
	short	justify;		/* _PG_LEFT, _PG_CENTER, _PG_RIGHT */
} titletype;
#define _TITLETYPE_DEFINED
#endif

/* Typedef for chart axes */
#ifndef _AXISTYPE_DEFINED
typedef	struct	{
	short		grid;		/* TRUE=grid lines drawn; FALSE no lines */
	short		gridstyle;	/* Style number from style pool for grid lines */
	titletype	axistitle;	/* Title definition for axis */
	short		axiscolor;	/* Color for axis */
	short		labeled;	/* TRUE=tic marks and titles drawn */
	short		rangetype;	/* _PG_LINEARAXIS, _PG_LOGAXIS */
	float		logbase;	/* Base used if log axis */
	short		autoscale;	/* TRUE=next 7 values calculated by system */
	float		scalemin;	/* Minimum value of scale */
	float		scalemax;	/* Maximum value of scale */
	float		scalefactor;	/* Scale factor for data on this axis */
	titletype	scaletitle;	/* Title definition for scaling factor */
	float		ticinterval;	/* Distance between tic marks (world coord.) */
	short		ticformat;	/* _PG_EXPFORMAT or _PG_DECFORMAT for tic labels */
	short		ticdecimals;	/* Number of decimals for tic labels (max=9)*/
} axistype;
#define _AXISTYPE_DEFINED
#endif

/* Typedef used for defining chart and data windows */
#ifndef _WINDOWTYPE_DEFINED
typedef	struct	{
	short		x1;		/* Left edge of window in pixels */
	short		y1;		/* Top edge of window in pixels */
	short		x2;		/* Right edge of window in pixels */
	short		y2;		/* Bottom edge of window in pixels */
	short		border;		/* TRUE for border, FALSE otherwise */
	short		background;	/* Internal palette color for window bgnd */
	short		borderstyle;	/* Style bytes for window border */
	short		bordercolor;	/* Internal palette color for window border */
} windowtype;
#define _WINDOWTYPE_DEFINED
#endif

/* Typedef for legend definition */
#ifndef _LEGENDTYPE_DEFINED
typedef struct	{
	short		legend;		/* TRUE=draw legend; FALSE=no legend */
	short		place;		/* _PG_RIGHT, _PG_BOTTOM, _PG_OVERLAY */
	short		textcolor;	/* Internal palette color for text */
	short		autosize;	/* TRUE=system calculates size */
	windowtype	legendwindow;	/* Window definition for legend */
} legendtype;
#define _LEGENDTYPE_DEFINED
#endif

/* Typedef for legend definition */
#ifndef _CHARTENV_DEFINED
typedef struct	{
	short		charttype;	/* _PG_BAR, _PG_COLUMN, _PG_LINE, _PG_SCATTER, _PG_PIE */
	short		chartstyle;	/* Style for selected chart type */
	windowtype	chartwindow;	/* Window definition for overall chart */
	windowtype	datawindow;	/* Window definition for data part of chart */
	titletype	maintitle;	/* Main chart title */
	titletype	subtitle;	/* Chart sub-title */
	axistype	xaxis;		/* Definition for X-axis */
	axistype	yaxis;		/* Definition for Y-axis */
	legendtype	legend;		/* Definition for legend */
} chartenv;
#define _CHARTENV_DEFINED
#endif

/* Typedef for character bitmap */
#ifndef _CHARMAP_DEFINED
typedef unsigned char charmap[8];
#define _CHARMAP_DEFINED
#endif

/* Typedef for pattern bitmap */
#ifndef _FILLMAP_DEFINED
typedef unsigned char fillmap[8];
#define _FILLMAP_DEFINED
#endif

/* Typedef for palette entry definition */
#ifndef _PALETTEENTRY_DEFINED
typedef struct {
	unsigned short	color;
	unsigned short	style;
	fillmap		fill;
	char		plotchar;
} paletteentry;
#define _PALETTEENTRY_DEFINED
#endif

/* Typedef for palette definition */
#ifndef _PALETTETYPE_DEFINED
typedef paletteentry palettetype[_PG_PALETTELEN];
#define _PALETTETYPE_DEFINED
#endif

/* Typedef for style sets */
#ifndef _STYLESET_DEFINED
typedef unsigned short styleset[_PG_PALETTELEN];
#define _STYLESET_DEFINED
#endif

/* Function prototypes for charting routines	*/

short _far _cdecl _pg_initchart(void);
short _far _cdecl _pg_defaultchart(chartenv _far *, short, short);

short _far _cdecl _pg_chart(chartenv _far *, const char _far * const _far *, const float _far *, short);
short _far _cdecl _pg_chartms(chartenv _far *, const char _far * const _far *, const float _far *, short, short, short, const char _far * const _far *);

short _far _cdecl _pg_chartscatter(chartenv _far *, const float _far *, const float _far *, short);
short _far _cdecl _pg_chartscatterms(chartenv _far *, const float _far *, const float _far *, short, short, short, const char _far * const _far *);

short _far _cdecl _pg_chartpie(chartenv _far *, const char _far * const _far *, const float _far *, const short _far *, short);

/* Function prototypes for support routines	*/

short _far _cdecl _pg_hlabelchart(chartenv _far *, short, short, short, const char _far *);
short _far _cdecl _pg_vlabelchart(chartenv _far *, short, short, short, const char _far *);

short _far _cdecl _pg_analyzechart(chartenv _far *, const char _far * const _far *, const float _far *, short);
short _far _cdecl _pg_analyzechartms(chartenv _far *, const char _far * const _far *, const float _far *, short, short, short, const char _far * const _far *);

short _far _cdecl _pg_analyzescatter(chartenv _far *, const float _far *, const float _far *, short);
short _far _cdecl _pg_analyzescatterms(chartenv _far *, const float _far *, const float _far *, short, short, short, const char _far * const _far *);

short _far _cdecl _pg_analyzepie(chartenv _far *, const char _far * const _far *, const float _far *, const short _far *, short);

short _far _cdecl _pg_getpalette(paletteentry _far *);
short _far _cdecl _pg_setpalette(const paletteentry _far *);
short _far _cdecl _pg_resetpalette(void);

void  _far _cdecl _pg_getstyleset(unsigned short _far *);
void  _far _cdecl _pg_setstyleset(const unsigned short _far *);
void  _far _cdecl _pg_resetstyleset(void);

short _far _cdecl _pg_getchardef(short, unsigned char _far *);
short _far _cdecl _pg_setchardef(short, const unsigned char _far *);

/* Restore default packing */
#pragma pack()
