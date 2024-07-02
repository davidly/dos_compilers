/* LIFE.C - Game of LIFE demonstration program.
 *
 * The game of life was invented in 1970 by mathematics professor John
 * Horton Conway. The object is to create and study the life forms that
 * evolve from patterns entered on the board (usually a video screen,
 * though life can also be played with pencil and paper).
 *
 * The game of life is based on the following laws:
 *
 *     1. Law of Survival - If a living cell has either two or or three
 *        neighbors, it survives.
 *
 *     2. Law of Death - A living cell with more than three neighbors
 *        dies of overcrowding. A living cell with less than two
 *        neighboers dies of isolation.
 *
 *     3. Law of Birth - A dead cell with exactly three neighbors is born
 *        in the next generation.
 *
 * These simple laws result in complex interactions. For example,
 * try entering the following patterns:
 *
 *      þþ       þ             þ        þþ                  þ    þ
 *     þ þ         þ            þ      þþ       þþþþþ     þþ þþþþ þþ
 *       þ      þþ  þþþ     þ   þ       þ       þ   þ       þ    þ
 *                          þþþþ
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <time.h>
#include <graph.h>
#include "tools.h"

/* Dimensions of population matrix for largest possible screen--
 * VGA 80 * 50).
 */
#define MAXROWS 46
#define MAXCOLS 78
#define MAXSCRN ((MAXROWS + 2) * (MAXCOLS + 2))

#define SROWS    (cfg.mrows + 2)            /* Screen rows        */
#define SCOLS    (cfg.mcols + 2)            /* Screen columns     */
#define SBUFSIZE (SROWS * SCOLS)            /* Screen buffer size */
#define MBUFSIZE (cfg.mrows * cfg.mcols)    /* Matrix buffer size */

#define BEEP 7

/* Action for change_cell */
enum CELLCHANGE { OFF, ON, TOGGLE };

/* Cell type specifies the symbol and attribute of a cell. The two
 * most common cells, life and death, are initialized.
 */
typedef struct LIFECELL
{
    unsigned char  symbol;
    unsigned char  atrib;
} CELL;
CELL life =
{   'þ',
    SETATRIB( _TBRIGHTWHITE, _TBLACK )
};
CELL death =
{   ' ',
    SETATRIB( _TBRIGHTWHITE, _TBLACK )
};

/* Structure for overall attributes of life, initialized for mono   */
struct LIFECONFIG
{
    float density;              /* Percent of random distribution   */
    int   rescan;               /* CGA rescan flag                  */
    int   far *videomem;        /* Address of video memory          */
    char  boxatrib;             /* Attribute for frame              */
    char  helpatrib;            /* Attribute for prompt line        */
    int   mrows;                /* Matrix rows                      */
    int   mcols;                /* Matrix columns                   */
    unsigned cursor;            /* Cursor begin and end lines       */
} cfg =
{
    0.40,
    FALSE,
    (int far *)0xb0000000,
    SETATRIB( _TWHITE, _TBLACK ),
    SETATRIB( _TBLACK, _TWHITE ),
    21,
    78
};

/* Global variables */
char    mat1[MAXROWS][MAXCOLS]; /* Matrix 1: stores current population  */
char    mat2[MAXROWS][MAXCOLS]; /* Matrix 2: stores crowding-numbers    */
int     cell;                   /* Cell character                       */
char    attrib;                 /* Video attribute of each location     */
int     forever;                /* Unlimited no. of generations?        */
long    repeat;                 /* Maximum number of generations to do  */
CELL    scrnbuf[MAXSCRN];       /* Screen Buffer area                   */

/* Key codes */
#define HM      0x0147
#define UA      0x0148
#define PU      0x0149
#define RA      0x014d
#define PD      0x0151
#define DA      0x0150
#define ED      0x014f
#define LA      0x014b
#define SH_HM   0x0247
#define SH_UA   0x0248
#define SH_PU   0x0249
#define SH_RA   0x024d
#define SH_PD   0x0251
#define SH_DA   0x0250
#define SH_ED   0x024f
#define SH_LA   0x024b
#define INS     0x0152
#define DEL     0x0153
#define ENTER   13
#define ESC     27

