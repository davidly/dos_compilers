/*				   SORTDEMO
 * This	program	graphically demonstrates six common sorting algorithms.	 It
 * prints 25 or	43 horizontal bars, all	of different lengths and all in	random
 * order, then sorts the bars from smallest to longest.
 *
 * The program also uses SOUND statements to generate different	pitches,
 * depending on	the location of	the bar	being printed. Note that the SOUND
 * statements delay the	speed of each sorting algorithm	so you can follow
 * the progress	of the sort. Therefore,	the times shown	are for	comparison
 * only. They are not an accurate measure of sort speed.
 *
 * If you use these sorting routines in	your own programs, you may notice
 * a difference	in their relative speeds (for example, the exchange
 * sort	may be faster than the shell sort) depending on	the number of
 * elements to be sorted and how "scrambled" they are to begin with.
 *
 * To build a statically linked	version, use this command line:
 *
 *   CL	/Lp /Zp	sortdemo.c
 *
 * If you wish to be able to run in either real	or protect mode, bind
 * with	the following command line:
 *
 *   BIND sortdemo.exe \lib\doscalls.lib \lib\api.lib \lib\apilmr.obj
 *
 * To build a dynamically linked version, make sure you	have the following
 * files:
 * ÿ
 *   CRTLIB.DLL	   Dynamic link	library	in LIBPATH directory
 *   CRTLIB.LIB	   Imports library in LIB directory
 *   CTREXE.OBJ	   Startup code	for .EXE files in LIB directory
 * ÿ
 * See MTDYNA.DOC for details on creating and using these files. Then use
 * the following command lines:
 *
 *   CL	/c /X /I\include\mt /Alfw /Gs2 /DDLL /Zp sortdemo.c
 *   LINK sortdemo \lib\crtexe /NOI /NOD,,,crtlib doscalls;
 */
#define	INCL_NOCOMMON
#define	INCL_DOSPROCESS
#define	INCL_DOSDATETIME
#define	INCL_SUB
#include <os2.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <malloc.h>

/* Declare data	types for colored bars and cells:
 */
struct SortType	{
    int	    Length;	    /* Bar length (the element compared
			     * in the different	sorts)		   */
    char    ColorVal;	    /* Bar color			   */
};

struct CELLINFO	{
    char    Char;
    char    Attr;
};

/* Declare function prototypes:
 */
int  main (void);
void BoxInit (void);
void BubbleSort	(void);
void DrawFrame (int Top, int Left, int Width, int Height);
void ElapsedTime (int CurrentRow);
void ExchangeSort (void);
void HeapSort (void);
void Initialize	(void);
void InsertionSort (void);
void PercolateDown (int	MaxLevel);
void PercolateUp (int MaxLevel);
void PrintOneBar (int Row);
void QuickSort (int Low, int High);
int  RandInt (int Lower, int Upper);
void Reinitialize (void);
void ShellSort (void);
int  Screen (int ACTION);
void SortMenu (void);
void SwapBars (int Row1, int Row2);
void Cls (void);
void Swaps (struct SortType *one, struct SortType *two);

/* Declare global constants:
 */
#define	BLOCK	    223
#define	TRUE	    1
#define	FALSE	    0
#define	SAVE	    TRUE
#define	SPACECELL   0x0720
#define	RESTORE	    FALSE
#define	FIRSTMENU   2
#define	LEFTCOLUMN  48
#define	WIDTH	    80 - LEFTCOLUMN
#define	WHITE	    0x0f

/* Declare global variables:
 */
DATETIME sTime,	wTime;
KBDKEYINFO inChar;
VIOMODEINFO wMode = { sizeof (wMode) };

struct SortType	SortArray[44], SortBackup[44];
long oTime, nTime;
int Sound, Pause;
int curSelect;

char *Menu[] = {
    "       C Sorting Demo",
    " ",
    "Insertion",
    "Bubble",
    "Heap",
    "Exchange",
    "Shell",
    "Quick",
    " ",
    "Toggle Sound: ",
    " ",
    "Pause Factor: ",
    "<   (Slower)",
    ">   (Faster)",
    " ",
    "Type first character of",
    "choice ( I B H E S Q T < > )",
    "or ESC key to end program: "
};
int Nlines = sizeof (Menu) / sizeof (Menu[0]);

