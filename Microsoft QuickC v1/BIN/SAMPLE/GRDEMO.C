/*
	GRDEMO.C - Demonstrates capabilities of the QuickC graphics library

	Since this program uses functions not found in the QuickC core
	library or the graphics library, you must use a program list to
	compile in memory. Select Set Program List from the File menu
	and enter GRDEMO as the program list name. Then specify GRDEMO
	as the only entry in the program list.

	An alternative is to create a quick library containing the routines
	used in GRDEMO. Use the following lines to build the quick library
	and load it into QuickC:

		QLIB /s grdemo.c
		QC /l grdemo.qlb grdemo
 */

#include <graph.h>
#include <string.h>
#include <math.h>
#include <bios.h>

/* Functions - prototypes and macros */

/* Demo	functions */

void circles(void);		/* Demo	selections */
void sphere(void);
int polygons(void);
int spiral(int,	int);
int inspiral(int, int, int);
void adjust(void);

int menu(int, int, char* []);	/* Menus */
void box(int, int, int,	int);
void itemize(int, int, char*, int);

int nextatrib(int);             /* Color changes */
void nextcolor(void);

/* Turtle graphics routines */

	/* Initiate and	set defaults */
short setturtle(short);
void home(void);

	/* Control pen and color */
int pendown(int);
short fillstate(short);
short penatrib(short);
short borderatrib(short);

	/* Control angle */
short turn(short);
short turnto(short);

	/* Turtle movement */
short move(short);
short moveto(short, short);
short poly(short, short);

	/* Figures (defined as macros) */

/* Puts a circle with radius <r> at current location.
   Returns nonzero if successful. */
#define circle(r) _ellipse(tc.isFill, \
	tc.xCur-(r), adj(tc.yCur-(r)), tc.xCur+(r), adj(tc.yCur+(r)))

/* Puts an ellipse with width <w> and height <h> at current location.
   Returns nonzero if successful. */
#define ellipse(w,h) _ellipse(tc.isFill, tc.xCur-((w)/2), \
	adj(tc.yCur-((h)/2)), tc.xCur+((w)/2), adj(tc.yCur+((h)/2)))

	/* Miscellaneous */

/* Fills starting at the current location.
   Returns nonzero if successful. */
#define fillin() _floodfill(tc.xCur, adj(tc.yCur),tc.border)

/* Returns nonzero if the current location is onscreen. */
#define onscreen() (!((tc.xCur < -xMAX) || (tc.xCur > xMAX) || \
			  (tc.yCur < -yMAX) || (tc.yCur > yMAX)))

/* Returns a long int mixed from red <r>, green <g>, and blue <b> bytes. */
#define RGB(r,g,b) (((long) ((b) << 8 | (g)) << 8) | (r))

short adj(short);
unsigned cursor(unsigned);

/* Constants */

#define	xMAX	(tc.xCnt / 2)
#define	yMAX	(tc.yCnt / 2)
#define	CIRCUMFERENCE	    360
#define HALFCIRCUMFERENCE   180

#define	PI	3.141593
#define	DEFAULT	-1
#define	TRUE	1
#define	FALSE	0
#define	NULL	0
#define TCURSOROFF  0x2020
#define LASTATR 15
#define NLASTATR 14

/* Scan codes */

#define	UP	72
#define	DOWN	80
#define	LEFT	75
#define	RIGHT	77
#define	ENTER	28

/* Structures for configuration	and other data */
struct videoconfig vc;

struct {
	long	xUnits,	yUnits;
	short	xCnt, yCnt;
	short   xCur, yCur;
	short	angle;
	short   border;
	short   numAtribs;
	short   numColors;
	short   atrib;
	short   isPen;
	short   isFill;
} tc = { 125, 90 };     /* Initial values for aspect.
			   Change to adjust for your screen. */

/* Initial and work arrays for remapable colors. */

long iColors[] = {
	_BLACK,         _BLUE,          _GREEN,         _CYAN,
	_RED,           _MAGENTA,       _BROWN,         _WHITE,
	_GRAY,          _LIGHTBLUE,     _LIGHTGREEN,    _LIGHTCYAN,
	_LIGHTRED,      _LIGHTMAGENTA,  _LIGHTYELLOW,   _BRIGHTWHITE };

