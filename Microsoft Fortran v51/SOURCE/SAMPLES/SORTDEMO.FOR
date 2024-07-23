CC  SORTDEMO.FOR
CC
CC  This program graphically demonstrates six common sorting algorithms.
CC  It displays 25 or 43 horizontal bars different lengths in random order,
CC  then sorts the bars from shortest to longest.
CC
CC  The program also uses the DosBeep API function to generate sounds of
CC  different pitches, depending on the location of the bar being displayed.
CC  Note that calls to the DosBeep and DosSleep functions delay the speed
CC  of each sorting algorithm so you can follow the progress of the sort.
CC  Therefore, the times shown are for comparisons only.  They are not an
CC  accurate measure of sort speed.
CC
CC  If you use these sorting routines in your own programs, you may notice
CC  a difference in their relative speeds -- for example, the exchange
CC  sort may be faster than the shell sort.  The speed of each algorithm
CC  depends on the number of elements to be sorted and how "scrambled"
CC  they are to begin with.
CC
CC  To compile this program, the following OS/2 include files must be copied
CC  from the distribution disks (as described in PACKING.LST on the SETUP
CC  disk) to either your current directory or the directory specified by
CC  the INCLUDE environment variable:
CC
CC      BSE.FI          BSEDOS.FI       BSESUB.FI
CC      BSE.FI          BSEDOS.FI       BSESUB.FI
CC
CC  To compile a protect-mode version, use the following command line:
CC
CC      FL /Lp sortdemo.for
CC
CC  To compile a bound version that can be run from either DOS or OS/2,
CC  use the following command line:
CC
CC      FL /Lp /Fb sortdemo.for
CC
CC  You cannot create a DOS-only version. Note that /Lp may not be
CC  required, depending on the library names you selected during setup.
CC

$NOTRUNCATE
$STORAGE:2

$DEFINE  INCL_NOCOMMON
$DEFINE  INCL_DOSPROCESS
$DEFINE  INCL_KBD
$DEFINE  INCL_VIO

      INCLUDE 'BSE.FI'
      INCLUDE 'BSE.FD'

      INTEGER*2            dummy, MaxBars, MaxColors, Pause,
     +                     CurRow, CurCol, C_LENGTH
      LOGICAL              Sound
      PARAMETER          ( C_LENGTH = 8000 )
      CHARACTER*(C_LENGTH) CellStr
      RECORD /VIOMODEINFO/ NewMode, OldMode

      COMMON /misc/        MaxBars, MaxColors, Sound, Pause

C
C     Get cursor position, screen contents, and current video mode.
C     The parameter C_LENGTH is the length of a cell string to hold
C     the screen contents, including attribute bytes.  Its value of
C     8000 allows enough space for 50-line mode.
C
      dummy      = VioGetCurPos( CurRow, CurCol, 0 )
      dummy      = VioReadCellStr( CellStr, C_LENGTH, 0, 0, 0 )
      OldMode.cb = 14
      NewMode.cb = 14
      dummy      = VioGetMode( OldMode, 0 )
      dummy      = VioGetMode( NewMode, 0 )

C
C     MaxColors is number of colors used when displaying bars.
C     If monochrome or color burst disabled, use one color.
C
      MaxColors = 15
      IF( (.NOT. BTEST( NewMode.fbType, 0 ))  .OR.
     +           BTEST( NewMode.fbType, 2 ) ) MaxColors = 1

C
C     MaxBars is number of bars, one for each screen line.
C     First try 43-line mode.  If neither EGA or VGA is
C     available, set for 25-line mode.
C
      MaxBars = 43
      IF( NewMode.row .NE. 43 ) THEN
         NewMode.row  = 43
         NewMode.hres = 640
         NewMode.vres = 350
         IF( VioSetMode( NewMode, 0 ) .NE. 0 ) THEN
            dummy       = VioGetMode( NewMode, 0 )
            MaxBars     = 25
            NewMode.row = 25
            dummy       = VioSetMode( NewMode, 0 )
         END IF
      END IF

      CALL Initialize
      CALL SortMenu

