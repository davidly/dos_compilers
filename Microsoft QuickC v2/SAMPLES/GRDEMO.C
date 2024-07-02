/* GRDEMO.C - Demonstrates capabilities of the QuickC graphics library.
 * Uses MENU module to display menus. Uses TURTLE module for Turtle graphics.
 */

#include <graph.h>
#include <math.h>
#include <malloc.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include "turtle.h"
#include "menu.h"

/* Function prototypes */
int  main( void );
void Circles( void );
void Sphere( void );
int  Polygons( void );
int  Spiral( int angle, double inc );
int  InSpiral( double side, int angle, int inc );
void Bug( void );
void Adjust( void );

/* Returns a random number between min and max, which must be in
 * integer range.
 */
#define getrandom( min, max ) ((rand() % (int)((max) - (min))) + (min) + 1)

/* Constants */
#define PI      3.141593
#define LASTATR 15
#define NLASTATR 14

/* Array and enum for main menu */
struct ITEM mnuMain[] =
{               /* Highlight  Char  Pos */
    0, "Quit",              /* Q     0  */
    0, "Circles",           /* C     0  */
    0, "Rotating Sphere",   /* R     0  */
    0, "Tunnel",            /* T     0  */
    0, "Spiral",            /* S     0  */
    0, "Inverted Spiral",   /* I     0  */
    0, "Bug",               /* B     0  */
    0, "Adjust Window",     /* A     0  */
    0, "Mode Change",       /* M     0  */
    0, NULL
};

/* Define constants (0, 1, 2,...) for menu choices */
enum CHOICES
{
    QUIT, CIRCLES, SPHERE, TUNNEL, SPIRAL, INSPIRAL, BUG, ADJUST, CHANGE
};

/* Arrays of video mode menu items and of corresponding mode numbers.
 * Each has a temporary array containing all items, and a pointer version
 * including all except Olivetti.
 */
struct ITEM mnuModesT[] =
{               /* Highlight  Char  Pos */
    0, "ORESCOLOR ",        /* O     0  */
    4, "MRES4COLOR ",       /* 4     4  */
    4, "MRESNOCOLOR",       /* N     4  */
    4, "HRESBW",            /* B     4  */
    0, "MRES16COLOR",       /* M     0  */
    0, "HRES16COLOR",       /* H     0  */
    0, "ERESCOLOR",         /* E     0  */
    4, "VRES2COLOR",        /* 2     4  */
    0, "VRES16COLOR",       /* V     0  */
    1, "MRES256COLOR",      /* R     4  */
    0, NULL
};
struct ITEM *mnuModes = &mnuModesT[1];  /* Default is no Olivetti mode */

int aModesT[] =
{
    _ORESCOLOR,
    _MRES4COLOR,
    _MRESNOCOLOR,
    _HRESBW,
    _MRES16COLOR,
    _HRES16COLOR,
    _ERESCOLOR,
    _VRES2COLOR,
    _VRES16COLOR,
    _MRES256COLOR,
    _TEXTMONO,
    _ERESNOCOLOR,
    _HERCMONO
};
int *aModes = &aModesT[1];              /* Default is no Olivetti mode */

/* Global video configuration */
struct videoconfig vc;

