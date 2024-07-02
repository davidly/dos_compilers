/* CHRTSUPT.C - Support module for presentation graphics demonstration
 * program.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <conio.h>
#include <graph.h>
#include <pgchart.h>
#include "chrtdemo.h"

/* Variables to manage menus.  */
int cMenuLevel = 0;                 /* Current menu level   */
char *szMenuTitles[10];             /* Stack of menu titles */

char *pszBlankMenu[4];

/* Variables used to track control and screen position.  */
extern struct SCREENINFO si;

/* Colors of menus and prompts. */
extern struct tagColor co;

/*  BlankMenu - Gets responses to two specified choices.
 *
 *  Params: pchTitle - Menu title string
 *          pchChoice1 - Selection 1 string
 *          pchChoice2 - Selection 2 string
 *
 *  Return: Number of choice, or ESCAPE
 */
int BlankMenu( char *pchTitle, char *pchChoice1, char *pchChoice2 )
{
    int iChoice;

    /* Initialize title and selections.  */
    pszBlankMenu[0] = pchTitle;
    pszBlankMenu[1] = pchChoice1;
    pszBlankMenu[2] = pchChoice2;
    pszBlankMenu[3] = "\0";
    PushTitle( pszBlankMenu[0]);

    while( TRUE )
    {
        /* Accept only first letter of either selection, or ESC.  */
        iChoice = Menu( pszBlankMenu );
        switch( iChoice )
        {
            case 1:
            case 2:
            case ESCAPE:
                return iChoice;
        }
    }
}

/*  ClrForm - Clears the center of the screen form.
 *
 *  Params: None
 */
void ClrForm()
{

    /* Set partial screen window and clear it, then reset full screen.  */
    _settextwindow( si.top, 1, si.bot, 80 );
    _clearscreen( _GWINDOW );
    _settextwindow( 1, 1, 25, 80 );

}

/*  ClrHelp - Clears the current help line.
 *
 *  Params: None
 */
void ClrHelp()
{
    /* Decrement the help line counter and clear the line.  */
    _settextwindow( --si.help, 1, si.help, 80 );
    _clearscreen( _GWINDOW );
    _settextwindow( 1, 1, 25, 80 );
}

/*  ErrorMsg - Displays an error message.
 *
 *  Params: pchMsg - error message string
 */
void ErrorMsg( char *pchMsg )
{

    /* Beep, set error color, and display error message and continue prompt.  */
    putch( BEEP );
    Help( pchMsg, co.ErrorColor );
    Help( "Press any key to continue.", co.ErrorColor );

    /* Wait for keypress and clear help lines.  */
    getch();
    ClrHelp();
    ClrHelp();

}

/*  Help - Displays a help line on the screen.
 *
 *  Params: pchMsg - error message string
 *          sColor - color for message
 */
void Help( char *pchMsg, short sColor )
{

    struct rccoord rcCursor;

    /* Save current cursor position.  */
    rcCursor = _gettextposition();

    /* Print out help line and increment Helpline position variable.  */
    PrintAt( si.help++, 5, pchMsg, sColor );

    /* Restore cursor position.  */
    _settextposition( rcCursor.row, rcCursor.col );

}

/*  InputCh - Prompts for and returns a character of input.
 *
 *  Params: pchPrompt - Prompt string
 *          pchAccept - String of acceptable characters (case insensitive)
 *
 *  Return: Character entered
 */
int InputCh( char *pchPrompt, char *pchAccept )
{
    int chResponse;

    /* Display prompt.  */
    PrintAt( si.mid, 10, pchPrompt, co.InputColor );

    /* Loop until response is valid.  */
    while( TRUE )
    {
        chResponse = toupper( getch() );

        /* Display and return if acceptable character, or beep if not.  */
        if( *strchr( pchAccept, chResponse) )
        {
            _settextcolor( co.InfoColor );
            putch( chResponse );
            return chResponse;
        }
        else
            putch( BEEP );
    }
}

/*  InputInt - Prompts for and returns an integer value within a
 *  specified range.
 *
 *  Params: pchPrompt - Prompt string
 *          iOld - Previous value
 *          iMin - Minimum value of range
 *          iMax - Maximum value of range
 *
 *  Return: integer input by user
 */
int InputInt( char *pchPrompt, int iOld, int iMin, int iMax )
{
    int i;
    char szTmp[70];

    /* Prompt for a string input and convert to an integer until a
     * value in the specified range is given. Then return the value.
     */
    do
    {
        InputStr( pchPrompt, itoa( iOld, szTmp, 10) );
        i = atoi( szTmp );
    } while( !InRange( i, iMin, iMax) );
    return i;
}

