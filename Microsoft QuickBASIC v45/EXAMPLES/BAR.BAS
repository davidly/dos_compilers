' Define type for the titles:
TYPE TitleType
   MainTitle AS STRING * 40
   XTitle AS STRING * 40
   YTitle AS STRING * 18
END TYPE

DECLARE SUB InputTitles (T AS TitleType)
DECLARE FUNCTION DrawGraph$ (T AS TitleType, Label$(), Value!(), N%)
DECLARE FUNCTION InputData% (Label$(), Value!())

' Variable declarations for titles and bar data:
DIM Titles AS TitleType, Label$(1 TO 5), Value(1 TO 5)

CONST FALSE = 0, TRUE = NOT FALSE

DO
   InputTitles Titles
   N% = InputData%(Label$(), Value())
   IF N% <> FALSE THEN
      NewGraph$ = DrawGraph$(Titles, Label$(), Value(), N%)
   END IF
LOOP WHILE NewGraph$ = "Y"

END
REM $STATIC
'
' ========================== DRAWGRAPH =========================
'   Draws a bar graph from the data entered in the INPUTTITLES
'   and INPUTDATA procedures.
' ==============================================================
'
FUNCTION DrawGraph$ (T AS TitleType, Label$(), Value(), N%) STATIC

   ' Set size of graph:
   CONST GRAPHTOP = 24, GRAPHBOTTOM = 171
   CONST GRAPHLEFT = 48, GRAPHRIGHT = 624
   CONST YLENGTH = GRAPHBOTTOM - GRAPHTOP

   ' Calculate max/min values:
   YMax = 0
   YMin = 0
   FOR I% = 1 TO N%
      IF Value(I%) < YMin THEN YMin = Value(I%)
      IF Value(I%) > YMax THEN YMax = Value(I%)
   NEXT I%

   ' Calculate width of bars and space between them:
   BarWidth = (GRAPHRIGHT - GRAPHLEFT) / N%
   BarSpace = .2 * BarWidth
   BarWidth = BarWidth - BarSpace

   SCREEN 2
   CLS

   ' Draw y axis:
   LINE (GRAPHLEFT, GRAPHTOP)-(GRAPHLEFT, GRAPHBOTTOM), 1

   ' Draw main graph title:
   Start% = 44 - (LEN(RTRIM$(T.MainTitle)) / 2)
   LOCATE 2, Start%
   PRINT RTRIM$(T.MainTitle);

   ' Annotate Y axis:
   Start% = CINT(13 - LEN(RTRIM$(T.YTitle)) / 2)
   FOR I% = 1 TO LEN(RTRIM$(T.YTitle))
      LOCATE Start% + I% - 1, 1
      PRINT MID$(T.YTitle, I%, 1);
   NEXT I%

   ' Calculate scale factor so labels aren't bigger than 4 digits:
   IF ABS(YMax) > ABS(YMin) THEN
      Power = YMax
   ELSE
      Power = YMin
   END IF
   Power = CINT(LOG(ABS(Power) / 100) / LOG(10))
   IF Power < 0 THEN Power = 0

   ' Scale min and max down:
   ScaleFactor = 10 ^ Power
   YMax = CINT(YMax / ScaleFactor)
   YMin = CINT(YMin / ScaleFactor)

   ' If power isn't zero then put scale factor on chart:
   IF Power <> 0 THEN
      LOCATE 3, 2
      PRINT "x 10^"; LTRIM$(STR$(Power))
   END IF

   ' Put tic mark and number for Max point on Y axis:
   LINE (GRAPHLEFT - 3, GRAPHTOP)-STEP(3, 0)
   LOCATE 4, 2
   PRINT USING "####"; YMax

   ' Put tic mark and number for Min point on Y axis:
   LINE (GRAPHLEFT - 3, GRAPHBOTTOM)-STEP(3, 0)
   LOCATE 22, 2
   PRINT USING "####"; YMin

   ' Scale min and max back up for charting calculations:
   YMax = YMax * ScaleFactor
   YMin = YMin * ScaleFactor

   ' Annotate X axis:
   Start% = 44 - (LEN(RTRIM$(T.XTitle)) / 2)
   LOCATE 25, Start%
   PRINT RTRIM$(T.XTitle);

   ' Calculate the pixel range for the Y axis:
   YRange = YMax - YMin

   ' Define a diagonally striped pattern:
   Tile$ = CHR$(1) + CHR$(2) + CHR$(4) + CHR$(8) + CHR$(16) + CHR$(32) + CHR$(64) + CHR$(128)

   ' Draw a zero line if appropriate:
   IF YMin < 0 THEN
      Bottom = GRAPHBOTTOM - ((-YMin) / YRange * YLENGTH)
      LOCATE INT((Bottom - 1) / 8) + 1, 5
      PRINT "0";
   ELSE
      Bottom = GRAPHBOTTOM
   END IF

   ' Draw x axis:
   LINE (GRAPHLEFT - 3, Bottom)-(GRAPHRIGHT, Bottom)

   ' Draw bars and labels:
   Start% = GRAPHLEFT + (BarSpace / 2)
   FOR I% = 1 TO N%

      ' Draw a bar label:
      BarMid = Start% + (BarWidth / 2)
      CharMid = INT((BarMid - 1) / 8) + 1
      LOCATE 23, CharMid - INT(LEN(RTRIM$(Label$(I%))) / 2)
      PRINT Label$(I%);

      ' Draw the bar and fill it with the striped pattern:
      BarHeight = (Value(I%) / YRange) * YLENGTH
      LINE (Start%, Bottom)-STEP(BarWidth, -BarHeight), , B
      PAINT (BarMid, Bottom - (BarHeight / 2)), Tile$, 1

      Start% = Start% + BarWidth + BarSpace
   NEXT I%

   LOCATE 1, 1, 1
   PRINT "New graph? ";
   DrawGraph$ = UCASE$(INPUT$(1))

