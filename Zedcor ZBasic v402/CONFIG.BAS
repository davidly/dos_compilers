'------------------------------------------------------------------------
'                            Array declarations
'------------------------------------------------------------------------
DIM ADRS%(15), BYTES(15)
DIM 30 MENU$(5), 7 LEP$(10), 40 MENU1$(5)
DIM 40 MENU2$(12), 7 SEP1$(10), SEP2$(10)

'------------------------------------------------------------------------
'                          Function declarations
'------------------------------------------------------------------------
LONG FN MENUKY$(ht,inc,top,P$)
COLOR ,&70 : PRINT @(ht,Line*inc+top-2) P$ ' Inverse text
DO
A$ = INKEY$
UNTIL LEN(A$) ' Wait for a keypress
A$ = RIGHT$(A$,1)
COLOR ,7 : PRINT @(ht,Line*inc+top-2) P$ ' Restore normal text
END FN = A$

LONG FN MAINMENU ' Used to put main menu on screen
CLS : LOCATE ,,0
FOR I = 1 TO 4
PRINT @(27,I*2+3) MENU$(I)
NEXT I
END FN

LONG FN Increment(X) ' Increment color attribute byte
X = (X AND &0F) + 1 : IF X > 15 THEN X = 0
X = X OR (BYTES(2) << 4) ' Combine with border color background
END FN = X

'------------------------------------------------------------------------
'                     Main program initialization
'------------------------------------------------------------------------
MODE 2 : CLS
PRINT "PLEASE ENTER COMPLETE PATHNAME TO FILE TO BE PATCHED:"
INPUT "-> "; FILE$
A$ = MID$(FILE$,2,1) ' Check for drive specifier
LONG IF A$ = ":"
DR$ = LEFT$(FILE$,2) ' Get drive specifier from string
FILE$ = RIGHT$(FILE$, LEN(FILE$)-2)
XELSE
A$ = PATH$(0) : DR$ = LEFT$(A$,2) ' Else use default
END IF
FOR I = LEN(FILE$) TO 1 STEP -1 ' Parse filename from full pathname
A$ = MID$(FILE$,I,1)
IF A$ = "\" THEN PSN = I : I = 1
NEXT I
LONG IF PSN <> 0
PTH$ = LEFT$(FILE$,PSN-1)
XELSE
PTH$ = PATH$(0)
END IF
OLDPTH$ = PATH$(0) : CHDIR PTH$ ' Save current path and set new
FILE$ = DR$ + FILE$ ' Build file specifier
OPEN "R", 1, FILE$, 1 ' Open the file
NUM_OF_BYTES = 0

DO
READ ADRS%(NUM_OF_BYTES) ' Get the addresses of the current values
NUM_OF_BYTES = NUM_OF_BYTES + 1
UNTIL ADRS%(NUM_OF_BYTES-1) = 0
DATA &6860 'COLOR1
DATA &6865 'COLOR2
DATA &6E6F 'COLOR3
DATA &6E85 'COLOR4
DATA &6EA7 'COLOR5
DATA &6ECD 'COLOR6
DATA &6EEF 'COLOR7
DATA &6EF0 'COLOR8
DATA &88DB 'COLOR9
DATA &88E4 'COLOR10
DATA &88EE 'COLOR11
DATA &8A49 'COLOR12
DATA &8A69 'COLOR13
DATA &89F6 'COLOR14
DATA 0

' Fill menu arrays
NUM_OF_BYTES = NUM_OF_BYTES - 2
FOR I = 1 TO 4
READ MENU$(I)
NEXT I
DATA " Line Editor Prompt Line  "
DATA "  Screen Editor Colors    "
DATA " Abandon Changes and Exit "
DATA "  Save Changes and Exit   "

FOR I = 1 TO 10
READ LEP$(I)
NEXT I
DATA "LIST* ","RUN   ","LOAD  ","SAVE  ","FIND   "
DATA "EDIT   ","CONFIG","COMPILE","KEY    ","EDITOR"

FOR I = 1 TO 5
READ MENU1$(I)
NEXT I
DATA "        Increment Text Color        "
DATA "     Increment Background Color     "
DATA "      Increment Numeric Color       "
DATA " Increment Numeric Background Color "
DATA "        Return to Main Menu         "

FOR I = 1 TO 10
READ SEP1$(I)
READ SEP2$(I)
NEXT I
DATA "LOAD   ","SAVE   ","CUT    ","PASTE  "
DATA "COPY   ","REPLACE","INSERT ","DELETE "
DATA "FIND   ","FIND N ","TABS   ","AUTOTAB"
DATA "RESTORE","LLIST  ","SCROLL","SCROLL"
DATA "FREEZE","FREEZE","EXIT  ","NEW   "

FOR I = 1 TO 12
READ MENU2$(I)
NEXT I
DATA "         Increment Border Color         "
DATA "      Increment Current Line Color      "
DATA "    Increment Non-Current Line Color    "
DATA "    Increment Warning Message Color     "
DATA "    Increment Load/Save Prompt Color    "
DATA "   Increment Load/Save Response Color   "
DATA "   Increment Function Key Text Color    "
DATA " Increment ALT-Function Key Text Color  "
DATA "  Increment Function Key Numeral Color  "
DATA "         Increment FILE: Color          "
DATA " Increment Memory Remaining Value Color "
DATA "          Return to Main Menu           "