main ()
{
    Screen (SAVE);
    VioGetMode (&wMode,	0);
    if (wMode.row != 43) {		/* Use 43-line mode if available */
	wMode.row = 43;
	wMode.hres = 640;		/* Try VGA */
	wMode.vres = 350;
	if (VioSetMode (&wMode,	0)) {
	    wMode.hres = 720;		/* Try EGA */
	    wMode.vres = 400;
	    if (VioSetMode (&wMode, 0))	{
		VioGetMode (&wMode, 0);
		wMode.row = 25;		/* Use 25 lines	*/
		VioSetMode (&wMode, 0);
	    }
	}
    }
    Initialize ();	   /* Initialize data values. */
    SortMenu ();	   /* Print sort menu. */
    if (!Screen	(RESTORE))
	Cls ();
    exit (0);
}

/* =============================== BoxInit ====================================
 *    Calls the	DrawFrame procedure to draw the	frame around the sort menu,
 *    then prints the different	options	stored in the OptionTitle array.
 * ============================================================================
 */
void BoxInit ()
{
    int	i;
    char Color = WHITE,	Factor[3];

    DrawFrame (1, LEFTCOLUMN - 3, WIDTH	+ 3, 22);

    for	(i = 0;	i < Nlines; i++)
	VioWrtCharStrAtt (Menu[i], strlen (Menu[i]),
			 FIRSTMENU + i,	LEFTCOLUMN, &Color, 0);

   /* Print the	current	value for Sound:
    */
    if (Sound)
	VioWrtCharStrAtt ("ON ", 3, 11,	LEFTCOLUMN + 14, &Color, 0);
    else
	VioWrtCharStrAtt ("OFF", 3, 11,	LEFTCOLUMN + 14, &Color, 0);

    sprintf (Factor,"%3.3u", Pause/30);
    VioWrtCharStrAtt (Factor, 3, 13, LEFTCOLUMN	+ 14, &Color, 0);

   /* Erase the	speed option if	the length of the Pause	is at a	limit
    */
    if (Pause == 900)
	VioWrtCharStrAtt ("            ", 12, 14, LEFTCOLUMN, &Color, 0);
    if (Pause == 0)
	VioWrtCharStrAtt ("            ", 12, 15, LEFTCOLUMN, &Color, 0);
}

/* ============================== BubbleSort ==================================
 *    The BubbleSort algorithm cycles through SortArray, comparing adjacent
 *    elements and swapping pairs that are out of order.  It continues to
 *    do this until no pairs are swapped.
 * ============================================================================
 */
void BubbleSort	()
{
    int	Row, Switch, Limit;

    Limit = wMode.row;
    do {
	Switch = FALSE;
	for (Row = 1; Row <= (Limit - 1); Row++) {

	   /* Two adjacent elements are	out of order, so swap their values
	    * and redraw those two bars: */
	    if (SortArray[Row].Length >	SortArray[Row +	1].Length) {
		Swaps (&SortArray[Row],	&SortArray[Row + 1]);
		SwapBars (Row, Row + 1);
		Switch = Row;
	    }
	}

    /* Sort on next pass only to where the last	switch was made: */
    Limit = Switch;
    } while (Switch);
}

/* ============================== DrawFrame ===================================
 *   Draws a rectangular frame using the high-order ASCII characters É (201) ,
 *   » (187) , È (200) , ¼ (188) , º (186) , and Í (205). The parameters
 *   TopSide, BottomSide, LeftSide, and	RightSide are the row and column
 *   arguments for the upper-left and lower-right corners of the frame.
 * ============================================================================
 */
void DrawFrame (int Top, int Left, int Width, int Height)
{
#define	ULEFT 201
#define	URIGHT 187
#define	LLEFT 200
#define	LRIGHT 188
#define	VERTICAL 186
#define	HORIZONTAL 205
#define	SPACE ' '

    int	 Row;
    char Color = WHITE,	TempStr[80];

    memset (TempStr, HORIZONTAL, Width);
    TempStr[0] = ULEFT;
    TempStr[Width - 1] = URIGHT;

    VioWrtCharStrAtt (TempStr, Width, Top, Left, &Color, 0);

    memset (TempStr, SPACE, Width);
    TempStr[0] = VERTICAL;
    TempStr[Width - 1] = VERTICAL;

    for	(Row = Top + 1;	Row <= Height -	1; Row++)
	VioWrtCharStrAtt (TempStr, Width, Row, Left, &Color, 0);

    memset (TempStr, HORIZONTAL, Width + 1);
    TempStr[0] = LLEFT;
    TempStr[Width - 1] = LRIGHT;

    VioWrtCharStrAtt (TempStr, Width, Top + Height - 1,	Left, &Color, 0);
}