/*  InputFloat - Prompts for and returns a float value.
 *
 *  Params: pchPrompt - Prompt string
 *          fOld - Previous value
 *
 *  Return: float input by user
 */
float InputFloat( char *pchPrompt, float fOld )
{
    char szTmp[70];

    /* Prompt for a string input and convert to a float. */
    sprintf( szTmp, "%f", fOld );
    InputStr( pchPrompt, szTmp );
    return (float)atof( szTmp );
}

/*  InputStr - Prompts for a string. Displays the previous string
 *  until the first character is given. Then replaces it with new
 *  entry.
 *
 *  Params: pchPrompt - Prompt string
 *          pchOld - Charater buffer containing previous string; it
 *            must be long enough to hold new string
 *
 *  Return: pointer to pchOld, which now contains new string
 */
char *InputStr( char *pchPrompt, char *pchOld )
{
    char szTmp[81];
    int x = 5, y = si.mid, ch;

    /* Display prompt in center of form.  */
    ClrForm();
    PrintAt( y, x, pchPrompt, co.InputColor );
    x += strlen( pchPrompt );

    /* Print the old value for reference.  */
    _outtext( pchOld );
    _settextposition( y, x );

    /* Wait for input. When received, clear old string.  */
    while( !(ch = kbhit()) )
        ;
    memset( szTmp, ' ', 80 );
    szTmp[80] = '\0';
    PrintAt( y, x, szTmp, -1 );

    /* Get new string. If string entered, return it. If null string
     * (ENTER key pressed), return old value.
     */
    _settextcolor( co.InfoColor );
    _settextposition( y, x );
    szTmp[0] = 70;             /* Maximum length to be read */

    cgets( szTmp );
    if( szTmp[1] > 0 )         /* Are any characters read?  */
    {
        strcpy( pchOld, &szTmp[2] );
        return &szTmp[2];
    }
    else
    {
        _settextposition( y, x );
        return pchOld;
    }
}

/*  InRange - Checks an integer to see if it is in a specified range.
 *
 *  Params: iValue - Integer to check
 *          iMin - Minimum value of range
 *          iMax - Maximim value of range
 *
 *  Return: TRUE if in range, FALSE if not
 */
BOOL InRange( int Value, int iMin, int iMax )
{
    /* Check range and return true if valid, false if not. Note that
     * (iMin >= iMax) is taken as a signal to check only the minimum
     * value; there is no maximum.
     */
    if( Value >= iMin )
        if( (Value <= iMax) || (iMin >= iMax) )
            return TRUE;
    else
    {
        ErrorMsg( "Invalid value." );
        return FALSE;
    }
}

/*  Menu - Draws menu on screen and returns choice number.
 *
 *  Params: array of menu strings
 *
 *  Return: number corresponding to the choice made from the menu
 */
int Menu( char *pszMenuList[] )
{
    int iItem, cItem, yItem, x = 10;
    int chResponse;

    /* Count menu items.  */
    for( cItem = 1; *pszMenuList[cItem]; cItem++ )
        ;
    --cItem;


    /* Clear the form and print the items in the menu.  */
    WrtForm( 10 + cItem );
    for( iItem = 1, yItem = 8; iItem <= cItem; iItem++, yItem++ )
    {
        PrintAt( yItem, x, pszMenuList[iItem], co.InputColor );
        PrintChar( yItem, x, pszMenuList[iItem][0], co.HiliteColor );
    }
    ++yItem;

    /* Display prompt and help.  */
    if( strcmpi( pszMenuList[0], "main menu" ) )    /* If not the main menu */
        Help( "Type the first letter of your selection or ESC to back up.",
                  co.InputColor );
    else
        Help( "Type the first letter of your selection or \"Q\" to quit.",
                  co.InputColor );

    PrintAt( yItem, x += 5, "Choice? ", co.InfoColor );
    x += 8;

    /* Loop until a valid choice is made. Beep at invalid choices.  */
    while( TRUE )
    {
        _settextposition( yItem, x );
        chResponse = toupper( getch() );

        /* Back up for ESC.  */
        if( chResponse == 27 )
        {
            ClrHelp();
            return ESCAPE;
        }

        /* Search first letters of choices for a match. If found, return
         * choice and clear help line.
         */
        for( iItem = 1; iItem <= cItem; iItem++ )
        {
            if( chResponse == toupper( pszMenuList[iItem][0]) )
            {
                putch( chResponse );
                ClrHelp();
                return iItem;
            }
        }

        /* If we get here, no valid choice was found, so beep and repeat.  */
        putch( BEEP );
    }
}

