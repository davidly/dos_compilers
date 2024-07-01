REM $Title:'Microsoft PPRINT- Formatted Print Utility'
REM $Subtitle:'Introduction'
'
' Microsoft PPRINT- Formatted Print Utility
' Copyright (C) Microsoft Corporation - 1986
'
' This program is designed to format QuickBASIC source files that include
' the formatting metacommands found in QuickBASIC V1.00 and earlier
' Microsoft BASIC Compilers.
'
' The Metacommands processed by PPRINT are:
'
'    TITLE: 'title'          Prints 'title' at the top of each page
'    SUBTITLE: 'subtitle'    Prints 'subtitle' below the title area
'    LINESIZE:n              Sets output line width to n
'    PAGESIZE:n              Sets the output page size to n
'    PAGE                    Skips to next page
'    PAGEIF:n                Skips to next page if there are fewer than n
'                             lines left on current page
'    SKIP[:n]                Skips n lines or to top of next page
'    LIST-                   Turns OFF output of lines
'    LIST+                   Turns ON output of lines
'
'
' USAGE:  The PPRINT Utility has the following usage:
'
'         PPRINT InputFile, [OutputFile]
'
'         If the OutputFile is ommitted, LPT1: is the default
'
' COMPILATION:
'
'    Since the PPRINT utility is distributed in source form (PPRINT.BAS)
'    You must compile it before using.  Suggested compilation procedures are
'    as follows:
'
'    1) Load PPRINT.BAS into the QuickBASIC editor
'    2) Select "Compile..." from the RUN Menu
'    3) Select ".EXE" from the output options section
'    4) press the "Compile" button or press return
'
'    These 4 steps should create a file PPRINT.EXE on your default
'    drive.
'
' REVISION HISTORY:
'
'    12/1/86- GEL - Fixed TARs # 57720 & 56937
'

rem $subtitle:'Global Declarations'
rem $page
	DEFINT a - z
	DIM KeyWordCount, LineCount, Seps$
	DIM KeyBoard, Console
	DIM InputFile$, OutputFile$
	DIM Temp$,x     ' temp variables
	'
	' global variables for handling metacommands
	DIM Out.Title$, Out.Subtitle$, MetaCommand.On
	DIM Out.LineSize, Out.Pagesize, Out.List, Out.LineCount, Out.BlankBottom
	DIM Out.PageNum

REM $subtitle:'FnToUpper- Converts To Uppercase'
rem $page
'
' FNToUpper$ - Convert string to uppercase
' Description:
'  This routine converts a string to uppercase. If already uppercase
'  nothing is done. Returns a null string if input is null
' Input:
'  InString$ - string to convert
' Output:
'  FNToUpper$ - uppercase string
Def FNToUpper$(InString$)
static LenInString, AscChar, Index, IndexInString

	LenInString = len(InString$)
	' Exit if input string is empty (null)
	if (LenInString = 0) then
		FNToUpper$ = ""
		Exit Def
	end if
	for IndexInstring = 1 to LenInString
		AscChar = asc(mid$(InString$, IndexInstring, 1))
		' &hdf is special bit pattern that converts from lower to upper
		if ((AscChar >= asc("a")) and (AscChar <= asc("z"))) then
			AscChar = AscChar and &hdf
			mid$(InString$, IndexInstring, 1) = chr$(AscChar)
		end if
	next IndexInString
	FNToUpper$ = InString$

End Def

rem $subtitle:'FnTabsToBlanks- Converts TABs to Blanks'
rem $page
'
' FnTabsToBlanks- turns TABs into blanks in the given string
'
' Input: Source$
' Output Source$ with ALL TABs as 3 Blanks
' Note: If TABs are set at a value different from 3, change the following
'       procedure in the 'Then' part of the IF statement
'
DEF FNTabsToBlanks$(source$)
STATIC Temp$,i

    Temp$ = ""
    If Instr(Source$, Chr$(9)) = 0 Then FnTabsToBlanks$ = Source$: Exit Def

    For i = 1 to Len(source$)
	If ASC(Mid$(Source$,i,1)) = 9  Then
		Temp$ = Temp$ + Space$(3) ' replace with 3 spaces
	    Else
		Temp$ = Temp$ + Mid$(source$,i,1)
	End If
    Next i

    FnTabsToBlanks$ = Temp$