int main()
{
    int rowMid, colMid;
    int fColor, fFirstTime = TRUE;
    int iMode, iMainCur = 0, iModesCur = 0;

    _displaycursor( _GCURSOROFF );
    _getvideoconfig( &vc );
    rowMid = vc.numtextrows / 2;
    colMid = vc.numtextcols / 2;

    /* Select best graphics mode, adjust menus, set color flag. Note
     * that this requires checking both the adapter and the mode.
     */
    switch( vc.adapter )
    {
        case _OCGA:
            mnuModes = &mnuModesT[0];           /* Turn on Olivetti mode */
            aModes = &aModesT[0];
        case _CGA:
            mnuModesT[4].achItem[0] = '\0';     /* Turn off EGA modes    */
            iMode = _MRES4COLOR;
            break;
        case _HGC:
            mnuModesT[7].achItem[0] = '\0';
            iMode = _HERCMONO;
            break;
        case _OEGA:
            mnuModes = &mnuModesT[0];           /* Turn on Olivetti mode */
            aModes = &aModesT[0];
        case _EGA:
            mnuModesT[7].achItem[0] = '\0';     /* Turn off VGA modes    */
            if( vc.memory > 64 )
                iMode = _ERESCOLOR;
            else
                iMode = _HRES16COLOR;
            break;
        case _OVGA:
            mnuModes = &mnuModesT[0];           /* Turn on Olivetti mode */
            aModes = &aModesT[0];
        case _VGA:
            iMode = _VRES16COLOR;
            break;
        case _MCGA:
            iMode = _MRES256COLOR;
            break;
        case _MDPA:
        default:
            puts( "No graphics mode available.\n" );
            return TRUE;
    }
    switch( vc.mode )
    {
        case _TEXTBW80:
        case _TEXTBW40:
            fColor = FALSE;
            break;
        case _TEXTMONO:
        case _ERESNOCOLOR:
        case _HERCMONO:
            fColor = FALSE;
            if( iMode != _HERCMONO )
                iMode = _ERESNOCOLOR;
            mnuMain[8].achItem[0] = '\0';       /* Turn off mode change */
            break;
        default:
            fColor = TRUE;
            break;
    }

    /* Find current mode in mode array. */
    for( iModesCur = 0; aModes[iModesCur] != iMode; iModesCur++ )
        ;

    /* Seed randomizer with time. */
    srand( (unsigned)time( NULL ) );

    while( TRUE )
    {
        /* Set text mode and optionally clear the screen to blue. */
        _setvideomode(_DEFAULTMODE );
        if( fColor )
            _setbkcolor( (long)_TBLUE );
        _clearscreen( _GCLEARSCREEN );

        /* Select from menu. */
        iMainCur = Menu( rowMid, colMid, mnuMain, iMainCur );

        /* Set graphics mode and initialize turtle graphics. Put border
         * on window.
         */
        if( iMainCur != CHANGE )
        {
            _setvideomode( iMode );
            _displaycursor( _GCURSOROFF );
            _getvideoconfig( &vc );
            InitTurtle( &vc );
            Rectangle( 2 * tc.xMax, 2 * tc.yMax );
        }

        /* Branch to menu choice. */
        switch( iMainCur )
        {
            case QUIT:
                _setvideomode( _DEFAULTMODE );
                return FALSE;
            case CIRCLES:
                Circles();
                break;
            case SPHERE:
                Sphere();
                break;
            case TUNNEL:
                PenDown( FALSE );
                MoveTo( -tc.xMax * .2, tc.yMax * .15 );
                PenDown( TRUE );
                Polygons();
                while( !GetKey( NO_WAIT ) )
                    NextColorValue( DEFAULT );   /* Rotate palette */
                break;
            case SPIRAL:
                if( Spiral( getrandom( 30, 80 ), (double)getrandom( 1, 5 ) ) )
                    break;
                while( !GetKey( NO_WAIT ) )
                    NextColorValue( DEFAULT );
                break;
            case INSPIRAL:
                NextColorIndex( 0 );
                if( InSpiral( (double)getrandom( 8, 20 ),
                              getrandom( 4, 22 ),
                              getrandom( 3, 31 ) ) )
                    break;
                while( !GetKey( NO_WAIT ) )
                    NextColorValue( DEFAULT );
                break;
            case BUG:
                Bug();
                break;
            case ADJUST:
                Adjust();
                continue;
            case CHANGE:
                if( fColor )
                    _setbkcolor( (long)_TBLUE );
                _clearscreen( _GCLEARSCREEN );

                iModesCur = Menu( rowMid, colMid, mnuModes, iModesCur );
                iMode = aModes[iModesCur];
                if( vc.adapter == _MCGA )
                    switch( iMode )
                    {
                        case _MRES16COLOR:
                        case _HRES16COLOR:
                        case _ERESCOLOR:
                        case _VRES16COLOR:
                            _settextposition( 1, 22 );
                            _outtext( "Mode not recognized" );
                            iMode = _MRES256COLOR;
                    }
                break;
        }
    }
}

