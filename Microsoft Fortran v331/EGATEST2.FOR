       PROGRAM EGATEST2
C
       INTEGER X,Y,PIXVAL
C
100    WRITE(*,*) 'X,Y,PIXEL VALUE '
       READ(*,*) X,Y,PIXVAL
       WRITE(*,*) X,Y,PIXVAL
       PAUSE 11
       CALL EGA2(X,Y,PIXVAL)
       PAUSE 12
       GOTO 100
C
       END
