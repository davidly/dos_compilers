/* life.c 
 *
 * Game of LIFE demonstration program.
 *
 * This program runs a version of the game LIFE that requires little
 * interaction. Yet user is able to stop the game if desired, and edit
 * the cells on the game grid.
 */
#include <stdio.h>
#include <dos.h>

#define ROWS 21			/* Dimensions of population matrix */
#define COLS 78
#define SCRNSIZE ((ROWS+2)*(COLS+2)*2)

char	mat1[ROWS][COLS];	/* Matrix 1: stores current population */
char	mat2[ROWS][COLS];	/* Matrix 2: stores crowding-numbers */
int	speed;			/* Timing factor (1-10) */
int	cell;			/* Cell character */
int	attrib;			/* Video attribute of each location */
char    far	*videomem;	/* Address of video memory
				     monochrome = b0000, cga = b8000 */
int	adapter;		/* Graphic adapter? cga, ega, mono */
int	more_rounds = 0;	/* Boolean: Continue LIFE? */
int	forever;		/* Boolean: unlimited no. of generations? */
int     pause;                  /* Boolean: pause execution? */
long	repeat; 		/* Maximum number of generations to do */
float	density;		/* Density of random distribution (0.0-100.0) */
char	scrnbuf[SCRNSIZE];   /* Screen Buffer area */

#define BUFLIMIT (scrnbuf + SCRNSIZE)

#define MONO  1                         /* Constant values for adapter */
#define CGA   2                         /*   variable */
#define EGA   3

/* Main function.
 *
 * Determine if command-line argument (an integer) is present.
 * If so, run the number of generations given on the command line.
 * Otherwise, run generations indefinitely.
 */
main(argc, argv)
int	argc;
char	**argv;
{
	long	atol();     /* Alpha string to long int conversion */

	if (argc == 1)                   /* No command-line argument */
		forever = 1;             /* So run forever */
	else
		repeat = atol(argv[1]);  /* Else, run given number */
	init_life();
	do {
		more_rounds = 0;
		init_buf();
		draw_box(attrib);
		init_mats();
		rand_dist(density/100.0);
		pause = 0;
		while (forever || repeat--) {
			proc_key();
			if (!pause) {
				if (speed < 10)
					timer();
				generation();
			} else
				if (pause_screen())
					break;
		}
	} while(more_rounds);
	set_cursor(24,0);
}


/* Initialize LIFE.
 * 
 * Initialize parameters (static variables) used in the game, including
 * background, cell type, population density, and location of video memory.
 */
init_life()
{
	init_adapter();
	switch (adapter) {
	case MONO:  videomem = (char far *) 0xb0000000;
		    speed = 5;
		    break;
	case CGA:   videomem = (char far *) 0xb8000000;
		    speed = 10;
		    break;
	case EGA:   videomem = (char far *) 0xb8000000;
		    speed = 5;
		    break;
	}
	cell = 254;
	attrib = 11;
	density = 40.0;
}

/* Initialize buffer.
 *
 * Initialize the screen buffer array with spaces and the attribute
 * inidicated in the variable attrib.
 */
init_buf()
{
	register char *p = scrnbuf;

	while (p < BUFLIMIT) {	
		*p++ = ' ';
		*p++ = attrib;
	}
}
		

/* Draw box.
 *
 * Clear screen, and then use extended-ascii line characters to
 * draw the frame (box) for the game of life.
 */
draw_box(attrib_val)
int	attrib_val;	/* Foreground/background attribute of box */
{
	char	*p;		/* pointer into screen buffer */
	int	i, incr;

	set_cursor(26,0);
	p = scrnbuf;

/* Draw top of box. */

	*p = 218;
	p += 2;
	for (i = 0; i < COLS; p += 2, i++)
		*p = 196;
	*p = 191;
	p += 2;

/* Draw side of box. */

	for (i = 0; i < ROWS; p += 160, i++) {
		incr = (COLS + 1) * 2;
		*p = 179;
		*(p + incr) = 179;
	}

/* Draw bottom of box. */

	*p = 192;
	p += 2;
	for (i = 0; i < COLS; p += 2, i++)
		*p = 196;
	*p = 217;
	p += 2;

	refresh(scrnbuf, videomem);  /* Copy scrnbuf to video memory */
	draw_prompt_box();
}

/* Draw Prompt Box.
 *
 * Put main prompt sequence at bottom of the screen.
 */