FOR I = 0 TO NUM_OF_BYTES
RECORD #1, ADRS%(I)-&100 ' Get current values from file
READ #1, A$;1
BYTES(I) = ASC(A$)
NEXT I
CLOSE #1

'------------------------------------------------------------------------
'                             Main menu
'------------------------------------------------------------------------
Line = 1
FN MAINMENU ' Put up the first menu screen
QUIT = 0
DO
A$ = FN MENUKY$(27,2,5,MENU$(Line)) ' Get a keypress
SELECT ASC(A$)
CASE 72, 75 ' Up arrow or left arrow
Line = Line - 1 : IF Line < 1 THEN Line = 4
CASE 80, 77 ' Down arrow or right arrow
Line = Line + 1 : IF Line > 4 THEN Line = 1
CASE 13, 32 ' Return or Space
LineSave = Line
ON Line GOSUB "LINE","SCREEN","ABANDON","DONE"
IF QUIT THEN "SKIP"
Line = LineSave
FN MAINMENU ' Refresh the main menu screen
"SKIP"
END SELECT
UNTIL QUIT
COLOR ,7 : CLS
CHDIR OLDPTH$ ' Restore previous path
END

'------------------------------------------------------------------------
'                Line editor function key prompt colors
'------------------------------------------------------------------------
"LINE"
COLOR ,7 : CLS : GOSUB "PUT FNKEYS" ' Simulate function key prompts
COLOR ,7
FOR I = 1 TO 5 : ' Put menu on screen
PRINT @(22,I*2+3) MENU1$(I)
NEXT I
Line = 1
QUIT = 0
DO
A$ = FN MENUKY$(22,2,5,MENU1$(Line)) ' Get a keypress
SELECT ASC(A$)
CASE 72, 75 ' Up arrow or left arrow
Line = Line - 1 : IF Line < 1 THEN Line = 5
CASE 80, 77 ' Down arrow or right arrow
Line = Line + 1 : IF Line > 5 THEN Line = 1
CASE 13, 32 ' Return or Space
ON Line GOSUB "LINE1","LINE2","LINE3","LINE4","LINE EXIT"
END SELECT
UNTIL QUIT
QUIT = 0 : RETURN

"LINE1" ' Increment function key text color
Y = BYTES(0) AND &0F
Y = Y + 1 : IF Y > 15 THEN Y = 0
BYTES(0) = (BYTES(0) AND &F0) OR Y
GOSUB "PUT FNKEYS"
RETURN

"LINE2" ' Increment function key background color
Y = (BYTES(0) AND &F0) >> 4
Y = Y + 1 : IF Y > 15 THEN Y = 0
BYTES(0) = (BYTES(0) AND &0F) OR (Y << 4)
GOSUB "PUT FNKEYS"
RETURN

"LINE3" ' Increment function key number color
Y = BYTES(1) AND &0F
Y = Y + 1 : IF Y > 15 THEN Y = 0
BYTES(1) = (BYTES(1) AND &F0) OR Y
GOSUB "PUT FNKEYS"
RETURN

"LINE4" ' Increment function key number background color
Y = BYTES(1) AND &F0
Y = Y + 16 : IF Y > 256 THEN Y = 0
BYTES(1) = (BYTES(1) AND &0F) OR Y
GOSUB "PUT FNKEYS"
RETURN

"LINE EXIT" ' Back to the main menu
QUIT = 1 : RETURN

"PUT FNKEYS" ' Simulate line editor function key prompt
LOCATE 0,24,0
FOR I = 1 TO 10
A$ = RIGHT$(STR$(I),1)
COLOR ,BYTES(1)
PRINT A$;
COLOR ,BYTES(0)
PRINT LEP$(I);
NEXT I
RETURN

'------------------------------------------------------------------------
'                   Full screen editor screen colors
'------------------------------------------------------------------------
"SCREEN"
COLOR ,7 : CLS
GOSUB "PAINT SCREEN" ' Simulate screen editor screen
COLOR ,7
FOR I = 1 TO 12 : ' Print the menu
PRINT @(20,I+2) MENU2$(I)
NEXT I
Line = 1 : QUIT = 0
DO
A$ = FN MENUKY$(20,1,4,MENU2$(Line))
SELECT ASC(A$)
CASE 72, 75 ' Up arrow or left arrow
Line = Line - 1 : IF Line < 1 THEN Line = 12
CASE 80, 77 ' Down arrow or right arrow
Line = Line + 1 : IF Line > 12 THEN Line = 1
CASE 13, 32 ' Return or Space
ON Line GOSUB "S1","S2","S3","S4","S5","S6","S7","S8","S9","S10","S11","S12"
END SELECT
UNTIL QUIT
QUIT = 0 : RETURN