/* ============================= ElapsedTime ==================================
 *    Prints seconds elapsed since the given sorting routine started.
 *    Note that	this time includes both	the time it takes to redraw the
 *    bars plus	the pause while	the SOUND statement plays a note, and
 *    thus is not an accurate indication of sorting speed.
 * ============================================================================
 */
void ElapsedTime (int CurrentRow)
{

    char Color = WHITE,	Timing[80];

    DosGetDateTime (&wTime);

    nTime = (wTime.hours * 360000) +
	    (wTime.minutes * 6000) +
	    (wTime.seconds * 100) +
	     wTime.hundredths;

    sprintf (Timing, "%7.2f", ((float)(nTime - oTime) /	100));

    /* Print the number	of seconds elapsed */
    VioWrtCharStrAtt (Timing, strlen (Timing), curSelect + FIRSTMENU + 2,
	LEFTCOLUMN + 15, &Color, 0);

    if (Sound)
	DosBeep	(60 * CurrentRow, 32);	 /* Play a note. */
    DosSleep ((ULONG)Pause);		 /* Pause. */

}

/* ============================= ExchangeSort =================================
 *   The ExchangeSort compares each element in SortArray - starting with
 *   the first element - with every following element.	If any of the
 *   following elements	is smaller than	the current element, it	is exchanged
 *   with the current element and the process is repeated for the next
 *   element in	SortArray.
 * ============================================================================
 */
void ExchangeSort ()
{
    int	Row, SmallestRow, j;

    for	(Row = 1; Row <= wMode.row - 1;	Row++) {
	SmallestRow = Row;
	for (j = Row + 1; j <= wMode.row; j++) {
	    if (SortArray[j].Length < SortArray[SmallestRow].Length) {
		SmallestRow = j;
		ElapsedTime (j);
	    }
	}
       /* Found	a row shorter than the current row, so swap those
	* two array elements: */
	if (SmallestRow	> Row) {
	    Swaps (&SortArray[Row], &SortArray[SmallestRow]);
	    SwapBars (Row, SmallestRow);
	}
    }

}

/* =============================== HeapSort ===================================
 *  The	HeapSort procedure works by calling two	other procedures - PercolateUp
 *  and	PercolateDown.	PercolateUp turns SortArray into a "heap," which has
 *  the	properties outlined in the diagram below:
 *
 *				 SortArray[1]
 *				 /	    \
 *		      SortArray[2]	     SortArray[3]
 *		     /		\	     /		\
 *	   SortArray[4]	  SortArray[5]	 SortArray[6]  SortArray[7]
 *	    /	   \	   /	   \	   /	  \	 /	\
 *	  ...	   ...	 ...	   ...	 ...	  ...  ...	...
 *
 *
 *  where each "parent node" is	greater	than each of its "child nodes";	for
 *  example, SortArray[1] is greater than SortArray[2] or SortArray[3],
 *  SortArray[4] is greater than SortArray[5] or SortArray[6], and so forth.
 *
 *  Therefore, once the	first FOR...NEXT loop in HeapSort is finished, the
 *  largest element is in SortArray[1].
 *
 *  The	second FOR...NEXT loop in HeapSort swaps the element in	SortArray[1]
 *  with the element in	MaxRow,	rebuilds the heap (with	PercolateDown) for
 *  MaxRow - 1,	then swaps the element in SortArray[1] with the	element	in
 *  MaxRow - 1,	rebuilds the heap for MaxRow - 2, and continues	in this	way
 *  until the array is sorted.
 * ============================================================================
 */
void HeapSort ()
{
    int	i;

    for	(i = 2;	i <= wMode.row;	i++)
	PercolateUp (i);

    for	(i = wMode.row;	i >= 2;	i--) {
	Swaps (&SortArray[1], &SortArray[i]);
	SwapBars (1, i);
	PercolateDown (i - 1);
    }
}

/* ============================== Initialize ==================================
 *    Initializes the SortBackup and OptionTitle arrays.  It also calls	the
 *    BoxInit procedure.
 * ============================================================================
 */
