/* MATHDEMO.C - Creates a simple on-screen calculator with functions for
 * basic integer arithmetic and for solving for the roots of a quadratic
 * equation. MATHDEMO invokes QuickAssembler procedures that illustrate
 * assembly-language instructions related to mathematics, including those
 * specific to the 8087 family of coprocessors.
 *
 * MATHDEMO.EXE is built from the following files:
 *    MATHDEMO.C - Main program
 *    MATH.ASM	 - QuickAssembler procedures for MATHDEMO
 *    COMMON.ASM - QuickAssembler procedures shared by other example programs
 *    DEMO.INC	 - Assembly include file with macros and structure declarations
 *    DEMO.H	 - C include file with prototypes and structure declarations
 *
 * Procedures:	AddLong       MulLong      DivLong     Quadratic
 *		SubLong       ImulLong     IdivLong
 */

#include "demo.h"
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>

/* Function prototypes */
void display_calc( void );
void display_help( void );
void press( void );
void push( int sign );

/* Global variables */
long s1, s2, s3;		/* Stack values: 1st, 2nd, 3rd	    */
char entry[11]; 		/* Entry window string		    */
int  col;			/* Current display column for entry */

main()
{
    int ch, err;			/* Keyboard character, return val  */
    static int sign, mode;		/* Sign flag, signed/unsigned flag */
    static float root1, root2;		/* Roots of quadratic equation	   */
    static short quotient, remainder;	/* Results of division		   */
    static long *product, result;
    static char *rmsg[2] = { "roots", "indeterminate" };
    static char *highmsg = { "high:" };
    static char *lowmsg  = { "low:" };

    GetVidConfig();
    display_calc();
    StrWrite( 9, 14, "+" );
    col = 20;
    while( ch != ESCAPE )
    {
	SetCurPos( 9, col );
	ch = getch();
	switch( (ch = toupper( ch )) )
	{
	    /* Display number in entry window. */
	    case '0':
	    case '1':
	    case '2':
	    case '3':
	    case '4':
	    case '5':
	    case '6':
	    case '7':
	    case '8':
	    case '9':
		putch( (char) ch );
		entry[col - 20] = (char) ch;
		entry[++col - 20] = 0;
		if( col == 30 )
		    col--;
		break;

	    /* Toggle between signed and unsigned arithmetic modes. */
	    case 'M':
		if( mode )
		{
		    mode = 0;			/* For signed mode,   */
		    StrWrite( 14, 57, "  (" );	/*   toggle flag off  */
		    StrWrite( 9, 14, "+" );	/*   and restore sign */
		}
		else
		{
		    mode++;			/* For unsigned mode, */
		    StrWrite( 14, 57, "(un" );	/*   toggle flag on   */
		    StrWrite(  9, 14, " " );	/*   and blank sign   */
		}
		sign = 0;
		break;

	    /* Solve for x in quadratic equation s3*x*x + s2*x + s3 = 0. */
	    case 'Q':
		push( sign );
		err = Quadratic( (float)s3, (float)s2, (float)s1,
				  &root1, &root2 );
		ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry window	*/
		ClearBox( 7, 9, 49, 10, 66 );	/* Clear result window	*/
		if( err < 2 )
		{
		    SetCurPos( 9, 50 );
		    printf( "%16.3f", root1 );		/* Display 1st root */
		    if( !err )
		    {
			SetCurPos( 10, 50 );
			printf( "%16.3f", root2 );	/* Display 2nd root */
		    }
		}
		if( err == 2)
		{
		    StrWrite(  9, 50, rmsg[0] );   /* Display "roots	*/
		    StrWrite( 10, 50, rmsg[1] );   /*	indeterminate"	*/
		}
		break;

	    /* Change sign. */
	    case 'S':
		if( !mode )		/* Allow sign changes only */
		{			/* in signed mode	   */
		    if( sign )
		    {
			StrWrite( 9, 14, "+" );
			sign = 0;
		    }
		    else
		    {
			StrWrite( 9, 14, "-" );
			sign++;
		    }
		}
		break;

	    /* Clear stack, reinitialize variables. */
	    case 'C':
		s3 = s2 = s1 = 0;
		ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry window  */
		ClearBox( 7, 9, 49, 10, 66 );	/* Clear result window */
		entry[0] = 0;
		col = 20;
		break;

	    /* Push values down stack when Enter key pressed. */
	    case CR:
		push( sign );
		break;

	    /* Display help screen. */
	    case '?':
	    case 'H':
		display_help(); 		/* Display help 	*/
		display_calc(); 		/* Redisplay calculator */
		StrWrite( 9, 20, entry );	/*   and entry number	*/
		if( mode )
		{
		    StrWrite( 14, 57, "(un" );	/* Make "unsigned"	*/
		    StrWrite(  9, 14, " " );	/*   and blank sign	*/
		}
		else
		{
		    if( sign )
			StrWrite( 9, 14, "-" );
		    else
			StrWrite( 9, 14, "+" );
		}
		break;

	    /* Add or subtract s1 and s2. */
	    case '+':
	    case '-':
		push( sign );
		if( (char) ch == '+' )
		    s1 = AddLong( s1, s2 );
		else
		    s1 = SubLong( s2, s1 );
		ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry window	*/
		ClearBox( 7, 9, 49, 10, 66 );	/* Clear result window	*/
		SetCurPos( 9, 56 );
		if( mode )
		    printf( "%lu", s1 );	/* Display unsigned or	*/
		else
		    printf( "%li", s1 );	/*   signed result	*/
		break;

	    /* Multiply s1 and s2. */
	    case '*':
		push( sign );
		if( mode )
		    product = MulLong(	s1, s2 );
		else
		    s1	    = ImulLong( s1, s2 );
		ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry window	*/
		ClearBox( 7, 9, 49, 10, 66 );	/* Clear result window	*/
		if( mode )
		{
		    StrWrite(  9, 50, highmsg );
		    StrWrite( 10, 50, lowmsg );
		    SetCurPos( 9, 56 );
		    printf( "%lu", *++product ); /* Display high and low   */
		    SetCurPos( 10, 56 );	 /*   double-word of	   */
		    printf( "%lu", *--product ); /*   unsigned product	   */
		    s1 = *product;		 /* Copy low word to stack */
		}
		else
		{
		    SetCurPos( 9, 56 );
		    printf( "%li", s1 );	/* Display signed product  */
		}
		break;

	    /* Divide s2 by s1. */
	    case '/':
		push( sign );
		if( mode )
		    quotient = DivLong(  s2, (int) s1, &remainder );
		else
		    quotient = IdivLong( s2, (int) s1, &remainder );
		ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry	        */
		ClearBox( 7, 9, 49, 10, 66 );	/* Clear result         */
		if( abs( (int) remainder ) >= (abs( (int) s1 ) >> 1) )
		{
		    if( quotient >= 0 ) 	/* Round up if		*/
			quotient++;		/*   remainder > s1/2   */
		    else
			quotient--;
		}
		SetCurPos( 9, 56 );
		if( mode )
		    printf( "%u", quotient );	/* Display result */
		else
		    printf( "%i", quotient );
		s1 = (long) quotient;		/* Copy quotient to stack */
		break;

	}
    }

    clear_scrn( 7, 0, 24 );		/* Clear screen before exit   */
    SetCurPos( 23, 0 ); 		/*   and set cursor to bottom */
    return( 0 );
}


