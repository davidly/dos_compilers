'
' *** COM2_EX.BAS - COMMON statement programming example
'
DIM X(1 TO 50)
COMMON X(), N

PRINT
PRINT "Now executing file com2_ex.bas, reached through a CHAIN command"
IF N > 0 THEN
   Sum = 0
   FOR I = 1 TO N
      Sum = Sum + X(I)
   NEXT I
   PRINT "The average of the values is"; Sum / N
END IF