/* String prompts */
char run_str[] =
"RUN:  F=Faster  S=Slower  O=Options  Q=Quit";

char edit_str[] =
"EDIT:  ARROWs=Move  SHIFT-ARROWs=Move/toggle  SPACE=Toggle  ENTER=Done  C=Clear";

char pause_str[] =
"PAUSE:  G=Go  C=Clear  Q=Quit  S=Step  E=Edit  N=New random  R=Read  W=Write";

char file_str[] = "Enter file name: ";

char ferr_str[] = "File access failure - press a key to continue . . .";

char dense_str[] = "Invalid density - press a key to continue . . .";

/* Function prototypes */
int  main( int argc, char **argv );
void run_mode( void );
int  pause_mode( void );
void edit_mode( void );
void init_life( void );
void init_buf( void );
void draw_box( void );
void init_mats( void );
void rand_dist( float chance );
void generation( void );
void pass2( void );
void change_cell( int action, int row, int col );
int  read_life( void );
int  write_life( void );
int  show_prompt( char *prompt, char response[] );
void refresh( CELL inbuffer[], int far *outbuffer );

/* main - Runs the game of life.
 *
 * Params: argc - the number of command-line arguments
 *         argv - array of command-line strings
 *
 * Return: 0
 *
 * Uses:   repeat
 */
int main( int argc, char **argv )
{

    /* Initialize video and matrixes. Draw frame. */
    init_life();
    init_buf();
    draw_box();
    init_mats();

    /* If no command-line argument, run forever. Otherwise, repeat the number
     * of times specified in command line. 0 in command line means start
     * by editing, not randomizing.
     */
    if( argc > 1 )
    {
        repeat = atol( argv[1] );
        forever = FALSE;
    }
    else
    {
        repeat = TRUE;
        forever = TRUE;
    }
    if ( !repeat )
    {
        forever = TRUE;
        edit_mode();
    }
    else
        rand_dist( cfg.density );

    /* Run life. */
    run_mode();

    /* Restore and quit. */
    _settextcursor( cfg.cursor );
    _displaycursor( _GCURSORON );
    _setvideomode( _DEFAULTMODE );
	exit( FALSE );
}

/* run_mode - Runs life, checking between generations for keystrokes.
 * When a keystroke is received, take appropriate action.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   repeat, forever, run_str
 */
void run_mode()
{
    char key;
    static clock_t speed = 100;   /* Delay in microseconds (less than 1000) */

    /* Display command prompt and check keys while running. */
    show_prompt( run_str, "" );
    while( forever || repeat-- )
    {
        delay( speed );
        generation();
        if( key = getkey( NO_WAIT ) )
		{
			key = toupper( key );
            switch( key )
            {
                case 'O':       /* Do pause mode action */
                    if( !pause_mode() )
                        return;
                    break;
                case 'F':       /* Faster */
                    if( speed )
                        speed -= 100;
                    break;
                case 'S':       /* Slower */
                    if( speed < 1000 )
                        speed += 100;
                    break;
                case 'Q':       /* Terminate */
                case ESC:
                    return;
            }
        }
    }
}

/* pause_mode - Gets a pause mode keystroke and takes appropriate action.
 *
 * Params: None
 *
 * Return: FALSE if quit, TRUE if any other command
 *
 * Uses:   cfg and various message strings
 */