/* Circles - Draw circles of varying sizes and colors on screen in a
 * round pattern.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   tc
 */
void Circles()
{
    double x, y, xyRadius;
    int fFill, fPenDown;

    /* Initialize and save pen and fill flags. */
    if( tc.cci <= 4 )
        fFill = SetFill( FALSE );
    else
        fFill = SetFill( TRUE );
    fPenDown = PenDown( FALSE );

    while( TRUE )
    {
        /* Draw circles. */
        for( xyRadius = 10.0; xyRadius <= 130.0; xyRadius++ )
        {
            x = (tc.xMax - 30) * atan( sin( xyRadius / PI ) );
            y = (tc.yMax - 30) * atan( cos( xyRadius / PI ) );
            MoveTo( x, y );
            PenColor( NextColorIndex( DEFAULT ) );
            Circle( xyRadius );
            if( GetKey( NO_WAIT ) )
            {
                PenDown( fPenDown );
                SetFill( fFill );
                return;
            }
        }

        /* For palette modes (except 256 color), start over. */
        if( tc.ccv == 64 || tc.ccv == 16 )
        {
            _clearscreen( _GCLEARSCREEN );
            SetFill( FALSE );
            MoveTo( 0.0, 0.0 );
            PenColor( WHITE );
            Rectangle( 2 * tc.xMax, 2 * tc.yMax );
            SetFill( fFill );
            NextColorValue( DEFAULT );
        }
    }
}

/* Sphere - Draw and fill slices of a sphere. Rotate colors in EGA+ modes
 * with more than 4 color indexes.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   tc
 */
void Sphere()
{
    double xCur, xSize, ySize, xInc;
    short ciBorder, fFill;
    short cvi = 0, ci = 0, c = 0;
    extern long cvlColors[];

    ySize = xSize = tc.yMax * 0.9 * 2;
    fFill = SetFill( FALSE );
    NextColorIndex( 0 );
    xInc = xSize / 14;
    ciBorder = PenColor( DEFAULT );
    BorderColor( ciBorder );

    /* Draw slices. */
    for( xCur = xInc; xCur <= xSize; xCur += xInc * 2 )
        Ellipse( xCur, ySize );
    SetFill( TRUE );
    PenDown( FALSE );
    Turn( 90 );
    xSize /= 2;
    MoveTo( xSize - xInc, 0.0 );

    NextColorValue( LIMITED );

    /* Fill slices. */
    while( tc.xCur >= (-xSize + xInc))
    {
        PenColor( NextColorIndex( DEFAULT ) );
        FillIn();
        Move( -xInc );
    }

    while( !GetKey( NO_WAIT ) )
        NextColorValue( LIMITED );

    PenDown( TRUE );
    SetFill( fFill );
}

/* Polygons - Draws polygons (starting with triangle) of increasing
 * size by incrementing the number of sides without changing the
 * length of sides. Make sure pen is down.
 *
 * Params: None
 *
 * Return: 1 for user interrupt, 0 for edge of screen encountered
 *
 * Uses:   tc
 */
int Polygons()
{
    int cSides = 3, atrib = 1;
    double dxy = tc.yUnit;

    while( TRUE )
    {
        PenColor( NextColorIndex( DEFAULT ) );
        if( !Poly( cSides++, dxy += 1.5 ) )
            return FALSE;
        if( GetKey( NO_WAIT ) )
            return TRUE;
    }
}

/* Spiral - Draw a spiral by incrementing the length of each side
 * of a rotating figure.
 *
 * Params: ang - determines tightness
 *         xyInc - determines size of sides
 *
 * Return: 1 for user interrupt, 0 for edge of screen encountered
 *
 * Uses:   tc
 */
