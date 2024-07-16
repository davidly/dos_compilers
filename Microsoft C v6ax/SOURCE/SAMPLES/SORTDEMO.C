/* SORTDEMO -This program graphically demonstrates six common sorting
 * algorithms. It prints 25 or 43 horizontal bars of different lengths
 * in random order, then sorts the bars from shortest to longest.
 * The program can beep to generate different pitches, depending on the
 * length and position of the bar.
 *
 * The program can be created for DOS or OS/2. To create for OS/2, define
 * the symbol OS2. Command lines for DOS and OS/2 are shown below:
 *
 * DOS:
 *    cl /Lr sortdemo.c graphics.lib
 *
 * OS/2:
 *    cl /Lp /DOS2 sortdemo.c grtextp.lib
 */

#include <graph.h>          // _outtext, _settextcolor, _settextposition
#include <string.h>         // strlen
#include <stdio.h>          // sprintf
#include <conio.h>          // getch
#include <stdlib.h>         // srand, rand, toupper
#include <malloc.h>         // malloc, free
#include <time.h>           // time, clock

enum BOOL { FALSE, TRUE };

/* Structure type for colored bars */
typedef struct _BAR
{
    char len;
    char clr;
} BAR;

/* Structure type for screen cells */
typedef struct _CELL
{
    char chChar;
    char chAttr;
} CELL;

/* Function prototypes */
void main( void  );
void Cls( void  );
void InitMenu( void  );             // Menu Functions
void DrawFrame( int iTop, int Left, int Width, int Height );
void RunMenu( void  );
void DrawTime( int iCurrentRow );
void InitBars( void  );             // Bar functions
void ReInitBars( void  );
void DrawBar( int iRow );
void SwapBars( int iRow1, int iRow2 );
void Swaps( BAR *one, BAR *two );
void InsertionSort( void  );        // Sort functions
void BubbleSort( void  );
void HeapSort( void  );
void PercolateUp( int iMaxLevel );
void PercolateDown( int iMaxLevel );
void ExchangeSort( void  );
void ShellSort( void  );
void QuickSort( int iLow, int iHigh );
void Beep( int frequency, int duration );
void Sleep( clock_t wait );

/* Macro */
#define GetRandom( min, max ) ((rand() % (int)(((max) + 1) - (min))) + (min))
#define _outtextxy( ach, x, y )   { _settextposition( y, x ); \
                                    _outtext( ach ); }

/* Constants */
#define ESC        27
#define BLANK      32
#define BLOCK      223
#define TOP        1
#define FIRSTMENU  (TOP + 6)
#define LEFTCOLUMN 48
#define PROMPTPOS  27
#define WIDTH      (80 - LEFTCOLUMN)
#define HEIGHT     (cszMenu + 2)
#define MENUCOLOR  15
#define BLANKCOLOR 7
#define BACKCOLOR  0L
#define PAUSELIMIT 900

/* Global variables */
clock_t clStart, clFinish, clPause = 30L;
int fSound, iCurChoice, iSwaps, iCompares, cRow;

BAR abarWork[43], abarPerm[43]; // Temporary and permanent sort arrays

char *aszMenu[] =
{
    "",
    "       C Sorting Demo",
    "",
    "              Time  Swap  Comp",
    "",
    "Insertion",
    "Bubble",
    "Heap",
    "Exchange",
    "Shell",
    "Quick",
    "",
    "Toggle Sound: ",
    "",
    "Pause Factor: ",
    "<   (Slower)",
    ">   (Faster)",
    "",
    "Type first character of",
    "choice ( I B H E S Q T < > )",
    "or ESC key to end program: "
    "",
};
int cszMenu = sizeof( aszMenu ) / sizeof( aszMenu[0] );

void main()
{
    cRow = _settextrows( 43 );
    _clearscreen( _GCLEARSCREEN );
    _displaycursor( _GCURSOROFF );
    InitBars();
    InitMenu();
    RunMenu();                     // Respond to menu until quit
    _setvideomode( _DEFAULTMODE );
}


/* InitMenu - Calls the DrawFrame procedure to draw the frame around the
 * sort menu, then prints the different options stored in the menu array.
 */
