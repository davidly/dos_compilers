"SHELL SORT" Y=NI
"Z1" Y = Y/2
IF Y = 0 THEN RETURN: REM SORT COMPLETE
Z99=NI-Y
FOR K9 = 1 TO Z99
I = K9
"X2" E2 = I+Y
REM: IN LINE BELOW CHANGE <= TO >= FOR DESCENDING ORDER
IF SA(I) <= SA(E2) THEN "X3" ELSE SWAP SA(I),SA(E2)
I=I-Y
IF I>0 THEN "X2"
"X3" NEXT K9
GOTO "Z1"
END
