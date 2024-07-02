DEFINT A-Z         ' Default variable type is integer

DECLARE SUB ShiftPalette ()
DECLARE SUB WindowVals (WL%, WR%, WT%, WB%)
DECLARE SUB ScreenTest (EM%, CR%, VL%, VR%, VT%, VB%)

CONST FALSE = 0, TRUE = NOT FALSE       ' Boolean constants

' Set maximum number of iterations per point:
CONST MAXLOOP = 30, MAXSIZE = 1000000

DIM PaletteArray(15)
FOR I = 0 TO 15 : PaletteArray(I) = I : NEXT I

' Call WindowVals to get coordinates of window corners:
WindowVals WLeft, WRight, WTop, WBottom

' Call ScreenTest to find out if this is an EGA machine,
' and get coordinates of viewport corners:
ScreenTest EgaMode, ColorRange, VLeft, VRight, VTop, VBottom

' Define viewport and corresponding window:
VIEW (VLeft, VTop)-(VRight, VBottom), 0, ColorRange
WINDOW (WLeft, WTop)-(WRight, WBottom)

LOCATE 24, 10 : PRINT "Press any key to quit.";

XLength = VRight - VLeft
YLength = VBottom - VTop
ColorWidth = MAXLOOP \ ColorRange

' Loop through each pixel in viewport and calculate
' whether or not it is in the Mandelbrot Set:
FOR Y = 0 TO YLength       ' Loop through every line in
                           ' the viewport.
   LogicY = PMAP(Y, 3)     ' Get the pixel's logical y
                           ' coordinate.
   PSET (WLeft, LogicY)    ' Plot leftmost pixel in the line.
   OldColor = 0            ' Start with background color.

   FOR X = 0 TO XLength    ' Loop through every pixel in
                           ' the line.
      LogicX = PMAP(X, 2)  ' Get the pixel's logical x
                           ' coordinate .
      MandelX& = LogicX
      MandelY& = LogicY

      ' Do the calculations to see if this point is in
      ' the Mandelbrot Set:
      FOR I = 1 TO MAXLOOP
         RealNum& = MandelX& * MandelX&
         ImagNum& = MandelY& * MandelY&
         IF (RealNum& + ImagNum&) >= MAXSIZE THEN EXIT  FOR
         MandelY& = (MandelX& * MandelY&) \ 250 + LogicY
         MandelX& = (RealNum& - ImagNum&) \ 500 + LogicX
      NEXT I

      ' Assign a color to the point:
      PColor = I \ ColorWidth

      ' If color has changed, draw a line from the
      ' last point referenced to the new point,
      ' using the old color:
      IF PColor <> OldColor THEN
         LINE -(LogicX, LogicY), (ColorRange - OldColor)
         OldColor = PColor
      END IF

      IF INKEY$ <> "" THEN END
   NEXT X

   ' Draw the last line segment to the right edge of
   ' the viewport:
   LINE -(LogicX, LogicY), (ColorRange - OldColor)

   ' If this is an EGA machine, shift the palette after
   ' drawing each line:
   IF EgaMode THEN ShiftPalette
NEXT Y

DO
   ' Continue shifting the palette until the user
   ' presses a key:
   IF EgaMode THEN ShiftPalette
LOOP WHILE INKEY$ = ""

SCREEN 0, 0             ' Restore the screen to text mode,
WIDTH 80                ' 80 columns.
END

BadScreen:              ' Error handler that is invoked if
   EgaMode = FALSE      ' there is no EGA graphics card
   RESUME NEXT
'
' ======================= ShiftPalette =======================
' Rotates the palette by one each time it is called.
' ============================================================
'
SUB ShiftPalette STATIC
   SHARED PaletteArray(), ColorRange

   FOR I = 1 TO ColorRange
      PaletteArray(I) = (PaletteArray(I) MOD ColorRange) + 1
   NEXT I
   PALETTE USING PaletteArray(0)

END SUB
'
' ======================== ScreenTest ========================
'    Tests to see if user has EGA hardware with SCREEN 8.
'    If this causes an error, the EM flag is set to FALSE,
'    and the screen is set with SCREEN 1.
'
'    Also sets values for corners of viewport (VL = left,
'    VR = right, VT = top, VB = bottom), scaled with the
'    correct aspect ratio so viewport is a perfect square.
' ============================================================
'
SUB ScreenTest (EM, CR, VL, VR, VT, VB) STATIC
   EM = TRUE
   ON ERROR GOTO BadScreen
   SCREEN 8, 1
   ON ERROR GOTO 0

   IF EM THEN           ' No error, so SCREEN 8 is OK
      VL = 110  : VR = 529
      VT = 5    : VB = 179
      CR = 15           ' 16 colors (0 - 15)

   ELSE                 ' Error, so use SCREEN 1
      SCREEN 1, 1
      VL = 55   : VR = 264
      VT = 5    : VB = 179
      CR = 3            ' 4 colors (0 - 3)
   END IF

END SUB
'
' ======================== WindowVals ========================
'     Gets window corners as input from the user, or sets
'     values for the corners if there is no input.
' ============================================================
'
SUB WindowVals (WL, WR, WT, WB) STATIC
   CLS
   PRINT "This program prints the graphic representation of"
   PRINT "the complete Mandelbrot Set. The default window is"
   PRINT "from (-1000,625) to (250,-625). To zoom in on part"
   PRINT "of the figure, input coordinates inside this window."
   PRINT
   PRINT "Press <ENTER> to see the default window. Press any"
   PRINT "other key to input your own window coordinates: ";
   LOCATE , , 1
   Resp$ = INPUT$(1)

   ' User didn't press ENTER, so input window corners:
   IF Resp$ <> CHR$(13) THEN
      PRINT
      INPUT "X coordinate of upper left corner: ", WL
      DO
         INPUT "X coordinate of lower right corner: ", WR
         IF WR <= WL THEN
         PRINT "Right corner must be greater than left corner."
         END IF
      LOOP WHILE WR <= WL
      INPUT "Y coordinate of upper left corner: ", WT
      DO
         INPUT "Y coordinate of lower right corner: ", WB
         IF WB >= WT THEN
         PRINT "Bottom corner must be less than top corner."
         END IF
      LOOP WHILE WB >= WT

   ELSE         ' Pressed ENTER, so set default values.
      WL = -1000
      WR = 250
      WT = 625
      WB = -625
   END IF
END SUB