long wColors[256];

/* Array and enum for main menu */

char *mnuMain[]	= {
        "Quit",
        "Circles",
        "Sphere",
        "Tunnel",
        "Spiral",
        "Inverted Spiral",
        "Adjust Aspect",
        "Change Mode",
	NULL };

enum { QUIT, CIRCLES, SPHERE, TUNNEL, SPIRAL, INSPIRAL,	ADJUST,	CHANGE };

/* Arrays for video modes */

char *mnuModes[] = {
        "MRES4COLOR ",
        "MRESNOCOLOR",
        "HRESBW",
        "MRES16COLOR",
        "HRES16COLOR",
        "ERESCOLOR",
        "VRES2COLOR",
        "VRES16COLOR",
        "MRES256COLOR",
	NULL };

/* Array for modes */
int modes[] = {
	_MRES4COLOR,
	_MRESNOCOLOR,
	_HRESBW,
	_MRES16COLOR,
	_HRES16COLOR,
	_ERESCOLOR,
	_VRES2COLOR,
	_VRES16COLOR,
	_MRES256COLOR,
	_ERESNOCOLOR,
	DEFAULT	};

/* Structure for menu attributes (variables for color and monochrome) */
struct mnuAtr {
	int	fgNormal, fgSelect, fgBorder;
	long	bgNormal, bgSelect, bgBorder;
	int	centered;
	char	nw[2], ne[2], se[2], sw[2], ns[2], ew[2];
} menus	= {
	0, 15, 4,
	3, 4, 3,
	TRUE,
        "\xda", "\xbf", "\xd9", "\xc0", "\xb3", "\xc4"
};

struct mnuAtr bwmenus =	{
	0x70, 0xf, 0x70,
	0x7, 0x70, 0x7,
	TRUE,
        "\xda", "\xbf", "\xd9", "\xc0", "\xb3", "\xc4"
};
char mess1[] = {
        "Graphics Demonstration Program" } ;
char mess2[] = {
        "Move to menu selection with cursor keys, press ENTER to select" };
int lmess1 = sizeof(mess1), lmess2 = sizeof(mess2);

main ()
{
	int choice, crow, ccol;
	int tmode, vmode;

	_getvideoconfig(&vc);
	crow = vc.numtextrows /	2;
	ccol = vc.numtextcols /	2;

	/* Select best text and	graphics modes and adjust menus	*/

	switch (vc.adapter) {
		case _MDPA :
			puts("No graphics mode available.\n");
			exit(0);
		case _CGA :
			mnuModes[3] = NULL;
			vmode =	_MRES4COLOR;
			break;
		case _EGA :
			mnuModes[6] = NULL;
			if (vc.memory > 64)
				vmode = _ERESCOLOR;
			else
				vmode = _HRES16COLOR;
			break;
		case _VGA :
		case _MCGA :
			vmode =	_MRES256COLOR;
			break;
	}
	switch (vc.mode) {
		case _TEXTBW80 :
			menus =	bwmenus;
		case _TEXTBW40 :
			_setvideomode(_TEXTBW80);
			break;
		case _TEXTC40 :
			tmode =	_TEXTC80;
			break;
		case _TEXTMONO :
		case _ERESNOCOLOR :
			menus =	bwmenus;
			tmode =	_TEXTMONO;
			vmode =	_ERESNOCOLOR;
			mnuMain[7] = NULL;
			break;
		default	:
			tmode =	_TEXTC80;
	}

	_setvideomode(tmode);
	srand(time(0L));

	_settextposition(1,40 -	(lmess1	/ 2));
	_outtext(mess1);
	_settextposition(2,40 -	(lmess2	/ 2));
	_outtext(mess2);

	/* Select and branch to	menu choices */

	for (;;) {
		choice = menu(crow,ccol,mnuMain);
		setturtle(vmode);

		switch (choice) {
			case QUIT :
				_setvideomode (_DEFAULTMODE); exit(0);
			case CIRCLES :
				circles(); break;
			case SPHERE :
				sphere(); break;
			case TUNNEL :
				nextatrib(0);
				pendown(FALSE);
				moveto(-xMAX * .3, yMAX	* .3);
				turn(35);
				pendown(TRUE);
				polygons();
				while (!kbhit())
					nextcolor();
				break;
			case SPIRAL :
				nextatrib(0);
				spiral((rand() % 50) + 30, (rand() % 4)	+ 1);
				while (!kbhit())
					nextcolor();
				break;
			case INSPIRAL :
				nextatrib(0);
				inspiral((rand() % 12) + 8, (rand() %20) + 2,
					(rand() % 30) + 1);
				while (!kbhit())
					nextcolor();
				break;
			case ADJUST :
				adjust();
				_setvideomode(tmode);
				continue;
			case CHANGE :
				for (;;) {
					_setvideomode (tmode);
					vmode =	modes[menu(crow,ccol,mnuModes)];
					if (!setturtle(vmode)) {
						_settextposition(1,22);
						_outtext("Mode not available on this machine.\n");
					} else
						break;
				}
				_setvideomode (tmode);
				continue;
		}
		_bios_keybrd(_KEYBRD_READ);
		_setvideomode (tmode);
	}
}