C
C     Restore line mode, screen contents, and cursor position
C     before exiting.
C
      dummy     = VioSetMode( OldMode, 0 )
      dummy     = VioWrtCellStr( CellStr, C_LENGTH, 0, 0, 0 )
      dummy     = VioSetCurPos( CurRow, CurCol, 0 )
      END



CC  Block Data Subprogram - Initializes data held in common block /misc/.
CC
CC  Uses:    MaxBars   - Number of bars to sort (25 or 43)
CC           MaxColors - Number of colors (1 or 15)
CC           Sound     - .TRUE. for sound on, .FALSE. for sound off
CC           Pause     - Number of milliseconds to pause when
CC                       displaying sorting speed

      BLOCK DATA
      IMPLICIT INTEGER*2 ( a - z )

      LOGICAL       Sound
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      DATA          Sound, Pause  / .TRUE., 30 /
      END



CC  Initialize - Generates a pattern of bar in random lengths and colors,
CC  then stores the pattern in the SortBackup array.  Also calls the
CC  BoxInit subroutine.
CC
CC  Params:  None

      SUBROUTINE Initialize
      IMPLICIT INTEGER*2 ( a - z )

      LOGICAL       Sound
      REAL*4        Rand
      DIMENSION     TempArray(43)
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

C
C     BarLength and BarColor are indexes for the row dimensions of
C     SortArray and SortBackup.  Bar lengths are contained in the
C     first row of SortArray, and bar colors in the second row.
C
      BarLength = 1
      BarColor  = 2
      DO i = 1, MaxBars
         TempArray(i) = i
      END DO
C
C     Seed the random-number generator with current hundredth second.
C
      CALL GETTIM( dummy, dummy, dummy, Rseed )
      CALL SEED( Rseed )

      MaxIndex = MaxBars
      DO i = 1, MaxBars
C
C        Find a random element in TempArray between 1 and MaxIndex, 
C        then assign the value in that element to LengthBar.
C
         CALL RANDOM( Rand )

         Index     = (MaxIndex * Rand) + 1
         LengthBar = TempArray(index)
C
C        Overwrite the value in TempArray(Index) with the value in
C        TempArray(MaxIndex) so the value in TempArray(Index) is
C        chosen only once.
C
         TempArray(index) = TempArray(MaxIndex)
C
C        Decrease the value of MaxIndex so that TempArray(MaxIndex) can't
C        be chosen on the next pass through the loop.
C
         MaxIndex = MaxIndex - 1

         SortBackup(BarLength,i) = LengthBar
         IF( MaxColors .EQ. 1 ) THEN
            SortBackup(BarColor,i) = 7
         ELSE  
            SortBackup(BarColor,i) = MOD( LengthBar, MaxColors ) + 1
         END IF
      END DO

      CALL cls
C
C     Assign values in SortBackup to SortArray and redraw unsorted
C     bars on the screen.
C
      CALL Reinitialize
C
C     Draw frame and display the SortDemo menu.
C
      CALL BoxInit
      RETURN
      END



CC  BoxInit - Calls the DrawFrame procedure to draw the frame around
CC  the SortDemo menu, then displays the menu.
CC
CC  Params:  None

      SUBROUTINE BoxInit
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*1     COLOR
      INTEGER*2     FIRSTMENU, LEFT, LINELENGTH, NLINES, WIDTH
      CHARACTER*4   Factor
      CHARACTER*12  BLANK
      PARAMETER   ( COLOR      = 15, FIRSTMENU = 1 , LEFT  = 48     ,
     +              LINELENGTH = 28, NLINES    = 18, WIDTH = 80-LEFT,
     +              BLANK      = '            ' )
      LOGICAL       Sound
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      CHARACTER*(LINELENGTH)  menu(NLINES)
      DATA menu / '     FORTRAN Sorting Demo',
     +            ' ',
     +            'Insertion',
     +            'Bubble',
     +            'Heap',
     +            'Exchange',
     +            'Shell',
     +            'Quick',
     +            ' ',
     +            'Toggle Sound: ',
     +            ' ',
     +            'Pause Factor: ',
     +            '<   (Slower)',
     +            '>   (Faster)',
     +            ' ',
     +            'Type first character of',
     +            'choice ( I B H E S Q T < > )',
     +            'or ESC key to end program: ' /

      CALL DrawFrame( 1, LEFT-3, WIDTH + 3, 22)

      DO i = 1, NLINES
         dummy = VioWrtCharStrAtt( menu(i), LINELENGTH,
     +                             FIRSTMENU + i, LEFT, COLOR, 0)
      END DO

      WRITE (Factor, '(I2.2)') Pause / 30
      dummy = VioWrtCharStrAtt( Factor, LEN( Factor ), 13,
     +                          LEFT + 14, COLOR, 0)