void InitMenu()
{
    int  i;
    char ach[15];

    _settextcolor( MENUCOLOR );
    _setbkcolor( BACKCOLOR );
    DrawFrame( TOP, LEFTCOLUMN - 3, WIDTH + 3, HEIGHT );
    for( i = 0; i < cszMenu; i++ )
        _outtextxy( aszMenu[i], LEFTCOLUMN, TOP + i + 1 );

    /* Print the current value for Sound. */
    if( fSound )
        strcpy( ach, "ON " );
    else
        strcpy( ach, "OFF" );

    _outtextxy( ach, LEFTCOLUMN + 14, cszMenu - 7 );
    sprintf( ach, "%3.3u", clPause / 30 );
    _outtextxy( ach, LEFTCOLUMN + 14, cszMenu - 5 );

    /* Erase the speed option if the length of the pause is at a limit. */
    strcpy( ach, "            " );
    if( clPause == PAUSELIMIT )
        _outtextxy( ach, LEFTCOLUMN, cszMenu - 4 );
    if( clPause == 0L )
        _outtextxy( ach, LEFTCOLUMN, cszMenu - 3 );
}


/* DrawFrame - Draws a rectangular frame using the double-line box
 * characters. The parameters iTop, iLeft, iWidth, and iHeight are
 * the row and column arguments for the upper-left and lower-right
 * corners of the frame.
 */
void DrawFrame( int iTop, int iLeft, int iWidth, int iHeight )
{
    enum { ULEFT = 201, URIGHT = 187,
           LLEFT = 200, LRIGHT = 188, VERTICAL = 186, HORIZONTAL = 205
         };
    int iRow;
    char achTmp[80];

    memset( achTmp, HORIZONTAL, iWidth );
    achTmp[0] = ULEFT;
    achTmp[iWidth - 1] = URIGHT;
    achTmp[iWidth] = '\0';
    _outtextxy( achTmp, iLeft, iTop );

    memset( achTmp, BLANK, iWidth );
    achTmp[0] = VERTICAL;
    achTmp[iWidth - 1] = VERTICAL;
    for(  iRow = iTop + 1; iRow <= iHeight; iRow++ )
        _outtextxy( achTmp, iLeft, iRow );

    memset( achTmp, HORIZONTAL, iWidth );
    achTmp[0] = LLEFT;
    achTmp[iWidth - 1] = LRIGHT;
    _outtextxy( achTmp, iLeft, iTop + iHeight );
}


/* RunMenu - The RunMenu procedure first calls the ReInitBars
 * procedure to make sure the abarWork is in its unsorted form, then
 * prompts the user to make one of the following choices:
 *
 *  - Run one of the sorting algorithms
 *  - Toggle sound on or off
 *  - Increase or decrease speed
 *  - End the program
 */
void RunMenu()
{
    char    ch;

    while( TRUE )
    {
        iSwaps = iCompares = 0;
        _settextposition( TOP + cszMenu, LEFTCOLUMN + PROMPTPOS );
        _displaycursor( _GCURSORON );
        ch = getch();
        _displaycursor( _GCURSOROFF );

        /* Branch to the appropriate procedure depending on the key. */
        switch( toupper( ch ) )
        {
            case 'I':
                iCurChoice = 0;
                ReInitBars();
                InsertionSort();
                DrawTime( 0 );   // Print final time
                break;
            case 'B':
                iCurChoice = 1;
                ReInitBars();
                BubbleSort();
                DrawTime( 0 );
                break;

            case 'H':
                iCurChoice = 2;
                ReInitBars();
                HeapSort();
                DrawTime( 0 );
                break;

            case 'E':
                iCurChoice = 3;
                ReInitBars();
                ExchangeSort();
                DrawTime( 0 );
                break;

            case 'S':
                iCurChoice = 4;
                ReInitBars();
                ShellSort();
                DrawTime( 0 );
                break;

            case 'Q':
                iCurChoice = 5;
                ReInitBars();
                QuickSort( 0, cRow );
                DrawTime( 0 );
                break;

            case '>':
                /* Decrease pause length to speed up sorting time, then
                 * redraw the menu to clear any timing results (since
                 * they won't compare with future results).
                 */
                if( clPause )
                    clPause -= 30L;
                InitMenu();
                break;

            case '<':
                /* Increase pause length to slow down sorting time. */
                if( clPause <= 900L )
                    clPause += 30L;
                InitMenu();
                break;

            case 'T':
                fSound = !fSound;
                InitMenu();
                break;

            case ESC:
                return;

            default:        // Unknown key ignored
                break;
        }
    }
}