/* display_calc - Clears screen and displays calculator.
 *
 * Params:  None
 */

void display_calc( void )
{
    static char *calculator[19] =
    {
   "               ***   QuickAssembler Math Demonstration Program  ***",
   "",
   "",
   "ÚÄ Integer Calculator ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿",
   "³                                                                        ³",
   "³         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿        ³",
   "³         ³                ³                 ³                  ³        ³",
   "³         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                 ³                  ³        ³",
   "³                      entry                 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        ³",
   "³                                                          result        ³",
   "³         7  8  9      +   -                 ? = Help                    ³",
   "³                                            M = Mode   (signed)         ³",
   "³         4  5  6      *   /                 S = Change sign             ³",
   "³                                            Q = Solve quadratic         ³",
   "³         1  2  3      ÄÙ Enter             C = Clear all               ³",
   "³                                                                        ³",
   "³            0                             Esc = Quit                    ³",
   "³                                                                        ³",
   "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
    };
    int i;

    clear_scrn( 7, 0, 24 );
    if( vconfig.display )
	ClearBox( 31, 6, 2, 21, 77 );
    else
	ClearBox( 15, 6, 2, 21, 77 );
    ClearBox( 7, 9, 14, 9, 29 );		/* Clear entry window  */
    ClearBox( 7, 9, 49, 10, 66 );		/* Clear result window */
    for( i = 0; i < 19; i++)			/* Display calculator  */
	StrWrite( i + 3, 3, calculator[i] );
}



