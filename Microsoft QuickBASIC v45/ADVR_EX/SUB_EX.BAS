'
' *** SUB1_EX.BAS - SUB statement programming example
'
INPUT "File to be searched";F$
INPUT "Pattern to search for";P$
OPEN F$ FOR INPUT AS #1
DO WHILE NOT EOF(1)
   LINE INPUT #1, Test$
   CALL Linesearch(Test$,P$)
LOOP

SUB Linesearch(Test$,P$) STATIC
   Num = Num + 1
   X = INSTR(Test$,P$)
   IF X > 0 THEN PRINT "Line #";Num;": ";Test$
END SUB