/* DrawTime - Prints seconds elapsed since the given sorting routine
 * started. Note that this time includes both the time it takes to redraw
 * the bars plus the pause while Beep plays a note, and thus is not an
 * accurate indication of sorting speed.
 */
void DrawTime( int iCurrentRow )
{
    char achTiming[80];

    _settextcolor( MENUCOLOR );
    clFinish = clock();

    sprintf( achTiming, "%7.2f  %4.i  %4.i",
             (float)(clFinish - clStart) / CLOCKS_PER_SEC,
             iSwaps, iCompares );

    /* Print the number of seconds elapsed */
    _outtextxy( achTiming, LEFTCOLUMN + 11, FIRSTMENU + iCurChoice );
    if( fSound )
    {
        Beep( 60 * iCurrentRow, 75 );   // Play note
        Sleep( clPause - 75L );         // Pause adjusted for note duration
    }
    else
        Sleep( clPause );               // Pause
}


/* InitBars - Initializes the bar arrays and the menu box.
 */
void InitBars()
{
    struct videoconfig vc;
    int aTemp[43], iRow, iRowMax, iRand, iColorMax, iLength;

    /* Seed the random-number generator. */
    srand( (unsigned)time( NULL ) );
    fSound = TRUE;
    clPause = 30L;

    /* If monochrome or color burst disabled, use one color */
    _getvideoconfig( &vc );
    if( (vc.monitor == _MONO) || (vc.mode == _TEXTBW80) ||
                                 (vc.mode == _TEXTBW40) )
        iColorMax = 1;
    else
        iColorMax = 15;

    /* Randomize an array of rows. */
    for( iRow = 0; iRow < cRow; iRow++ )
        aTemp[iRow] = iRow + 1;
    iRowMax = cRow - 1;
    for( iRow = 0; iRow < cRow; iRow++ )
    {
        /* Find a random element in aTemp between 0 and iRowMax,
         * then assign the value in that element to iLength.
         */
        iRand = GetRandom( 0, iRowMax );
        iLength = aTemp[iRand];

        /* Overwrite the value in aTemp[iRand] with the value in
         * aTemp[iRowMax] so the value in aTemp[iRand] is
         * chosen only once.
         */
        aTemp[iRand] = aTemp[iRowMax];

        /* Decrease the value of iRowMax so that aTemp[iRowMax] can't
         * be chosen on the next pass through the loop.
         */
        --iRowMax;
        abarPerm[iRow].len = iLength;
        if( iColorMax == 1 )
            abarPerm[iRow].clr = BLANKCOLOR;
        else
            abarPerm[iRow].clr = iLength % iColorMax + 1;
    }

    /* Assign permanent sort values to temporary and draw unsorted bars. */
    ReInitBars();
}


/* ReInitBars - Restores the array abarWork to its original unsorted
 * state and draws the unsorted bars.
 */
void ReInitBars()
{
    int iRow;

    clStart = clock();
    for( iRow = 0; iRow < cRow; iRow++ )
    {
        abarWork[iRow] = abarPerm[iRow];
        DrawBar( iRow );
    }
}


/* DrawBar - Prints a bar at a specified row by first blanking the
 * old bar, then drawing a new bar having the length and color given in
 * the work array.
 */
void DrawBar( int iRow )
{
    int  cSpace;
    char achT[43];

    memset( achT, BLOCK, abarWork[iRow].len );
    cSpace = cRow - abarWork[iRow].len;
    memset( achT + abarWork[iRow].len, ' ', cSpace );
    achT[cRow] = '\0';
    _settextcolor( abarWork[iRow].clr );
    _outtextxy( achT, 0, iRow + 1 );
}


