#include <dos.h> 
#include <conio.h> 
#include <math.h>

#define SQUARE(root) ((root) * (root))
#define ABS(num) (((num) < 0) ? (-num) : (num)) 
#define PI 3.14159265

/* Function prototypes */ 

int  init (int);
void dot ( int, int, int );
int  isqrt ( int );
void circle ( int, int, int, int );
void palette ( int );
void background ( int );

/* Arrays for storing address information for all pixels */ 

unsigned yaddr[200];
unsigned xaddr[640];
char shift[640];
char point[640];

char far *scrn = (char far *)0xB8000000;	/* Screen buffer	*/

int  max_x, max_y, max_clr, shifter, back = 3, pal = 1;

/*
 * Use variables rather than constants for the following 
 * values so we can change them in the debugger
 */

int  aspect = 270, x_wid = 85, y_wid = 78;

main()
{
	int i, x, y, mode = 4, tmode, p = 1, b = 8;

	tmode = getmode();
	init(mode);
	background(b);
	palette(p);
	for (i = 0; i <= 90; ++i) {	/* Draw circles	*/ 
		x = x_wid * atan(sin(i / PI));
		y = y_wid * atan(cos(i / PI));
		circle((max_x / 2) + x,100 + y,i % 40,(i % max_clr) + 1);
	}
	for (i = 0; i <= 90; ++i) {	/* Erase them	*/ 
		x = x_wid * atan(sin(i / PI));
		y = y_wid * atan(cos(i / PI));
		circle((max_x / 2)+x,100+y,i % 40,0);
	}
	init(tmode);	/* Restore original mode	*/
	return(0);
}

int getmode()

{
	union REGS inregs, outregs;

	inregs.h.ah = 0x0F;	/* Use BIOS call to get mode	*/

	inregs.h.al = 0; 
	int86(0x10,&inregs,&outregs);
	if (outregs.h.al == 7) {
		puts("Can't run with monochrome adapter.\a");
		exit(7);
	}
	else
		return(outregs.h.al);
}


int init (num)
int num;
{
	int indx = 0, indx2 = 0;
	unsigned clr_wid, mask;
	union REGS inregs, outregs;

	if (num > 6) {		/* Can't assign EGA modes	*/ 
				/* (they could be added easily)	*/
		puts("Invalid mode.\x07");
		exit(0);
	}
	switch (num) {
	case 4 :                /* Set variables for each mode  */

		max_clr = 3;
		max_x = 320;
		max_y = 200;
		shifter = 4;
		clr_wid = 2;
		break; 
	case 5 : 
		max_clr = 1;
		max_x = 320;
		max_y = 200;
		shifter = 4;
		clr_wid = 2;
		break;
	case 6 : 
		max_clr = 1;
		max_x = 640;
		max_y = 200;
		shifter = 8;
		clr_wid = 1;
		break;
	}
	if (num > 3) {			/* For graphics modes only,     */
		while (indx < max_y) {	/* calculate all y offsets      */ 
			yaddr[indx] = 80 * indx2;
			++indx; 
			yaddr[indx] = (80 * indx2) + 0x2000;
			++indx; 
			++indx2; 
		}
					/* Calculate all x offsets      */ 

		for (indx = 0; indx < max_x; ++indx) {
			mask = 0x80 >> (clr_wid * (indx % shifter));

			if (num != 6) { /* Medium resolution offsets	*/ 

				mask |= (mask >> 1);
				shift[indx] = 6 - (clr_wid * (indx % shifter));
			}
			else            /* High resolution offsets	*/ 

				shift[indx] = 7 - (indx % shifter);
			point[indx] = ~mask;
			xaddr[indx] = indx / shifter;
		}
	}

	inregs.h.ah = 0;	/* Use BIOS call to set mode	*/
	inregs.h.al = num;
	int86(0x10,&inregs,&outregs);
	return(num);
}

/* Draw a dot	*/ 

void dot ( x, y, clr )
int x, y, clr;

{
	unsigned total;
	char tcolor; 

	clr = ABS(clr) & max_clr;       /* Check color boundary */

	total = xaddr[x] + yaddr[y];    /* Put in screen buffer */

	scrn[total] = (clr << shift[x]) | (scrn[total] & point[x]);
}

int isqrt ( arg )      /* Calculate integer square root  */ 
int arg;               /* (real square root is too slow) */


{
	int odd_int, old_arg, first_sqrt; 

	odd_int = 1;          /* Initialize with 1              */

	old_arg = arg;        /* Save argument                  */

	while (arg >= 0) {    /* Find double approximate root   */ 
		arg = arg - odd_int;
		odd_int = odd_int + 2;
	}
	first_sqrt = odd_int >> 1;      /* Divide by two        */


	/* Return adjusted root */ 
	if (SQUARE(first_sqrt) - first_sqrt + 1 > old_arg)
		return(first_sqrt - 1);
	else 
		return(first_sqrt);
}

void circle ( cx, cy, radius, clr )
int cx, cy, radius, clr;

{
	int a, af, b, bf, target, r2, temp;

	clr = ABS(clr) & max_clr;       /* Check color boundary */

	target = 0; 
	a = radius; 
	b = 0; 
	r2 = SQUARE(radius);
	while (a >= b) {                /* Calculate new point  */ 
		b = isqrt(r2 - SQUARE(a));
		temp = target; 
		target = b; 
		b = temp; 

		while (b < target) {    /* Plot point in each   */ 
		                        /* quadrant             */ 
			af = max_x * a / aspect;
			bf = max_x * b / aspect;
			dot(cx + af,cy + b,clr); 
			dot(cx + bf,cy + a,clr);
			dot(cx - af,cy + b,clr); 
			dot(cx - bf,cy + a,clr);
			dot(cx - af,cy - b,clr); 
			dot(cx - bf,cy - a,clr);
			dot(cx + af,cy - b,clr); 
			dot(cx + bf,cy - a,clr);
			b = b + 1;
		}
		a = a - 1;
	}
}

void palette ( color )
int color;

{
	union REGS inregs, outregs;

	color &= 0x01;
	inregs.h.ah = 0x0B;     /* Call BIOS to set palette     */

	inregs.h.bh = 1;
	inregs.h.bl = color; 
	int86(0x10,&inregs,&outregs);
}

void background ( color )
int color;

{
	union REGS inregs, outregs;

	color &= 0x0F; 
	inregs.h.ah = 0x0B;     /* Call BIOS to set background  */

	inregs.h.bh = 0;
	inregs.h.bl = color;
	int86(0x10,&inregs,&outregs);
}         