C
C     Erase the speed option if the length of the Pause is at a limit.
C
      IF( Pause .EQ. 900 ) THEN
         dummy = VioWrtCharStrAtt( BLANK, 12, 14, LEFT, COLOR, 0 )
      ELSEIF( Pause .EQ. 0 ) THEN
         dummy = VioWrtCharStrAtt( BLANK, 12, 15, LEFT, COLOR, 0 )
      END IF

C
C     Display the current value for Sound.
C
      IF( Sound ) THEN
        dummy = VioWrtCharStrAtt( 'ON ', 3, 11, LEFT + 14, COLOR, 0 )
      ELSE
        dummy = VioWrtCharStrAtt( 'OFF', 3, 11, LEFT + 14, COLOR, 0 )
      END IF

      RETURN
      END



CC  DrawFrame - Draws a rectangular frame using the high-order ASCII
CC  characters 201, 187, 200, 188, 186, and 205.
CC
CC  Params:  Top    - row number of top line
CC           Left   - column number of left edge
CC           Width  - number of columns in frame
CC           Height - number of rows in frame

      SUBROUTINE DrawFrame( Top, Left, Width, Height )
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*1     cell(2), COLOR, ULEFT, URIGHT, LLEFT,
     +              LRIGHT, VERTICAL, HORIZONTAL, SPACE
      CHARACTER*80  TempStr
      PARAMETER   ( ULEFT  = 'É', URIGHT   = '»', LLEFT      = 'È',
     +              LRIGHT = '¼', VERTICAL = 'º', HORIZONTAL = 'Í',
     +              SPACE  = ' ', COLOR    = 15 )

      bottom  = Top  + Height - 1
      right   = Left + Width  - 1
      cell(2) = COLOR
      cell(1) = ULEFT
      dummy   = VioWrtNCell( cell, 1, Top, Left, 0)
      cell(1) = HORIZONTAL
      dummy   = VioWrtNCell( cell, Width-2, Top, Left + 1, 0)
      cell(1) = URIGHT
      dummy   = VioWrtNCell( cell, 1, Top, right, 0)
      TempStr(1:1) = CHAR( VERTICAL )

      DO i = 2, Width-1
         TempStr(i:i) = CHAR( SPACE )
      END DO

      TempStr(Width:Width) = CHAR( VERTICAL )
      DO i = 1, Height-2
         dummy = VioWrtCharStrAtt( TempStr, Width, i + Top,
     +                             Left, COLOR, 0)
      END DO

      cell(1) = LLEFT
      dummy   = VioWrtNCell( cell, 1, bottom, Left, 0)
      cell(1) = HORIZONTAL
      dummy   = VioWrtNCell( cell, Width-2, bottom, Left + 1, 0)
      cell(1) = LRIGHT
      dummy   = VioWrtNCell( cell, 1, bottom, right, 0)
      RETURN
      END




