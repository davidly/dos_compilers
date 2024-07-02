'
' *** CMD_EX.BAS -- COMMAND$ function programming example
'
' Default variable type is integer in this module.
DEFINT A-Z

' Declare the Comline subprogram, as well as the number and
' type of its parameters.
DECLARE SUB Comline(N, A$(),Max)

DIM A$(1 TO 15)
' Get what was typed on the command line.
CALL Comline(N,A$(),10)
' Print out each part of the command line.
PRINT "Number of arguments = ";N
PRINT "Arguments are: "
FOR I=1 TO N : PRINT A$(I) : NEXT I

' Subroutine to get command line and split into arguments.
' Parameters:  NumArgs : Number of command line args found.
'              Args$() : Array in which to return arguments.
'              MaxArgs : Maximum number of arguments array
'                        can return.

SUB Comline(NumArgs,Args$(1),MaxArgs) STATIC
CONST TRUE=-1, FALSE=0

   NumArgs=0 : In=FALSE
' Get the command line using the COMMAND$ function.
   Cl$=COMMAND$
   L=LEN(Cl$)
' Go through the command line a character at a time.
   FOR I=1 TO L
      C$=MID$(Cl$,I,1)
    'Test for character being a blank or a tab.
      IF (C$<>" " AND C$<>CHR$(9)) THEN
    ' Neither blank nor tab.
    ' Test to see if you're already
    ' inside an argument.
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
