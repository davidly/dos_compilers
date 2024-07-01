       PROGRAM DKF
C
       INTEGER X,Y,PIX
C
55     CALL SETCUR(4,0)
       WRITE(*,*) 'R,C'
       READ(*,*) R,PIX
       THETA = -0.5
C
       DO 200 I = 0,231
       THETA = THETA + 0.25
       X=R*COS(THETA)+320.0
       Y=.78*(R*SIN(THETA))+175.0
       CALL EGADOT(X,Y,PIX)
200    CONTINUE
       GOTO 55
C
       END