CC  ElapsedTime - Displays seconds elapsed since the given sorting routine
CC  started.  Note that this time includes both the time it takes to
CC  redraw the bars plus the pause while the DosBeep function plays a
CC  note, and thus is not meant to be a true measure of sorting speed.
CC
CC  Params:  CurrentRow
CC
CC  Uses:    SortArray, SortBackup - length and color for each bar
CC           time0 - Starting time for sort

      SUBROUTINE ElapsedTime( CurrentRow )
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*1     COLOR
      INTEGER*4     time0, time1
      CHARACTER*7   Timing
      LOGICAL       Sound
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON /time/ time0
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select
      PARAMETER   ( COLOR = 15, FIRSTMENU = 1, LEFT = 48 )

      CALL GETTIM( Hour, Minute, Second, Hundredth )
      time1 = Hour   * 360000 +
     +        Minute * 6000   +
     +        Second * 100    +
     +        Hundredth

      WRITE (Timing, '(F7.2)') FLOAT( time1 - time0 ) / 100.0
C
C     Display the number of seconds elapsed.
C
      dummy = VioWrtCharStrAtt( Timing, LEN( Timing ),
     +                          Select+FIRSTMENU+3, LEFT+15, COLOR, 0)

      IF( Sound ) dummy = DosBeep( 60 * CurrentRow, 32 )
      dummy = DosSleep( INT4( Pause ) )
      RETURN
      END



CC  InsertionSort - The InsertionSort procedure compares the length of
CC  each successive element in SortArray with the lengths of all the
CC  preceding elements.  When the procedure finds the appropriate place
CC  for the new element, it inserts the element in its new place, and
CC  moves all the other elements down one place.
CC
CC  Params:  None

      SUBROUTINE InsertionSort
      IMPLICIT INTEGER*2 ( a - z )

      DIMENSION     TempArray(2)
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      DO Row = 2, MaxBars
         TempArray(BarLength) = SortArray(BarLength,Row)
         TempArray(BarColor)  = SortArray(BarColor,Row)
         DO j = Row, 2, -1
C
C           As long as the length of the j-1st element is greater than the
C           length of the original element in SortArray(Row), keep shifting
C           the array elements down.
C
            IF( SortArray(BarLength,j - 1) .GT.
     +          TempArray(BarLength) ) THEN
                SortArray(BarLength,j) = SortArray(BarLength,j - 1)
                SortArray(BarColor,j)  = SortArray(BarColor,j - 1)
                CALL PrintOneBar(j)
                CALL ElapsedTime(j)
            ELSE
                EXIT
            END IF
         END DO
     
C
C        Insert the original value of SortArray(Row) in SortArray(j).
C
         SortArray(BarLength,j) = TempArray(BarLength)
         SortArray(BarColor,j)  = TempArray(BarColor)
         CALL PrintOneBar( j )
         CALL ElapsedTime( j )
      END DO
      RETURN
      END



CC  BubbleSort - The BubbleSort algorithm cycles through SortArray,
CC  comparing adjacent elements and swapping pairs that are out of
CC  order.  It continues to do this until no pairs are swapped.
CC
CC  Params:  None

      SUBROUTINE BubbleSort
      IMPLICIT INTEGER*2 ( a - z )

      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      limit  = MaxBars
      DO WHILE( limit .NE. 0 )
         switch = 0
         DO row = 1, limit-1
C
C           If two adjacent elements are out of order, swap
C           their values and redraw those two bars.
C
            IF( SortArray(BarLength,row ) .GT. 
     +          SortArray(BarLength,row + 1 ) ) THEN
                CALL SwapSortArray( row, row + 1 )
                CALL SwapBars( row, row + 1 )
                switch = row
            END IF
         END DO
C
C        Sort on next pass only to where the last switch was made.
C
         limit = switch
      END DO
      RETURN
      END




CC  ExchangeSort - Beginning with the first element, ExchangeSort compares
CC  each element in SortArray with every following element.  If any of the
CC  following elements is smaller than the current element, it is exchanged
CC  with the current element.  The process is then repeated for the next
CC  element in SortArray.
CC
CC  Params:  None

      SUBROUTINE ExchangeSort
      IMPLICIT INTEGER*2 ( a - z )

      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      DO Row = 1, MaxBars-1
         SmallestRow = Row
         DO j = Row + 1, MaxBars
            IF( SortArray(BarLength,j) .LT.
     +          SortArray(BarLength,SmallestRow) ) THEN
                SmallestRow = j
                CALL ElapsedTime( j )
            END IF
         END DO
         IF( SmallestRow .GT. Row ) THEN
