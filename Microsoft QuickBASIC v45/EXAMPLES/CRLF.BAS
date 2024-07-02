DEFINT A-Z              ' Default variable type is integer

' The Backup$ FUNCTION makes a backup file with
' the same base as FileName$, plus a .BAK extension:
DECLARE FUNCTION Backup$ (FileName$)

' Initialize symbolic constants and variables:
CONST FALSE = 0, TRUE = NOT FALSE

CarReturn$ = CHR$(13)
LineFeed$ = CHR$(10)

DO
   CLS

   ' Get the name of the file to change:
   INPUT "Which file do you want to convert"; OutFile$

   InFile$ = Backup$(OutFile$)  ' Get the backup file's name.

   ON ERROR GOTO ErrorHandler   ' Turn on error trapping.

   NAME OutFile$ AS InFile$     ' Copy the input file to the
                                ' backup file.

   ON ERROR GOTO 0              ' Turn off error trapping.

   ' Open the backup file for input and the old file
   ' for output:
   OPEN InFile$ FOR INPUT AS #1
   OPEN OutFile$ FOR OUTPUT AS #2

   ' The PrevCarReturn variable is a flag that is set to TRUE
   ' whenever the program reads a carriage-return character:
   PrevCarReturn = FALSE

   ' Read from the input file until reaching
   ' the end of the file:
   DO UNTIL EOF(1)

      ' Not the end of the file, so read a character:
      FileChar$ = INPUT$(1, #1)

      SELECT CASE FileChar$

         CASE CarReturn$        ' The character is a CR.

            ' If the previous character was also a
            ' CR, put a LF before the character:
            IF PrevCarReturn THEN
                FileChar$ = LineFeed$ + FileChar$
            END IF

            ' In any case, set the PrevCarReturn
            ' variable to TRUE:
            PrevCarReturn = TRUE

         CASE LineFeed$         ' The character is a LF.

            ' If the previous character was not a
            ' CR, put a CR before the character:
            IF NOT PrevCarReturn THEN
                FileChar$ = CarReturn$ + FileChar$
            END IF

            ' In any case, set the PrevCarReturn
            ' variable to FALSE:
            PrevCarReturn = FALSE

         CASE ELSE              ' Neither a CR nor a LF.

            ' If the previous character was a CR,
            ' set the PrevCarReturn variable to FALSE
            ' and put a LF before the current character:
            IF PrevCarReturn THEN
                PrevCarReturn = FALSE
                FileChar$ = LineFeed$ + FileChar$
            END IF

      END SELECT

      ' Write the character(s) to the new file:
      PRINT #2, FileChar$;
   LOOP

   ' Write a LF if the last character in the file was a CR:
   IF PrevCarReturn THEN PRINT #2, LineFeed$;

   CLOSE                        ' Close both files.
   PRINT "Another file (Y/N)?"  ' Prompt to continue.

   ' Change the input to uppercase (capital letter):
   More$ = UCASE$(INPUT$(1))

' Continue the program if the user entered a "y" or a "Y":
LOOP WHILE More$ = "Y"
END

ErrorHandler:           ' Error-handling routine
   CONST NOFILE = 53, FILEEXISTS = 58

   ' The ERR function returns the error code for last error:
   SELECT CASE ERR
      CASE NOFILE       ' Program couldn't find file with
                        ' input name.
         PRINT "No such file in current directory."
         INPUT "Enter new name: ", OutFile$
         InFile$ = Backup$(OutFile$)
         RESUME
      CASE FILEEXISTS   ' There is already a file named
                        ' <filename>.BAK in this directory:
                        ' remove it, then continue.
         KILL InFile$
         RESUME
      CASE ELSE         ' An unanticipated error occurred:
                        ' stop the program.
         ON ERROR GOTO 0
   END SELECT
'
' ========================= BACKUP$ ==========================
'   This procedure returns a file name that consists of the
'   base name of the input file (everything before the ".")
'   plus the extension ".BAK"
' ============================================================
'
FUNCTION Backup$ (FileName$) STATIC

   ' Look for a period:
   Extension = INSTR(FileName$, ".")

   ' If there is a period, add .BAK to the base:
   IF Extension > 0 THEN
      Backup$ = LEFT$(FileName$, Extension - 1) + ".BAK"

   ' Otherwise, add .BAK to the whole name:
   ELSE
      Backup$ = FileName$ + ".BAK"
   END IF
END FUNCTION
