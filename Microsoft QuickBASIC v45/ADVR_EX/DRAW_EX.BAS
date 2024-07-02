' *** DRAW_EX.BAS ***
'
' Declare procedure.
DECLARE SUB Face (Min$)
'
' Select 640 x 200 pixel high-resolution graphics screen.
SCREEN 2
DO
   CLS
   ' Get string containing minutes value.
   Min$ = MID$(TIME$,4,2)
   ' Draw clock face.
   Face Min$
   ' Wait until minute changes or a key is pressed.
   DO
      ' Print time at top of screen.
      LOCATE 2,37
      PRINT TIME$
      ' Test for a key press.
      Test$ = INKEY$
   LOOP WHILE Min$ = MID$(TIME$,4,2) AND Test$ = ""
' End program when a key is pressed.
LOOP WHILE Test$ = ""
END
'
' Draw the clock face.
SUB Face (Min$) STATIC
   LOCATE 23,30
   PRINT "Press any key to end"
   CIRCLE (320,100),175
   ' Convert strings to numbers.
   Hr = VAL(TIME$)
   Min = VAL(Min$)
   ' Convert numbers to angles.
   Little = 360 - (30 * Hr + Min/2)
   Big = 360 - (6*Min)
   ' Draw the hands.
   DRAW "TA=" + VARPTR$(Little) + "NU40"
   DRAW "TA=" + VARPTR$(Big) + "NU70"
END SUB