/* SwapBars - Calls DrawBar twice to switch the two bars in iRow1 and
 * iRow2, then calls DrawTime to update the time.
 */
void SwapBars( int iRow1, int iRow2 )
{
    DrawBar( iRow1 );
    DrawBar( iRow2 );
    DrawTime( iRow1 );
}


/* Swaps - Exchanges two bar structures.
 */
void Swaps( BAR *bar1, BAR *bar2 )
{
    BAR barTmp;

    ++iSwaps;
    barTmp = *bar1;
    *bar1  = *bar2;
    *bar2  = barTmp;
}


/* InsertionSort - InsertionSort compares the length of each element
 * with the lengths of all the preceding elements. When the appropriate
 * place for the new element is found, the element is inserted and
 * all the other elements are moved down one place.
 */
void InsertionSort()
{
    BAR barTemp;
    int iRow, iRowTmp, iLength;

    /* Start at the top. */
    for( iRow = 0; iRow < cRow; iRow++ )
    {
        barTemp = abarWork[iRow];
        iLength = barTemp.len;

        /* As long as the length of the temporary element is greater than
         * the length of the original, keep shifting the elements down.
         */
        for( iRowTmp = iRow; iRowTmp; iRowTmp-- )
        {
            iCompares++;
            if( abarWork[iRowTmp - 1].len > iLength )
            {
                ++iSwaps;
                abarWork[iRowTmp] = abarWork[iRowTmp - 1];
                DrawBar( iRowTmp );         // Print the new bar
                DrawTime( iRowTmp );        // Print the elapsed time

            }
            else                            // Otherwise, exit
                break;
        }

        /* Insert the original bar in the temporary position. */
        abarWork[iRowTmp] = barTemp;
        DrawBar( iRowTmp );
        DrawTime( iRowTmp );
    }
}


/* BubbleSort - BubbleSort cycles through the elements, comparing
 * adjacent elements and swapping pairs that are out of order. It
 * continues to do this until no out-of-order pairs are found.
 */
void BubbleSort()
{
    int iRow, iSwitch, iLimit = cRow;

    /* Move the longest bar down to the bottom until all are in order. */
    do
    {
        iSwitch = 0;
        for( iRow = 0; iRow < iLimit; iRow++ )
        {
            /* If two adjacent elements are out of order, swap their values
             * and redraw those two bars.
             */
            iCompares++;
            if( abarWork[iRow].len > abarWork[iRow + 1].len )
            {
                Swaps( &abarWork[iRow], &abarWork[iRow + 1] );
                SwapBars( iRow, iRow + 1 );
                iSwitch = iRow;
            }
        }

        /* Sort on next pass only to where the last switch was made. */
        iLimit = iSwitch;
    } while( iSwitch );
}


/* HeapSort - HeapSort (also called TreeSort) works by calling
 * PercolateUp and PercolateDown. PercolateUp organizes the elements
 * into a "heap" or "tree," which has the properties shown below:
 *
 *                             element[1]
 *                           /            \
 *                element[2]                element[3]
 *               /          \              /          \
 *         element[4]     element[5]   element[6]    element[7]
 *         /        \     /        \   /        \    /        \
 *        ...      ...   ...      ... ...      ...  ...      ...
 *
 *
 * Each "parent node" is greater than each of its "child nodes"; for
 * example, element[1] is greater than element[2] or element[3];
 * element[4] is greater than element[5] or element[6], and so forth.
 * Therefore, once the first loop in HeapSort is finished, the
 * largest element is in element[1].
 *
 * The second loop rebuilds the heap (with PercolateDown), but starts
 * at the top and works down, moving the largest elements to the bottom.
 * This has the effect of moving the smallest elements to the top and
 * sorting the heap.
 */
void HeapSort()
{
    int i;

    for( i = 1; i < cRow; i++ )
        PercolateUp( i );

    for( i = cRow - 1; i > 0; i-- )
    {
        Swaps( &abarWork[0], &abarWork[i] );
        SwapBars( 0, i );
        PercolateDown( i - 1 );
    }
}


/* PercolateUp - Converts elements into a "heap" with the largest
 * element at the top (see the diagram above).
 */
