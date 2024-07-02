/* TURTLE - Module of functions to implement turtle graphics. Turtle graphics
 * is a model for specifying relative movements of an imaginary pointer whose
 * direction, color, visibility, and other attributes are given default
 * values using turtle functions. To use the turtle module, include TURTLE.H
 * in your program. The following functions (many defined as macros)
 * are public :
 *
 *   InitTurtle      - Initiate turtle graphics
 *   Home            - Reset turtle defaults
 *   PenDown         - Set pen visibility
 *   SetFill         - Set fill state
 *   PenColor        - Set pen color index
 *   BorderColor     - Set border color index
 *   Turn            - Set direction relative to current
 *   TurnTo          - Set absolute direction
 *   Move            - Move in current direction
 *   MoveTo          - Move to absolute location
 *   Poly            - Draw a polygon
 *   Circle          - Draw a circle with center at current location
 *   Ellipse         - Draw an ellipse with center at current location
 *   Rectangle       - Draw a rectangle with center at current location
 *   ImageSize       - Get size of rectangle with top-left origin
 *   GetImage        - Get rectangular image with top-left origin
 *   PutImage        - Put rectangular image with top-left origin
 *   FillIn          - Fill from the current location to border
 *   NextColorIndex  - Rotate to next color index
 *   NextColorValue  - Rotate to next color value
 *   OnScreen        - Report whether current location is on screen
 *   RGB             - Combine Red, Green, and Blue elements of color value
 *
 * The TURTLE structure, the "tc" global variable (having TURTLE type), and
 * "vlColors" variable are defined. However, these are not normally used
 * directly by the programmer.
 */

#include <graph.h>
#include <math.h>
#include <string.h>
#include "turtle.h"

#define PI       3.141593

long cvlColors[256];            /* Array of long color values              */

TURTLE tc = { 1.39 };    /* Initial aspect - adjust for your screen */

/* InitTurtle - Initializes all turtle defaults. This function should be
 * called at least once (after _setvideomode and _getvideoconfig) and
 * additionally after any change to a new graphics mode.
 *
 * Params: vc - pointer to videoconfig structure
 *
 * Return: 0 if fail, 1 if success
 *
 * Uses:   tc structure variable cvlColors array
 */
short InitTurtle( struct videoconfig *vc )
{
    int i;
    unsigned cvuInc, cvuRed, cvuGreen, cvuBlue; /* Unsigned portions of */
    static int mode = -1;                       /*   color values       */

    /* Terminate if not graphics mode. */
    if( !vc->numxpixels )
        return 0;

    /* If mode has changed, set window coordinates. */
    if( mode != vc->mode )
    {
        mode = vc->mode;
        tc.xsLeft = tc.ysTop = 0;
        tc.xsRight = vc->numxpixels - 1;
        tc.ysBot = vc->numypixels - 1;
    }

    /* Set palette flag. */
    switch( vc->adapter )
    {
        case _MDPA:
        case _CGA:
        case _OCGA:
        case _HGC:
            tc.fPalette = FALSE;
            break;
        default:
            tc.fPalette = TRUE;
            break;
    }

    /* Set palette defaults. */
    switch( vc->mode )
    {
        case _HRESBW:
        case _HERCMONO:
        case _ERESNOCOLOR:
        case _ORESCOLOR:
        case _VRES2COLOR:
            tc.ccv = 0;
            tc.cci = 2;
            return Home();
        case _MRES256COLOR:        /* Active bits in this order:          */
            cvuInc = 12;
            tc.ccv = tc.cci = 125; /* ???????? ??bbbbbb ??gggggg ??rrrrrr */
            break;
        case _ERESCOLOR:
            if( vc->memory == 64 )
            {
                cvuInc = 32;
                tc.ccv = 16;       /* ???????? ??????Bb ??????Gg ??????Rr */
                tc.cci = 4;
                break;
            } /* Else fall through */
        case _VRES16COLOR:
            cvuInc = 16;
            tc.ccv = 64;           /* ???????? ??????bb ??????gg ??????rr */
            tc.cci = 16;
            break;
        case _MRES4COLOR:
        case _MRESNOCOLOR:
            cvuInc = 32;
            tc.ccv = 16;           /* ???????? ??????Bb ??????Gg ??????Rr */
            tc.cci = 4;
            break;
        case _MRES16COLOR:
        case _HRES16COLOR:
            cvuInc = 32;
            tc.cci = tc.ccv = 16;  /* ???????? ??????Bb ??????Gg ??????Rr */
            break;
    }

    /* Fill palette arrays. */
    for( i = 0, cvuBlue = 0; cvuBlue < 64; cvuBlue += cvuInc )
        for( cvuGreen = 0; cvuGreen < 64; cvuGreen += cvuInc )
            for( cvuRed = 0; cvuRed < 64; cvuRed += cvuInc )
                {
                    cvlColors[i] = RGB( cvuRed, cvuGreen, cvuBlue );
                    /* Special case of 6 bits for 16 colors (RGBI).
                     * If both bits are on for any color, intensity is set.
                     * If one bit is set for a color, that color is on.
                     */
                    if( cvuInc == 32 )
                        cvlColors[i + 8] = cvlColors[i] | (cvlColors[i] >> 1);
                    i++;
                }
    cvlColors[tc.ccv - 1] = _BRIGHTWHITE;
    NextColorValue( DEFAULT );
    return Home();
}

