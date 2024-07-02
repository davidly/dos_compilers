DECLARE FUNCTION Filter$ (Txt$, FilterString$)

' Input a line:
LINE INPUT "Enter a number with commas: ", A$

' Look for only valid numeric characters (0123456789.-) in the
' input string:
CleanNum$ = Filter$(A$, "0123456789.-")

' Convert the string to a number:
PRINT "The number's value = "; VAL(CleanNum$)
END
'
' ========================== FILTER ==========================
'         Takes unwanted characters out of a string by
'        comparing them with a filter string containing
'             only acceptable numeric characters
' ============================================================
'
FUNCTION Filter$ (Txt$, FilterString$) STATIC
   Temp$ = ""
   TxtLength = LEN(Txt$)

   FOR I = 1 TO TxtLength     ' Isolate each character in
      C$ = MID$(Txt$, I, 1)   ' the string.

      ' If the character is in the filter string, save it:
      IF INSTR(FilterString$, C$) <> 0 THEN
         Temp$ = Temp$ + C$
      END IF
   NEXT I

   Filter$ = Temp$
END FUNCTION
