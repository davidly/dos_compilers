       PROGRAM XXC
C
       INTEGER A,B,F
C
       CALL EGASCR
C
10     WRITE(*,*) 'ROW,COL,RAD,THS,THE,COL'
       READ(*,*) A,B,C,D,E,F
C
       CALL EGAARC(A,B,C,D,E,F)
C
       GOTO 10
       END
