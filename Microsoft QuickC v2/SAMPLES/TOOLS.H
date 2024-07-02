/* TOOLS.H - Contains definitions for general constants and macros,
 * as well as constants and prototypes for functions in TOOLS.C
 */

#define TRUE 1
#define FALSE 0

/* Text output colors. Note that monochrome can only use _TBLACK,
 * _TWHITE, _TBRIGHTWHITE, and _TUNDERLINE. Graphics black-and-white
 * can only use the first three of these. The first eight colors
 * can be used as background colors (although they may need to be
 * cast to long).
 */
enum TEXTCOLORS
{
    _TBLACK,        _TBLUE,         _TGREEN,        _TCYAN,
    _TRED,          _TMAGENTA,      _TBROWN,        _TWHITE,
    _TGREY,         _TLIGHTBLUE,    _TLIGHTGREEN,   _TLIGHTCYAN,
    _TLIGHTRED,     _TLIGHTMAGENTA, _TLIGHTYELLOW,  _TBRIGHTWHITE,
};
#define _TUNDERLINE 1

/* Macros to combine background and foreground colors, and to combine
 * starting and ending cursor lines.
 */
#define SETATRIB( fore, back )   ( ((back) << 4) | (fore))
#define SETCURSOR( first, last ) ( ((first) << 8) | (last))

/* Action codes for getkey */
enum WAITACTION { NO_WAIT, WAIT, CLEAR_WAIT };

/* Prototypes of functions in TOOLS.C */
void delay( clock_t wait );
unsigned getkey( int waitflag );