/* Put circles of varying sizes	and colors on screen in	a round	pattern	*/

void circles()
{
	int i, x, y;
	long tb;

	tb = _getbkcolor();
	if ((vc.mode < _HRESBW) || (vc.numcolors == 2))
		fillstate(FALSE);
	else {
		fillstate(TRUE);
		_setbkcolor(_BRIGHTWHITE);
	}
	pendown(FALSE);
	for (;;) {
		if (vc.numcolors <= 4)
			nextcolor();
		for (i = 5; i <= 150; ++i) {	/* Draw	circles	*/
			x = (xMAX-30) *	atan(sin(i / PI));
			y = (yMAX-30) *	atan(cos(i / PI));
			penatrib(nextatrib(DEFAULT));
			moveto(x,y);
			circle (i % 30);
			if (kbhit()) {
				_setbkcolor(tb);
				pendown(TRUE);
				return;
			}
		}
	}
}

/* Draw	and fill sphere; rotate	colors in EGA modes;
   change palette in CGA modes */

void sphere()
{
	int i, ix, x, y, border, inc;

	y = x = tc.yCnt * 0.9;
	fillstate(FALSE);
	nextatrib(0);
	inc = y / 14;
	border = penatrib(DEFAULT);
	borderatrib(border);
	for (ix = inc; ix <= x; ix += (inc * 2))        /* Draw circles */
		ellipse(ix, y);
	fillstate(TRUE);
	pendown(FALSE);
	turn(90);
	x /= 2;
	moveto(-x + inc,0);
	while (tc.xCur <= (x - inc)) {                  /* Fill circles */
		penatrib(nextatrib(DEFAULT));
		fillin();
		move(inc);
	}
	while (!kbhit())                                /* Rotate colors */
		nextcolor();
	pendown(TRUE);
}

/* Draw	polygons of increasing size by incrementing the	number of sides.
   Return 1 for user interrupt, 0 for edge of screen encountered. */

int polygons()
{
	int sides = 3, size = 2, atrib = 1;
	for (;;) {
		penatrib(nextatrib(atrib++ % NLASTATR));
		if (!poly(sides++,size++))
			return(0);
		if (kbhit())
			return(1);
	}
}

/* Draw	a spiral by increasing each side of a rotating figure.
	<angle> determines tightness.
	<inc> determines size.
   Return 1 for user interrupt, 0 for edge of screen encountered. */

int spiral(angle, inc)
int angle, inc;
{
	int side = 1, atrib = 1;

	for (;;) {
		penatrib(nextatrib(atrib++ % NLASTATR));
		if (!move(side += inc))
			return(0);
		turn(angle);
		if (kbhit())
			return(1);
	}
}

/* Draw	an inverted spiral by increasing each angle of a rotating figure.
	<side> determines size.
	<angle> determines shape.
	<inc> determines tightness and shape.
   Return 1 for user interrupt, 0 for edge of screen encountered. */

int inspiral(side, angle, inc)
int side, angle, inc;
{
	int atrib = 1;

	for (;;) {
		penatrib(nextatrib(atrib++ % NLASTATR));
		if (!move(side))
			return(0);
		turn(angle += inc);
		if (kbhit())
			return(1);
	}
}