draw_prompt_box()
{
	set_cursor(23,0);
	printf( "Press key to control execution:  ");
	printf( "F=faster  S=slower  P=pause(restart, quit) ");
	set_cursor(26,0);
}

/* Initialize Matrixes.
 *
 * Clear Matrix 1 and Matrix 2, then initialize all the zones
 * (1-9) of Matrix 1.
 *
 * The "zones" are used by the LIFE algorithm to determine method of
 * calculating neighbors. Zones are pertinent to edges and corners:
 *
 *    +-+--------------+-+
 *    |6|      2       |7|
 *    +-+--------------+-+
 *    | |              | |
 *    |4|      1       |5|
 *    | |              | |
 *    +-+--------------+-+
 *    |8|      3       |9|
 *    +-+--------------+-+
 *
 * Zones are recorded in Matrix 1 for ease of computation. If a cell
 * lives, then we add 100 to mark cell's existence.
 */
init_mats()
{
	int i, j;              	    /* Loop counters. */
	char *p = (char *) mat1;    /* Pointer into Matrix 1. */

/* Initialize zones in Matrix 1 */

	clear_mat(mat1, ROWS * COLS);  /* Initialize matrix to all 0's */
	clear_mat(mat2, ROWS * COLS);

	*p++ = 6;                           /* Initilialize row 1 */
	for (i = 0; i < COLS-2; i++)       
		*p++ = 2;
	*p++ = 7;

	for (j = 0; j < ROWS-2; j++) {     /* Initialize center rows */
		*p++ = 4;
		for (i = 0; i < COLS-2; i++)
			*p++ = 1;
		*p++ = 5;
	}

	*p++ = 8;                           /* Initialize bottom row */
	for (i = 0; i < COLS-2; i++)
		*p++ = 3;
	*p++ = 9;

}


/* Random Distribution.
 *
 * Put a random distribution into Matrix 1.
 * Add 100 to each cell that is alive, according to the distribution.
 */
rand_dist(chance)
float	chance;
{
	char	*p;
	char	*bp = (char *) scrnbuf;
	int	rnd;             /* output from rand() */
	int	amt;		 /* Amount to exceed for a cell to live */
	int	i, j;            /* Loop counters */
	long	time();		 /* Grab time for seed of random sequence */

	p = (char *) mat1;
	amt = chance * 32768;
	srand((unsigned) time(0));
	bp += 162;
	for (i = 0; i < ROWS; i++, bp += 4)
		for (j = 0; j < COLS; j++, p++, bp += 2) {
			rnd = rand();
			if (rnd < amt) {
				*p += 100;
				*bp = cell;
				*(bp+1) = attrib;
			}
		}
		
	refresh(scrnbuf, videomem);  /* Put results to the screen */
}

/* Timing mechanism.
 *
 * Use the variable "speed" to determine how long to delay before
 * the next generation of life.
 */
timer()
{
	long	period;     /* Count to this number */
	long	i;          /* Loop variable */
	long    j;          /* Dummy variable, to slow down loop */

	period = (10 - speed);
	period *= period;
	period *= 700;
	for (i = 0; i < period; i++)
		j = i * 2;
}


#define NW  (-1-COLS)            /* Directional constants, within    */
#define N   (-COLS)              /*  Matrix 2. For example, NW refers */
#define NE  (1-COLS)             /*  to the upper, left-hand neighbor */
#define E   (1)
#define SE  (1+COLS)
#define S   (COLS)
#define SW  (-1+COLS)
#define W   (-1)
#define LIMIT ((char *)mat1+ROWS*COLS)

/* Do one generation of life.
 *
 * The algorithm used here first clears all of Matrix 2, calling
 * an assembly routine for maximum speed. Then, Matrix 1 is scanned.
 * Wherever a living cell is found, the CORRESPONDING NEIGHBOR CELLS
 * IN MATRIX 2 are incremented by 1, and the corresponding cell itself
 * is incremented by 100. If no living cell is found, do nothing.
 * This gives us a fast method for determining neighbor count, which is
 * kept track of in Matrix 2.
 *
 * The "zone" of each cell is checked, and used as a guide for determining
 * neighbors. Nothern neighbors of northernmost row are found in the
 * southernmost row, so that the game has a "boundless" effect...formations
 * that move off one side automatically circle around to the other side.
 *
 * Pass 2 is called to determine what actually lives or dies, based on
 * the neighbor-count of each cell.
 */