End Def


rem $subtitle:'FnStrSpn- String Spanner'
rem $page
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
Def FNStrSpn(InString$, Separater$)
static LenInString, LenSeparater, StartFound, IndexSeparater, IndexInString
static ChTemp$

	LenInString = Len(InString$)
	LenSeparater = Len(Separater$)
	' Examine each character from InString$ to see if it is in Separater$
	for IndexInString = 1 to LenInString
		ChTemp$ = Mid$(InString$, IndexInString, 1)
		StartFound = false
		' search all of the Separaters to see of any equal this character
		for IndexSeparater = 1 to LenSeparater
			if (ChTemp$ = Mid$(Separater$, IndexSeparater, 1)) then
				goto NextChar
			end if
		next IndexSeparater
		' found a character not equal to one of the Separaters$
		' exit from loops
		StartFound = true
		goto EndStrSpn
NextChar:
	Next IndexInString
EndStrSpn:
	if (StartFound) then
		FNStrSpn = IndexInString
	else
		FNStrSpn = 0
	end if
End Def

rem $subtitle:'FnStrBrk- String Breaker'
rem $page
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
static LenString1, IndexString1, StartFound
static ChTemp$

	LenString1 = Len(String1$)
	' Search String1$ until one of the characters from String2$ is found
	' or run out of characters from String$2
	for IndexString1 = 1 to LenString1
		ChTemp$ = Mid$(String1$, IndexString1, 1)
		if (instr(String2$, ChTemp$)) then
			StartFound = true
			FNStrBrk = IndexString1
			Exit Def
		end if
	Next IndexString1
	FnStrBrk = 0

End Def

rem $subtitle:'FnGetToken- Gets a Token'
rem $page
'
' FNGetToken$ - Extract a token for a string.
' Description:
' This routine extracts tokens from strings. A token is a word that is 
' surrounded by separaters, such as spaces or commas. It is usually the
' word of interest and examining sentences or commands. If the string
' to search for tokens "Search$" is null (.i.e "") then the last
' non-null string passed will be used. The allows for multiple calls
' to FNGetToken$ to move through the string. EG: The sequences of calls
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
'
def FNGetToken$(Search$, InSeps$)
static TokenIndex1

	' Null strings indicate use of last string used
	' TokenString$ is set to last string if Search$ is not null
	if (Search$ = "") then
		Search$ = TokenString$
	else
		TokenIndex2 = 1
		TokenString$ = Search$
	end if
	' If last separater position is past end of search string then no more
	' tokens can be in string, since searching is started from this position
	' Exit with null return in this case
	if (TokenIndex2 >= len(Search$)) then
		FNGetToken$ = ""
		 Exit Def
	end if
	' Section out a token from the search string. This is done by finding the
	' start of a token then locating it's end by the start of separaters
	TokenIndex1 = FNStrSpn(mid$(Search$, TokenIndex2, len(Search$)), InSeps$) 
	' If no more token bump to end of line so we move past current point
	if (TokenIndex1 = 0) then
		TokenIndex1 = len(Search$)
	else
		TokenIndex1 = TokenIndex1 + TokenIndex2 - 1
	end if
	TokenIndex2 = FNStrBrk(mid$(Search$, TokenIndex1, len(Search$)), InSeps$) 
	' If separater position (end of token) came back zero the token must be
	' up against end of string. Set the separater position one past string
	' length so that size of token computation is correct and next call
	' with same string will return null for no more tokens
	if (TokenIndex2 = 0) then
		TokenIndex2 = len(Search$) + 1
	else
		TokenIndex2 = TokenIndex1 + TokenIndex2 - 1
	end if
	' Cut out token from search string and convert to uppercase. 
	' It is converted to uppercase since string compares are case sensitive
	FNGetToken$ = mid$(Search$,TokenIndex1,TokenIndex2 - TokenIndex1)
end def

rem $subtitle:'FnIsNumber- Is a Number?'
rem $page
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
static CharAsc

	if (Char$ = "") then
		FNIsNumber = false
	else
		CharAsc = asc(Char$)
		FNIsNumber = ((CharAsc >= asc("0")) and (CharAsc <= asc("9")))
	end if

end def

