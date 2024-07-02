'
' *** COM1_EX.BAS - COMMON statement programming example
'
DIM Values(1 TO 50)
COMMON Values(), NumValues

PRINT "Enter values one per line. Type 'END' to quit."
NumValues = 0
DO
   INPUT "-> ", N$
   IF I >= 50 OR UCASE$(N$) = "END" THEN EXIT DO
   NumValues = NumValues + 1
   Values(NumValues) = VAL(N$)
LOOP
PRINT "Leaving COM1_EX.BAS to chain to COM2_EX.BAS"
PRINT "Press any key to chain... "
DO WHILE INKEY$ = ""
LOOP

CHAIN "com2_ex"