void PercolateUp( int iMaxLevel )
{
    int i = iMaxLevel, iParent;

    /* Move the value in abarWork[iMaxLevel] up the heap until it has
     * reached its proper node (that is, until it is greater than either
     * of its child nodes, or until it has reached 1, the top of the heap).
     */
    while( i )
    {
        iParent = i / 2;    // Get the subscript for the parent node

        iCompares++;
        if( abarWork[i].len > abarWork[iParent].len )
        {
            /* The value at the current node is bigger than the value at
             * its parent node, so swap these two array elements.
             */
            Swaps( &abarWork[iParent], &abarWork[i] );
            SwapBars( iParent, i );
            i = iParent;
        }
        else
            /* Otherwise, the element has reached its proper place in the
             * heap, so exit this procedure.
             */
            break;
    }
}


/* PercolateDown - Converts elements to a "heap" with the largest elements
 * at the bottom. When this is done to a reversed heap (largest elements
 * at top), it has the effect of sorting the elements.
 */
void PercolateDown( int iMaxLevel )
{
    int iChild, i = 0;

    /* Move the value in abarWork[0] down the heap until it has reached
     * its proper node (that is, until it is less than its parent node
     * or until it has reached iMaxLevel, the bottom of the current heap).
     */
    while( TRUE )
    {
        /* Get the subscript for the child node. */
        iChild = 2 * i;

        /* Reached the bottom of the heap, so exit this procedure. */
        if( iChild > iMaxLevel )
            break;

        /* If there are two child nodes, find out which one is bigger. */
        if( iChild + 1 <= iMaxLevel )
        {
            iCompares++;
            if( abarWork[iChild + 1].len > abarWork[iChild].len )
                iChild++;
        }

        iCompares++;
        if( abarWork[i].len < abarWork[iChild].len )
        {
            /* Move the value down since it is still not bigger than
             * either one of its children.
             */
            Swaps( &abarWork[i], &abarWork[iChild] );
            SwapBars( i, iChild );
            i = iChild;
        }
        else
            /* Otherwise, abarWork has been restored to a heap from 1 to
             * iMaxLevel, so exit.
             */
            break;
    }
}


/* ExchangeSort - The ExchangeSort compares each element--starting with
 * the first--with every following element. If any of the following
 * elements is smaller than the current element, it is exchanged with
 * the current element and the process is repeated for the next element.
 */
void ExchangeSort()
{
    int iRowCur, iRowMin, iRowNext;

    for( iRowCur = 0; iRowCur < cRow; iRowCur++ )
    {
        iRowMin = iRowCur;
        for( iRowNext = iRowCur; iRowNext < cRow; iRowNext++ )
        {
            iCompares++;
            if( abarWork[iRowNext].len < abarWork[iRowMin].len )
            {
                iRowMin = iRowNext;
                DrawTime( iRowNext );
            }
        }

        /* If a row is shorter than the current row, swap those two
         * array elements.
         */
        if( iRowMin > iRowCur )
        {
            Swaps( &abarWork[iRowCur], &abarWork[iRowMin] );
            SwapBars( iRowCur, iRowMin );
        }
    }
}


/* ShellSort - ShellSort is similar to the BubbleSort. However, it
 * begins by comparing elements that are far apart (separated by the
 * value of the iOffset variable, which is initially half the distance
 * between the first and last element), then comparing elements that
 * are closer together. When iOffset is one, the last iteration of
 * is merely a bubble sort.
 */
void ShellSort()
{
    int iOffset, iSwitch, iLimit, iRow;

    /* Set comparison offset to half the number of bars. */
    iOffset = cRow / 2;

    while( iOffset )
    {
        /* Loop until offset gets to zero. */
        iLimit = cRow - iOffset;
        do
        {
            iSwitch = FALSE;     // Assume no switches at this offset.

            /* Compare elements and switch ones out of order. */
            for( iRow = 0; iRow <= iLimit; iRow++ )
            {
                iCompares++;
                if( abarWork[iRow].len > abarWork[iRow + iOffset].len )
                {
                    Swaps( &abarWork[iRow], &abarWork[iRow + iOffset] );
                    SwapBars( iRow, iRow + iOffset );
                    iSwitch = iRow;
                }
            }

            /* Sort on next pass only to where last switch was made. */
            iLimit = iSwitch - iOffset;
        } while( iSwitch );

        /* No switches at last offset, try one half as big. */
        iOffset = iOffset / 2;
    }
}


