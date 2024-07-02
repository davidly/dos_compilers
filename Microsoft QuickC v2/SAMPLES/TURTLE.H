/* Function prototypes, macros, structure, and global variables for
 * Turtle Graphics functions.
 */

/* Initiate and set defaults */
short InitTurtle( struct videoconfig *vc );
short Home( struct videoconfig *vc );

/* Control pen and color */
int   PenDown( int state );
short SetFill( short state );
short PenColor( short atrib );
short BorderColor( short border );

/* Control angle */
short Turn( short angle );
short TurnTo( short angle );

/* Turtle movement */
short Move( double distance );
short MoveTo( double x, double y );
short Poly( int number, double side );

/* Rotate color index or value */
short NextColorIndex( short ciCur );
void  NextColorValue( int fAction );

/* Put a circle with radius <r> at current location. */
#define Circle( r ) _ellipse_w( tc.fFill, tc.xCur-(r), tc.yCur-(r), \
                                          tc.xCur+(r), tc.yCur+(r) )

/* Puts an ellipse with width <w> and height <h> at current location. */
#define Ellipse( w, h ) _ellipse_w( tc.fFill, \
                                    tc.xCur-((w)/2), tc.yCur-((h)/2), \
                                    tc.xCur+((w)/2), tc.yCur+((h)/2) )

/* Puts the center of a rectangle with width <w> and height <h>
 * at current location.
 */
#define Rectangle( w, h ) _rectangle_w( tc.fFill, \
                                        tc.xCur-((w)/2), tc.yCur-((h)/2), \
                                        tc.xCur+((w)/2), tc.yCur+((h)/2) )

/* Gets the imagesize of an image with width <w> and height <h>
 * with left-top at current location. Returns image size.
 */
#define ImageSize( w, h ) _imagesize_w( tc.xCur, tc.yCur, \
                                        tc.xCur+(w), tc.yCur+(h) )

/* Gets an image with width <w> and height <h> with left-top
 * at current location. Returns image buffer.
 */
#define GetImage( w,h,buf) _getimage_w( tc.xCur, tc.yCur, \
                                        tc.xCur+(w), tc.yCur+(h), buf )

/* Puts the top-left corner of a specified image at current location
 * using a specified action (_GPSET, _GPRESET, _GAND, _GOR, _GXOR).
 */
#define PutImage( buf, act )  _putimage_w( tc.xCur, tc.yCur, buf, act )

/* Fills starting at the current location and continues to border. */
#define FillIn() _floodfill_w( tc.xCur, tc.yCur, tc.ciBorder )

/* Returns nonzero if the current location is onscreen. */
#define OnScreen() (!((tc.xCur < -tc.xMax) || (tc.xCur > tc.xMax) || \
                      (tc.yCur < -tc.yMax) || (tc.yCur > tc.yMax)))

/* Returns a long int mixed from red, green, and blue bytes. */
#define RGB( r,g,b) (((long)((b) << 8 | (g)) << 8) | (r))

/* Constants */
#define CIRCUMFERENCE     360
#define HALFCIRCUMFERENCE 180

#define DEFAULT -1
#define LIMITED  0
#define TRUE     1
#define FALSE    0
#define WHITE (tc.cci - 1)

/* Structures for configuration and other data */
struct TURTLE
{
    double  yxRatio;                /* Y to X aspect ratio          */
    double  xMax, yMax;             /* Maximum x and y              */
    double  yUnit;                  /* Window size of one pixel     */
    double  xCur, yCur;             /* Current position             */
    short   cci;                    /* Count of color indexes       */
    short   ccv;                    /* Count of color values        */
    short   ciCur;                  /* Current color index          */
    short   ciBorder;               /* Current border color index   */
    short   angCur;                 /* Current angle                */
    int     fPenDown;               /* Pen state                    */
    int     fFill;                  /* Fill state                   */
    int     fPalette;               /* Palette availability         */
    short   xsLeft, xsRight;        /* Absolute window corners      */
    short   ysTop, ysBot;
}
extern struct TURTLE tc;
