/* MENU - Module of functions to put menus on the screen and handle keyboard
 * input. To use it, include the MENU.H file in your program. The following
 * functions are public:
 *
 *   Menu       -   Puts a menu on screen and reads input for it
 *   Box        -   Puts a box on screen (fill it yourself)
 *   GetKey     -   Gets ASCII or function key
 *   _outchar   -   Displays character using current text position and color
 *
 * The following structures are defined:
 *
 *   MENU       -   Defines menu colors, box type, and centering
 *   ITEM       -   Defines text of menu item and index of highlight character
 *
 * The global variable "mnuAtrib" has type MENU. Change this variable to
 * change menu appearance.
 */

#include <string.h>
#include <stddef.h>
#include <ctype.h>
#include <graph.h>
#include <bios.h>
#include "menu.h"

/* Default menu attribute. The default works for color or B&W. You can
 * override the default value by defining your own MENU variable and
 * assigning it to mnuAtrib, or you can modify specific fields at
 * run time. For example, you could use a different attribute for color
 * than for black and white.
 */
struct MENU mnuAtrib =
{
    _TBLACK, _TBLACK, _TWHITE, _TBRIGHTWHITE, _TBRIGHTWHITE,
    _TWHITE, _TWHITE, _TBLACK, _TWHITE, _TBLACK,
    TRUE,
    'Ú', '¿', 'Ù', 'À', '³', 'Ä'
};

/* Menu - Puts menu on screen and reads menu input from keyboard. When a
 * highlighted hot key or ENTER is pressed, returns the index of the
 * selected menu item.
 *
 * Params: row and col - If "fCentered" attribute of "mnuAtrib" is true,
 *           center row and column of menu; otherwise top left of menu
 *         aItem - array of structure containing the text of each item
 *           and the index of the highlighted hot key
 *         iCur - index of the current selection--pass 0 for first item,
 *           or maintain a static value
 *
 * Return: The index of the selected item
 *
 * Uses:   mnuAtrib
 */
int Menu( int row, int col, struct ITEM aItem[], int iCur )
{
    int cItem, cchItem = 2; /* Counts of items and chars per item       */
    int i, iPrev;           /* Indexes - temporary and previous         */
    int acchItem[MAXITEM];  /* Array of counts of character in items    */
    char *pchT;             /* Temporary character pointer              */
    char achHilite[36];     /* Array for highlight characters           */
    unsigned uKey;          /* Unsigned key code                        */
    long bgColor;           /* Screen color, position, and cursor       */
    short fgColor;
    struct rccoord rc;
    unsigned fCursor;

    /* Save screen information. */
    fCursor = _displaycursor( _GCURSOROFF );
    bgColor = _getbkcolor();
    fgColor = _gettextcolor();
    rc = _gettextposition();

    /* Count items, find longest, and put count of each in array. Also,
     * put the highlighted character from each in a string.
     */
    for( cItem = 0; aItem[cItem].achItem[0]; cItem++ )
    {
        acchItem[cItem] = strlen( aItem[cItem].achItem );
        cchItem = (acchItem[cItem] > cchItem) ? acchItem[cItem] : cchItem;
        i = aItem[cItem].iHilite;
        achHilite[cItem] = aItem[cItem].achItem[i];
    }
    cchItem += 2;
    achHilite[cItem] = 0;          /* Null-terminate and lowercase string  */
    strlwr( achHilite );

    /* Adjust if centered, and draw menu box. */
    if( mnuAtrib.fCentered )
    {
        row -= cItem / 2;
        col -= cchItem / 2;
    }
    Box( row++, col++, cItem, cchItem );

    /* Put items on menu. */
    for( i = 0; i < cItem; i++ )
    {
        if( i == iCur )
            Itemize( row + i, col, TRUE, aItem[i], cchItem - acchItem[i] );
        else
            Itemize( row + i, col, FALSE, aItem[i], cchItem - acchItem[i] );
    }

    while( TRUE )
    {
        /* Wait until a uKey is pressed, then evaluate it. */
        uKey = GetKey( WAIT );
        switch( uKey )
        {
            case U_UP:                      /* Up key       */
                iPrev = iCur;
                iCur = (iCur > 0) ? (--iCur % cItem) : cItem - 1;
                break;
            case U_DN:                      /* Down key     */
                iPrev = iCur;
                iCur = (iCur < cItem) ? (++iCur % cItem) : 0;
                break;
            default:
                if( uKey > 256 )            /* Ignore unknown function key  */
                    continue;
                pchT = strchr( achHilite, (char)tolower( uKey ) );
                if( pchT != NULL )          /* If in highlight string,      */
                    iCur = pchT - achHilite;/*   evaluate and fall through  */
                else
                    continue;               /* Ignore unknown ASCII key     */
            case ENTER:
                _setbkcolor( bgColor );
                _settextcolor( fgColor );
                _settextposition( rc.row, rc.col );
                _displaycursor( fCursor );
                return iCur;
        }
        /* Redisplay current and previous. */
        Itemize( row + iCur, col,
                 TRUE, aItem[iCur], cchItem - acchItem[iCur] );
        Itemize( row + iPrev, col,
                 FALSE, aItem[iPrev], cchItem - acchItem[iPrev] );
    }
}

/* Box - Draw menu box, filling interior with blanks of the border color.
 *
 * Params: row and col - upper left of box
 *         rowLast and colLast - height and width
 *
 * Return: None
 *
 * Uses:   mnuAtrib
 */
