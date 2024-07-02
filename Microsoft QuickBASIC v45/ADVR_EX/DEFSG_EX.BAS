' *** DEFSG_EX.BAS ***
'
DECLARE SUB CapsOn ()
DECLARE SUB CapsOff ()
DECLARE SUB PrntMsg (R%,C%,M$)

CLS
CapsOn
PrntMsg 24,1,"<Caps Lock On>"
LOCATE 12,10
LINE INPUT "Enter a string (all characters are caps): ",S$
CapsOff
PrntMsg 24,1,"              "
PrntMsg 25,1,"Press any key to continue..."
DO WHILE INKEY$="" : LOOP
CLS
END

SUB CapsOn STATIC
' Turn Caps Lock on
   ' Set segment to low memory
   DEF SEG = 0
   ' Set Caps Lock on (turn on bit 6 of &H0417)
   POKE &H0417,PEEK(&H0417) OR &H40
   ' Restore segment
   DEF SEG
END SUB

SUB CapsOff STATIC
' Turn Caps Lock off
   DEF SEG=0
   ' Set Caps Lock off (turn off bit 6 of &H0417)
   POKE &H0417,PEEK(&H0417) AND &HBF
   DEF SEG
END SUB

SUB PrntMsg (Row%, Col%, Message$) STATIC
' Print message at Row%, Col% without changing cursor
   ' Save cursor position
   CurRow%=CSRLIN : CurCol%=POS(0)
   LOCATE Row%,Col% : PRINT Message$;
   ' Restore cursor
   LOCATE CurRow%,CurCol%
END SUB
