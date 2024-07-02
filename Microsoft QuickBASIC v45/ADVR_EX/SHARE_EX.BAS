'
' *** SHARE_EX.BAS - SHARED statement programming example
'
DEFINT A-Z
DO
   INPUT "Decimal number (input number <= 0 to quit): ",Decimal
   IF Decimal <= 0 THEN EXIT DO
   INPUT "New base: ",Newbase
   N$ = ""
   PRINT Decimal "base 10 equals ";
   DO WHILE Decimal > 0
      CALL Convert (Decimal,Newbase)
      Decimal = Decimal\Newbase
   LOOP
   PRINT N$ " base" Newbase
   PRINT
LOOP

SUB Convert (D,Nb) STATIC
SHARED N$
   ' Take the remainder to find the value of the current
   ' digit.
   R = D MOD Nb
   ' If the digit is less than ten, return a digit (0...9).
   ' Otherwise, return a letter (A...Z).
   IF R < 10 THEN Digit$ = CHR$(R+48) ELSE Digit$ = CHR$(R+55)
   N$ = RIGHT$(Digit$,1) + N$
END SUB