generation()
{
	register  char *p1;    /* Pointers into mat1, mat2 */
	register  char *p2;
	int	diff;          /* No. of bytes between mat1 & mat2 */
	int	zone;	       /* Which "zone" does cell lie in? */

	clear_mat(mat2, ROWS * COLS);
	diff = (char *) mat2 - (char *) mat1;
	for (p1 = (char *) mat1; p1 < LIMIT; p1++) {
		if (*p1 > 100) {                      /* Is cell alive? */
		    p2 = p1 + diff;            /* P2 is corresponding cell */
		    *p2 += 100;
		    zone = (*p1 - 100);        /* Zone is residue of 100 */
		    switch (zone) {            /* Take action based on zone */
		    case 1:	++*(p2 + NW);
				++*(p2 + N);
				++*(p2 + NE);
				++*(p2 + E);
				++*(p2 + SE);
				++*(p2 + S);
				++*(p2 + SW);
				++*(p2 + W);
				break;
		    case 2:	++*(p2 + (NW + ROWS * COLS));
				++*(p2 + (N + ROWS * COLS));
				++*(p2 + (NE + ROWS * COLS));
				++*(p2 + E);
				++*(p2 + SE);
				++*(p2 + S);
				++*(p2 + SW);
				++*(p2 + W);
				break;
		    case 3:	++*(p2 + NW);
				++*(p2 + N);
				++*(p2 + NE);
				++*(p2 + E);
				++*(p2 + (SE - ROWS * COLS));
				++*(p2 + (S - ROWS * COLS));
				++*(p2 + (SW - ROWS * COLS));
				++*(p2 + W);
				break;
		    case 4:	++*(p2 + (NW + COLS));
				++*(p2 + N);
				++*(p2 + NE);
				++*(p2 + E);
				++*(p2 + SE);
				++*(p2 + S);
				++*(p2 + (SW + COLS));
				++*(p2 + (W + COLS));
				break;
		    case 5:	++*(p2 + NW);
				++*(p2 + N);
				++*(p2 + (NE - COLS));
				++*(p2 + (E - COLS));
				++*(p2 + (SE - COLS));
				++*(p2 + S);
				++*(p2 + SW);
				++*(p2 + W);
				break;
		    case 6:	++*(p2 + NW + ROWS * COLS + COLS);
				++*(p2 + N + ROWS * COLS);
				++*(p2 + NE + ROWS * COLS);
				++*(p2 + E);
				++*(p2 + SE);
				++*(p2 + S);
				++*(p2 + SW + COLS);
				++*(p2 + W + COLS);
				break;
		    case 7:	++*(p2 + NW + ROWS * COLS);
				++*(p2 + N + ROWS * COLS);
				++*(p2 + NE + ROWS * COLS - COLS);
				++*(p2 + E - COLS);
				++*(p2 + SE - COLS);
				++*(p2 + S);
				++*(p2 + SW);
				++*(p2 + W);
				break;
		    case 8:	++*(p2 + NW + COLS);
				++*(p2 + N);
				++*(p2 + NE);
				++*(p2 + E);
				++*(p2 + SE - ROWS * COLS);
				++*(p2 + S - ROWS * COLS);
				++*(p2 + SW + COLS - ROWS * COLS);
				++*(p2 + W + COLS);
				break;
		    case 9:	++*(p2 + NW);
				++*(p2 + N);
				++*(p2 + NE - COLS);
				++*(p2 + E - COLS);
				++*(p2 + SE - ROWS * COLS - COLS);
				++*(p2 + S - ROWS * COLS);
				++*(p2 + SW - ROWS * COLS);
				++*(p2 + W);
				break;
		    default:    break;
		    }
		} /* End if. */
	} /* End for. */
	pass2();                     /* Call pass2, for birth & death */
	refresh(scrnbuf, videomem);  /* Write final results to screen */
}

/* Do scan of Matrix 2 (pass 2).
 *
 * Scan Matrix 2: a value of 3 indicates a blank cell which should
 * undergo a "birth." A value > 100 (cell was alive) but NOT equal
 * to 102 or 103 means that there is a living cell that must die.
 * Adjust screen buffer and Matrix 1 accordingly.
 */
