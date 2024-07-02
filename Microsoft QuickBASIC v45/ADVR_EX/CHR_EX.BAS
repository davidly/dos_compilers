' *** CHR_EX.BAS ***
'
DEFINT A-Z
' Display two double-sided boxes.
CALL DBox(5,22,18,40)
CALL DBox(1,4,4,50)
END

' Subroutine to display boxes.
' Parameters:
'  Urow%, Ucol% : Row and column of upper-left corner.
'  Lrow%, Lcol% : Row and column of lower-right corner.
'  Constants for extended ASCII graphic characters.
CONST ULEFTC=201, URIGHTC=187, VERTICAL=186, HORIZONTAL=205
CONST LLEFTC=200, LRIGHTC=188

SUB DBox (Urow%, Ucol%, Lrow%, Lcol%) STATIC
   ' Draw top of box.
   LOCATE Urow%, Ucol% : PRINT CHR$(ULEFTC);
   LOCATE ,Ucol%+1 : PRINT STRING$(Lcol%-Ucol%,CHR$(HORIZONTAL));
   LOCATE ,Lcol% : PRINT CHR$(URIGHTC);
   ' Draw body of box.
   FOR I=Urow%+1 TO Lrow%-1
      LOCATE I,Ucol% : PRINT CHR$(VERTICAL);
      LOCATE  ,Lcol% : PRINT CHR$(VERTICAL);
   NEXT I
   ' Draw bottom of box.
   LOCATE Lrow%, Ucol% : PRINT CHR$(LLEFTC);
   LOCATE ,Ucol%+1 : PRINT STRING$(Lcol%-Ucol%,CHR$(HORIZONTAL));
   LOCATE ,Lcol% : PRINT CHR$(LRIGHTC);
END SUB