C
C           Found a row shorter than the current row,
C           so swap those two array elements.
C
            CALL SwapSortArray( Row, SmallestRow )
            CALL SwapBars( Row, SmallestRow )
         END IF
      END DO
      RETURN
      END



CC  HeapSort - The HeapSort subroutine works by calling two other
CC  subroutines:  PercolateUp and PercolateDown.  PercolateUp turns
CC  SortArray into a "heap," which has the properties outlined in the
CC  diagram below.
CC
CC                               SortArray(1)
CC                               /          \
CC                    SortArray(2)           SortArray(3)
CC                   /          \            /          \
CC         SortArray(4)   SortArray(5)   SortArray(6)  SortArray(7)
CC          /      \       /       \       /      \      /      \
CC        ...      ...   ...       ...   ...      ...  ...      ...
CC
CC
CC  Here each "parent node" is greater than each of its "child nodes".
CC  For example, the value of SortArray(1) is greater than that of
CC  SortArray(2) or SortArray(3), SortArray(3) is greater than
CC  SortArray(6) or SortArray(7), and so forth.
CC
CC  Therefore, once the first DO loop in HeapSort is finished, the largest
CC  element is in SortArray(1).
CC
CC  The second DO loop in HeapSort swaps the element in SortArray(1) with
CC  the element in MaxRow, rebuilds the heap (with PercolateDown) for
CC  MaxRow - 1, then swaps the element in SortArray(1) with the element
CC  in MaxRow - 1, rebuilds the heap for MaxRow - 2, and continues in
CC  this way until the array is sorted.
CC
CC  Params:  None

      SUBROUTINE HeapSort
      IMPLICIT INTEGER*2 ( a - z )

      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      DO i = 2, MaxBars
         CALL PercolateUp( i )
      END DO

      DO i = MaxBars, 2, -1
         CALL SwapSortArray( 1, i )
         CALL SwapBars( 1, i )
         CALL PercolateDown( i - 1 )
      END DO
      RETURN
      END



CC  PercolateUp - The PercolateUp procedure converts elements 1 to
CC  MaxLevel in SortArray into a "heap".  (See the diagram with the
CC  HeapSort procedure.)
CC
CC  Params:  MaxLevel - Highest element in heap

      SUBROUTINE PercolateUp( MaxLevel )
      IMPLICIT INTEGER*2 ( a - z )

      COMMON   SortArray(2,43), SortBackup(2,43),
     +         BarLength, BarColor, Select

C
C     Move the value in SortArray(MaxLevel) up the heap until it has
C     reached its proper node -- that is, until it is greater than either
C     of its child nodes, or until it has reached 1, the top of the heap.
C
      i = MaxLevel
      DO WHILE( i .NE. 1 )

C
C        Get the subscript for the parent node.
C
         Parent = i / 2

C
C        If the value at the current node is still bigger than the
C        value at its parent node, swap these two array elements.
C        Otherwise, the element has reached its proper place in the
C        heap, in which case the procedure exits.
C
         IF( SortArray(BarLength,i) .GT.
     +       SortArray(BarLength,Parent) ) THEN
             CALL SwapSortArray( Parent, i )
             CALL SwapBars( Parent, i )
             i = Parent
         ELSE
             i = 1
         END IF
      END DO
      RETURN
      END



CC  PercolateDown - The PercolateDown procedure restores elements 1
CC  to MaxLevel in SortArray from a "heap".  (See the diagram with
CC  the HeapSort procedure.)
CC
CC  Params:  MaxLevel - Highest element in heap

      SUBROUTINE PercolateDown( MaxLevel )
      IMPLICIT INTEGER*2 ( a - z )

      COMMON   SortArray(2,43), SortBackup(2,43),
     +         BarLength, BarColor, Select

C     Move the value in SortArray(1) down the heap until it has reached
C     its proper node -- that is, until it is less than its parent node
C     or until it has reached MaxLevel, the bottom of the current heap.
C
      i = 1
      DO WHILE( .TRUE. )

