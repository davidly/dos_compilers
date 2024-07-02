DECLARE FUNCTION GetArraySize (WLeft, WRight, WTop, WBottom)

SCREEN 2
CLS
VIEW (20, 10)-(620, 190), , 1

CONST PI = 3.141592653589#

WINDOW (-3.15, -.14)-(3.56, 1.01)

' $DYNAMIC
' The rectangle is smaller than the one in the previous
' program, which means Array is also smaller:
WLeft = -.18
WRight = .18
WTop = .05
WBottom = -.05

ArraySize% = GetArraySize(WLeft, WRight, WTop, WBottom)

DIM Array(1 TO ArraySize%) AS INTEGER

CIRCLE (0, 0), .18
PAINT (0, 0)

GET (WLeft, WTop)-(WRight, WBottom), Array
CLS

LINE (-3, .8)-(3.4, .2), , B
Pattern$ = CHR$(126) + CHR$(0) + CHR$(126) + CHR$(126)
PAINT (0, .5), Pattern$

LOCATE 21, 29
PRINT "Press any key to end"

StepSize = .02
StartLoop = -PI
Decay = 1

DO
   EndLoop = -StartLoop
   FOR X = StartLoop TO EndLoop STEP StepSize
      Y = ABS(COS(X)) * Decay - .14

      ' The first PUT statement places the image on
      ' the screen:
      PUT (X, Y), Array, XOR

      ' An empty FOR...NEXT loop to delay the program and
      ' reduce image flicker:
      FOR I = 1 TO 5: NEXT I

      IF Y < -.13 THEN Decay = Decay * .9
      Esc$ = INKEY$
      IF Esc$ <> "" OR Decay < .01 THEN EXIT FOR

      ' The second PUT statement erases the image and
      ' restores the background:
      PUT (X, Y), Array, XOR
   NEXT X

   StepSize = -StepSize
   StartLoop = -StartLoop
LOOP UNTIL Esc$ <> "" OR Decay < .01

Pause$ = INPUT$(1)
END
REM $STATIC
REM $DYNAMIC
FUNCTION GetArraySize (WLeft, WRight, WTop, WBottom) STATIC
   VLeft = PMAP(WLeft, 0)
   VRight = PMAP(WRight, 0)
   VTop = PMAP(WTop, 1)
   VBottom = PMAP(WBottom, 1)

   RectHeight = ABS(VBottom - VTop) + 1
   RectWidth = ABS(VRight - VLeft) + 1

   ByteSize = 4 + RectHeight * INT((RectWidth + 7) / 8)
   GetArraySize = ByteSize \ 2 + 1
END FUNCTION