rem $subtitle:'FnIsChar- Is a character?'
rem $page
def FNIsChar(Char$)
static CharAsc

	CharAsc = asc(Char$)
	FNIsChar = ((CharAsc >= asc("A")) and (CharAsc <= asc("z")))

end def


rem $subtitle:'FnIsKeyword- Is a Keyword?'
rem $page
' FNIsKeyWord - returns true if specified string is a BASIC key word
' Description:
'  Checks keyword list agains String$, non-zero return if keyword
'
def FNIsKeyWord(Key$)
static KeyWord$, AscCh, t

	if (len(Key$) > 0) then
		t = asc(key$)

		while t < 33 AND Key$ <> ""    ' strip off all spaces and below
		    key$= mid$(key$,2)
		    If key$ <> "" then t = asc(key$) Else FNIsKeyword=0: Exit Def
		wend
		Key$ = FNToUpper$(Key$)
		AscCh = (asc(Key$) - asc("A") + 1)
		if ((AscCh >= 0 ) and (AscCh <= 24)) then
			on (AscCh) gosub AKey, BKey, CKey, DKey, EKey, FKey, GKey, HKey, _
								  IKey, JKey, KKey, LKey, MKey, NKey, OKey, PKey, _
								  QKey, RKey, SKey, TKey, UKey, VKey, WKey, XKey, _
								  YKey, ZKey
			read KeyWord$

			while (KeyWord$ <> "")
				if (KeyWord$ = Key$) then
					FNIsKeyWord = TRUE
					exit def
				end if
				read KeyWord$
			wend
		end if
	end if
	FNIsKeyWord = FALSE
	exit def
AKey:
	DATA ABS, AND, APPEND, AS, ASC, ATN, AUTO, ""
	restore AKey: return
BKey:
	DATA BEEP, BLOAD, BSAVE, ""
	restore BKey: return
CKey:
	DATA CALL, CALLS, CDBL, CHAIN, CHDIR, CHR$, CINT, CIRCLE, CLEAR
	DATA CLOSE, CLS, COLOR, COM, COMMAND$, COMMON, CONT, COS, CSNG
	DATA CSRLIN, CVD, CVI, CVS, "", ""
	restore CKey: return
DKey:
	DATA DATA, DATE$, DEF, DEFDBL, DEFINT, DEFSNG, DEFSTR, DEF FN, DEF USR, DELETE
	DATA DIM, DRAW, ""
	restore DKey: return
EKey:
	DATA EDIT, ELSE, END, ENVIRON, ENVIRON$, EOF, EQV, ERASE
	DATA ERL, ERR, ERROR, EXIT, EXP, ""
	restore EKey: return
FKey:
	DATA FIELD, FILES, FIX, FOR, FRE, ""
	restore FKey: return
GKey:
	DATA GET, GO, GOSUB, GOTO, ""
	restore GKey: return
HKey:
	DATA HEX$, ""
	restore HKey: return
IKey:
	DATA IF, IMP, INKEY$, INP, INPUT, INPUT$, INPUT$, INSTR, INT, ""
	restore IKey: return
JKey:
	DATA ""
	restore JKey: return
KKey:
	DATA KEY, KILL, ""
	restore KKey: return
LKey:
	DATA LCOPY, LEFT$, LEN, LET, LINE, LIST, LBOUND, LLIST, LOAD
	DATA LOC, LOCAL, LOCATE, LOCK, LOF, LOG, LPOS, LPRINT, LSET, ""
	restore LKey: return
MKey:
	DATA MERGE, MID$, MKD$, MKI$, MKS$, MKDIR, MOD, MOTOR, ""
	restore MKey: return
NKey:
	DATA NAME, NEW, NEXT, NOT NULL, ""
	restore NKey: return
OKey:
	DATA OCT$, ON, OPEN, OPTION, OR, OUT, OUTPUT, ""
	restore OKey: return
PKey:
	DATA PAINT, PALETTE, PEEK, PEN, PLAY, PMAP
	DATA POINT, POKE, POS, PRESET, PRINT, PSET, PUT, ""
	restore PKey: return
QKey:
	DATA ""
	restore QKey: return
RKey:
	DATA RANDOMIZE, READ, REDIM, REM, RENUM, REM, RENUM
	DATA RESTORE, RESUME, RETURN, RIGHT$, RMDIR, RND, RSET, RUN, ""
	restore RKey: return