C
C        Get the subscript for the child node.
C
         Child = 2 * i

C
C        IF the bottom of the heap is reached, exit this procedure.
C
         IF( Child .GT. MaxLevel) EXIT

C
C        If there are two child nodes, determine which is bigger.
C
         IF( Child + 1 .LE. MaxLevel ) THEN
            IF( SortArray(BarLength,Child + 1) .GT.
     +          SortArray(BarLength,Child) ) Child = Child + 1
         END IF

C
C        Move the value down if it is still not bigger than either of
C        its children.  Otherwise, SortArray has been restored to a
C        heap from 1 to MaxLevel, in which case the routine exits.
C
         IF( SortArray(BarLength,i) .LT.
     +       SortArray(BarLength,Child) ) THEN
             CALL SwapSortArray(i, Child)
             CALL SwapBars(i, Child)
             i = Child
         ELSE
             EXIT
         END IF
      END DO
      RETURN
      END



CC  ShellSort - The ShellSort procedure is similar to the BubbleSort
CC  procedure.  However, ShellSort begins by comparing elements that
CC  are far apart -- that is, separated by the value of the Offset
CC  variable, which is initially half the distance between the first
CC  and last element.  The procedure repeats by comparing elements that
CC  are successively closer together.  Note that when Offset is one, the
CC  last iteration of this procedure is merely a bubble sort.
CC
CC  Params:  None

      SUBROUTINE ShellSort
      IMPLICIT INTEGER*2 ( a - z )

      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

C
C     Set comparison offset to half the number of records in SortArray.
C
      Offset = MaxBars / 2
      DO WHILE( Offset .GT. 0 )
         Limit  = MaxBars - Offset
         Switch = 1
         DO WHILE( Switch .GT. 0 )

C
C           Assume no switches at this offset.
C
            Switch = 0
C
C           Compare elements and switch ones out of order.
C
            DO Row = 1, Limit
               IF( SortArray(BarLength,Row) .GT. 
     +             SortArray(BarLength,Row + Offset) ) THEN
                   CALL SwapSortArray( Row, Row + Offset )
                   CALL SwapBars( Row, Row + Offset )
                   Switch = Row
               END IF
            END DO

C
C           Sort on next pass only to where last switch was made.
C
            Limit = Switch - Offset
         END DO
C
C        No switches at last offset, try one half as big.
C
         Offset = Offset / 2
      END DO
      RETURN
      END



CC  QuickSort - QuickSort works by picking a random "pivot" element in
CC  SortArray, then moving every element that is bigger to one side of
CC  the pivot, and every element that is smaller to the other side.  The
CC  procedure is repeated with the two subdivisions created by the pivot.
CC  When the number of elements in a subdivision reaches two, the array
CC  is sorted.
CC
CC  Params:  Low, High - Lower and upper boundaries for sorting

      SUBROUTINE QuickSort( Low, High )
      IMPLICIT INTEGER*2 ( a - z )

      PARAMETER ( LOG2MAXBARS = 6 )
      INTEGER*1   StackPtr, Upper(LOG2MAXBARS), Lower(LOG2MAXBARS)
      COMMON      SortArray(2,43), SortBackup(2,43),
     +            BarLength, BarColor, Select

      Lower(1) = Low
      Upper(1) = High
      StackPtr = 1

      DO WHILE( StackPtr .GT. 0 )
         IF( Lower(StackPtr) .GE. Upper(StackPtr) ) THEN
            StackPtr = StackPtr - 1
            CYCLE
         END IF
C
C        Move in from both sides towards the pivot element.
C
         i     = Lower(StackPtr)
         j     = Upper(StackPtr)
         Pivot = SortArray(BarLength,j)

         DO WHILE( i .LT. j )
            DO WHILE( (i .LT. j)  .AND.
     +                (SortArray(BarLength,i) .LE. Pivot) )
               i = i + 1
            END DO

            DO WHILE( (j .GT. i)  .AND.
     +                (SortArray(BarLength,j) .GE. Pivot ) )
               j = j - 1
            END DO