int pause_mode()
{
    int i, pause = TRUE;
    char tmp[80];
    char key;

    show_prompt( pause_str, "" );
    while( pause )
    {
        key = getkey( WAIT );
        switch( toupper( key ) )
        {

            case 'C':              /* Clear life arena              */
                init_buf();
                draw_box();
                init_mats();
                break;
            case 'G':              /* Go - restart life             */
                pause = FALSE;
                break;
            case 'E':              /* Edit - edit current pattern   */
                edit_mode();
                break;
            case 'Q':              /* Quit - end game               */
            case ESC:
                return FALSE;
            case 'S':              /* Step - do one generation      */
                generation();
                repeat--;
                break;
            case 'N':              /* New - randomize again         */
                sprintf( tmp, "Current density: %.f  Enter new: ",
                         cfg.density * 100 );
                show_prompt( tmp, tmp );
                i = atoi( tmp );
                if ( (i < 1) || (i > 100) )
                {
                    show_prompt( dense_str, "" );
                    putch( BEEP );
                    getch();
                    show_prompt( pause_str, "" );
                    break;
                }
                /* Clear screen and set new. */
                init_buf();
                draw_box();
                init_mats();
                show_prompt( pause_str, "" );
                rand_dist( cfg.density = (float)(i / 100.0) );
                break;
            case 'R':              /* Get a new pattern from file   */
                if( !read_life() )
                {
                    show_prompt( ferr_str, "" );
                    putch( BEEP );
                    getch();
                }
                show_prompt( pause_str, "" );
                break;
            case 'W':              /* Write current pattern to file */
                if( !write_life() )
                {
                    show_prompt( ferr_str, "" );
                    putch( BEEP );
                    getch();
                }
                show_prompt( pause_str, "" );
                break;
        }
    }
    /* Restore run prompt. */
    show_prompt( run_str, "" );
    return TRUE;
}

/* edit_mode - Repeatedly accepts editing keystrokes and takes
 * appropriate action.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   repeat, cfg, edit_str, pause_str
 */
void edit_mode()
{
    int more = TRUE;
    unsigned key;
    int curs_row = cfg.mrows / 2, curs_col = cfg.mcols / 2;

    /* Update prompt, turn on cursor, and center cursor. */
    show_prompt( edit_str, "" );
    _displaycursor ( _GCURSORON );
    _settextposition( curs_row + 2, curs_col + 2 );

    do {
        key = getkey( WAIT );
        switch( key )
        {
            case SH_HM:         /* Move northwest */
            case HM:
                if( (curs_col > 0) && (curs_row > 0) )
                {
                    curs_col--;
                    curs_row--;
                }
                break;
            case SH_UA:         /* Move north */
            case UA:
            case 'k':
                if( curs_row > 0 )
                    curs_row--;
                break;
            case SH_PU:         /* Move northeast */
            case PU:
                if( (curs_col < cfg.mcols - 1) && (curs_row > 0) )
                {
                    curs_col++;
                    curs_row--;
                }
                break;
            case SH_RA:         /* Move east */
            case RA:
            case 'l':
                if( curs_col < cfg.mcols - 1)
                    curs_col++;
                break;
            case SH_PD:         /* Move southeast */
            case PD:
                if( (curs_col < cfg.mcols - 1) && (curs_row < cfg.mrows - 1) )
                {
                    curs_col++;
                    curs_row++;
                }
                break;
            case SH_DA:         /* Move south */
            case DA:
            case 'j':
                if( curs_row < cfg.mrows - 1)
                    curs_row++;
                break;
            case SH_ED:         /* Move southwest */
            case ED:
                if( (curs_col > 0 ) && (curs_row < cfg.mrows - 1) )
                {
                    curs_col--;
                    curs_row++;
                }
                break;
            case SH_LA:         /* Move west */
            case LA:
            case 'h':
                if( curs_col > 0 )
                    curs_col--;
                break;
            case ' ':           /* Toggle current cell */
                change_cell( TOGGLE, curs_row, curs_col );
                break;
            case INS:           /* Turn current cell on */
                change_cell( ON, curs_row, curs_col );
                break;
            case DEL:           /* Turn current cell off */
                change_cell( OFF, curs_row, curs_col );
                break;
            case 'C':           /* Clear cells */
            case 'c':
                init_buf();
                draw_box();
                init_mats();
                break;
            case 'D':           /* Done - accept editing changes */
            case 'd':
            case ENTER:
                more = FALSE;
                break;
            default:            /* Ignore unknown keys */
                break;
        }
        /* If shift was down, toggle key. */
        if( (key >> 8) == 2 )
            change_cell( TOGGLE, curs_row, curs_col );

        /* Update cursor position. */
        _settextposition( curs_row + 2, curs_col + 2 );

    } while( more );

    /* Turn off cursor and restore pause prompt. */
    _displaycursor (_GCURSOROFF );
    show_prompt( pause_str, "" );
}

