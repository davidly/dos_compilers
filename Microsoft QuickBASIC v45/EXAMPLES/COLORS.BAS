SCREEN 1

Esc$ = CHR$(27)

' Draw three boxes and paint the interior of each
' box with a different color:
FOR ColorVal = 1 TO 3
   LINE (X, Y)-STEP(60, 50), ColorVal, BF
   X = X + 61
   Y = Y + 51
NEXT ColorVal

LOCATE 21, 1
PRINT "Press ESC to end."
PRINT "Press any other key to continue."

' Restrict additional printed output to the twenty-third line:
VIEW PRINT 23 TO 23

DO
   PaletteVal = 1
   DO

      ' PaletteVal is either one or zero:
      PaletteVal = 1 - PaletteVal

      ' Set the background color and choose the palette:
      COLOR BackGroundVal, PaletteVal
      PRINT "Background ="; BackGroundVal; "Palette ="; PaletteVal;

      Pause$ = INPUT$(1)        ' Wait for a keystroke.
      PRINT

   ' Exit the loop if both palettes have been shown,
   ' or if the user pressed the ESC key:
   LOOP UNTIL PaletteVal = 1 OR Pause$ = Esc$

   BackGroundVal = BackGroundVal + 1

' Exit this loop if all sixteen background colors have been
' shown, or if the user pressed the ESC key:
LOOP UNTIL BackGroundVal > 15 OR Pause$ = Esc$

SCREEN 0                        ' Restore text mode and
WIDTH 80                        ' eighty-column screen width.
