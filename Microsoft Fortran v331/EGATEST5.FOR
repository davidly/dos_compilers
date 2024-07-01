       PROGRAM DDSK
C
       INTEGER X1,Y1,X2,Y2,COLOR
C
10     WRITE(*,*) 'X1,Y1,X2,Y2,COLOR = '
       READ(*,*) X1,Y1,X2,Y2,COLOR
C
       CALL ELSUB(X1,Y1,X2,Y2,COLOR)
C
       CALL SETCUR(4,0)
       GOTO 10
       END
