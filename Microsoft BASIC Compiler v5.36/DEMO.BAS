10 ' $TITLE : 'MS-BASIC' $SUBTITLE : 'Program'
20 DEFINT A-Z
30 DIM A(10,10),B(10,10),C(10,10)
40 PRINT "Start of program"
50 ' $OCODE +
60 FOR I=1 TO 10
70   FOR J=1 TO 10
80     A(I,J) = A(I-1,J-1)+B(I,J)*C(I,J)
90   NEXT
100 NEXT
110 ' $OCODE -
120 PRINT "End of Program"
130 END