/* init_life - Initializes the screen mode, rows, and cursor status.
 * Sets global screen, configuration, and life variables.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   Sets the following:
 *           cfg.rescan - flag for CGA retrace handling
 *              .cursor - cusor shape
 *              .mrows - maximum rows
 *              .videomem - pointer to screen buffer
 *              .boxatrib - foreground and background colors of frame
 *              .helpatrib - colors of help line
 *           life.atrib - colors of live cells
 *           death.atrib - colors of dead cells
 */
void init_life()
{
    struct videoconfig vc;

    /* Save starting cursor and set block cursor. Then turn it off. */
    cfg.cursor = _settextcursor( SETCURSOR( 0, 7 ) );
    _displaycursor( _GCURSOROFF );

    /* Get configuration and set variables based on adapter. */
    _getvideoconfig( &vc );
    switch( vc.adapter )
    {
        case _CGA:
            cfg.rescan = TRUE;
            break;
        case _EGA:
        case _OEGA:
            cfg.mrows = 39;              /* 43-line - 4 lines */
            break;
        case _VGA:
        case _OVGA:
            cfg.mrows = 46;              /* 50-line - 4 lines */
            break;
        default:
            cfg.mrows = 21;              /* 25-line - 4 lines */
            break;
    }

    /* Set variables based on mode. */
    switch( vc.mode )
    {

        case _HERCMONO:
        case _ERESNOCOLOR:
        case _TEXTMONO:
            _setvideomoderows( _TEXTMONO, cfg.mrows + 4 );
            break;

        case _TEXTBW40:
        case _TEXTBW80:
            cfg.videomem = (int far *)0xb8000000;
            _setvideomoderows( _TEXTBW80, cfg.mrows + 4 );
            break;

        default:
            cfg.videomem = (int far *)0xb8000000;
            cfg.boxatrib = SETATRIB( _TBRIGHTWHITE, _TBLUE );
            life.atrib = death.atrib = SETATRIB( _TWHITE, _TBLUE );
            cfg.helpatrib = SETATRIB( _TWHITE, _TBLACK );
            _setvideomoderows( _TEXTC80, cfg.mrows + 4 );
            break;
    }
}

/* init_buf - Initialize screen buffer dead cells.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void init_buf()
{
    register CELL *p = scrnbuf;

    while( p < scrnbuf + SBUFSIZE )
        *p++ = death;
}


/* draw_box - Write extended-ascii line characters around the frame (box)
 * of the screen buffer. Then write the modified buffer to the screen.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void draw_box()
{
    register unsigned char *p = (char *)scrnbuf;   /* Pointer into buffer */
    int i, incr;

    /* Draw top of box. */
    *p = 'Ú';
    p +=2;
    for( i = 0; i < cfg.mcols; p += 2, i++ )
        *p = 'Ä';
    *p = '¿';
    p += 2;

    /* Draw side of box. */
    incr = (SCOLS - 1) * 2;
    for( i = 0; i < cfg.mrows; p += (SCOLS * 2), i++ )
    {
        *p = '³';
        *(p + incr) = '³';
    }

    /* Draw bottom of box. */
    *p = 'À';
    p += 2;
    for( i = 0; i < cfg.mcols; p += 2, i++)
        *p = 'Ä';
    *p = 'Ù';

    /* Copy modified screen buffer to video memory. */
    refresh( scrnbuf, cfg.videomem );
}

/* init_mats - Initializes life matrixes. Clears matrix 1 and matrix 2,
 * then initialize all the zones (1-9) of matrix 1.
 *
 * The "zones" are used by the LIFE algorithm to determine the method
 * of calculating neighbors. Zones are pertinent to edges and corners:
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
 * Zones are recorded in matrix 1 for ease of computation. If a cell
 * lives, then add 100 to flag cell's existence.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void init_mats()
{
    int i, j;                   /* Loop counters         */
    char *p = (char *)mat1;     /* Pointer into matrix 1 */

    /* Initialize zones in matrix 1 to 0. */
    memset( mat1, 0, cfg.mrows * cfg.mcols );
    memset( mat2, 0, cfg.mrows * cfg.mcols );

    /* Initilialize row 1 to zones 6, 2, and 7. */
    *p++ = 6;
    for( i = 0; i < (cfg.mcols - 2); i++)
        *p++ = 2;
    *p++ = 7;

    /* Initialize center rows to zones 4, 1, and 5. */
    for( j = 0; j < (cfg.mrows - 2); j++ )
    {
        *p++ = 4;
        for( i = 0; i < (cfg.mcols - 2); i++ )
            *p++ = 1;
        *p++ = 5;
    }

    /* Initialize bottom row to zones 8, 3, and 9. */
    *p++ = 8;
    for( i = 0; i < (cfg.mcols - 2); i++ )
        *p++ = 3;
    *p++ = 9;
}

