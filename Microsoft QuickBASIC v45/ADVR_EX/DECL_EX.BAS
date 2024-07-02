'
' *** DECL_EX.BAS - DECLARE statement programming example
'
' Generate 20 random numbers, store them in an array, and
' sort. The sort subprogram is called without the CALL keyword.
DECLARE SUB Sort(A(1) AS SINGLE, N AS INTEGER)
DIM Array1(1 TO 20)

' Generate 20 random numbers.
RANDOMIZE TIMER
FOR I=1 TO 20
   Array1(I)=RND
NEXT I

' Sort the array and call Sort without the CALL keyword.
' Notice the absence of parentheses around the arguments in
' the call to Sort.
Sort Array1(), 20%

' Print the sorted array.
FOR I=1 TO 20
   PRINT Array1(I)
NEXT I
END

' Sort subroutine.
SUB Sort(A(1), N%) STATIC

   FOR I= 1 TO N%-1
      FOR J=I+1 TO N%
         IF A(I)>A(J) THEN SWAP A(I), A(J)
      NEXT J
   NEXT I

END SUB
