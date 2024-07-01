'   Microsoft RemLine- Line Number Removal Utility
'   Copyright (C) Microsoft Corporation- 1985,1986

'   REMLINE.BAS is a program to remove line numbers from Microsoft BASIC
'   Programs. It removes only those line numbers that are not the object
'   of a goto, gosub or if-then
'
'   REMLINE is run by typing:
'
'			REMLINE [<input file> [, <output file>]]
'
'   where <input file> is any input file name and <output file> is 
'         is any output file name. If <output file> is not present 
'         the output goes to the console.  If <output file>
'         is present <input file> has to be present.
'
'   It makes several assumptions about the program
'	 1. Program is correct syntactically, and runs in an MS Interpreter.
'     2. 200 limit on referenced line numbers. If larger, change LineTable!
'        declaration.
'     3. The first number encountered on a line is considered a line num-
'        ber; thus some continuation lines (in a compiler specific 
'        construct) may not work correctly.
'     4. Remember that ERL assumes the existence of line numbers, so 
'        REMLINE should not be used on programs which depend on ERL.

	DEFINT a - z 
	DIM SHARED KeyWordTable$( 8 ) 
	DIM SHARED LineTable!( 400 )
	DIM KeyWordCount, LineCount, Seps$
	DIM KeyBoard, Console
	DIM InputFile$, OutputFile$
	 
'
' FNToUpper$ - Convert string to uppercase
' Description:
'  This routine converts a string to uppercase. If already uppercase
'  nothing is done. Returns a null string if input is null
' Input:
'  InString$ - string to convert
' Output:
'  FNToUpper$ - uppercase string
' Uses:
'  AscChar - temp used to hold ASCII form of character
'  LenInString - Length of input string
'  IndexInstring - Current index into input string
Def FNToUpper$(InString$)

	LenInString = len(InString$)
	' Exit if input string is empty (null)
	if (LenInString = 0) then FNToUpper$ = "" : Exit Def
	for IndexInstring = 1 to LenInString
		AscChar = asc(mid$(InString$, IndexInstring, 1))
		' &hdf is special bit pattern that converts from lower to upper
		if ((AscChar >= asc("a")) and (AscChar <= asc("z"))) then _
			AscChar = AscChar and &hdf: _	
		mid$(InString$, IndexInstring, 1) = chr$(AscChar)
	next IndexInString
	FNToUpper$ = InString$

End Def

'
' FNStrSpn - Get the index of the first character within InString$ that is
'				 NOT one of the characters from Separater$ 
' Description:
' This routine will search the parameter string InString$ until it finds 
' a character that is not part of the Separater string. This can be used 
' with FNStrBrk to isolate strings within strings that are separated by
' blanks, comma etc. whatever is specified in Separater$.  This is especially
' helpful in extracting parameters from the command line. See FNGetToken$
' for example of use.
'
' Input:
'   InString$ = string to search 
'   Separater$ = string of Separater
'
' Output:
'   FNStrSpn = index into InString$ if 0 then all character in Separater$ 
'              are in InString$
' Uses:
'  LenInString, LenSeprater = length parameter strings
'  ChTemp$ = temp used for current character from InString$
'  StartFound = Logical flag if search was successful
'  IndexSeparater, IndexInString = current indices into parameter strings
'
Def FNStrSpn(InString$, Separater$)

	LenInString = Len(InString$)
	LenSeparater = Len(Separater$)
	' Examine each character from InString$ to see if it is in Separater$
	for IndexInString = 1 to LenInString
		ChTemp$ = Mid$(InString$, IndexInString, 1)
		StartFound = false
		' search all of the Separaters to see of any equal this character
		for IndexSeparater = 1 to LenSeparater
			if (ChTemp$ = Mid$(Separater$, IndexSeparater, 1)) then _
			goto NextChar
		next IndexSeparater
		' found a character not equal to one of the Separaters$
		' exit from loops
		StartFound = true
		goto EndStrSpn
NextChar:
	Next IndexInString
EndStrSpn:
	if (StartFound) then _
		FNStrSpn = IndexInString _
	else FnStrSpn = 0 

End Def