/* display_help - Clears screen and displays help text.
 *
 * Params:  None
 */

void display_help( void )
{
    static char *help_msg[23] =
    {
	"The Integer Calculator works somewhat like a Hewlett-Packard hand " \
	"calculator.", "Type the first integer, press Enter (ÄÙ), type the " \
	"second integer, and press", "the desired operator key.  The answer " \
	"appears in the result window.",
	"",
	"To keep things simple, the Integer Calculator handles only long or " \
	"short", "integers -- no floating point numbers allowed.  Unsigned " \
	"numbers can range", "from 0 to 4,294,967,295; signed numbers from " \
	"-2,147,483,648 to 2,147,483,647.", "There's one exception to " \
	"this:  when dividing two numbers, the divisor must", "be a short " \
	"integer from 0 to 65,535 for unsigned division, or from -32,768",
	"to 32,767 for signed division.",
	"",
	"Press the M key to toggle between signed and unsigned arithmetic.  " \
	"Press the", "S key to change the sign of the number in the entry " \
	"window.  You'll notice", "the Calculator allows a change of sign " \
	"only in \"signed\" mode.",
	"",
	"The Calculator uses coprocessor instructions (either real or " \
	"simulated) to", "solve for the roots of a quadratic equation in " \
	"the form",
	"",
	"                     A*x*x + B*x + C = 0",
	"",
	"Enter the three equation constants A, B, and C in order, then " \
	"press Q.  The", "roots, if they exist, appear in the result " \
	"window.  If the equation has only", "one root, then only a single " \
	"number is displayed."
    };
    int i;

    clear_scrn( 7, 0, 24 );
    for( i = 0; i < 23; i++)
	StrWrite( i, 0, help_msg[i] );
    press();
}


/* push - Pushes values down one stack position:  s3 becomes s2,
 * s2 becomes s1, and s1 becomes the value in the entry window.
 *
 * Params:  sign - Current sign status (0 = positive, 1 = negative)
 */

void push( int sign )
{
    unsigned long place;

    s3	  = s2;
    s2	  = s1;
    s1	  = 0;
    place = 1;
    if( entry[col - 20] )
    {
	s1    = (long) (entry[col - 20] - '0');
	place = 10;
    }
    while( col > 20 )
    {
	s1    += place * (long) (entry[--col - 20] - '0');
	place *= 10;
    }
    if( sign )
	s1 = -s1;
    ClearBox( 7, 9, 15, 9, 29 );	/* Clear entry window	     */
    entry[0] = 0;			/* Reinitialize entry string */
    col      = 20;			/* Reset column count	     */
}


/* press - Prompt for keyboard signal to continue.
 *
 * Params:  None
 */

void press( void )
{
    SetCurPos( 24, 49 );
    printf( ". . . press a key to continue" );
    SetCurPos( 24, 47 );
    getch();
}