C
C           If the pivot element is not yet reached, it means that two
C           elements on either side are out of order, so swap them.
C
            IF( i .LT. j ) THEN
               CALL SwapSortArray( i, j )
               CALL SwapBars( i, j )
            END IF
         END DO

C
C        Move the pivot element back to its proper place in the array.
C
         j = Upper(StackPtr)
         CALL SwapSortArray( i, j )
         CALL SwapBars( i, j )

         IF( (i - Lower(StackPtr)) .LT. (Upper(StackPtr) - i) ) THEN
            Lower(StackPtr + 1) = Lower(StackPtr)
            Upper(StackPtr + 1) = i - 1
            Lower(StackPtr)     = i + 1
         ELSE
            Lower(StackPtr + 1) = i + 1
            Upper(StackPtr + 1) = Upper(StackPtr)
            Upper(StackPtr)     = i - 1
         END IF

         StackPtr = StackPtr + 1
      END DO
      RETURN
      END



CC  PrintOneBar - Displays SortArray(BarLength,Row) at the row indicated
CC  by the Row parameter, using the color in SortArray(BarColor,Row).
CC  The VioWrtNCell display function assumes row numbering begins with
CC  0 instead of 1; therefore, the value passed to this function is 1
CC  less than the value of Row.
CC
CC  Params:  Row

      SUBROUTINE PrintOneBar( Row )
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*1     cell(2), BLOCK, SPACE, COLOR
      PARAMETER   ( BLOCK = 'ß', SPACE = ' ', COLOR = 7 )
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      cell(1) = BLOCK
      cell(2) = SortArray(BarColor,Row)
      dummy   = VioWrtNCell( cell, SortArray(BarLength,Row),
     +                       Row - 1, 1, 0 )
      blanks  = MaxBars - SortArray(BarLength,Row)
      IF( blanks .GT. 0 ) THEN
         cell(1) = SPACE
         cell(2) = COLOR
         dummy   = VioWrtNCell( cell, blanks, Row - 1,
     +                          SortArray(BarLength,Row) + 1, 0 )
      END IF
      RETURN
      END



CC  Reinitialize - Restores the array SortArray to its original unsorted
CC  state while displaying the unsorted bars.
CC
CC  Params:  None
CC
CC  Uses:    time0 - Starting time for sort

      SUBROUTINE Reinitialize
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*4     time0
      COMMON /misc/ MaxBars, MaxColors, Sound, Pause
      COMMON /time/ time0
      COMMON        SortArray(2,43), SortBackup(2,43),
     +              BarLength, BarColor, Select

      DO row = 1, MaxBars
         SortArray(BarLength,row) = SortBackup(BarLength,row)
         SortArray(BarColor,row)  = SortBackup(BarColor,row)
         CALL PrintOneBar( row )
      END DO

      CALL GETTIM( Hour, Minute, Second, Hundredth )
      time0 = Hour   * 360000 +
     +        Minute * 6000   +
     +        Second * 100    +
     +        Hundredth
      RETURN
      END



CC  SortMenu - The SortMenu procedure first calls the Reinitialize
CC  procedure to make sure the SortArray is in its unsorted form,
CC  then prompts for one of the following selections:
CC
CC           *  One of the sorting algorithms
CC           *  Toggle sound on or off
CC           *  Increase or decrease speed
CC           *  End the program
CC
CC  Params:  None

      SUBROUTINE SortMenu
      IMPLICIT INTEGER*2 ( a - z )

      INCLUDE 'BSE.FD'

      PARAMETER         ( FIRSTMENU = 1, NLINES = 18, SPACE = 32 )
      CHARACTER*1         inkey
      LOGICAL             Sound
      RECORD /KBDKEYINFO/ kbd
      COMMON /misc/       MaxBars, MaxColors, Sound, Pause
      COMMON              SortArray(2,43), SortBackup(2,43),
     +                    BarLength, BarColor, Select

C
C     Locate the cursor
C
      dummy = VioSetCurPos( FIRSTMENU + NLINES, 75, 0 )

      DO WHILE( .TRUE. )
         dummy = KbdCharIn( kbd, 0, 0 )
         inkey = kbd.chChar

