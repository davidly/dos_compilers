SCREEN 2

' View port sized to proper scale for graph:
VIEW (20, 2)-(620, 172), , 1

CONST PI = 3.141592653589#

' Make window large enough to graph sine wave from
' 0 radians to 2ã radians:
WINDOW (0, -1.1)-(2 * PI, 1.1)

Style% = &HFF00                 ' Use to make dashed line.

VIEW PRINT 23 TO 24             ' Scroll printed output in
                                ' rows 23 and 24.
DO
   PRINT TAB(20);
   INPUT "Number of cycles (0 to end): ", Cycles
   CLS
   LINE (2 * PI, 0)-(0, 0), , , Style%  ' Draw the x (horizontal) axis.
   IF Cycles > 0 THEN
      ' Start at (0,0) and plot the graph:
      FOR X = 0 TO 2 * PI STEP .01
         Y = SIN(Cycles * X)    ' Calculate the y coordinate.
         LINE -(X, Y)           ' Draw a line from the last
                                ' point to the new point.
      NEXT X
   END IF
LOOP WHILE Cycles > 0