pass2()
{
	int 	 i;                  /* Loop variable */
	register char *p2;           /* Pointer into Matrix 2 */
	register int j;              /* Inner-loop variable */
	char	 *bp;                /* Pointer into screen buffer */
	char	 *top_left;         /* Location of top-right cell within
                                        video buffer */
	int	 diff;               /* Distance between Matrixes 1 & 2 */

	top_left = scrnbuf + 162;
	p2 = (char *) mat2;
	diff = (char *) mat2 - (char *) mat1;
	for (i = 0; i < ROWS * 160; i += 160)
	    for (j = 0; j < COLS; j++, p2++) {
		if (*p2 < 100) {
			if (*p2 == 3) {
				*(p2 - diff) += 100;
				bp = top_left + i + (j * 2);
				*bp = cell;
				*(bp + 1) = attrib;
			}
		} else
			if (*p2 < 102  ||  *p2 > 103) {
				*(p2 - diff) -= 100;
				bp = top_left + i + (j * 2);
				*bp = ' ';
				*(bp + 1) = attrib;
			}
	    }
}

/* Process keystroke.
 *
 * Check keyboard buffer and take action if a keystroke is waiting
 * there in the buffer.
 */
proc_key()
{
	int	key;      /* value of keystroke */

	while (get_key(&key)) {
		switch (key) {
		    case('p'):
		    case('P'): pause = 1;
			       break;
		    case('s'):
		    case('S'): if (speed > 1)
				   --speed;
			       break;
		    case('f'):
		    case('F'): if (speed < 10)
				   ++speed;
			       break;
		    default:   break;
		}
	}
}

/* Pause screen.
 *
 * Print "pause condition" prompt and wait for a meaningful
 * keystroke. Then take action based on this keystroke.
 */
pause_screen()
{
	int	key;      /* value of keystroke */

	set_cursor(23,0);
        printf("PAUSE screen controls:  C=continue  Q=quit");
	printf("  S=step  R=restart                 ");
	set_cursor(26,0);

	do {
		while (!get_key(&key))
			;      
	} while (key!='c' && key!='C' && key!='Q' && key!= 'q' &&
               key!='S' && key!='s' && key!='R' && key!='r');
	switch(key) {
	case('C'):
	case('c'):
		draw_prompt_box();
		pause = 0;
		break;
	case('Q'):
	case('q'):
		more_rounds = 0;
		return(1);
		break;
	case('S'):
	case('s'):
		generation();
		repeat--;
		break;
	case('E'):
	case('e'):
		edit();
		break;
	case('R'):
	case('r'):
		more_rounds = 1;
		return(1);
	default:
		break;
	}
	return(0);
}

/* Initialize video adapter indicator.
 *
 * Determine whether adapter is monochrome, ega, or cga.
 * Issue set mode BIOS command, using standard mode for color,
 * B&W, or monochrome.
 */
init_adapter()
{
	int mode;                 /* Value returned by BIOS call */
	union REGS regs;

	regs.h.ah = 0xF;
	int86(0x10, &regs, &regs);   /* Get video mode, place in AL */
	mode = regs.h.al;
	if (mode == 7)               /* 7 and 15 are MONO modes */
		adapter = MONO;
	else if (mode == 15) {
		adapter = MONO;
		set_mode(7);         /* Set to 7, standard MONO mode */
	} else {
		adapter = is_ega();         /* Test for CGA vs. EGA */
		if (mode >= 8 && mode <=14)
			set_mode(3);
		else switch (mode) {
		case 1:			    /* Color */
		case 3:
		case 4:	set_mode(3);	    /* 3 is standard color mode */
			break;
		case 0:			    /* B & W */
		case 2:
		case 5:
		case 6:	set_mode(2);        /* 2 is standard B & W mode */
			break;
		} /* end switch */
	} /* end else */
}


is_ega()
{
	union REGS regs;
	char far *ega_byte = (char far *) 0x487;
	int  ega_inactive;

	regs.h.ah = 0x12;
	regs.x.cx = 0;
	regs.h.bl = 0x10;
	int86(0x10, &regs, &regs);
	if (regs.x.cx == 0)
		return (CGA);
	ega_inactive = *ega_byte & 0x8;
	if (ega_inactive)
		return (CGA);
	return (EGA);
}

set_mode(mode)
int	mode;
{
	union REGS regs;
	
	regs.h.al = (char) mode;
	regs.h.ah = 0;
	int86(0x10, &regs, &regs);
	regs.h.al = 0;
	regs.h.ah = 5;
	int86(0x10, &regs, &regs);
}
