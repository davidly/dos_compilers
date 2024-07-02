' *** CALL_EX.BAS
'
DEFINT A-Z
CONST MAXFILES = 5, ARRAYDIM = MAXFILES + 1
DIM File$(1 TO ARRAYDIM)
' Separate command line into arguments.
CALL Comline (Numargs,File$(),ARRAYDIM)
IF Numargs < 3 OR Numargs >MAXFILES THEN
  ' Too many or too few files.
   PRINT "Use more than 3 and fewer than";MAXFILES;"files"
ELSE
  ' Printout list of files.
   CALL Printout(File$(),Numargs)
END IF
END

SUB Comline(NumArgs,Args$(1),MaxArgs) STATIC
' Subroutine to get command line and split into arguments.
' Parameters:  NumArgs : Number of args found.
'              Args$() : Array in which to return arguments.
'              MaxArgs : Maximum number of arguments
CONST TRUE = -1, FALSE = 0
NumArgs=0 : In=FALSE
' Get the command line using the COMMAND$ function.
   Cl$ = COMMAND$
   L = LEN(Cl$)
' Go through the command line a character at a time.
   FOR I = 1 TO L
      C$ = MID$(Cl$,I,1)
      'Test for a blank or tab.
      IF (C$ <> " " AND C$ <> CHR$(9)) THEN
         ' Neither blank nor tab.
         ' Test already inside an argument.
         IF NOT In THEN
         ' You've found the start of a new argument.
         ' Test for too many arguments.
            IF NumArgs=MaxArgs THEN EXIT FOR
            NumArgs=NumArgs+1
            In=TRUE
         END IF
         ' Add the character to the current argument.
         Args$(NumArgs)=Args$(NumArgs)+C$
      ELSE
         ' Found a blank or a tab.
         ' Set "Not in an argument" flag to FALSE.
         In=FALSE
      END IF
   NEXT I
END SUB

SUB Printout(F$(1),N) STATIC
   ' Open target file.
   OPEN F$(N) FOR OUTPUT AS #3
   ' Loop executes once for each file.
   ' Copy the first N-1 files onto the Nth file.
   FOR File = 1 TO N - 1
      OPEN F$(File) FOR INPUT AS #1
      DO WHILE NOT EOF(1)
         'Read file.
	 LINE INPUT #1, Temp$
         'Write data to target file.
	 PRINT #3, Temp$
	 PRINT Temp$
      LOOP
      CLOSE #1
    NEXT
    CLOSE
END SUB
