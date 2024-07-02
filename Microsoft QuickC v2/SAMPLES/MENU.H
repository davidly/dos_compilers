#define TRUE  1
#define FALSE 0

/* Sample key codes for getkey. Additional codes in the same format may
 * be added.
 */
#define U_UP    0x0148      /* Unshifted */
#define U_DN    0x0150
#define U_LT    0x014b
#define U_RT    0x014d
#define S_UP    0x0248      /* Shifted */
#define S_DN    0x0250
#define S_LT    0x024b
#define S_RT    0x024d

#define N_PLUS  0x014e      /* PLUS and MINUS on numeric keypad */
#define N_MINUS 0x014a

#define ENTER   13          /* ASCII */

/* Action codes for getkey */
enum WAITACTION { NO_WAIT, WAIT, CLEAR_WAIT };

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

/* Structure and global variable for menu attributes */
struct MENU
{
    int     fgBorder, fgNormal, fgSelect, fgNormHilite, fgSelHilite;
    long    bgBorder, bgNormal, bgSelect, bgNormHilite, bgSelHilite;
    int     fCentered;
    unsigned char   chNW, chNE, chSE, chSW, chNS, chEW;
};
extern struct MENU mnuAtrib;

/* Structure and maximum length for menu items */
#define MAXITEM 20
struct ITEM
{
    int     iHilite;
    char    achItem[MAXITEM];
};

/* Public menu, output, and input functions */
int Menu( int row, int col, struct ITEM aItem[], int iCur );
void Box( int row, int col, int rowLast, int colLast );
void Itemize( int row, int col, int fCur, struct ITEM itm, int cBlank );
unsigned GetKey( int fWait );
void _outchar( char out );
