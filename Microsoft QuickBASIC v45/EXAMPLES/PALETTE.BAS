DECLARE SUB InitPalette ()
DECLARE SUB ChangePalette ()
DECLARE SUB DrawEllipses ()
DEFINT A-Z

DIM SHARED PaletteArray(15)

SCREEN 8                 ' 640 x 200 resolution; 16 colors

InitPalette
DrawEllipses

DO
   ChangePalette
LOOP WHILE INKEY$ = ""   ' Shift palette until key pressed

END

'
' ======================= InitPalette ========================
'    This procedure initializes the integer array used to
'    change the palette.
' ============================================================
'
SUB InitPalette STATIC
   FOR I = 0 TO 15
      PaletteArray(I) = I
   NEXT I
END SUB

'
' ====================== DrawEllipses ========================
'    This procedure draws fifteen concentric ellipses, and
'    paints the interior of each with a different color.
' ============================================================
'
SUB DrawEllipses STATIC
   CONST ASPECT = 1 / 3
   FOR ColorVal = 15 TO 1 STEP -1
      Radius = 20 * ColorVal
      CIRCLE (320, 100), Radius, ColorVal, , , ASPECT
      PAINT (320, 100), ColorVal
   NEXT
END SUB

'
' ====================== ChangePalette =======================
'    This procedure rotates the palette by one each time it
'    is called.  For example, after the first call to
'    ChangePalette, PaletteArray(1) = 2, PaletteArray(2) = 3,
'    . . . , PaletteArray(14) = 15, and PaletteArray(15) = 1
' ============================================================
'
SUB ChangePalette STATIC
   FOR I = 1 TO 15
      PaletteArray(I) = (PaletteArray(I) MOD 15) + 1
   NEXT I

   ' Shift the color displayed by each of the attributes from
   ' one to fifteen:
   PALETTE USING PaletteArray(0)
END SUB