/* Draw	an adjustable circle to	enable the user	to visually adjust the
   screen aspect. */

void adjust()
{
	int i, y, pen, radius = yMAX * .6;
	char buffer[3];

	pen = penatrib(DEFAULT);
	_outtext("Modify initial structure\nvalues in program");
	_outtext("\n\nAdjust with cursor keys: ");
	_outtext("\n UP - adjust up");
	_outtext("\n DOWN - adjust down");
	_outtext("\n ENTER - finished\n\n");
	_outtext("xUnits   125\n");
	for (;;) {
		y = tc.yUnits;
		penatrib(pen);
		home();
		pendown(FALSE);	    /* Draw white circle with cross. */
		moveto(75,0);
		circle(radius);
		for (i = 1; i <= 4; i++) {
			pendown(TRUE);
			move(radius);
			turn(180);
			pendown(FALSE);
			move(radius);
			turn(90);
		}

		_settextposition(11,1); /* Show units and adjust */
		_outtext("yUnits   ");
		 ltoa(tc.yUnits,buffer,10);
		_outtext(buffer);
		_outtext(" ");
		switch ((_bios_keybrd(_KEYBRD_READ) & 0xff00) >> 8) {
			case UP	:
				--y;
				break;
			case DOWN :
				++y;
				break;
			case ENTER :
				tc.yUnits = y;
				return;
		}
		penatrib(0);            /* Erase circle with black */
		moveto(75,0);
		circle(radius);
		for (i = 1; i <= 4; i++) {
			pendown(TRUE);
			move(radius);
			turn(180);
			pendown(FALSE);
			move(radius);
			turn(90);
		}
		tc.yUnits = y;
	}
}

/* Put menu on screen.
	Starting <row> and <column>.
	Array of menu <items> strings.
	Global structure variable <menus> determines:
		Colors of border, normal items,	and selected item.
		Centered or left justfied.
		Border characters.
   Returns number of item selected. */

int menu(row, col, items)
int row, col;
char *items[];
{
	int i, num, max	= 2, prev, curr	= 0, choice;
	int litem[25];
	long bcolor;

	cursor(TCURSOROFF);
	bcolor = _getbkcolor();

	/* Count items,	find longest, and put length of	each in	array */

	for (num = 0; items[num]; num++) {
		litem[num] = strlen(items[num]);
		max = (litem[num] > max) ? litem[num] :	max;
	}
	max += 2;

	if (menus.centered) {
		row -= num / 2;
		col -= max / 2;
	}

	/* Draw	menu box */

	_settextcolor(menus.fgBorder);
	_setbkcolor(menus.bgBorder);
	box(row++,col++,num,max);

	/* Put items in	menu */

	for (i = 0; i <	num; ++i) {
		if (i == curr) {
			_settextcolor(menus.fgSelect);
			_setbkcolor(menus.bgSelect);
		} else {
			_settextcolor(menus.fgNormal);
			_setbkcolor(menus.bgNormal);
		}
		itemize(row+i,col,items[i],max - litem[i]);
	}

	/* Get selection */

	for (;;) {
		switch ((_bios_keybrd(_KEYBRD_READ) & 0xff00) >> 8) {
			case UP	:
				prev = curr;
				curr = (curr > 0) ? (--curr % num) : num-1;
				break;
			case DOWN :
				prev = curr;
				curr = (curr < num) ? (++curr %	num) : 0;
				break;
			case ENTER :
				_setbkcolor(bcolor);
				return(curr);
			default	:
				continue;
		}
		_settextcolor(menus.fgSelect);
		_setbkcolor(menus.bgSelect);
		itemize(row+curr,col,items[curr],max - litem[curr]);
		_settextcolor(menus.fgNormal);
		_setbkcolor(menus.bgNormal);
		itemize(row+prev,col,items[prev],max - litem[prev]);
	}
}

/* Draw	menu box.
	<row> and <col> are upper left of box.
	<hi> and <wid> are height and width. */

