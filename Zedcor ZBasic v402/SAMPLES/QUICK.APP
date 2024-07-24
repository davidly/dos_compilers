"QUICK SORT"
L(1)=1:R(1)=NI:P2=1
DO
  LONG IF L(P2)<R(P2)
    Z=L(P2):J=R(P2)
    SA=SA(J):M4=(Z+J)>>1
    LONG IF J-Z>=6
      SZ=SA(Z):SM=SA(M4)
      LONG IF SA<= SZ OR SA>=SM OR SA>=SZ OR SA<= SM
        LONG IF SZ>=SM OR SZ<= SA OR SZ<=SM OR SZ>=SA
          SWAP SA(M4),SA(J)
        XELSE
          SWAP SA(Z),SA(J)
        END IF
        SA = SA(J)
      END IF
    END IF
    WHILE Z<J
      WHILE SA(Z) < SA
        Z=Z+1
      WEND
      DO
        J=J-1
      UNTIL Z>= J OR SA>= SA(J)
      LONG IF Z<J
        SWAP SA(Z),SA(J)
      END IF
    WEND
    J=R(P2):SWAP SA(Z),SA(J)
    LONG IF Z-L(P2)<R(P2)-Z
      L(P2+1)=L(P2): R(P2+ÿ1ÿ)=Z-1:L(P2)=Z+1
    XELSE
      L(P2+1)=Z+1:R(P2+1)=R(P2):R(P2)=Z-1
    END IF
    P2=P2+1
  XELSE
    P2=P2-1
  END IF
UNTIL P2<=0
RETURN : REM SORT FINISHED HERE
END
