'
' *** DEFFN_EX.BAS - DEF FN function programming example
'
DEF FNFactorial#(X)
   STATIC Tmp#, I
   Tmp#=1
   FOR I=2 TO X
      Tmp#=Tmp#*I
   NEXT I
   FNFactorial#=Tmp#
END DEF

INPUT "Enter a number: ",Num
PRINT Num "factorial is" FNFactorial#(Num)