'
' FNStrBrk - finds the first occurance of any character in string2$ in
'            string1$
' Description:
' This routine is the opposite to FNStrSpn. It finds the first occurance
' of one of the characters from String2$ within String$. It is used
' generally for search from specific strings within strings. See FNSeparater
' on use. See FNGetToken$ to see the routines in use.
'
' Input:
'   string1$ = string to search for first occurance
'   string2$ = string of characters to search for
' Output:
'   FNStrBrk = index to character in string1$ of first occurance
'
' Uses:
'  LenString1 = length parameter string
'  ChTemp$ = temp used for current character from String1$
'  IndexString1 = current indices into parameter string
'
Def FNStrBrk(String1$, String2$)

	LenString1 = Len(String1$)
	' Search String1$ until one of the characters from String2$ is found
	' or run out of characters from String$2
	for IndexString1 = 1 to LenString1
		ChTemp$ = Mid$(String1$, IndexString1, 1)
		if (instr(String2$, ChTemp$)) then _
			StartFound = true: _
			FNStrBrk = IndexString1: _
			Exit Def
	Next IndexString1
	FnStrBrk = 0

End Def
'
' FNGetToken$ - Extract a token for a string.
' Description:
' This routine extracts tokens from strings. A token is a word that is 
' surrounded by separaters, such as spaces or commas. It is usually the
' word of interest and examining sentences or commands. If the string
' to search for tokens "Search$" is null (.i.e "") then the last
' non-null string passed will be used. The allows for multiple calls
' to FNGetToken$ to move through the string. EG: the sequences of calls
'  would be:
'    token$ = FNGetToken$("token string, a short one", " ,")
'    while (token$ <> "")
'       print token$
'       token$ = FNGetToken$("", " ,")
'    wend
' This will return "token", "string", "a", "short", "one" 
'
' Note that the token is returned as an Uppercase character string.
'
' Input:
'  Search$ = string to search
'  InSeps$  = String of Seps$
' Output:
'  FNGetToken$ = next token
' Uses:
'  TokenString$ = last non-null string passed as parameter (do not modify)
'  TokenIndex2 = index to last separater (do not modify)
'  TokenIndex1 = index to last token
'
def FNGetToken$(Search$, InSeps$)


	' Null strings indicate use of last string used
	' TokenString$ is set to last string if Search$ is not null
	if (Search$ = "") then _
		Search$ = TokenString$ _
	else TokenIndex2 = 1: _
		TokenString$ = Search$
	' If last separater position is past end of search string then no more
	' tokens can be in string, since searching is started from this position
	' Exit with null return in this case
	if (TokenIndex2 >= len(Search$)) then _
		FNGetToken$ = "": Exit Def
	' Section out a token from the search string. This is done by finding the
	' start of a token then locating it's end by the start of separaters
	TokenIndex1 = FNStrSpn(mid$(Search$, TokenIndex2, len(Search$)), InSeps$) 
	' If no more token bump to end of line so we move past current point
	if (TokenIndex1 = 0) then _
		TokenIndex1 = len(Search$): _
	else TokenIndex1 = TokenIndex1 + TokenIndex2 - 1
	TokenIndex2 = FNStrBrk(mid$(Search$, TokenIndex1, len(Search$)), InSeps$) 
	' If separater position (end of token) came back zero the token must be
	' up against end of string. Set the separater position one past string
	' length so that size of token computation is correct and next call
	' with same string will return null for no more tokens
	if (TokenIndex2 = 0) then _
		TokenIndex2 = len(Search$) + 1 _
	else TokenIndex2 = TokenIndex1 + TokenIndex2 - 1
	' Cut out token from search string and convert to uppercase. 
	' It is converted to uppercase since string compares are case sensitive
	FNGetToken$ = FNToUpper$(mid$(Search$,TokenIndex1,TokenIndex2 - TokenIndex1))
end def

'
' FNIsNumber - Checks to see if character a number or alpha
' Description:
'  This routine returns true if character passed is in the range 0 - 9
'  It returns false if not. It is used to tell wither a token is
'  a number or alpha.
' Input:
'  Char - character to check
' Output:
'  FNIsNumber - true if within 0 - 9
'
def FNIsNumber(Char$)

	if (Char$ = "") then _
		FNIsNumber = false: _
	else CharAsc = asc(Char$): _
		FNIsNumber = ((CharAsc >= asc("0")) and (CharAsc <= asc("9")))

end def

' 
' GetFileNames - Parses the input and output file names from command$
' Description:
'	This routine retrieves the input and output file names. These should
'  be separated by a comma with the input file name coming first.
' Input:
'  Command$ - Command line
'  true, false - logical flags
' Output:
'	Console - flag if no output file
'  InputFile$, OutputFile$ - Input/Output file name
' 
sub GetFileNames static
shared Console, InputFile$, OutputFile$, Seps$, true, false

	Console = false
	if (Command$ = "") then
		print " Microsoft RemLine: Line Number Removal Utility"
		print " "
		Input "    Input Filename (return to terminate)";InputFile$
		If inputfile$ = "" Then Exit Sub
		Input "    Output Filename (default is console:)";OutputFile$
		if (OutputFile$ = "") then Console = true
		CLS
	    ELSE
		InputFile$ = FNGetToken$(Command$, Seps$)
		OutputFile$ = FNGetToken$("", Seps$)
		if (OutputFile$ = "") then Console = true
	END IF