SKey:
	DATA SAVE, SCREEN, SEG, SGN, SHARED, SHELL, SIN, SOUND, SPACE
	DATA SPC, SQR, STATIC, STEP, STICK, STOP, STR, STRIG, STRING
	DATA SUB, SWAP, SYSTEM, ""
	restore SKey: return
TKey:
	DATA TAB, TAN, THEN, TIME, TIMER, TO, TROFF, TRON, ""
	restore TKey: return
UKey:
	DATA UBOUND, UNLOCK, USING, ""
	restore UKey: return
VKey:
	DATA VAL, VARPTR, VIEW, ""
	restore VKey: return
WKey:
	DATA WAIT, WEND, WHILE, WIDTH, WINDOW, WRITE, ""
	restore WKey: return
XKey:
	DATA XOR, ""
	restore XKey: return
YKey:
	DATA ""
	restore YKey: return
ZKey:
	DATA ""
	restore ZKey: return

end def

rem $subtitle:'FnIsMetacommand- Is a Metacommand?'
rem $page
'FNIsMetaCommand- returns non-zero if source$ is a meta command of
' the form "'$metacommand" or "$metacommand"
'
' Input:
'   Source$ - source string to determine if metacommand
'
def FnIsMetacommand(source$)

' The following is a list of the metacommands processed by this program
Meta$ = "TITLE SUBTITLE LINESIZE PAGESIZE PAGE PAGEIF SKIP LIST- LIST+ LIST"

  if (mid$(source$,1,1)) = "'" then source$=mid$(source$,2)
  if ((mid$(source$,1,1)) <> "$") OR (len(source$) < 4 ) then
		       FnIsMetacommand = 0
		       exit def
		   else
		       source$=Mid$(source$,2)  ' get rid of the $
		       source$ = FnToUpper$(source$) 'convert to uppercase
		       x = instr(meta$,source$)
		       if x <> 0 then FnIsMetacommand = -1 else FnIsMetacommand = 0
  end if
end def


rem $subtitle:'InQuote'
rem $page
' InQuote- determines whether or not we are in the middle of a
'            quoted literal
'
'   Input: Target$- string to see if it contains a double quote character
'   Output: either 1 or 0, toggles state of Quoted.Literal
'
SUB InQuote(Target$, Quoted.Literal) STATIC
STATIC x,xi
    x= INSTR(1,target$,chr$(34))    ' is there a quote in the string??
    IF x = 0 then
	Exit SUB               ' no quote chracters, exit...

    ELSE
	x1 = Instr(x+1, target$,chr$(34))   ' look for a 2nd quote
	if x1 = 0 then quoted.Literal = NOT Quoted.Literal
    END IF
END SUB


rem $subtitle:'Write.Outputfile- writes 1 line'
rem $page
' Write.Outputfile- Writes one line to the output file, handling all the
'                   all the parameters set up by metacommands.
' Assumptions:- This routine assumes that channel #2 has been opened for output
'
' Input:
'    OutputLine$ - The line to output
' Output:
'    None
' Uses:
'     Out.Title$, Out.SubTitle$, Out.LineSize, Out.PageSize, Out.List,
'     Out.LineCount, Out.BlankBottom, MetaCommand.On, True, False
SUB Write.Outputfile(outputLine$) STATIC

SHARED Out.Title$, Out.SubTitle$, Out.LineSize, Out.PageSize, Out.List
SHARED Out.LineCount, Out.BlankBottom, MetaCommand.On, True, False
    If Out.List = False THEN Exit Sub   'Listing is OFF
    If MetaCommand.On Then MetaCommand.On = False: Exit Sub   ' Don't Print the metacommand line
    IF Out.LineCount = 0 Then CALL Out.Header    'must be first time into this routine

    ' Convert all TABs in the line to Blanks
    OutputLine$ = FnTabsToBlanks$(outputline$)

    'Output the line, given the page width
    OutLine.Length = Len(outputLine$)
    While OutLine.Length > Out.LineSize-1
	IF (Out.LineCount > (Out.PageSize-Out.BlankBottom)) AND (Out.PageSize <> 255) THEN CALL Out.Header
	PRINT #2, Mid$(OutputLine$,1,Out.LineSize-1)
	OutputLine$ = Mid$(OutputLine$,Out.LineSize) 'start at next char
	OutLine.Length  = Len(outputLine$)
	Out.LineCount = Out.LineCount + 1
    Wend
    IF (Out.LineCount > (Out.PageSize-Out.BlankBottom)) AND (Out.PageSize <> 255) THEN CALL Out.Header
    PRINT #2, Mid$(OutputLine$,1,Out.LineSize-1)
    Out.LineCount = Out.LineCount + 1

