	PC-LISP V3.00 (C) February 1st 1990 Peter Ashwood-Smith
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	This is a PC-LISP source or executable distribution disk. To
unpack the disk use the 'arc' utility provided on the disk. You can
get arc instructions by typing 'arc'. To get a list of files in the
archive 'src.arc' or 'exe.arc' type 'arc l src.arc' or 'arc l exe.arc'
To extract all the files in the archive onto your hard disk. Copy 
the disk contents to a directory on your hard disk then type.

       "arc x exe.arc *.*"  or  "arc x src.arc *.*"

	After which you can erase the exe.arc or src.arc file as well as
the arc.exe program. You now have a directory that contains either the 
entire pc-lisp executable distribution or the pc-lisp source distribution.

	You will probably then want to copy the files *.L to a direcory
of lisp programs, say \liblisp. Then add to your autoexec.bat file the 
statement: "set LISP_LIB=\liblisp"

	Have fun and regards,

	    Peter Ashwood-Smith

    N.B.

       There are a number of undocumented functions in 3.00. In 
particular if you look in Q&A.L you will see the code that self tests 
them. A short description of the undocumented non Franz functions
follows:

    (toupper str) -> string str zapped to upper case chars.
    (tolower str) -> string str zapped to lower case chars.
    (readln [port] [eof]) -> next line read from [port]/piport as a string 
		    or nil/eof on end of file.
    (strlen str) -> length of the string or atom str as a fixnum.
    (strcomp str) -> string str without ANY blanks in it at all ie compressed.
    (strtrim str) -> string str without any trailing blanks.
    (strpad str n) -> string str padded/truncated to 'n' chars long.

  In addition the Franz 'autoload property is now allowed and it is 
possible to put the property 'autoload on an atom with a property value
which is a string naming the file where the function can be found. See 
LISPcraft for more details.
