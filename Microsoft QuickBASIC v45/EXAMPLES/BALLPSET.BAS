DECLARE FUNCTION GetArraySize (WLeft, WRight, WTop, WBottom)

SCREEN 2
CLS

' Define a viewport and draw a border around it:
VIEW (20, 10)-(620, 190), , 1

CONST PI = 3.141592653589#

' Redefine the coordinates of the viewport with logical
' coordinates:
WINDOW (-3.15, -.14)-(3.56, 1.01)

' Arrays in program are now dynamic:
' $DYNAMIC

' Calculate the logical coordinates for the top and bottom of a
' rectangle large enough to hold the image that will be drawn
' with CIRCLE and PAINT:
WLeft = -.21
WRight = .21
WTop = .07
WBottom = -.07

' Call the GetArraySize function, passing it the rectangle's
' logical coordinates:
ArraySize% = GetArraySize(WLeft, WRight, WTop, WBottom)

DIM Array(1 TO ArraySize%) AS INTEGER

' Draw and paint the circle:
CIRCLE (0, 0), .18
PAINT (0, 0)

' Store the rectangle in Array:
GET (WLeft, WTop)-(WRight, WBottom), Array
CLS

' Draw a box and fill it with a pattern:
LINE (-3, .8)-(3.4, .2), , B
Pattern$ = CHR$(126) + CHR$(0) + CHR$(126) + CHR$(126)
PAINT (0, .5), Pattern$

LOCATE 21, 29
PRINT "Press any key to end"

' Initialize loop variables:
StepSize = .02
StartLoop = -PI
Decay = 1

DO
   EndLoop = -StartLoop
   FOR X = StartLoop TO EndLoop STEP StepSize

      ' Each time the ball "bounces" (hits the bottom of the
      ' viewport), the Decay variable gets smaller, making the
      ' height of the next bounce smaller:
      Y = ABS(COS(X)) * Decay - .14
      IF Y < -.13 THEN Decay = Decay * .9

      ' Stop if a key pressed or if Decay is less than .01:
      Esc$ = INKEY$
      IF Esc$ <> "" OR Decay < .01 THEN EXIT FOR

      ' Put the image on the screen.  The StepSize offset is
      ' smaller than the border around the circle, so each time
      ' the image moves, it erases any traces left from the
      ' previous PUT (it also erases anything else on the
      ' screen):
      PUT (X, Y), Array, PSET
   NEXT X

   ' Reverse direction:
   StepSize = -StepSize
   StartLoop = -StartLoop
LOOP UNTIL Esc$ <> "" OR Decay < .01

Pause$ = INPUT$(1)
END
REM $STATIC
REM $DYNAMIC
FUNCTION GetArraySize (WLeft, WRight, WTop, WBottom) STATIC

   ' Map the logical coordinates passed to this function to
   ' their physical-coordinate equivalents:
   VLeft = PMAP(WLeft, 0)
   VRight = PMAP(WRight, 0)
   VTop = PMAP(WTop, 1)
   VBottom = PMAP(WBottom, 1)

   ' Calculate the height and width in pixels of the
   ' enclosing rectangle:
   RectHeight = ABS(VBottom - VTop) + 1
   RectWidth = ABS(VRight - VLeft) + 1

   ' Calculate size in bytes of array:
   ByteSize = 4 + RectHeight * INT((RectWidth + 7) / 8)

   ' Array is integer, so divide bytes by two:
   GetArraySize = ByteSize \ 2 + 1
END FUNCTION