int Spiral( int ang, double xyInc )
{
    double xy = tc.yUnit;

    while( TRUE )
    {
        PenColor( NextColorIndex( DEFAULT ) );
        if( !Move( xy += xyInc ) )
            return FALSE;
        Turn( ang );
        if( GetKey( NO_WAIT ) )
            return TRUE;
    }
}

/* InSpiral - Draw an inverted spiral by increasing each angle
 * of a rotating figure while keeping the length of sides constant.
 *
 * Params: xy - determines size
 *         ang - initial angle determines shape
 *         angInc - determines tightness and shape
 *
 * Return: 1 for user interrupt, 0 for edge of screen encountered
 */
int InSpiral( double xy, int ang, int angInc )
{
    while( TRUE )
    {
        PenColor( NextColorIndex( DEFAULT ) );
        if( !Move( xy ) )
            return FALSE;
        Turn( ang += angInc );
        if( GetKey( NO_WAIT ))
            return TRUE;
    }
}

/* Bug - Draws a winged bug on the screen. Then moves it randomly
 * around the screen.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   tc
 */
void Bug()
{

    static unsigned char uTopWing[] = { 0x81, 0x3c, 0xc3, 0x66,
                                        0x66, 0x0f, 0xf0, 0x18 };
    static unsigned char uBotWing[] = { 0x66, 0x0f, 0xf0, 0x18,
                                        0x81, 0x3c, 0xc3, 0x66 };
    char *buffer;               /* Buffer for image */

    /* Draw bug. */
    PenDown( FALSE );
    SetFill( TRUE );
    Move( 40.0 );               /* Draw and fill front wings */
    Turn( 90 );
    Move( 80.0 );
    PenColor( 1 );
    _setfillmask( uTopWing );
    Ellipse( 172.0, 70.0 );
    Turn( 180 );
    Move( 160.0 );
    Ellipse( 172.0, 70.0 );
    Turn(-90 );
    MoveTo( 0.0, 0.0 );
    Move( 25.0 );               /* Draw and fill back wings */
    Turn( 90 );
    Move( 70.0 );
    PenColor( 2 );
    _setfillmask( uBotWing );
    Ellipse( 150.0, 70.0 );
    Turn( 180 );
    Move( 140.0 );
    Ellipse( 150.0, 70.0 );
    Turn(-90 );
    MoveTo( 0.0, 0.0 );
    _setfillmask( NULL );       /* Draw body */
    PenColor( 3 );
    BorderColor( 3 );
    Ellipse( 52.0, 220.0 );
    PenColor( 1 );              /* Drill eyes */
    BorderColor( 1 );
    SetFill( FALSE );
    Move( 90.0 );
    Turn( 90 );
    Move( 22.0 );
    Circle( 20.0 );
    PenColor( 0 );
    FillIn();
    PenColor( 1 );
    Turn( 180 );
    Move( 44.0 );
    Circle( 20.0 );
    PenColor( 0 );
    FillIn();

    /* Move into position - top-right of image. */
    MoveTo( 0.0, 0.0 );
    TurnTo( 0 );
    Move( 120.0 );
    Turn( -90 );
    Move( 175.0 );
    Turn( 90 );

    /* Size image and allocate memory for it. */
    buffer = (char *)malloc( (size_t)ImageSize( 350.0, 240.0 ) );
    GetImage( 350.0, 240.0, buffer );

    /* Move randomly, adjusting at edges. */
    while( !GetKey( NO_WAIT ) )
    {
        if( tc.xCur <= (-tc.xMax + 15.0) )
            TurnTo( 90 );
        else if( tc.yCur <= (-tc.yMax + 15.0) )
            TurnTo( 180 );
        else if( tc.xCur >= (tc.xMax - 365.0) )
            TurnTo( 270 );
        else if( tc.yCur >= (tc.yMax - 255.0) )
            TurnTo( 0 );
        else
            Turn( getrandom( -20, 20 ) );
        Move( 3.0 );
        PutImage( buffer, _GPSET );
    }
    free( (char *)buffer );
}