void Initialize	()
{
    int	TempArray[44], i, MaxColors, MaxIndex, Index, BarLength;

    for	(i = 1;	i <= wMode.row;	i++)
	TempArray[i] = i;

    MaxIndex = wMode.row;

    srand (time(0L));	     /*	Seed the random-number generator. */

    /* If monochrome or	color burst disabled, use one color */
    if ((wMode.fbType &	VGMT_OTHER) && (!(wMode.fbType & VGMT_DISABLEBURST)))
	MaxColors = 15;
    else
	MaxColors = 1;

    for	(i = 1;	i <= wMode.row;	i++) {

       /* Find a random	element	in TempArray between 1 and MaxIndex,
	* then assign the value	in that	element	to BarLength: */
	Index =	RandInt	(1, MaxIndex);
	BarLength = TempArray[Index];

       /* Overwrite the	value in TempArray[Index] with the value in
	* TempArray[MaxIndex] so the value in TempArray[Index] is
	* chosen only once: */
	TempArray[Index] = TempArray[MaxIndex];

       /* Decrease the value of	MaxIndex so that TempArray[MaxIndex] can't
	* be chosen on the next	pass through the loop: */
	--MaxIndex;

	SortBackup[i].Length = BarLength;

	if (MaxColors == 1)
	    SortBackup[i].ColorVal = 7;
	else
	    SortBackup[i].ColorVal = BarLength % MaxColors + 1;
    }

    Cls	();
    Reinitialize ();	 /* Assign values in SortBackup	to SortArray and draw
			  * unsorted bars on the screen. */
    Sound = TRUE;
    Pause = 30;		 /* Initialize Pause. */
    BoxInit ();		 /* Draw frame for the sort menu and print options. */

}

/* ============================= InsertionSort ================================
 *   The InsertionSort procedure compares the length of	each successive
 *   element in	SortArray with the lengths of all the preceding	elements.
 *   When the procedure	finds the appropriate place for	the new	element, it
 *   inserts the element in its	new place, and moves all the other elements
 *   down one place.
 * ============================================================================
 */
void InsertionSort ()
{
    struct SortType TempVal;
    int	TempLength;
    int	j, Row;

    for	(Row = 2; Row <= wMode.row; Row++) {
	TempVal	= SortArray[Row];
	TempLength = TempVal.Length;
	for (j = Row; j	>= 2; j--) {

	   /* As long as the length of the j-1st element is greater than the
	    * length of	the original element in	SortArray[Row],	keep shifting
	    * the array	elements down: */
	    if (SortArray[j - 1].Length	> TempLength) {
		SortArray[j] = SortArray[j - 1];
		PrintOneBar (j);	    /* Print the new bar. */
		ElapsedTime (j);	    /* Print the elapsed time. */

	     /*	Otherwise, exit: */
	     } else
		break;
	}

	/* Insert the original value of	SortArray[Row] in SortArray[j]:	*/
	SortArray[j] = TempVal;
	PrintOneBar (j);
	ElapsedTime (j);
    }
}

/* ============================	PercolateDown =================================
 *   The PercolateDown procedure restores the elements of SortArray from 1 to
 *   MaxLevel to a "heap" (see the diagram with	the HeapSort procedure).
 * ============================================================================
 */
void PercolateDown (int	MaxLevel)
{
    int	Child, i = 1;

   /* Move the value in	SortArray[0] down the heap until it has	reached
    * its proper node (that is,	until it is less than its parent node
    * or until it has reached MaxLevel,	the bottom of the current heap): */
    for	(;;) {
	Child =	2 * i;		  /* Get the subscript for the child node. */

	/* Reached the bottom of the heap, so exit this	procedure: */
	if (Child > MaxLevel)
	    break;

	/* If there are	two child nodes, find out which	one is bigger: */
	if (Child + 1 <= MaxLevel)
	    if (SortArray[Child	+ 1].Length > SortArray[Child].Length)
		++Child;

       /* Move the value down if it is still not bigger	than either one	of
	* its children:	*/
	if (SortArray[i].Length	< SortArray[Child].Length) {
	    Swaps (&SortArray[i], &SortArray[Child]);
	    SwapBars (i, Child);
	    i =	Child;

       /* Otherwise, SortArray has been	restored to a heap from	1 to
	* MaxLevel, so exit: */
	} else
	    break;
    }
}

/* ============================== PercolateUp =================================
 *   The PercolateUp procedure converts	the elements from 1 to MaxLevel	in
 *   SortArray into a "heap" (see the diagram with the HeapSort	procedure).
 * ============================================================================
 */
void PercolateUp (int MaxLevel)
{
    int	i = MaxLevel, Parent;

   /* Move the value in	SortArray[MaxLevel] up the heap	until it has
    * reached its proper node (that is,	until it is greater than either
    * of its child nodes, or until it has reached 1, the top of	the heap): */
    while (i !=	1) {
	Parent = i / 2;		  /* Get the subscript for the parent node. */

       /* The value at the current node	is still bigger	than the value at
	* its parent node, so swap these two array elements: */
	if (SortArray[i].Length	> SortArray[Parent].Length) {
	    Swaps (&SortArray[Parent], &SortArray[i]);
	    SwapBars (Parent, i);
	    i =	Parent;

       /* Otherwise, the element has reached its proper	place in the heap,
	* so exit this procedure: */
	} else
	    break;
    }
}

