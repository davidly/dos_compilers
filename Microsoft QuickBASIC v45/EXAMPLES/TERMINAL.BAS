DEFINT A-Z

DECLARE SUB Filter (InString$)

COLOR 7, 1                      ' Set screen color.
CLS

Quit$ = CHR$(0) + CHR$(16)      ' Value returned by INKEY$
                                ' when ALT+q is pressed.

' Set up prompt on bottom line of screen and turn cursor on:
LOCATE 24, 1, 1
PRINT STRING$(80, "_");
LOCATE 25, 1
PRINT TAB(30); "Press ALT+q to quit";

VIEW PRINT 1 TO 23              ' Print between lines 1 & 23.

' Open communications (1200 baud, no parity, 8-bit data,
' 1 stop bit, 256-byte input buffer):
OPEN "COM1:1200,N,8,1" FOR RANDOM AS #1 LEN = 256

DO                              ' Main communications loop.

   KeyInput$ = INKEY$           ' Check the keyboard.

   IF KeyInput$ = Quit$ THEN    ' Exit the loop if the user
      EXIT DO                   ' pressed ALT+q.

   ELSEIF KeyInput$ <> "" THEN  ' Otherwise, if the user has
      PRINT #1, KeyInput$;      ' pressed a key, send the
   END IF                       ' character typed to the modem.

   ' Check the modem. If characters are waiting (EOF(1) is
   ' true), get them and print them to the screen:
   IF NOT EOF(1) THEN

      ' LOC(1) gives the number of characters waiting:
      ModemInput$ = INPUT$(LOC(1), #1)

      Filter ModemInput$        ' Filter out line feeds and
      PRINT ModemInput$;        ' backspaces, then print.
   END IF
LOOP

CLOSE                           ' End communications.
CLS
END
'
' ========================= FILTER ==========================
'     Filters characters in an input string.
' ============================================================
'
SUB Filter (InString$) STATIC

   ' Look for backspace characters and recode them to
   ' CHR$(29) (the LEFT cursor key):
   DO
      BackSpace = INSTR(Instring$, CHR$(8))
      IF BackSpace THEN
         MID$(InString$, BackSpace) = CHR$(29)
      END IF
   LOOP WHILE BackSpace

   ' Look for line-feed characters and remove any found:
   DO
      LineFeed = INSTR(Instring$, CHR$(10))
      IF LineFeed THEN
         InString$ = LEFT$(InString$, LineFeed - 1) + _
                      MID$(InString$, LineFeed + 1)
      END IF
   LOOP WHILE LineFeed

END SUB
