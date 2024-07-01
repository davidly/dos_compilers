       PROGRAM DKF
C
       INTEGER X,Y,PIX
C
       Y = 50
C
       DO 200 PIX = 1,15
       Y=Y+10
       DO 100 X = 0,638
       CALL EGADOT(X,Y,PIX)
100    CONTINUE
200    CONTINUE
C
       DO 400 PIX = 1,15
       Y=Y+10
       DO 300 X = 0,348
       CALL EGADOT(Y,X,PIX)
300    CONTINUE
400    CONTINUE
       END