End Sub


rem $subtitle:'Out.Header- Writes the Header Info'
rem $page
' Out.Header - Output the header to the output file
'
' Assumptions- Assumes Channel #2 is open for output
' Input:
'    None
' Output:
'    None
' Uses:
'     Out.Title$, Out.SubTitle$, Out.LineSize, Out.PageSize, Out.List,
'     Out.LineCount
SUB Out.Header STATIC

SHARED Out.Title$, Out.SubTitle$, Out.LineSize
SHARED Out.LineCount, Out.PageNum, Out.List

    If Out.List = 0 Then exit sub

    ' first update the screen
    Locate 2,5:print "Microsoft PPRINT: Formatted Print Utility"
    locate 4,5:print space$(60)
    locate 4,5:print "Currently printing Page: ";Out.Pagenum
	 if out.pagenum > 1 then Print #2, Chr$(12)    ' The FF character

    Print #2, Mid$(Out.Title$,1,Out.LineSize);
	 page$ = "Page"+string$(4-len(str$(out.pagenum))," ")+str$(out.PageNum)
    print #2,Tab(Out.LineSize-len(page$));Page$
	 print #2, Mid$(Out.Subtitle$,1,Out.LineSize);
	 print.date$ = left$(date$,6)+right$(date$,2)
	 print #2, Tab(Out.LineSize-8);print.date$
    print #2, Tab(Out.LineSize-8);Time$
	 Print #2,Tab(Out.LineSize-35);"Microsoft QuickBASIC Compiler V2.01"

    Print #2, ""  ' add a blank line
    Out.LineCount = 7
    Out.PageNum = Out.PageNum + 1

END SUB


rem $subtitle:'ProcessMetacommand- Process 1 Metacommand'
rem $page
' ProcessMetaCommand- Determines which meta command it is and takes
'                     the appropriate action(s)
'
' Input
'    Token$- Last token found
' Output
'    None, except the action associated with the metacommand
'

SUB ProcessMetaCommand( Token$) STATIC
SHARED Out.Title$, Out.SubTitle$, Out.LineSize, Out.PageSize, Out.List
SHARED Out.LineCount, Out.BlankBottom, MetaCommand.On, True, False
SHARED OutputFile$
STATIC X, Meta1$
' Each item in the following list is an a 10 character boundary so that
' I can find the index, divide by 10, and use the ON...GOTO contruct

meta1$ = "         TITLE     SUBTITLE  LINESIZE  PAGE      PAGESIZE  PAGEIF    SKIP      LIST-     LIST+"


  if (mid$(token$,1,1)) = "'" then token$=mid$(token$,2)
  token$=Mid$(token$,2)  ' get rid of the $
  token$ = FnToUpper$(token$) 'convert to uppercase
  MetaCommand.On = -1
  x = instr(Meta1$,token$)/10

  ON x GOTO Title, Subtitle, LineSize,  Page, PageSize, Pageif, Skip, ListOff, ListOn

Title:
    arg$=FnGetToken$("","'"): Arg$=FnGetToken$("","'")
    Out.Title$ = Arg$
    Exit Sub
Subtitle:
    arg$=FnGetToken$("","'"): Arg$=FnGetToken$("","'")
    Out.SubTitle$ = Arg$
    Exit Sub
LineSize:
    arg$=FnGetToken$("","':  ")
    Out.LineSize=Val(arg$)
    IF OutputFile$ = "LPT1:" THEN WIDTH #2,Out.LineSize  'FIX #57720
    Exit Sub
Page:
    CALL Out.Header
    Exit Sub
PageSize:
    arg$=FnGetToken$("","':  ")
    Out.PageSize=Val(arg$)
    Out.LineCount = Out.LineCount MOD Out.PageSize
    Exit Sub