/* ============================== PrintOneBar =================================
 *  Prints SortArray[Row].BarString at the row indicated by the	Row
 *  parameter, using the color in SortArray[Row].ColorVal.
 * ============================================================================
 */
void PrintOneBar (int Row)
{
    struct CELLINFO Cell;
    int	NumSpaces;

    Cell.Attr =	SortArray[Row].ColorVal;
    Cell.Char =	BLOCK;
    VioWrtNCell	((PBYTE)&Cell, SortArray[Row].Length, Row, 1, 0);
    Cell.Char =	SPACECELL;
    NumSpaces =	wMode.row - SortArray[Row].Length;
    if (NumSpaces > 0)
	VioWrtNCell ((PBYTE)&Cell, NumSpaces, Row, SortArray[Row].Length+1, 0);
}

/* ============================== QuickSort ===================================
 *   QuickSort works by	picking	a random "pivot" element in SortArray, then
 *   moving every element that is bigger to one	side of	the pivot, and every
 *   element that is smaller to	the other side.	 QuickSort is then called
 *   recursively with the two subdivisions created by the pivot.  Once the
 *   number of elements	in a subdivision reaches two, the recursive calls end
 *   and the array is sorted.
 * ============================================================================
 */
void QuickSort (int Low, int High)
{
    int	i, j, RandIndex, Partition;

    if (Low < High) {

       /* Only two elements in this subdivision; swap them if they are out of
	* order, then end recursive calls: */
	if (High - Low == 1) {
	    if (SortArray[Low].Length >	SortArray[High].Length)	{
		Swaps (&SortArray[Low],	&SortArray[High]);
		SwapBars (Low, High);
	    }
	} else {
	    Partition =	SortArray[High].Length;
	    do {

	       /* Move in from both sides towards the pivot element: */
		i = Low;
		j = High;
		while ((i < j) && (SortArray[i].Length <= Partition))
		    i++;

		while ((j > i) && (SortArray[j].Length >= Partition))
		    j--;

	       /* If we	haven't reached the pivot element, it means that two
		* elements on either side are out of order, so swap them: */
		if (i <	j) {
		    Swaps (&SortArray[i], &SortArray[j]);
		    SwapBars (i, j);
		}
	    } while (i < j);

	   /* Move the pivot element back to its proper	place in the array: */
	    Swaps (&SortArray[i], &SortArray[High]);
	    SwapBars (i, High);

	   /* Recursively call the QuickSort procedure (pass the smaller
	    * subdivision first	to use less stack space): */
	    if ((i - Low) < (High - i))	{
		QuickSort (Low,	i - 1);
		QuickSort (i + 1, High);
	    } else {
		QuickSort (i + 1, High);
		QuickSort (Low,	i - 1);
	    }
	}
    }
}

/* =============================== RandInt ====================================
 *   Returns a random integer greater than or equal to the Lower parameter
 *   and less than or equal to the Upper parameter.
 * ============================================================================
 */
int RandInt (int Lower,	int Upper)
{
    return ((int)((float)rand () / 32767. * (Upper - Lower + 1)) + Lower);
}

/* ============================== Reinitialize ================================
 *   Restores the array	SortArray to its original unsorted state, then
 *   prints the	unsorted color bars.
 * ============================================================================
 */
void Reinitialize ()
{
    int	Row;

    DosGetDateTime (&sTime);
    oTime = (sTime.hours * 360000) +
	    (sTime.minutes * 6000) +
	    (sTime.seconds * 100) +
	     sTime.hundredths;

    for	(Row = 1; Row <= wMode.row; Row++) {
	SortArray[Row] = SortBackup[Row];
	PrintOneBar (Row);
    }
}

int Screen (int	ACTION)
{
    static VIOMODEINFO Mode;
    static PCH CellStr;
    static USHORT Row, Col, Length;
    if (ACTION)	{
	Mode.cb	= sizeof(Mode);
	VioGetMode (&Mode, 0);
	Length = 2*Mode.row*Mode.col;
	CellStr	= malloc (Length);
	if (CellStr == NULL)
	    return (FALSE);
	VioReadCellStr (CellStr, &Length, 0, 0,	0);
	VioGetCurPos (&Row, &Col, 0);
    }
    else {
	VioSetMode (&Mode, 0);
	if (CellStr == NULL)
	    return (FALSE);
	VioWrtCellStr (CellStr,	Length,	0, 0, 0);
	VioSetCurPos (Row, Col,	0);
    }
    return (TRUE);
}