/* rand_dist - Initializes a random distribution of cells. The cells
 * are updated both in matrix 1 and in the screen buffer. If a cell has
 * a random value greater than the calculated distribution, 100 is added
 * to its value in matrix 1, and it is written into the screen buffer.
 *
 * Params: chance - the percentage of randomness
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void rand_dist( float chance )
{
    char    *p = (char *)mat1;      /* Pointer to matrix 1      */
    register CELL *bp = scrnbuf;    /* Pointer to screen buffer */
    int     i, j;                   /* Loop counters            */
    int     amt, rnd;

    amt = (int)(chance * 32768);    /* Amount to exceed for a cell to live  */
    srand( (unsigned)time( NULL ) );/* Randomize seed                       */
    bp += SCOLS + 1;                /* Start at first non-frame cell        */

    /* Assign life or death to each cell. */
    for( i = 0; i < cfg.mrows; i++, bp += 2 )
    {
        for( j = 0; j < cfg.mcols; j++, p++, bp++ )
        {
            rnd = rand();
            if( rnd < amt )
            {
                *p += 100;
                *bp = life;
            }
        }
    }

    /* Put results on the screen. */
    refresh( scrnbuf, cfg.videomem );
}

#define NW  (-1-cfg.mcols)        /* Directional constants, within     */
#define N   (-cfg.mcols)          /*  matrix 2. For example, NW refers */
#define NE  (1-cfg.mcols)         /*  to the upper, left-hand neighbor */
#define E   (1)
#define SE  (1+cfg.mcols)
#define S   (cfg.mcols)
#define SW  (-1+cfg.mcols)
#define W   (-1)