Pageif:
    arg$=FnGetToken$("","':  ")
    x =Val(arg$)
    If (Out.PageSize-Out.BlankBottom-x) <= Out.LineCount Then CALL Out.Header
    Exit Sub
Skip:
    arg$=FnGetToken$("","':  ")
    x =Val(arg$)
    IF (Out.LineCount+x) > (Out.PageSize-Out.BlankBottom) Then
			       Call Out.Header
			   Else
			       For i=1 to x
				  Call Write.OutputFile(" ")
			       Next i
    END IF
    MetaCommand.On = -1   ' Fix #56937
    Exit Sub
ListOff:
    Out.List = False
    Exit Sub
ListOn:
    Out.List= True
    Exit Sub
END SUB

rem $subtitle:'GetFilenames- Gets the I/O filenames'
rem $page
'
' GetFileNames - Parses the input and output file names from command$
' Description:
'	This routine retrieves the input and output file names. These should
'  be separated by a comma with the input file name coming first.
' Input:
'  Command$ - Command line
'  true, false - logical flags
' Output:
'  InputFile$, OutputFile$ - Input/Output file name
' 
sub GetFileNames static
shared InputFile$, OutputFile$, Seps$, true, false

	if (Command$ = "") then
		print " Microsoft PPrint: Formatted Print Utility"
		print " "
		Input "    Input Filename (return to terminate)";InputFile$
		If inputfile$ = "" Then Exit Sub
		Input "    Output Filename (default is LPT1:)";OutputFile$
		CLS
	else
		InputFile$ = FNGetToken$(Command$, Seps$)
		OutputFile$ = FNGetToken$("", "  ")      'next token is outputfilename
	end if
ExitGet:
		'Add .bas if filename has no extension
		if Instr(InputFile$,".") = 0 then InputFile$ = InputFile$ + ".bas"
		if (OutputFile$ = "") then OutputFile$ = "LPT1:"
end sub

rem $subtitle:'InitSys- Initialize the System'
rem $page
'
'  initialize the system
'
SUB initsys STATIC
SHARED true, false, KeyWordCount, Seps$
SHARED Out.Title$, Out.SubTitle$, Out.LineSize, Out.PageSize, Out.List, Out.LineCount, Out.BlankBottom, Out.PageNum

	Seps$ = " ,:   ": true = -1: false = 0
	Out.Title$ = ""
	Out.SubTitle$ = ""
	Out.LineSize = 80
	Out.PageSize = 66
	Out.List = true
	Out.LineCount = 0
	Out.BlankBottom = 6 '6 lines are left blank at the bottom of each
			    ' page unless pagesize=255 meaning an infinate
			    ' page.
	Out.PageNum = 1
	MetaCommand.On = 0
END SUB

rem $subtitle:'MAIN PROGRAM'
rem $page
main:
	Call InitSys
	Call GetFileNames
	If Inputfile$ = "" Then goto Exitmain
	open InputFile$ for input as #1
	open outputfile$ for output as #2
	while not eof(1)
		line input #1, LineCur$
		outputLine$ = LineCur$
		OutputIndex = 1
		TokenCur$ = FNGetToken$(LineCur$, Seps$)
		while (TokenCur$ <> "")
		      CALL InQuote(TokenCur$,Quoted.Literal)
		      IF FNIsKeyWord(TokenCur$) then
			  ' Make uppercase
			  ' stuff into line at appropriate position
			  '
			  Temp$=FNToUpper$(TokenCur$)
			  x = Instr(OutputIndex,OutputLine$,TokenCur$)
			  IF NOT Quoted.Literal THEN MID$(OutPutLine$,x) = Temp$ 'replace with uppercase
			  OutputIndex = x + len(temp$)

		      ELSEIF  FnIsMetacommand(tokencur$) Then
			      OutputIndex = OutputIndex + Len(TokenCur$)
			      ' process the metacommand
			      Call ProcessMetaCommand(TokenCur$)
		      ELSE
			      'move index across line
			      OutputIndex = OutputIndex + Len(TokenCur$)
		      END IF

		      TokenCur$ = FNGetToken$("", Seps$)
		wend
		Call Write.Outputfile(OutputLine$)
	wend

	Print #2,chr$(12) 'send one last FF character
	CLOSE   ' Close all files

Exitmain:
end