void box(row, col, hi, wid)
int row, col, hi, wid;
{
	int i;
	char temp[80];

	_settextposition(row,col);
	temp[0] = *menus.nw;
	memset(temp+1,*menus.ew,wid);
	temp[wid+1] = *menus.ne;
	temp[wid+2] = NULL;
	_outtext(temp);
	for (i = 1; i <= hi; ++i) {
		_settextposition(row+i,col);
		_outtext(menus.ns);
		_settextposition(row+i,col+wid+1);
		_outtext(menus.ns);
	}
	_settextposition(row+hi+1,col);
	temp[0] = *menus.sw;
	memset(temp+1,*menus.ew,wid);
	temp[wid+1] = *menus.se;
	temp[wid+2] = NULL;
	_outtext(temp);
}

/* Put an item in menu.
	<row> and <col> are left position.
	<str> is the string item.
	<len> is the number of blanks to fill. */

void itemize(row,col,str,len)
int row, col, len;
char str[];
{
	char temp[80];

	_settextposition(row,col);
	_outtext(" ");
	_outtext(str);
	memset(temp,' ',len--);
	temp[len] = NULL;
	_outtext(temp);
}

/* Rotate to next color attribute.
	<init> initializes new starting color.
	(specify DEFAULT to rotate to next color)
   Return rotated color attribute. */

int nextatrib(init)
int init;
{
	static int atr;

	if (vc.numcolors == 2)
		return(atr = !atr);
	if (!(init == DEFAULT))
		atr = init;
	return(atr = (atr % (tc.numAtribs-1) + 1));
}

/* Rotate to next palette array for EGA and higher.
   Rotate palette for CGA color. */

void nextcolor(void)
{
	static int co = 0;
	int w, i;

	if ((--co < 0) || (co >= tc.numColors - 1))
		co = tc.numColors - 1;
	w = co;
	if (vc.adapter > _CGA) {
		for (i = LASTATR-1; i > 0; --i) {
			_remappalette(i, wColors[w]);
			if (--w < 0)
				w = tc.numColors - 1;
		}
	}
}

/* Set the display mode and establish turtle defaults.
	<mode> is the mode to set.
   Returns 0 if	mode is	invalid, else returns nonzero. */

short setturtle(mode)
short mode;
{
	int ret, i = 0, btm, top = 63, inc, red = 0, green = 0, blue = 0;
	float ratio;

	_getvideoconfig(&vc);
	if (mode < _MRES4COLOR)
		return(0);
	if (!(mode == vc.mode))	{
		if(!(ret = _setvideomode(mode)))
			return(0);
		_getvideoconfig(&vc);
	} else
		ret = mode;

	home();
	switch (vc.mode) {              /* Set palette defaults */
		case _MRES256COLOR :
			tc.numColors = tc.numAtribs = 125;
			inc = btm = 12;
			break;
		case _ERESCOLOR :
		case _VRES16COLOR :
		/* For full 64 color palette, btm = 0; tc.numColors = 64 */
			inc = btm = 16; tc.numColors = 27;
			break;
		case _MRES4COLOR :
		case _MRESNOCOLOR :
			inc = 32; btm = 0; tc.numColors = 8;
			break;
		default:
			tc.numColors = 16;
			memcpy(wColors,iColors,16 * sizeof(iColors[0]));
			_remapallpalette(iColors);
			return(ret);
	}

	/* Fill palette arrays */
	for (blue = btm; blue <= top; blue += inc)
		for (green = btm; green <= top; green += inc)
			for (red = btm; red <= top; red += inc)
				wColors[i++] = RGB(red, green, blue);
	nextcolor();
	return(ret);
}

/* Sets	initial	turtle parameters. Use to reset	without	changing mode. */

void home()
{
	float ratio;

	if (vc.mode == _MRES256COLOR)
		tc.numAtribs = 125;
	else
		tc.numAtribs = vc.numcolors;
	tc.xCnt = vc.numxpixels;
	tc.yCnt = vc.numypixels;
	_setlogorg(tc.xCnt / 2, tc.yCnt / 2);

	ratio = (float)(tc.xUnits * tc.yCnt) / (tc.yUnits * tc.xCnt);
	tc.yCnt /= ratio;

	tc.xCur = 0;
	tc.yCur = 0;
	tc.isPen = 1;
	_moveto(0, 0);
	tc.angle = 0;
	_remappalette(LASTATR,_BRIGHTWHITE);
	borderatrib(LASTATR);
	penatrib(LASTATR);
	fillstate(_GBORDER);
}

