' TOKEN.BAS
'
' Demonstrates a BASIC version of the strtok C function.
'
DECLARE FUNCTION StrTok$(Source$,Delimiters$)

LINE INPUT "Enter string: ",P$
' Set up the characters that separate tokens.
Delimiters$=" ,;:().?"+CHR$(9)+CHR$(34)
' Invoke StrTok$ with the string to tokenize.
Token$=StrTok$(P$,Delimiters$)
WHILE Token$<>""
   PRINT Token$
   ' Call StrTok$ with a null string so it knows this
   ' isn't the first call.
   Token$=StrTok$("",Delimiters$)
WEND

FUNCTION StrTok$(Srce$,Delim$)
STATIC Start%, SaveStr$

   ' If first call, make a copy of the string.
   IF Srce$<>"" THEN
      Start%=1 : SaveStr$=Srce$
   END IF

   BegPos%=Start% : Ln%=LEN(SaveStr$)
   ' Look for start of a token (character that isn't delimiter).
   WHILE BegPos%<=Ln% AND INSTR(Delim$,MID$(SaveStr$,BegPos%,1))<>0
      BegPos%=BegPos%+1
   WEND
   ' Test for token start found.
   IF BegPos% > Ln% THEN
      StrTok$="" : EXIT FUNCTION
   END IF
   ' Find the end of the token.
   EndPos%=BegPos%
   WHILE EndPos% <= Ln% AND INSTR(Delim$,MID$(SaveStr$,EndPos%,1))=0
      EndPos%=EndPos%+1
   WEND
   StrTok$=MID$(SaveStr$,BegPos%,EndPos%-BegPos%)
   ' Set starting point for search for next token.
   Start%=EndPos%

END FUNCTION