/* Home - Resets turtle defaults. This function can be called if you have
 * not changed the video mode, but you want to put the turtle back in
 * the center of the window and restore all defaults. For example, you can
 * change the absolute window corners and then call it to set a new
 * turtle window.
 *
 * Params: None
 *
 * Return: 0 if fail, 1 if success
 *
 * Uses:   tc
 */
short Home()
{
    struct _wxycoord xy1, xy2;

    _setviewport( tc.xsLeft, tc.ysTop, tc.xsRight, tc.ysBot );

    /* Set the window based on screen height 1000 and width based on
     * aspect ratio.
     */
    tc.yMax = 500.0;
    tc.xMax = tc.yMax * tc.yxRatio;
    if( !_setwindow( FALSE, -tc.xMax, -tc.yMax, tc.xMax, tc.yMax ) )
        return 0;

    /* Calculate the unit size of 1 pixel using Y axis. */
    xy1 = _getwindowcoord( 1, 1 );
    xy2 = _getwindowcoord( 1, 2 );
    tc.yUnit = xy2.wy - xy1.wy;

    /* Set defaults for current pixel, angle, pen state and fill state. */
    tc.xCur = tc.yCur = 0.0;
    _moveto_w( tc.xCur, tc.yCur );
    TurnTo( 0 );
    PenDown( TRUE );
    SetFill( FALSE );

    /* Make white the last color index and set pen and border to it. */
    _remappalette( WHITE, _BRIGHTWHITE );
    BorderColor( WHITE );
    PenColor( WHITE );
    _setbkcolor( _BLACK );
    return 1;
}

/* PenDown - Sets the visibility of the pen used by Move and MoveTo. The
 * state can be TRUE (visible), FALSE (invisible), or DEFAULT (return
 * current without changing).
 *
 * Params: fPenDown
 *
 * Return: current pen state
 *
 * Uses:   tc
 */
int PenDown( int fPenDown )
{
    switch( fPenDown )
    {
        case DEFAULT:
            break;
        case FALSE:
            tc.fPenDown = FALSE;
            break;
        default:
            tc.fPenDown = TRUE;
            break;
    }
    return tc.fPenDown;
}

/* SetFill - Determines the state of filling figures such as Rectangle,
 * Circle, and Ellipse. State can be TRUE (fill inside), FALSE (border
 * only), or DEFAULT (return current fill state).
 *
 * Params: fFill
 *
 * Return: current fill state
 *
 * Uses:   tc
 */
short SetFill( short fFill )
{
    switch( fFill )
    {
        case DEFAULT:
            break;
        case _GBORDER:
        case FALSE:
            tc.fFill = _GBORDER;
            break;
        default:
            tc.fFill = _GFILLINTERIOR;
            break;
    }
    return tc.fFill;
}

/* PenColor - Sets the color index of the pen.
 *
 * Params: ciCur - any color index of DEFAULT to return without changing
 *
 * Return: current pen color index
 *
 * Uses:   tc
 */
short PenColor( short ciCur )
{
    if( ciCur != DEFAULT )
        _setcolor( tc.ciCur = ciCur );
    return tc.ciCur;
}

/* BorderColor - Sets the color index of the border that will be recognized
 * by fills.
 *
 * Params: ciBorder - any color index of DEFAULT to return without changing
 *
 * Return: current border color index
 *
 * Uses:   tc
 */
short BorderColor( short border )
{
    if( border != DEFAULT )
        tc.ciBorder = border;
    return tc.ciBorder;
}

/* Turn - Sets a new direction relative to the current direction.
 *
 * Params: angCur - a positive (clockwise) or negative (counterclockwise)
 *           angle in degrees
 *
 * Return: new current absolute angle
 *
 * Uses:   tc
 */
short Turn( short angCur )
{
    return( tc.angCur = ((tc.angCur + angCur) % CIRCUMFERENCE) );
}