/* Makes the turtle pen	used in	move() and moveto() visible or invisible.
	<state> can be TRUE (visible), FALSE (invisible),
	or DEFAULT (return current)
   Returns current state. */

int pendown(state)
int state;
{
	switch (state) {
		case TRUE:
			tc.isPen = TRUE;
			break;
		case FALSE:
			tc.isPen = FALSE;
	}
	return(tc.isPen);
}

/* Determines whether figures should be filled.
	<state> can be TRUE (fill), FALSE (border only),
	or DEFAULT (return current)
   Returns current state. */

short fillstate(state)
short state;
{
	switch (state) {
		case _GBORDER:
		case FALSE:
			tc.isFill = _GBORDER;
			break;
		case _GFILLINTERIOR:
		case TRUE:
			tc.isFill = _GFILLINTERIOR;
	}
	return(tc.isFill);
}

/* Sets the color attribute of the pen.
	<atrib> is new atribute (use DEFAULT to get current).
   Returns current color attribute. */

short penatrib(atrib)
short atrib;
{
	if (!(atrib == DEFAULT)) {
		_setcolor(tc.atrib = atrib);
	}
	return(tc.atrib);
}

/* Sets the color attribute to be used as a boundary in fills.
	<border> is new border (use DEFAULT to get current).
   Returns border attribute. */

short borderatrib(border)
short border;
{
	if (!(border ==	DEFAULT))
			tc.border = border;
	return(tc.border);
}

/* Sets a new turtle <angle> relative to the current angle.
   Returns the new angle. */

short turn(angle)
short angle;
{
	return(tc.angle	= ((tc.angle + angle) %	CIRCUMFERENCE));
}

/* Sets a specified turtle <angle>.
   Returns the new angle. */

short turnto(angle)
short angle;
{
	return(tc.angle	= (angle % CIRCUMFERENCE));
}

/* Moves from the current position in the current direction. A line is
   drawn if the	pen is down. The current position is reset.
	<distance> is the adjusted length of line.
   Returns 0 if	the new	position is off	the screen. */

short move(distance)
short distance;
{
	short dX, dY, ret;
	double workangle;

	workangle = (tc.angle -	90) * PI / HALFCIRCUMFERENCE;
	dX = distance *	cos(workangle);
	dY = distance *	sin(workangle);
	if (tc.isPen)
		_lineto(tc.xCur + dX, adj(tc.yCur + dY));
	else
		_moveto(tc.xCur + dX, adj(tc.yCur + dY));
	tc.xCur += dX;
	tc.yCur += dY;
	return(onscreen());
}

/* Moves from the current position to a	specified position. A line is
   drawn if the	pen is down. The current position is reset.
	<x> and <y> are destination coordinates.
   Returns 0 if new position is off screen. */

short moveto(x,	y)
short x, y;
{
	if (tc.isPen)
		_lineto(x, adj(y));
	else
		_moveto(x, adj(y));
	tc.xCur = x;
	tc.yCur = y;
	return(onscreen());
}

/* Draws a polygon
	<number> specifies how many sides.
	<side> specifies the length of each side.
   Returns 0 if any part of polygon is off screen. */

short poly(number,side)
short number, side;
{
	int i, ret = 1;
	double angle;

	angle =	360 / number;
	for (i = 1; i <= number; ++i) {
		ret = move(side) && ret;
		turn(angle);
	}
	return(ret);
}

/* Adjusts a specified <y> value for screen aspect.
   Returns the new value. */

short adj(y)
short y;
{
	if (y)
		y = (y * (tc.xUnits*vc.numypixels)) / (tc.yUnits*vc.numxpixels);
	return(y);
}

/* Change the cursor shape.
	<value> has starting line in upper byte, ending line in lower byte.
   Returns the previous	cursor value. */

unsigned cursor(value)
unsigned value;
{
	union REGS inregs, outregs;
	int ret;

	inregs.h.ah = 3;	/* Get old cursor */
	inregs.h.bh = 0;
	int86(0x10,&inregs,&outregs);
	ret = outregs.x.cx;

	inregs.h.ah = 1;	/* Set new cursor */
	inregs.x.cx = value;
	int86(0x10,&inregs,&outregs);

	return(ret);
}