/* =============================== ShellSort ==================================
 *  The	ShellSort procedure is similar to the BubbleSort procedure.  However,
 *  ShellSort begins by	comparing elements that	are far	apart (separated by
 *  the	value of the Offset variable, which is initially half the distance
 *  between the	first and last element), then comparing	elements that are
 *  closer together (when Offset is one, the last iteration of this procedure
 *  is merely a	bubble sort).
 * ============================================================================
 */
void ShellSort ()
{
    int	Offset,	Switch,	Limit, Row;

    /* Set comparison offset to	half the number	of records in SortArray: */
    Offset = wMode.row / 2;

    while (Offset) {		 /* Loop until offset gets to zero. */
	Limit =	wMode.row - Offset;
	do {
	    Switch = FALSE;	   /* Assume no	switches at this offset. */

	   /* Compare elements and switch ones out of order: */
	    for	(Row = 1; Row <= Limit;	Row++)
		if (SortArray[Row].Length > SortArray[Row + Offset].Length) {
		    Swaps (&SortArray[Row], &SortArray[Row + Offset]);
		    SwapBars (Row, Row + Offset);
		    Switch = Row;
		}

	    /* Sort on next pass only to where last switch was made: */
	    Limit = Switch - Offset;
	} while	(Switch);

       /* No switches at last offset, try one half as big: */
	Offset = Offset	/ 2;
    }
}

/* =============================== SortMenu ===================================
 *   The SortMenu procedure first calls	the Reinitialize procedure to make
 *   sure the SortArray	is in its unsorted form, then prompts the user to
 *   make one of the following choices:
 *
 *		 * One of the sorting algorithms
 *		 * Toggle sound	on or off
 *		 * Increase or decrease	speed
 *		 * End the program
 * ============================================================================
 */
void SortMenu ()
{
    for	(;;) {

	VioSetCurPos (FIRSTMENU	+ Nlines - 1, LEFTCOLUMN + 27, 0);

	KbdCharIn (&inChar, 0, 0);

	/* Branch to the appropriate procedure depending on the	key typed: */
	switch (toupper	(inChar.chChar)) {
	    case 'I':
		curSelect = 0;
		Reinitialize ();
		InsertionSort ();
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case 'B':
		curSelect = 1;
		Reinitialize ();
		BubbleSort ();
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case 'H':
		curSelect = 2;
		Reinitialize ();
		HeapSort ();
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case 'E':
		curSelect = 3;
		Reinitialize ();
		ExchangeSort ();
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case 'S':
		curSelect = 4;
		Reinitialize ();
		ShellSort ();
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case 'Q':
		curSelect = 5;
		Reinitialize ();
		QuickSort (1, wMode.row);
		ElapsedTime (0);		  /* Print final time. */
		break;
	    case '>':

	   /* Decrease pause length to speed up	sorting	time, then redraw
	    * the menu to clear	any timing results (since they won't compare
	    * with future results): */
		if (Pause != 0)
		    Pause -= 30;
		BoxInit	();
		break;

	    case '<':

	   /* Increase pause length to slow down sorting time, then redraw
	    * the menu to clear	any timing results (since they won't compare
	    * with future results): */
		if (Pause != 900)
		    Pause += 30;
		BoxInit	();
		break;

	    case 'T':
		Sound =	!Sound;
		BoxInit	();
		break;

	    case 27:

	   /* User pressed ESC,	so exit	this procedure and return to main: */
		return;
	}
    }
}

/* =============================== SwapBars ===================================
 *   Calls PrintOneBar twice to	switch the two bars in Row1 and	Row2,
 *   then calls	the ElapsedTime	procedure.
 * ============================================================================
 */
void SwapBars (int Row1, int Row2)
{
    PrintOneBar	(Row1);
    PrintOneBar	(Row2);
    ElapsedTime	(Row1);
}

void Cls ()
{
    char Cell =	SPACECELL;

    VioScrollDn	(0, 0, -1, -1, -1, &Cell, 0);
}

void Swaps (struct SortType *one, struct SortType *two)
{
    struct SortType temp;

    temp = *one;
    *one = *two;
    *two = temp;

}
