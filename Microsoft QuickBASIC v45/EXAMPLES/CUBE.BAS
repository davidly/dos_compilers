' The macro string to draw the cube and paint its sides:
Plot$ = "BR30 BU25 C1 R54 U45 L54 D45 BE20 P1,1 G20 C2 G20" + "R54 E20 L54 BD5 P2,2 U5 C4 G20 U45 E20 D45 BL5 P4,4"

APage% = 1      ' Initialize values for the active and visual
VPage% = 0      ' pages, as well as the angle of rotation.
Angle% = 0

DO

   ' Draw to the active page while showing
   ' the visual page:
   SCREEN 7, , APage%, VPage%
   CLS 1

   ' Rotate the cube "Angle%" degrees:
   DRAW "TA" + STR$(Angle%) + Plot$

   ' Angle% is some multiple of 15 degrees:
   Angle% = (Angle% + 15) MOD 360

   ' Switch the active and visual pages:
   SWAP APage%, VPage%

LOOP WHILE INKEY$ = ""     ' A key press ends the program.

END