/* TurnTo - Sets a new absolute direction.
 *
 * Params: angCur - a positive (clockwise) or negative (counterclockwise)
 *           angle in degrees (0 points to 12 o'clock)
 *
 * Return: new current absolute angle
 *
 * Uses:   tc
 */
short TurnTo( short angCur )
{
    if( angCur < 0 )
        return( tc.angCur = 360 - (angCur % CIRCUMFERENCE) );
    else
        return( tc.angCur = angCur % CIRCUMFERENCE );
}

/* Move - Moves from the current position in the current direction for a
 * specified distance. A line is drawn if the pen is down. The current
 * position is reset to the destination.
 *
 * Params: dxy - difference between current xy and new xy
 *
 * Return: 0 if new position is off screen, nonzero if on screen
 *
 * Uses:   tc
 */
short Move( double dxy )
{
    double dx, dy;          /* Differences of X and Y */
    double angT;

    /* Calculate new X and Y positions. */
    angT = (tc.angCur - 90) * (PI / HALFCIRCUMFERENCE);
    dx = dxy * cos( angT );
    dy = dxy * sin( angT );

    /* Move, drawing if pen down, then update position */
    if( tc.fPenDown )
        _lineto_w( tc.xCur + dx, tc.yCur + dy );
    else
        _moveto_w( tc.xCur + dx, tc.yCur + dy );
    tc.xCur += dx;
    tc.yCur += dy;
    return OnScreen();
}

/* MoveTo - Moves from the current position to a specified position. A
 * line is drawn if the pen is down. The current position is reset to the
 * destination. The current direction is not changed.
 *
 * Params: x and y - destination position
 *
 * Return: 0 if new position is off screen, nonzero if on screen
 *
 * Uses:   tc
 */
short MoveTo( double x, double y )
{
    if( tc.fPenDown )
        _lineto_w( x, y );
    else
        _moveto_w( x, y );
    tc.xCur = x;
    tc.yCur = y;
    return OnScreen();
}

/* Poly - Draws a polygon.
 *
 * Params: cSide - count of polygon sides
 *         dxySide - distance of each side
 *
 * Return: 0 if any part of polygon is off screen, nonzero if on screen
 */
short Poly( int cSide, double dxySide )
{
    short i, angT, fPen, ret = TRUE;

    /* Make sure pen is down (restore pen state when done). */
    fPen = PenDown( TRUE );

    /* Calculate angle, then draw each side. */
    angT = 360 / cSide;
    for( i = 1; i <= cSide; i++ )
    {
        ret = Move( dxySide ) && ret;
        Turn( angT );
    }
    PenDown( fPen );
    return ret;
}

/* NextColorIndex - Rotate to next color index. First attribute (normally
 * background) and last attribute (white) are skipped.
 *
 * Params: ciCur - Specify DEFAULT to use color index from last call,
 *           or specify a new color to rotate from
 *
 * Return: rotated color index
 *
 * Uses:   tc
 */
short NextColorIndex( short ciCur )
{
    static short ciPrev = 0;    /* Static to retain index between calls */

    /* Assign new current if given. */
    if( ciCur != DEFAULT )
        ciPrev = ciCur;

    /* Toggle for two-color modes, rotate for multi-color modes. */
    if( tc.cci == 2 )
        return( ciPrev = !ciPrev );
    else
        return( ciPrev = (++ciPrev % (tc.cci - 1)) );
}

/* NextColorValue - Rotate to next color value for adapters (EGA
 * and higher) that support remappable palettes.
 *
 * Params: fAction - DEFAULT (rotate all) or LIMITED (rotate first 14 only)
 *
 * Return: None
 *
 * Uses:   tc
 */
void NextColorValue( int fAction )
{
    static int icvCur = 1;  /* Current index into color value array */
    static int ciCur = 1;   /* Current color index                  */
    int icvT;               /* Temporary index into color values    */
    int i;

    /* Ignore modes with no palette values. */
    if( !tc.fPalette || !tc.ccv )
        return;

    /* Increment and rotate color value index. */
    icvT = (++icvCur % (tc.ccv - 2)) + 1;


    /* DEFAULT - Remap all color indexes, 14 at a time. For most modes,
     * this is all the indexes  except first and last. For 256-color
     * mode, rotating all available indexes would be too slow.
     */
    if( fAction == DEFAULT )
        for( i = 1; i <= 14; i++ )
            _remappalette( (ciCur++ % (tc.cci - 2)) + 1,
                           cvlColors[(icvT++ % (tc.ccv - 2)) + 1] );

    /* LIMITED - Rotate only the first 14 color indexes. */
    else
        for( i = 1; i <= 14; i++ )
            _remappalette( i, cvlColors[(icvT++ % (tc.ccv - 1)) + 1] );
}