/* QuickSort - QuickSort works by picking a random "pivot" element,
 * then moving every element that is bigger to one side of the pivot,
 * and every element that is smaller to the other side. QuickSort is
 * then called recursively with the two subdivisions created by the pivot.
 * Once the number of elements in a subdivision reaches two, the recursive
 * calls end and the array is sorted.
 */
void QuickSort( int iLow, int iHigh )
{
    int iUp, iDown, iBreak;

    if( iLow < iHigh )
    {
        /* Only two elements in this subdivision; swap them if they are
         * out of order, then end recursive calls.
         */
        if( (iHigh - iLow) == 1 )
        {
            iCompares++;
            if( abarWork[iLow].len > abarWork[iHigh].len )
            {
                Swaps( &abarWork[iLow], &abarWork[iHigh] );
                SwapBars( iLow, iHigh );
            }
        }
        else
        {
            iBreak = abarWork[iHigh].len;
            do
            {
                /* Move in from both sides towards the pivot element. */
                iUp = iLow;
                iDown = iHigh;
                iCompares++;
                while( (iUp < iDown) && (abarWork[iUp].len <= iBreak) )
                    iUp++;
                iCompares++;
                while( (iDown > iUp) && (abarWork[iDown].len >= iBreak) )
                    iDown--;
                /* If we haven't reached the pivot, it means that two
                 * elements on either side are out of order, so swap them.
                 */
                if( iUp < iDown )
                {
                    Swaps( &abarWork[iUp], &abarWork[iDown] );
                    SwapBars( iUp, iDown );
                }
            } while ( iUp < iDown );

            /* Move pivot element back to its proper place in the array. */
            Swaps( &abarWork[iUp], &abarWork[iHigh] );
            SwapBars( iUp, iHigh );

            /* Recursively call the QuickSort procedure (pass the smaller
             * subdivision first to use less stack space).
             */
            if( (iUp - iLow) < (iHigh - iUp) )
            {
                QuickSort( iLow, iUp - 1 );
                QuickSort( iUp + 1, iHigh );
            }
            else
            {
                QuickSort( iUp + 1, iHigh );
                QuickSort( iLow, iUp - 1 );
            }
        }
    }
}

/* Beep - Sounds the speaker for a time specified in microseconds by
 * duration at a pitch specified in hertz by frequency.
 */
void Beep( int frequency, int duration )
{
/* Use system call for OS/2 */
#if defined( OS2 )
#define INCL_NOCOMMON
#define INCL_NOPM
#define INCL_DOSPROCESS
#include <os2.h>
    DosBeep( frequency, duration );
#else
/* Define procedure for DOS */
    int control;

    /* If frequency is 0, Beep doesn't try to make a sound. It
     * just sleeps for the duration.
     */
    if( frequency )
    {
        /* 75 is about the shortest reliable duration of a sound. */
        if( duration < 75 )
            duration = 75;

        /* Prepare timer by sending 10111100 to port 43. */
        outp( 0x43, 0xb6 );

        /* Divide input frequency by timer ticks per second and
         * write (byte by byte) to timer.
         */
        frequency = (unsigned)(1193180L / frequency);
        outp( 0x42, (char)frequency );
        outp( 0x42, (char)(frequency >> 8) );

        /* Save speaker control byte. */
        control = inp( 0x61 );

        /* Turn on the speaker (with bits 0 and 1). */
        outp( 0x61, control | 0x3 );
    }

    Sleep( (clock_t)duration );

    /* Turn speaker back on if necessary. */
    if( frequency )
        outp( 0x61, control );

#endif              /* DOS version */
}

/* Pauses for a specified number of microseconds. */
void Sleep( clock_t wait )
{
    clock_t goal;

    goal = wait + clock();
    while( goal >= clock() )
        ;
}