/* generation - Do one generation of life. First matrix 2 is cleared, then
 * matrix 1 is scanned. Wherever a living cell is found, the CORRESPONDING
 * NEIGHBOR CELLS IN MATRIX 2 are incremented by 1, and the corresponding
 * cell itself is incremented by 100. If the cell is not living, do nothing.
 * This provides a fast method of determining neighbor count, which is
 * kept track of in matrix 2.
 *
 * The "zone" of each cell is checked, and used as a guide for determining
 * neighbors. Nothern neighbors of northernmost row are found in the
 * southernmost row, so that the game has a "boundless" effect...formations
 * that move off one side automatically circle around to the other side.
 *
 * Pass 2 is called to determine what actually lives or dies, based on
 * the neighbor-count of each cell.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void generation()
{
    register  char *p1;    /* Pointers into matrixes 1 and 2 */
    register  char *p2;
    int     diff;          /* Bytes between matrixes 1 and 2 */
    int     zone;          /* Zone of each cell              */
    int     msize = MBUFSIZE;

    /* Clear matrix 2 and calculate distance between zones 1 and 2. */
    memset( mat2, 0, msize );
    diff = (char *)mat2 - (char *)mat1;

    /* For each cell . . . */
    for( p1 = (char *)mat1; p1 < (char *)mat1 + msize; p1++ )
    {
        /* If matrix 1 cell is alive . . . */
        if( *p1 > 100 )
        {
            /* Point to matrix 2 cell and update it. */
            p2 = p1 + diff;
            *p2 += 100;

            /* Get the zone and update the neighbors accordingly. */
            zone = (*p1 - 100);
            switch( zone )
            {
                case 1:
                    ++*(p2 + NW);
                    ++*(p2 + N);
                    ++*(p2 + NE);
                    ++*(p2 + E);
                    ++*(p2 + SE);
                    ++*(p2 + S);
                    ++*(p2 + SW);
                    ++*(p2 + W);
                    break;
                case 2:
                    ++*(p2 + NW + msize);
                    ++*(p2 + N + msize);
                    ++*(p2 + NE + msize);
                    ++*(p2 + E);
                    ++*(p2 + SE);
                    ++*(p2 + S);
                    ++*(p2 + SW);
                    ++*(p2 + W);
                    break;
                case 3:
                    ++*(p2 + NW);
                    ++*(p2 + N);
                    ++*(p2 + NE);
                    ++*(p2 + E);
                    ++*(p2 + SE - msize);
                    ++*(p2 + S - msize);
                    ++*(p2 + SW - msize);
                    ++*(p2 + W);
                    break;
                case 4:
                    ++*(p2 + NW + cfg.mcols);
                    ++*(p2 + N);
                    ++*(p2 + NE);
                    ++*(p2 + E);
                    ++*(p2 + SE);
                    ++*(p2 + S);
                    ++*(p2 + SW + cfg.mcols);
                    ++*(p2 + W + cfg.mcols);
                    break;
                case 5:
                    ++*(p2 + NW);
                    ++*(p2 + N);
                    ++*(p2 + NE - cfg.mcols);
                    ++*(p2 + E - cfg.mcols);
                    ++*(p2 + SE - cfg.mcols);
                    ++*(p2 + S);
                    ++*(p2 + SW);
                    ++*(p2 + W);
                    break;
                case 6:
                    ++*(p2 + NW + msize + cfg.mcols);
                    ++*(p2 + N + msize);
                    ++*(p2 + NE + msize);
                    ++*(p2 + E);
                    ++*(p2 + SE);
                    ++*(p2 + S);
                    ++*(p2 + SW + cfg.mcols);
                    ++*(p2 + W + cfg.mcols);
                    break;
                case 7:
                    ++*(p2 + NW + msize);
                    ++*(p2 + N + msize);
                    ++*(p2 + NE + msize - cfg.mcols);
                    ++*(p2 + E - cfg.mcols);
                    ++*(p2 + SE - cfg.mcols);
                    ++*(p2 + S);
                    ++*(p2 + SW);
                    ++*(p2 + W);
                    break;
                case 8:
                    ++*(p2 + NW + cfg.mcols);
                    ++*(p2 + N);
                    ++*(p2 + NE);
                    ++*(p2 + E);
                    ++*(p2 + SE - msize);
                    ++*(p2 + S - msize);
                    ++*(p2 + SW + cfg.mcols - msize);
                    ++*(p2 + W + cfg.mcols);
                    break;
                case 9:
                    ++*(p2 + NW);
                    ++*(p2 + N);
                    ++*(p2 + NE - cfg.mcols);
                    ++*(p2 + E - cfg.mcols);
                    ++*(p2 + SE - msize - cfg.mcols);
                    ++*(p2 + S - msize);
                    ++*(p2 + SW - msize);
                    ++*(p2 + W);
                    break;
                default:
                    break;
            }
        } /* End if */
    } /* End for */

    /* Call pass2 to calculate birth or death of each cell. */
    pass2();
}

/* pass2 - Scan matrix 2 and update matrix 1 according to the following:
 *
 *    Matrix 2 value        Matrix 1 result
 *    --------------        ----------------------
 *          3               Dead cell becomes live
 *          102, 103        No change
 *          other > 100     Live cell becomes dead
 *          other < 100     No change
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void pass2()
{
    register int i, j;              /* Loop variables               */
    register char *p2= (char *)mat2;/* Pointer into matrix 2        */
    CELL     *bp = scrnbuf;         /* Pointer into screen buffer   */
    int      diff;                  /* Distance between matrixes    */

    /* Skip frame to first cell and calculate distance between matrixes. */
    bp += SCOLS + 1;
    diff = (char *)mat2 - (char *)mat1;

    /* Outer loop counts rows. */
    for( i = 0; i < cfg.mrows; i++, bp += 2 )
    {
        /* Next loop counts columns. */
        for( j = 0; j < cfg.mcols; j++, p2++, bp++ )
        {
            /* Write live cell if 3. */
            if( *p2 < 100 )
            {
                if( *p2 == 3 )
                {
                    *(p2 - diff) += 100;
                    *bp = life;
                }
            }
            else
            /* Dead cell if above 100, but not 102 or 103. */
            {
                if( (*p2 < 102) || (*p2 > 103) )
                {
                    *(p2 - diff) -= 100;
                    *bp = death;
                }
            }
        }
    }

    /* Put results on the screen. */
    refresh( scrnbuf, cfg.videomem );
}

