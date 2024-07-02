' *** FUNC_EX.BAS ***

LINE INPUT "Enter a string: ",InString$
PRINT "The string length is"; StrLen(InString$)

FUNCTION StrLen(X$)
   IF X$ = "" THEN
      ' The length of a null string is zero.
      StrLen=0
   ELSE
      ' Non-null string--make a recursive call.
      ' The length of a non-null string is 1
      ' plus the length of the rest of the string.
      StrLen=1+StrLen(MID$(X$,2))
   END IF
END FUNCTION