END FUNCTION
'
' ========================= INPUTDATA ========================
'         Gets input for the bar labels and their values
' ============================================================
'
FUNCTION InputData% (Label$(), Value()) STATIC

   ' Initialize the number of data values:
   NumData% = 0

   ' Print data-entry instructions:
   CLS
   PRINT "Enter data for up to 5 bars:"
   PRINT "   * Enter the label and value for each bar."
   PRINT "   * Values can be negative."
   PRINT "   * Enter a blank label to stop."
   PRINT
   PRINT "After viewing the graph, press any key ";
   PRINT "to end the program."

   ' Accept data until blank label or 5 entries:
   Done% = FALSE
   DO
      NumData% = NumData% + 1
      PRINT
      PRINT "Bar("; LTRIM$(STR$(NumData%)); "):"
      INPUT ; "        Label? ", Label$(NumData%)

      ' Only input value if label isn't blank:
      IF Label$(NumData%) <> "" THEN
         LOCATE , 35
         INPUT "Value? ", Value(NumData%)

      ' If label was blank, decrement data counter and
      ' set Done flag equal to TRUE:
      ELSE
         NumData% = NumData% - 1
         Done% = TRUE
      END IF
   LOOP UNTIL (NumData% = 5) OR Done%

   ' Return the number of data values input:
   InputData% = NumData%

END FUNCTION
'
' ======================= INPUTTITLES ========================
'       Accepts input for the three different graph titles
' ============================================================
'
SUB InputTitles (T AS TitleType) STATIC

   ' Set text screen:
   SCREEN 0, 0

   ' Input Titles
   DO
      CLS
      INPUT "Enter main graph title: ", T.MainTitle
      INPUT "Enter X-Axis title    : ", T.XTitle
      INPUT "Enter Y-Axis title    : ", T.YTitle

      ' Check to see if titles are OK:
      LOCATE 7, 1
      PRINT "OK (Y to continue, N to change)? ";
      LOCATE , , 1
      OK$ = UCASE$(INPUT$(1))
   LOOP UNTIL OK$ = "Y"
END SUB