C
C        Make input character upper case for easier comparisons.
C
         IF( LGE( inkey, 'a' )  .AND.  LLE( inkey, 'z' ) )
     +      inkey = CHAR( ICHAR( inkey ) - SPACE )

C
C        Branch to the appropriate procedure depending on the key typed.
C
         IF( inkey .EQ. 'I' ) THEN
            Select = 0
            CALL Reinitialize
            CALL InsertionSort
            CALL ElapsedTime( 0 )

         ELSEIF( inkey .EQ. 'B' ) THEN
            Select = 1
            CALL Reinitialize
            CALL BubbleSort
            CALL ElapsedTime( 0 )

         ELSEIF( inkey .EQ. 'H' ) THEN
            Select = 2
            CALL Reinitialize
            CALL HeapSort
            CALL ElapsedTime( 0 )

         ELSEIF( inkey .EQ. 'E' ) THEN
            Select = 3
            CALL Reinitialize
            CALL ExchangeSort
            CALL ElapsedTime( 0 )

         ELSEIF( inkey .EQ. 'S' ) THEN
            Select = 4
            CALL Reinitialize
            CALL ShellSort
            CALL ElapsedTime( 0 )

         ELSEIF( inkey .EQ. 'Q' ) THEN
            Select = 5
            CALL Reinitialize
            CALL QuickSort( 1, MaxBars )
            CALL ElapsedTime( 0 )

C
C        If 'T', toggle the sound, then redraw the menu to clear any
C        timing results since they won't compare with future results.
C
         ELSEIF( inkey .EQ. 'T' ) THEN
            Sound = .NOT. Sound
            CALL Boxinit

C
C        If '<', increase pause length to slow down sorting time, then
C        redraw the menu to clear any timing results since they won't
C        compare with future results.
C
         ELSEIF( inkey .EQ. '<'  .AND.  Pause .NE. 900 ) THEN
            Pause = Pause + 30
            CALL BoxInit

C
C        If '>', decrease pause length to speed up sorting time, then
C        redraw the menu to clear any timing results since they won't
C        compare with future results.
C
         ELSEIF( inkey .EQ. '>'  .AND.  Pause .NE. 0 ) THEN
            Pause = Pause - 30
            CALL BoxInit

C
C        If ESC key, exit loop and return.
C
         ELSEIF( inkey .EQ. CHAR( 27 ) ) THEN
            EXIT
         END IF

      END DO
      RETURN
      END



CC  SwapBars - Calls PrintOneBar twice to switch the two bars in Row1
CC  and Row2, then calls the ElapsedTime procedure.
CC
CC  Params:  Row1, Row2

      SUBROUTINE SwapBars( Row1, Row2 )
      IMPLICIT INTEGER*2 ( a - z )

      CALL PrintOneBar( Row1 )
      CALL PrintOneBar( Row2 )
      CALL ElapsedTime( Row1 )
      RETURN
      END



CC  SwapSortArray - Swaps color and length for two bars by exchanging
CC  elements i and j in both rows of SortArray.  Row 1 of SortArray
CC  holds bar lengths and row 2 holds bar colors.
CC
CC  Params:  i, j - Element numbers for bars to be swapped

      SUBROUTINE SwapSortArray( i, j )
      IMPLICIT INTEGER*2 ( a - z )

      COMMON   SortArray(2,43), SortBackup(2,43),
     +         BarLength, BarColor, Select

      temp           = SortArray(1,i)
      SortArray(1,i) = SortArray(1,j)
      SortArray(1,j) = temp
      temp           = SortArray(2,i)
      SortArray(2,i) = SortArray(2,j)
      SortArray(2,j) = temp
      RETURN
      END



CC  cls - Clears screen using a normal display attribute of 7.
CC
CC  Params:  None

      SUBROUTINE cls
      IMPLICIT INTEGER*2 ( a - z )

      INTEGER*1 cell(2)  / ' ', 7 /

      dummy = VioScrollDn( 0, 0, -1, -1, -1, cell, 0 )
      RETURN
      END
