'
' *** UCASE_EX.BAS -- UCASE$ function programming example
'
DEFINT A-Z

FUNCTION YesQues(Prompt$,Row,Col) STATIC
   OldRow=CSRLIN
   OldCol=POS(0)
   ' Print prompt at Row, Col.
   LOCATE Row,Col : PRINT Prompt$ "(Y/N):";
   DO
      ' Get the user to press a key.
      DO
	 Resp$=INKEY$
      LOOP WHILE Resp$=""
      Resp$=UCASE$(Resp$)
      ' Test to see if it's yes or no.
      IF Resp$="Y" OR Resp$="N" THEN
	 EXIT DO
      ELSE
	 BEEP
      END IF
   LOOP
   ' Print the response on the line.
   PRINT Resp$;
   ' Move the cursor back to the old position.
   LOCATE OldRow,OldCol
   ' Return a Boolean value by returning the result of a test.
   YesQues=(Resp$="Y")
END FUNCTION

DO
LOOP WHILE NOT YesQues("Do you know the frequency?",12,5)