/* Adjust - Allow the user to interactively adjust the display window.
 * Unshifted direction keys adjust the window size. Shifted direction
 * keys move the window. The numeric keypad plus and minus keys adjust
 * aspect without changing the window. A window frame and a circle give
 * visual feedback on adjustments.
 *
 * Params: None
 *
 * Return: None
 *
 * Uses:   tc and vc
 */
#define WININC 4
void Adjust()
{
    short i;
    double xyRadius = 400.0;
    char achT[40];

    while( TRUE )
    {
        /* Display instructions. */
        _settextposition( 2, 1 );
        _outtext(" Grey PLUS and MINUS Adjust aspect\n" );
        _outtext(" Cursor keys         Size window\n" );
        _outtext(" SHIFT cursor keys   Move window\n" );
        _outtext(" ENTER               Finished\n\n" );
        sprintf( achT, "\n  ratio=%1.2f  xMax=%.f  yMax=%.f",
                 tc.yxRatio, tc.xMax, tc.yMax );
        _outtext( achT );
        Rectangle( 2 * tc.xMax,  2 * tc.yMax );
        PenDown( FALSE );

        /* Draw circle with cross. */
        MoveTo( 75.0, 0.0 );
        Circle( xyRadius );
        for( i = 1; i <= 4; i++)
        {
            PenDown( TRUE );
            Move( xyRadius );
            Turn( 180 );
            PenDown( FALSE );
            Move( xyRadius );
            Turn( 90 );
        }

        switch( GetKey( CLEAR_WAIT ) )
        {
            /* Adjust aspect. */
            case N_MINUS:
                tc.yxRatio = (tc.xMax - (WININC * tc.yUnit)) / tc.yMax;
                break;
            case N_PLUS:
                tc.yxRatio = (tc.xMax + (WININC * tc.yUnit)) / tc.yMax;
                break;

            /* Adjust window size. */
            case U_RT:
                if( tc.xsLeft < (vc.numxpixels / 3) )
                    tc.xsLeft += WININC;
                if( tc.xsRight > (vc.numxpixels - (vc.numxpixels / 3)) )
                    tc.xsRight -= WININC;
                break;
            case U_LT:
                if( tc.xsLeft )
                    tc.xsLeft -= WININC;
                if( tc.xsRight < vc.numxpixels )
                    tc.xsRight += WININC;
                break;
            case U_DN:
                if( tc.ysTop < (vc.numypixels / 3) )
                    tc.ysTop += WININC;
                if( tc.ysBot > (vc.numypixels - (vc.numypixels / 3)) )
                    tc.ysBot -= WININC;
                break;
            case U_UP:
                if( tc.ysTop )
                    tc.ysTop -= WININC;
                if( tc.ysBot < vc.numypixels )
                    tc.ysBot += WININC;
                break;

            /* Adjust window position. */
            case S_LT:
                if( tc.xsLeft )
                {
                    tc.xsLeft -= WININC;
                    tc.xsRight -= WININC;
                }
                break;
            case S_RT:
                if( tc.xsRight < vc.numxpixels )
                {
                    tc.xsLeft += WININC;
                    tc.xsRight += WININC;
                }
                break;
            case S_UP:
                if( tc.ysTop )
                {
                    tc.ysTop -= WININC;
                    tc.ysBot -= WININC;
                }
                break;
            case S_DN:
                if( tc.ysBot < vc.numypixels )
                {
                    tc.ysTop += WININC;
                    tc.ysBot += WININC;
                }
                break;

            /* Finished. */
            case ENTER:
                return;

            /* Ignore unknown key. */
            default:
                Home( &vc );
                continue;
        }
        /* Clear screen and reset defaults after each adjustement. */
        _clearscreen( _GCLEARSCREEN );
        Home( &vc );
    }
}