/* change_cell - Set the state of a specified cell. The cell may be turned
 * on, off, or toggled. Update the status in matrix 1 and in the screen
 * buffer.
 *
 * Params: action - OFF, ON, or TOGGLE
 *         row
 *         col
 *
 * Return: None
 *
 * Uses:   scrnbuf, cfg
 */
void change_cell( int action, int row, int col )
{
    register CELL *sp = scrnbuf;

    /* Skip frame to first cell. */
    sp += SCOLS + 1;
    sp += row * SCOLS;
    sp += col;

    /* Set cell state. */
    switch( action )
    {
        case OFF:
            mat1[row][col] -= 100;
            *sp = death;
            break;
        case ON:
            mat1[row][col] += 100;
            *sp = life;
            break;
        case TOGGLE:
            if( mat1[row][col] > 100 )
            {
                mat1[row][col] -= 100;
                *sp = death;
            }
            else
            {
                mat1[row][col] += 100;
                *sp = life;
            }
            break;
    }

    /* Show result on screen. */
    refresh( scrnbuf, cfg.videomem );
}

/* show_prompt - Displays a specified prompt line on the bottom of the
 * screen. If a non-null buffer is passed for a response, waits for the
 * user to enter a string.
 *
 * Params: prompt - prompt or help string
 *         response - buffer for string response (if NULL, no response)
 *
 * Return: TRUE if no response expected or valid received, FALSE if
 *         invalid response
 */
int show_prompt( char *prompt, char response[] )
{
    char tmp[81];

    /* Clear old prompt, and write new. */
    memset( tmp, ' ', 80 );
    tmp[80] = 0;
    _settextcolor( cfg.helpatrib & 0x00ff );
    _setbkcolor( (long)(cfg.helpatrib >> 4) );
    _settextposition( SROWS + 1, 1 );
    _outtext( tmp );
    _settextposition( SROWS + 1, 1 );
    _outtext( prompt );

    /* If a response buffer was passed, get a response for it. */
    if ( *response )
    {
        _displaycursor( _GCURSORON );
        tmp[0] = 80;
        cgets( tmp );
        strcpy( response, tmp + 2 );

        _displaycursor( _GCURSOROFF );
        if( *response )
            return TRUE;
        else
            return FALSE;
    }
    else
        return TRUE;
}

/* read_life - Reads a life pattern from a file. The pattern is bit decoded
 * (life for bit set, death for bit clear). If the file contains more cells
 * than the screen, extra cells are ignored. For example, this happens if
 * a pattern was saved in 25-line mode, but read in 43-line mode.
 *
 * Params: None
 *
 * Return: TRUE if successful, FALSE if unsuccessful
 *
 * Uses:   scrnbuf, cfg
 */