"S1" ' Increment border color
BYTES(2) = BYTES(2) + 1
IF BYTES(2) > 7 THEN BYTES(2) = 0
GOSUB "PAINT SCREEN"
RETURN

"S2" ' Increment current line color
BYTES(3) = BYTES(3) + 1
IF BYTES(3) > 15 THEN BYTES(3) = 0
COLOR ,BYTES(3) : PRINT @(0,19) "10 REM This is the current cursor line"
COLOR ,7 : RETURN

"S3" ' Increment non-current line color
BYTES(4) = BYTES(4) + 1
IF BYTES(4) > 15 THEN BYTES(4) = 0
COLOR ,BYTES(4) : PRINT @(0,20) "20 REM This is not the current line"
COLOR ,7 : RETURN

"S4" ' Increment warning message color
BYTES(5) = FN Increment(BYTES(5))
COLOR ,BYTES(5) : PRINT @(60,21) "Warning message"
COLOR ,7 : RETURN

"S5" ' Increment Load/Save prompt color
BYTES(6) = FN Increment(BYTES(6))
COLOR ,BYTES(6) : PRINT @(0,21) "Enter filename to load [.BAS]:";
COLOR ,7 : RETURN

"S6" ' Increment Load/Save response color
BYTES(7) = FN Increment(BYTES(7))
COLOR ,BYTES(7) : PRINT @(31,21) "CONFIG.BAS";
PRINT @(6,22) "CONFIG.BAS";
COLOR ,7 : RETURN

"S7" ' Increment function key text color
BYTES(8) = FN Increment(BYTES(8))
GOSUB "PUT KEYS"
COLOR ,7 : RETURN

"S8" ' Increment ALT-function key text color
BYTES(9) = FN Increment(BYTES(9))
GOSUB "PUT ALTKEYS"
COLOR ,7 : RETURN

"S9" ' Increment function key number color
BYTES(10) = FN Increment(BYTES(10))
GOSUB "PUT KEYS" : GOSUB "PUT ALTKEYS"
COLOR ,7 : RETURN

"S10" ' Increment "FILE:" message color
BYTES(11) = FN Increment(BYTES(11))
COLOR ,BYTES(11) : PRINT @(0,22) "FILE:";
PRINT @(66,22) "MEMORY:";
COLOR ,7 : RETURN

"S11" ' Increment memory remaining color
BYTES(12) = FN Increment(BYTES(12))
COLOR ,BYTES(12) : PRINT @(74,22) "65535";
COLOR ,7 : RETURN

"S12" ' Back to the main menu
QUIT = 1 : RETURN

"PAINT SCREEN"
COLOR ,,BYTES(2) : BACKGROUND = BYTES(2)
FOR I = 5 TO 12
BYTES(I) = (BYTES(I) AND &0F) OR (BACKGROUND << 4)
NEXT I
GOSUB "PUT ALTKEYS"
GOSUB "PUT KEYS"
LOCATE 0,22,0
COLOR ,BYTES(11)
PRINT SPACE$(80);
PRINT @(0,22) "FILE: ";
PRINT @(66,22) "MEMORY: ";
COLOR ,BYTES(7) : PRINT @(6,22) "CONFIG.BAS";
COLOR ,BYTES(12) : PRINT @(74,22) "65535";
COLOR ,BYTES(6) : PRINT @(0,21) SPACE$(80);
PRINT @(0,21) "Enter filename to load [.BAS]: ";
COLOR ,BYTES(7) : PRINT "CONFIG.BAS";
COLOR ,BYTES(5) : PRINT @(60,21) "Warning message";
COLOR ,BYTES(3) : PRINT @(0,19) "10 REM This is the current cursor line"
COLOR ,BYTES(4) : PRINT @(0,20) "20 REM This is not the current line"
RETURN

"PUT KEYS"
COLOR ,BYTES(8) : PRINT @(0,23) SPACE$(80);
LOCATE 0,23,0
FOR I = 1 TO 10
COLOR ,BYTES(10)
A$ = RIGHT$(STR$(I),1)
PRINT A$;
COLOR ,BYTES(8)
PRINT SEP1$(I);
NEXT I
RETURN

"PUT ALTKEYS"
LOCATE 0,24,0
FOR I = 1 TO 10
COLOR ,BYTES(10)
A$ = RIGHT$(STR$(I),1)
PRINT A$;
COLOR ,BYTES(9)
PRINT SEP2$(I);
NEXT I
RETURN

'------------------------------------------------------------------------
'                   Abandon changes and quit program
'------------------------------------------------------------------------
"ABANDON"
QUIT = 1 : RETURN

'------------------------------------------------------------------------
'                    Save changes and quit program
'------------------------------------------------------------------------
"DONE"
OPEN "R", 1, FILE$, 1 ' Open the file with 1-byte long records
FOR I = 0 TO NUM_OF_BYTES
RECORD #1, ADRS%(I) - &100
A$ = CHR$(BYTES(I))
WRITE #1, A$;1
NEXT I
CLOSE #1
QUIT = 1 : RETURN

'------------------------------------------------------------------------
'                           End of program
'------------------------------------------------------------------------