void Box( int row, int col, int rowLast, int colLast )
{
    int i;
    char achT[MAXITEM + 2];         /* Temporary array of characters */

    /* Set color and position. */
    _settextposition( row, col );
    _settextcolor( mnuAtrib.fgBorder );
    _setbkcolor( mnuAtrib.bgBorder );

    /* Draw box top. */
    achT[0] = mnuAtrib.chNW;
    memset( achT + 1, mnuAtrib.chEW, colLast );
    achT[colLast + 1] = mnuAtrib.chNE;
    achT[colLast + 2] = 0;
    _outtext( achT );

    /* Draw box sides and center. */
    achT[0] = mnuAtrib.chNS;
    memset( achT + 1, ' ', colLast );
    achT[colLast + 1] = mnuAtrib.chNS;
    achT[colLast + 2] = 0;
    for( i = 1; i <= rowLast; ++i )
    {
        _settextposition( row + i, col );
        _outtext( achT );
    }

    /* Draw box bottom. */
    _settextposition( row + rowLast + 1, col );
    achT[0] = mnuAtrib.chSW;
    memset( achT + 1, mnuAtrib.chEW, colLast );
    achT[colLast + 1] = mnuAtrib.chSE;
    achT[colLast + 2] = 0;
    _outtext( achT );
}

/* Itemize - Display one selection (item) of a menu. This function
 * is normally only used internally by Menu.
 *
 * Params: row and col - top left of menu
 *         fCur - flag set if item is current selection
 *         itm - structure containing item text and index of highlight
 *         cBlank - count of blanks to fill
 *
 * Return: none
 *
 * Uses:   mnuAtrib
 */
void Itemize( int row, int col, int fCur, struct ITEM itm, int cBlank )
{
    int i;
    char achT[MAXITEM];             /* Temporary array of characters */

    /* Set text position and color. */
    _settextposition( row, col );
    if( fCur )
    {
        _settextcolor( mnuAtrib.fgSelect );
        _setbkcolor( mnuAtrib.bgSelect );
    }
    else
    {
        _settextcolor( mnuAtrib.fgNormal );
        _setbkcolor( mnuAtrib.bgNormal );
    }

    /* Display item and fill blanks. */
    strcat( strcpy( achT, " " ), itm.achItem );
    _outtext( achT );
    memset( achT, ' ', cBlank-- );
    achT[cBlank] = 0;
    _outtext( achT );

    /* Set position and color of highlight character, then display it. */
    i = itm.iHilite;
    _settextposition( row, col + i + 1 );
    if( fCur )
    {
        _settextcolor( mnuAtrib.fgSelHilite );
        _setbkcolor( mnuAtrib.bgSelHilite );
    }
    else
    {
        _settextcolor( mnuAtrib.fgNormHilite );
        _setbkcolor( mnuAtrib.bgNormHilite );
    }
    _outchar( itm.achItem[i] );
}

/* GetKey - Gets a key from the keyboard. This routine distinguishes
 * between ASCII keys and function or control keys with different shift
 * states. It also accepts a flag to return immediately if no key is
 * available.
 *
 * Params: fWait - Code to indicate how to handle keyboard buffer:
 *   NO_WAIT     Return 0 if no key in buffer, else return key
 *   WAIT        Return first key if available, else wait for key
 *   CLEAR_WAIT  Throw away any key in buffer and wait for new key
 *
 * Return: One of the following:
 *
 *   Keytype                                High Byte    Low Byte
 *   -------                                ---------    --------
 *   No key available (only with NO_WAIT)       0           0
 *   ASCII value                                0        ASCII code
 *   Unshifted function or keypad               1        scan code
 *   Shifted function or keypad                 2        scan code
 *   CTRL function or keypad                    3        scan code
 *   ALT function or keypad                     4        scan code
 *
 * Note:   getkey cannot return codes for keys not recognized by BIOS
 *         int 16, such as the CTRL-UP or the 5 key on the numeric keypad.
 */
unsigned GetKey( int fWait )
{
    unsigned uKey, uShift;

    /* If CLEAR_WAIT, drain the keyboard buffer. */
    if( fWait == CLEAR_WAIT )
        while( _bios_keybrd( _KEYBRD_READY ) )
            _bios_keybrd( _KEYBRD_READ );

    /* If NO_WAIT, return 0 if there is no key ready. */
    if( !fWait && !_bios_keybrd( _KEYBRD_READY ) )
        return FALSE;

    /* Get key code. */
    uKey = _bios_keybrd( _KEYBRD_READ );

    /* If low byte is not zero, it's an ASCII key. Check scan code to see
     * if it's on the numeric keypad. If not, clear high byte and return.
     */
    if( uKey & 0x00ff )
        if( (uKey >> 8) < 69 )
            return( uKey & 0x00ff );

    /* For function keys and numeric keypad, put scan code in low byte
     * and shift state codes in high byte.
     */
    uKey >>= 8;
    uShift = _bios_keybrd( _KEYBRD_SHIFTSTATUS ) & 0x000f;
    switch( uShift )
    {
        case 0:
            return( 0x0100 | uKey );  /* None (1)    */
        case 1:
        case 2:
        case 3:
            return( 0x0200 | uKey );  /* Shift (2)   */
        case 4:
            return( 0x0300 | uKey );  /* Control (3) */
        case 8:
            return( 0x0400 | uKey );  /* Alt (4)     */
    }
}

/* _outchar - Display a character. This is the character equivalent of
 * _outtext. It is affected by _settextposition, _settextcolor, and
 * _setbkcolor. It should not be used in loops. Build strings and then
 * _outtext to show multiple characters.
 *
 * Params: out - character to be displayed
 *
 * Return: none
 */
void _outchar( char out )
{
    static char achT[2] = " ";      /* Temporary array of characters */

    achT[0] = out;
    _outtext( achT );
}