int read_life()
{
    CELL *scrnp = scrnbuf;          /* Pointer into screen buffer   */
    char *matp = (char *)mat1;      /* Pointer into matrix 1        */
    unsigned char mbyte, fbyte;     /* Mask byte and read byte      */
    int  i, j, k;                   /* Loop counters                */
    int  more = TRUE;               /* Continuation flag            */
    FILE *filep;                    /* Ptr to file struct           */
    char fname[81];                 /* File name buffer             */

    /* Fail if prompt or file open fails. */
    if( !show_prompt( file_str, fname ) )
        return FALSE;
    if( !(filep = fopen( fname, "rb" )) )
        return FALSE;

    /* Initialize buffer, screen, and pointers. */
    init_buf();
    init_mats();
    draw_box();
    scrnp += SCOLS + 1;

    /* Initialize mask byte and read first byte. */
    mbyte = 0x80;
    fread( (void *)&fbyte, 1, 1, filep );

    /* Count rows . . . */
    for( i = 0, k = 0; (i < cfg.mrows) && more; i++, scrnp += 2 )
    {
        /* Count columns . . . */
        for( j = 0; (j < cfg.mcols) && more; j++, scrnp++, matp++)
        {
            /* If bit is on, make cell live. */
            if( mbyte & fbyte )
            {
                *matp += 100;
                *scrnp = life;
            }

            /* Adjust mask and read another byte if necessary. */
            mbyte >>= 1;
            if( ++k > 7 )
            {
                k = 0;
                mbyte = 0x80;

                /* Quit if there are no more bytes in file. */
                if( !fread( (void *)&fbyte, 1, 1, filep ) )
                    more = FALSE;
            }
        }
    }

    /* Show on screen and close file. */
    refresh( scrnbuf, cfg.videomem );
    fclose( filep );
    return TRUE;
}

/* write_life - Writes a life pattern to a file. The pattern is bit encoded
 * (life for bit set, death for bit clear).
 *
 * Params: None
 *
 * Return: TRUE if successful, FALSE if unsuccessful
 *
 * Uses:   scrnbuf, cfg
 */
int write_life()
{
    char *matp = (char *)mat1;      /* Pointer into matrix 1    */
    unsigned char mbyte, fbyte;     /* Mask byte and read byte  */
    int  i, j, k;                   /* Loop counters            */
    FILE *filep;                    /* Ptr to file struct       */
    char fname[81];                 /* File name buffer         */

    /* Fail if prompt or file open fails. */
    if( !show_prompt( file_str, fname ) )
        return FALSE;
    if( !(filep = fopen( fname, "wb" )) )
        return FALSE;

    /* Initialize mask and read bytes. */
    mbyte = 0x80;
    fbyte = k = 0;

    /* Count rows . . . */
    for( i = 0; i < cfg.mrows; i++)
    {
        /* Count columns . . . */
        for( j = 0; j < cfg.mcols; j++, matp++)
        {
            /* If cell is live, turn bit on. */
            if( *matp > 100 )
                fbyte += mbyte;

            /* Adjust mask and write another byte if necessary. */
            mbyte >>= 1;
            if( ++k > 7 )
            {
                fwrite( (void *)&fbyte, 1, 1, filep );
                fbyte = k = 0;
                mbyte = 0x80;
            }
        }
    }

    /* Make sure last byte is written, then close file. */
    if( k > 0 )
        fwrite( (void *)&fbyte, 1, 1, filep );
    fclose( filep );
    return TRUE;
}

/* refresh - Writes buffer containing cells to the actual video screen
 * buffer. If CGA, adjust for rescan while copying. Otherwise, copy
 * directly. The CGA variation can only be done fast enough in assembly.
 *
 * Params: inbuffer - internal buffer containing cells
 *         outbuffer - pointer to hardware video memory
 *
 * Return: None
 *
 * Uses:   cfg
 */
void refresh( CELL inbuffer[], int far *outbuffer )
{
    int ssize = SBUFSIZE;

    _asm \
    {
        mov  si, inbuffer   ; Load src = screen buffer
        les  di, outbuffer  ; Load dest = video memory
        mov  cx, ssize      ; rows * columns
        cld                 ; DF = 0 (direction flag)

        cmp  cfg.rescan, FALSE  ; If not CGA, don't check rescan
        je   notcga

        mov  dx, 03DAh
wait0:
        sti
        nop
        cli
        lodsw               ; Load character and save in BX
        mov  bx, ax

wait1:  in   al, dx         ; Wait till horizontal active
        shr  al, 1
        jc   wait1
        cli

wait2:  in   al, dx         ; Wait till horizontal inactive (retrace)
        shr  al, 1
        jnc  wait2

        mov  ax, bx         ; Restore character and
        stosw               ;   move to video memory
        sti

        loop wait0          ; Next
        jmp SHORT getout    ; Done for CGA

notcga:                     ; Non-CGA version
        rep  movsw          ; Copy the whole screen with no waiting
getout:

    }
}
