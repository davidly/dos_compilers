DIM Amount(1 TO 100)
CONST FALSE = 0, TRUE = NOT FALSE

' Get account's starting balance:
CLS
INPUT "Type starting balance, then press <ENTER>: ", Balance

' Get transactions. Continue accepting input until the
' input is zero for a transaction, or until 100
' transactions have been entered:
FOR TransacNum% = 1 TO 100
   PRINT TransacNum%;
   PRINT ") Enter transaction amount (0 to end): ";
   INPUT "", Amount(TransacNum%)
   IF Amount(TransacNum%) = 0 THEN
      TransacNum% = TransacNum% - 1
      EXIT FOR
   END IF
NEXT

' Sort transactions in ascending order,
' using a "bubble sort":
Limit% = TransacNum%
DO
   Swaps% = FALSE
   FOR I% = 1 TO (Limit% - 1)

      ' If two adjacent elements are out of order, switch
      ' those elements:
      IF Amount(I%) < Amount(I% + 1) THEN
         SWAP Amount(I%), Amount(I% + 1)
         Swaps% = I%
      END IF
   NEXT I%

   ' Sort on next pass only to where the last switch was made:
   IF Swaps% THEN Limit% = Swaps%

' Sort until no elements are exchanged:
LOOP WHILE Swaps%

' Print the sorted transaction array. If a transaction
' is greater than zero, print it as a "CREDIT"; if a
' transaction is less than zero, print it as a "DEBIT":
FOR I% = 1 TO TransacNum%
   IF Amount(I%) > 0 THEN
      PRINT USING "CREDIT: $$#####.##"; Amount(I%)
   ELSEIF Amount(I%) < 0 THEN
      PRINT USING "DEBIT:  $$#####.##"; Amount(I%)
   END IF

   ' Update balance:
   Balance = Balance + Amount(I%)
NEXT I%

' Print the final balance:
PRINT
PRINT "--------------------------"
PRINT USING "Final Total: $$######.##"; Balance
END
