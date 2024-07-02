' ENTAB.BAS
'
' Replace runs of spaces in a file with tabs.
'
DECLARE SUB SetTabPos ()
DECLARE SUB StripCommand (CLine$)


DEFINT A-Z
DECLARE FUNCTION ThisIsATab (Column AS INTEGER)

CONST MAXLINE = 255
CONST TABSPACE = 8
CONST NO = 0, YES = NOT NO

DIM SHARED TabStops(MAXLINE) AS INTEGER

StripCommand (COMMAND$)

' Set the tab positions (uses the global array TabStops).
SetTabPos

LastColumn = 1

DO

   CurrentColumn = LastColumn

' Replace a run of blanks with a tab when you reach a tab
' column. CurrentColumn is the current column read.
' LastColumn is the last column that was printed.
   DO
      C$ = INPUT$(1,#1)
      IF C$ <> " " AND C$ <> CHR$(9) THEN EXIT DO
      CurrentColumn = CurrentColumn + 1
      IF C$=CHR$(9) OR ThisIsATab(CurrentColumn) THEN
         ' Go to a tab column if we have a tab and this
         ' is not a tab column.
         DO WHILE NOT ThisIsATab(CurrentColumn)
            CurrentColumn=CurrentColumn+1
         LOOP
         PRINT #2, CHR$(9);
         LastColumn = CurrentColumn
      END IF
   LOOP

' Print out any blanks left over.
   DO WHILE LastColumn < CurrentColumn
      PRINT #2, " ";
      LastColumn = LastColumn + 1
   LOOP

' Print the non-blank character.
   PRINT #2, C$;

' Reset the column position if this is the end of a line.
   IF C$ = CHR$(10) THEN
      LastColumn = 1
   ELSE
      LastColumn = LastColumn + 1
   END IF

LOOP UNTIL EOF(1)
CLOSE #1, #2
END

'------------------SUB SetTabPos-------------------------
' Set the tab positions in the array TabStops.
'
SUB SetTabPos STATIC
   FOR I = 1 TO 255
      TabStops(I) = ((I MOD TABSPACE) = 1)
   NEXT I
END SUB
'
'------------------SUB StripCommand----------------------
'
SUB StripCommand (CommandLine$) STATIC
   IF CommandLine$ = "" THEN
      INPUT "File to entab:   ", InFileName$
      INPUT "Store entabbed file in:   ", OutFileName$
   ELSE
      SpacePos = INSTR(CommandLine$, " ")
      IF SpacePos > 0 THEN
         InFileName$ = LEFT$(CommandLine$, SpacePos - 1)
         OutFileName$ = LTRIM$(MID$(CommandLine$, SpacePos))
      ELSE
         InFileName$ = CommandLine$
         INPUT "Store entabbed file in:   ", OutFileName$
      END IF
   END IF
   OPEN InFileName$ FOR INPUT AS #1
   OPEN OutFileName$ FOR OUTPUT AS #2
END SUB
'---------------FUNCTION ThisIsATab----------------------
' Answer the question, "Is this a tab position?"
'
FUNCTION ThisIsATab (LastColumn AS INTEGER) STATIC
   IF LastColumn > MAXLINE THEN
      ThisIsATab = YES
   ELSE
      ThisIsATab = TabStops(LastColumn)
   END IF
END FUNCTION
