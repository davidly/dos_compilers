' Values for keys on the numeric keypad and the spacebar:
CONST UP = 72, DOWN = 80, LFT = 75, RGHT = 77
CONST UPLFT = 71, UPRGHT = 73, DOWNLFT = 79, DOWNRGHT = 81
CONST SPACEBAR = " "

' Null$ is the first character of the two-character INKEY$
' value returned for direction keys such as UP and DOWN:
Null$ = CHR$(0)

' Plot$ = "" means draw lines; Plot$ = "B" means move
' graphics cursor, but don't draw lines:
Plot$ = ""

PRINT "Use the cursor movement keys to draw lines."
PRINT "Press the spacebar to toggle line drawing on and off."
PRINT "Press <ENTER> to begin. Press q to end the program."
DO: LOOP WHILE INKEY$ = ""

SCREEN 1
CLS

DO
   SELECT CASE KeyVal$
      CASE Null$ + CHR$(UP)
         DRAW Plot$ + "C1 U2"
      CASE Null$ + CHR$(DOWN)
         DRAW Plot$ + "C1 D2"
      CASE Null$ + CHR$(LFT)
         DRAW Plot$ + "C2 L2"
      CASE Null$ + CHR$(RGHT)
         DRAW Plot$ + "C2 R2"
      CASE Null$ + CHR$(UPLFT)
         DRAW Plot$ + "C3 H2"
      CASE Null$ + CHR$(UPRGHT)
         DRAW Plot$ + "C3 E2"
      CASE Null$ + CHR$(DOWNLFT)
         DRAW Plot$ + "C3 G2"
      CASE Null$ + CHR$(DOWNRGHT)
         DRAW Plot$ + "C3 F2"
      CASE SPACEBAR
         IF Plot$ = "" THEN Plot$ = "B " ELSE Plot$ = ""
      CASE ELSE
         ' The user pressed some key other than one of the
         ' direction keys, the  spacebar, or "q", so
         ' don't do anything.
   END SELECT

   KeyVal$ = INKEY$

LOOP UNTIL KeyVal$ = "q"

SCREEN 0, 0
WIDTH 80
END
