' Declare symbolic constants used in program:
CONST FALSE = 0, TRUE = NOT FALSE

DECLARE FUNCTION GetFileName$ ()

' Set up the ERROR trap, and specify the name of the
' error-handling routine:
ON ERROR GOTO ErrorProc

DO
   Restart = FALSE
   CLS

   FileName$ = GetFileName$     ' Input file name.

   IF FileName$ = "" THEN
      END                       ' End if <ENTER> pressed.
   ELSE

      ' Otherwise, open the file, assigning it the
      ' next available file number:
      FileNum = FREEFILE
      OPEN FileName$ FOR INPUT AS FileNum
   END IF

   IF NOT Restart THEN

      ' Input search string:
      LINE INPUT "Enter string to locate: ", LocString$
      LocString$ = UCASE$(LocString$)

      ' Loop through the lines in the file, printing them
      ' if they contain the search string:
      LineNum = 1
      DO WHILE NOT EOF(FileNum)

         ' Input line from file:
         LINE INPUT #FileNum, LineBuffer$

         ' Check for string, printing the line and its
         ' number if found:
         IF INSTR(UCASE$(LineBuffer$), LocString$) <> 0 THEN
            PRINT USING "#### &"; LineNum, LineBuffer$
         END IF

         LineNum = LineNum + 1
      LOOP

      CLOSE FileNum             ' Close the file.

   END IF
LOOP WHILE Restart = TRUE

END

ErrorProc:

   SELECT CASE ERR

      CASE 64:                  ' Bad File Name
         PRINT "** ERROR - Invalid file name"

         ' Get a new file name and try again:
         FileName$ = GetFileName$

         ' Resume at the statement that caused the error:
         RESUME

      CASE 71:                  ' Disk not ready
         PRINT "** ERROR - Disk drive not ready"
         PRINT "Press C to continue, R to restart, Q to quit: "
         DO
            Char$ = UCASE$(INPUT$(1))
            IF Char$ = "C" THEN
               RESUME           ' Resume where you left off

            ELSEIF Char$ = "R" THEN
               Restart = TRUE   ' Resume at beginning
               RESUME NEXT

            ELSEIF Char$ = "Q" THEN
               END              ' Don't resume at all
            END IF
         LOOP

      CASE 53, 76:              ' File or path not found
         PRINT "** ERROR - File or path not found"
         FileName$ = GetFileName$
         RESUME

      CASE ELSE:                ' Unforeseen error

         ' Disable error trapping and print standard
         ' system message:
         ON ERROR GOTO 0
   END SELECT
'
' ======================= GETFILENAME$ =======================
'              Returns a file name from user input
' ============================================================
'
FUNCTION GetFileName$ STATIC
   INPUT "Enter file to search (press ENTER to quit): ", FTemp$
   GetFileName$ = FTemp$
END FUNCTION
