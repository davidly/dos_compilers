' *** SHELL_EX.BAS ***
'
DECLARE FUNCTION GetName$ (DirLine$)
LINE INPUT "Enter target drive and directory: ",PathSpec$
SHELL "DIR > DIRFILE"	 'Store directory listing in DIRFILE.
DO
   OPEN "DIRFILE" FOR INPUT AS #1
   INPUT "Enter date (MM-DD-YY): ",MDate$
   PRINT
   ' Read DIRFILE, test for input date.
   DO
      LINE INPUT #1, DirLine$
      ' Test directory line to see if date matches and the line
      ' is not one of the special directories ( . or .. ).
      IF INSTR(DirLine$,MDate$) > 0 AND LEFT$(DirLine$,1) <> "." THEN
	 FileSpec$ = GetName$(DirLine$)
	 ' Don't move temporary file.
	 IF FileSpec$ <> "DIRFILE" THEN
	    ' Build DOS command line to copy file.
	    DoLine$ = "COPY " + FileSpec$ + "  " + PathSpec$
	    PRINT DoLine$
	    ' Copy file.
	    SHELL DoLine$
	 END IF
      END IF
   LOOP UNTIL EOF(1)
CLOSE #1
   PRINT "New date?"
   R$ = INPUT$(1)
   CLS
LOOP UNTIL UCASE$(R$) <> "Y"
' KILL "DIRFILE".
END

FUNCTION GetName$ (DirLine$) STATIC
' This function gets the file name and extension from
' the directory-listing line.
   BaseName$ = RTRIM$(LEFT$(DirLine$,8))
   ' Check for extension.
   ExtName$  = RTRIM$(MID$(DirLine$,10,3))
   IF ExtName$ <> "" THEN
      BaseName$ = BaseName$ + "." + ExtName$
   END IF
   GetName$ = BaseName$
END FUNCTION
