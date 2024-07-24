'PRNTEST.APP
' by Chan Shippy
'    Rt. 1 Box 87
'    Colome, SD  57528
' For IBM/MS-DOS ZBasic ONLY!
'
' Modified to include check for printer selected
' Greg Branche, 10/21/87
'
CLS : MODE 3
GOSUB "Test Prn"
IF V$ = CHR$(27) THEN END 'Abort printing
LPRINT "Yep, the printer's ready!"
END

LONG FN Testprn(PRNum)
  ' PRNum should usually be 0
  tst% = 0
  MACHLG &8B,&16,PRNum
  MACHLG &B4,&02,&CD,&17,&F6,&C4,&6F
  MACHLG &75,&04,&FF,&06,tst%
  ' 1 = Printer Ready, 0 = Not Ready
END FN = tst%

"Test Prn"
LONG IF FN Testprn(0)
  RETURN 'printer is ready!
XELSE
  SOUND 800,50 : SOUND 600,50 : SOUND 800,50
  LOCATE 0,24 : CLS LINE
  LOCATE 10,24 : COLOR 15,0
  PRINT "Printer NOT READY! ";
  PRINT "<R> Retry, <ESC> Abort Printing";
  COLOR 7,0
  "Try Again"
  DO
    V$ = INKEY$
  UNTIL LEN(V$)
  V$ = UCASE$(V$)
  LONG IF V$ = "R"
    GOTO "Test Prn"
  XELSE
    IF V$ = CHR$(27) THEN RETURN
  END IF
  SOUND 800,130 : GOTO "Try Again"
END IF
