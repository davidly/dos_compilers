       PROGRAM BOILPUS
C
       INTEGER A,B,C,D,E,F
C
       CALL EGASCR
C
10     WRITE(*,*) 'X,Y,X1,Y1,COLOR = '
       READ(*,*) A,B,C,D,E
C
       CALL EFBOX(A,B,C,D,E)
C
       CALL SETCUR(2,0)
       GOTO 10
C
       END
