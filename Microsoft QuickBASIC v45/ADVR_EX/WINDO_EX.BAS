'
' *** WINDO_EX.BAS -- WINDOW statement programming example
'
PRINT "Press ENTER to start."
INPUT;"",A$
SCREEN 1 : COLOR 7              'Grey screen.
X = 500 : Xdelta = 50

DO
   DO WHILE X < 525 AND X > 50
      X = X + Xdelta            'Change window size.
      CALL Zoom(X)
      FOR I = 1 TO 1000         'Delay loop.
         IF INKEY$ <> "" THEN END   'Stop if key pressed.
      NEXT
   LOOP
   X = X - Xdelta
   Xdelta = -Xdelta             'Reverse size change.
LOOP

SUB Zoom(X) STATIC
   CLS
   WINDOW (-X,-X)-(X,X)         'Define new window.
   LINE (-X,-X)-(X,X),1,B       'Draw window border.
   CIRCLE (0,0),60,1,,,.5       'Draw ellipse with x-radius 60.
   PAINT (0,0),1                'Paint ellipse.
END SUB
