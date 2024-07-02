DECLARE SUB DrawPattern ()
DECLARE SUB EditPattern ()
DECLARE SUB Initialize ()
DECLARE SUB ShowPattern (OK$)

DIM Bit%(0 TO 7), Pattern$, Esc$, PatternSize%

DO
   Initialize
   EditPattern
   ShowPattern OK$
LOOP WHILE OK$ = "Y"

END
'
' ======================== DRAWPATTERN =======================
'    Draws a patterned rectangle on the right side of screen
' ============================================================
'
SUB DrawPattern STATIC
SHARED Pattern$

   VIEW (320, 24)-(622, 160), 0, 1  ' Set view to rectangle
   PAINT (1, 1), Pattern$           ' Use PAINT to fill it
   VIEW                             ' Set view to full screen

END SUB
'
' ======================== EDITPATTERN =======================
'                  Edits a tile-byte pattern
' ============================================================
'
SUB EditPattern STATIC
SHARED Pattern$, Esc$, Bit%(), PatternSize%

   ByteNum% = 1         ' Starting position.
   BitNum% = 7
   Null$ = CHR$(0)      ' CHR$(0) is the first byte of the
                        ' two-byte string returned when a
                        ' direction key such as UP or DOWN is
                        ' pressed.
   DO

      ' Calculate starting location on screen of this bit:
      X% = ((7 - BitNum%) * 16) + 80
      Y% = (ByteNum% + 2) * 8

      ' Wait for a key press (and flash cursor each 3/10 second):
      State% = 0
      RefTime = 0
      DO

         ' Check timer and switch cursor state if 3/10 second:
         IF ABS(TIMER - RefTime) > .3 THEN
            RefTime = TIMER
            State% = 1 - State%

            ' Turn the  border of bit on and off:
            LINE (X% - 1, Y% - 1)-STEP(15, 8), State%, B
         END IF

         Check$ = INKEY$        ' Check for key press.

      LOOP WHILE Check$ = ""    ' Loop until a key is pressed.

      ' Erase cursor:
      LINE (X% - 1, Y% - 1)-STEP(15, 8), 0, B

      SELECT CASE Check$        ' Respond to key press.

         CASE CHR$(27)          ' ESC key pressed:
            EXIT SUB            ' exit this subprogram

         CASE CHR$(32)          ' SPACEBAR pressed:
                                ' reset state of bit

            ' Invert bit in pattern string:
            CurrentByte% = ASC(MID$(Pattern$, ByteNum%, 1))
            CurrentByte% = CurrentByte% XOR Bit%(BitNum%)
            MID$ (Pattern$, ByteNum%) = CHR$(CurrentByte%)

            ' Redraw bit on screen:
            IF (CurrentByte% AND Bit%(BitNum%)) <> 0 THEN
                CurrentColor% = 1
            ELSE
                CurrentColor% = 0
            END IF
            LINE (X% + 1, Y% + 1)-STEP(11, 4), CurrentColor%, BF

         CASE CHR$(13)           ' ENTER key pressed:
            DrawPattern          ' draw pattern in box on right.

         CASE Null$ + CHR$(75)   ' LEFT key: move cursor left

            BitNum% = BitNum% + 1
            IF BitNum% > 7 THEN BitNum% = 0

         CASE Null$ + CHR$(77)   ' RIGHT key: move cursor right

            BitNum% = BitNum% - 1
            IF BitNum% < 0 THEN BitNum% = 7

         CASE Null$ + CHR$(72)   ' UP key: move cursor up

            ByteNum% = ByteNum% - 1
            IF ByteNum% < 1 THEN ByteNum% = PatternSize%

         CASE Null$ + CHR$(80)   ' DOWN key: move cursor down

            ByteNum% = ByteNum% + 1
            IF ByteNum% > PatternSize% THEN ByteNum% = 1

         CASE ELSE
            ' User pressed a key other than ESC, SPACEBAR,
            ' ENTER, UP, DOWN, LEFT, or RIGHT, so don't
            ' do anything.
      END SELECT
   LOOP
END SUB
'
' ======================== INITIALIZE ========================
'               Sets up starting pattern and screen
' ============================================================
'
SUB Initialize STATIC
SHARED Pattern$, Esc$, Bit%(), PatternSize%

   Esc$ = CHR$(27)              ' ESC character is ASCII 27.

   ' Set up an array holding bits in positions 0 to 7:
   FOR I% = 0 TO 7
      Bit%(I%) = 2 ^ I%
   NEXT I%

   CLS

   ' Input the pattern size (in number of bytes):
   LOCATE 5, 5
   PRINT "Enter pattern size (1-16 rows):";
   DO
      LOCATE 5, 38
      PRINT "    ";
      LOCATE 5, 38
      INPUT "", PatternSize%
   LOOP WHILE PatternSize% < 1 OR PatternSize% > 16

   ' Set initial pattern to all bits set:
   Pattern$ = STRING$(PatternSize%, 255)

   SCREEN 2                ' 640 x 200 monochrome graphics mode.

   ' Draw dividing lines:
   LINE (0, 10)-(635, 10), 1
   LINE (300, 0)-(300, 199)
   LINE (302, 0)-(302, 199)

   ' Print titles:
   LOCATE 1, 13: PRINT "Pattern Bytes"
   LOCATE 1, 53: PRINT "Pattern View"

   ' Draw editing screen for pattern:
   FOR I% = 1 TO PatternSize%

      ' Print label on left of each line:
      LOCATE I% + 3, 8
      PRINT USING "##:"; I%

      ' Draw "bit" boxes:
      X% = 80
      Y% = (I% + 2) * 8
      FOR J% = 1 TO 8
         LINE (X%, Y%)-STEP(13, 6), 1, BF
         X% = X% + 16
      NEXT J%
   NEXT I%

   DrawPattern                  ' Draw  "Pattern View" box.

   LOCATE 21, 1
   PRINT "DIRECTION keys........Move cursor"
   PRINT "SPACEBAR............Changes point"
   PRINT "ENTER............Displays pattern"
   PRINT "ESC.........................Quits";

END SUB
'
' ======================== SHOWPATTERN =======================
'     Prints the CHR$ values used by PAINT to make pattern
' ============================================================
'
SUB ShowPattern (OK$) STATIC
SHARED Pattern$, PatternSize%

   ' Return screen to 80-column text mode:
   SCREEN 0, 0
   WIDTH 80

   PRINT "The following characters make up your pattern:"
   PRINT

   ' Print out the value for each pattern byte:
   FOR I% = 1 TO PatternSize%
      PatternByte% = ASC(MID$(Pattern$, I%, 1))
      PRINT "CHR$("; LTRIM$(STR$(PatternByte%)); ")"
   NEXT I%

   PRINT
   LOCATE , , 1
   PRINT "New pattern? ";
   OK$ = UCASE$(INPUT$(1))
END SUB
