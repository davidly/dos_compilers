       PROGRAM EGATEST
C
       INTEGER X,Y,PIXVAL
C
100    WRITE(*,*) 'X,Y,PIXEL VALUE '
       READ(*,*) X,Y,PIXVAL
       CALL EGADOT(X,Y,PIXVAL)
       GOTO 100
C
       END