ExitGet:
end sub
	
' 
' BuildTable - Build a table of line numbers that are references
' Description:
'  This routine examines all of the text file looking for line numbers
'  that are the object of goto, gosub etc. As each is found it is entered
'  into a table of these line numbers. This table is used during a second
'  pass at the source to remove all line numbers not in this list
' Input:
'  KeyWordTable$ - array of keywords that have line number following them
'  KeyWordCount - number of entries in KeyWordTable$
'  Seps$ - current token Seps$
'  true, false - true, false flags
' Output:
'  LineTable! - table of referenced line numbers
'  LineCount - number of lines in LineTable!
' 
sub BuildTable	static
shared KeyWordCount, Seps$, LineCount, false, true

	WHILE NOT EOF( 1 ) 
		LINE INPUT #1, inlin$ 
		token$ = FNGetToken$(inlin$, Seps$)
		WHILE (token$ <> "")
			for KeyIndex = 0 to KeyWordCount
				if (KeyWordTable$(KeyIndex) <> token$) then  goto KeyNotFound
				token$ = FNGetToken$("", Seps$)
				' loop through looking for multiple lines in the case 
				' of a computed gosub or goto. A non-numeric will terminate
				' search (another keyword etc.)
				while (FNIsNumber(Left$(token$,1)))
					LineCount = LineCount + 1
					LineTable!(LineCount) = val(token$)
					token$ = FNGetToken$("", Seps$)
					if token$ <> "" then KeyIndex = 0
				wend 
KeyNotFound:
			next KeyIndex
KeyFound:
			token$ = FNGetToken$("", Seps$)
		WEND
	WEND

end Sub

' 
' GenOutFile - Generate output file
' Description:
'  This routine generates the output file removing the unreferenced line
'  numbers. 
' Input:
'  LineTable! - Table of line numbers that are referenced
'  LineCount - number of entries in LineTable!
'  Seps$ - Separaters used between keywords
'   Console - flags if output to file 
'  false, true - logical flags
'

sub GenOutFile static
shared false, true, Seps$, LineCount, Console

	WHILE NOT EOF( 1 ) 
		LINE INPUT #1, inlin$ 
		if (inlin$ = "") then goto NoLine
		token$ = FNGetToken$(inlin$, Seps$)
		if (not FNIsNumber(Left$(token$,1))) then goto NoLine
		Linenumber! = VAL(token$)
		FoundNumber = false
		for index = 1 to LineCount
			if (Linenumber! = LineTable!(index)) then _
				FoundNumber = true
		next index
		if (not FoundNumber) then _
			mid$(inlin$,FNStrSpn(inlin$,Seps$),len(token$)) = space$(len(token$))
NoLine:
		if (Console) then _
			PRINT inlin$ _
		else Print #2, inlin$
WEND 
end sub 
' 
'  initialize the system 
' 
SUB initsys STATIC
SHARED true, false, KeyWordCount, Seps$, KeyWordTable$()

	Seps$ = " ,:	": true = -1: false = 0 
	RESTORE keydata       'keywords 
	' Initialize the keyword table. Keywords are recognized so that 
	' the difference between a line number and a numeric contstant can
	' be determined
	KeyWordCount = 0 
	READ KeyWord$ 
	WHILE KeyWord$ <> "" 
		KeyWordCount = KeyWordCount + 1 
		KeyWordTable$( KeyWordCount ) = KeyWord$ 
		READ KeyWord$ 
	WEND 
END SUB 

'  keyword search data 

keydata:
	DATA THEN, ELSE, GOSUB, GOTO, RESUME, RETURN, RESTORE, RUN, "" 

main:
	CALL initsys 
	CALL GetFileNames
	if (InputFile$ = "") goto ExitMain
	OPEN InputFile$ FOR INPUT AS 1 
	call BuildTable
	CLOSE #1 
	OPEN InputFile$ FOR INPUT AS 1 
	if (not Console) then _
		OPEN OutputFile$ FOR OUTPUT AS 2
	call GenOutFile
	CLOSE #1 
	ExitMain:
end

