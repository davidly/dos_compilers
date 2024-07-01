       PROGRAM DKJFS
C
       INTEGER AX,AY,AX1,AY1,COLO
C
       CALL EGASCR
C
10     WRITE(*,*) 'AX,AY,AX1,AY1,COLO'
       READ(*,*) AX,AY,AX1,AY1,COLO
C
       CALL EBOX(AX,AY,AX1,AY1,COLO)
C
       GOTO 10
       END