/*  PopTitle - Pops a menu title from the menu stack.
 *
 *  Params: None
 */
void PopTitle()
{
    szMenuTitles[--cMenuLevel] = "";
}

/*  PrintAt - Prints a string at the row/column coordinates
 *            specified, in the specified color.
 *
 *  Params: row        - row at which to begin output of string
 *          col        - column at which to begin output of string
 *          lpszString - zero (null) terminated string
 *          sColor     - color in which to output string (-1 if
 *                       PrintAt should leave color alone)
 */
void PrintAt( int row, int column, char _far *lpszString, short sColor )
{
    if( sColor != -1 )
        _settextcolor( sColor );
    _settextposition( row, column );
    _outtext( lpszString );
}

/*  PrintChar - Prints a character at the row/column coordinates
 *              specified, in the specified color.
 *
 *  Params: row        - row at which to begin output of string
 *          col        - column at which to begin output of string
 *          cChar      - character to print
 *          sColor     - color in which to output string (-1 if
 *                       PrintChar should leave color alone)
 */
void PrintChar(int row, int column, char cChar, short sColor)
{
    char szTiny[2];

    szTiny[0] = cChar;
    szTiny[1] = '\0';
    PrintAt( row, column, szTiny, sColor );
}

/*  PushTitle - Pushes a menu title on to the menu stack.
 *
 *  Params: pchTitle - title string to push
 */
void PushTitle( char *pchTitle )
{
    szMenuTitles[cMenuLevel++] = pchTitle;
}

/*  SetDisplayColors - Set the colors to values appropriate to the display
 *                     adaptor being used.
 *
 * Parms: None
 */
void SetDisplayColors()
{
    if( ismono( si.mode ) )
    {
        co.InputColor  = M_INPUTCOLOR;
        co.HiliteColor = M_HILITECOLOR;
        co.FormColor   = M_FORMCOLOR;
        co.TitleColor  = M_TITLECOLOR;
        co.ErrorColor  = M_ERRORCOLOR;
        co.InfoColor   = M_INFOCOLOR;
    }
    else
    {
        co.InputColor  = C_INPUTCOLOR;
        co.HiliteColor = C_HILITECOLOR;
        co.FormColor   = C_FORMCOLOR;
        co.TitleColor  = C_TITLECOLOR;
        co.ErrorColor  = C_ERRORCOLOR;
        co.InfoColor   = C_INFOCOLOR;
    }
}

/*  SprintAt - Format a string, using sprintf() and output to screen
 *             using PrintAt.
 *
 *  Parms: iRow  - Row at which to begin display
 *         iCol  - Column at which to begin display
 *         szFmt - Format string (see run-time library documentation for
 *                 correct formation of a format string)
 *         ...   - Variables to output
 */
void SprintAt( int iRow, int iCol, char * szFmt, ... )
{
    char szTmp[81];
    va_list Marker;
    va_list saveMarker;

    va_start( Marker, szFmt );
    saveMarker = Marker;
    vsprintf( szTmp, szFmt, Marker );
    va_end( Marker );

    PrintAt( iRow, iCol, szTmp, -1 );
}

/*  WrtForm - Displays screen form.
 *
 *  Params: yBot - Row number of the bottom row
 */
void WrtForm( int yBot )
{
    int i;
    char szTmp[81];

    /* Print message in upper right.  */
    _clearscreen( _GCLEARSCREEN );
    PrintAt( 1, 55, "Presentation Graphics Demo", co.TitleColor );

    /* Clear the top separator line.  */
    memset( szTmp, ' ', 79 );
    szTmp[79] = 0;

    /* Display each level of the menu title.  */
    _settextposition( 5, 5 );
    for( i = 0; i < cMenuLevel; i++ )
    {
        if( i )
            _outtext( " - " );
        _outtext( szMenuTitles[i] );
    }

    /* Display the top separator line.  */
    memset( szTmp, 196, 80 );
    szTmp[80] = 0;
    PrintAt( 6, 1, szTmp, co.FormColor );

    /* Display the bottom separator line.  */
    PrintAt( yBot, 1, szTmp, co.FormColor );

    /* Set the global screen variables.  */

    si.help = yBot + 1;
    si.top = 7;
    si.bot = yBot - 1;
    si.mid = (si.top + si.bot) / 2;
}
