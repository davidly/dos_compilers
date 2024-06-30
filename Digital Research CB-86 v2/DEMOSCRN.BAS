\	********************************************
\	*  TEST PROGRAM FOR PC DOS SCREEN CONTROL  *
\	********************************************
\	*  This program was written and tested by  *
\	*  Digital  Research  Technical  Support   *
\	********************************************
	integer ROW, COL, RET, I, J
	string  PAD, SP, TL

%include PCSCRN.DEF

	TL   = string$(8,"0123456789")
	PAD  = string$(76,chr$(1))
	SP   = string$(60," ")

    def PRTCTR (S$,ROW)
	integer PRTCTR, ROW, COL
	COL = int%((79-len(S$))/2)
	call setcur(ROW,COL) : print S$;
	fend


    def TST.OK (TEST)
	integer TST.OK, TEST
	string  YN, ERR.TST
	YN = ucase$(chr$(inkey))
	if YN <> "N" then return
	on TEST goto 1,2,3,4,5,6,7,8,9,10,11,12,13
	1: ERR.TST = "CLEAR SCREEN" : goto EXIT
	2: ERR.TST = "HOME CURSOR" : goto EXIT
	3: ERR.TST = "ERASE TO END OF LINE" : goto EXIT
	4: ERR.TST = "ERASE TO END OF SCREEN" : goto EXIT
	5: ERR.TST = "SET CURSOR POSITION" : goto EXIT
	6: ERR.TST = "GET CURRENT CURSOR POSITION" : goto EXIT
	7: ERR.TST = "MOVE CURSOR UP ONE LINE" : goto EXIT
	8: ERR.TST = "MOVE CURSOR DOWN ONE LINE" : goto EXIT
	9: ERR.TST = "MOVE CURSOR RIGHT ONE COLUMN" : goto EXIT
       10: ERR.TST = "MOVE CURSOR LEFT ONE COLUMN" : goto EXIT
       11: ERR.TST = "ADD NEW LINE AND SCROLL SCREEN DOWN" : goto EXIT
       12: ERR.TST = "PRINT STRING IN REVERSE VIDEO MODE" : goto EXIT
       13: ERR.TST = "PRINT STRING IN BLINKING VIDEO MODE" : goto EXIT
     EXIT: call cls
	call prtctr("====> ABNORMAL TERMINATION <=====",10)
	   call setcur(12,10)
	   print using "TEST: [&] failed";ERR.TST
	   call setcur(23,0) : stop
	fend

    def PRT.ROW.NUM(I)
	integer I
	string  L
	L = str$(I)
	call setcur(I,0) : print using "//: ";L;
	fend

    def BLK.FILL
	integer BLK.FILL, I
	string  L
	call cls : print TL;
	for I = 1 to 23
	  call prt.row.num(I)
	  print PAD;
	next I
	fend

\	************************************
\	* (1)  TEST CLEAR SCREEN FUNCTION  *
\	************************************

	call BLK.FILL : TMP1$ = " Test CLEAR SCREEN Function "
			TMP2$ = "        press any key       "
	COL = int%((79-len(TMP1$))/2)
	call setcur(11,COL) : call prtblnk(TMP1$)
	call setcur(13,COL) : call prtrev(TMP2$)
	I = inkey
	call cls
	call prtctr(" Well, did it clear the screen? ",11)
	call TST.OK(1)

\	************************************
\	* (2)  TEST HOME CURSOR FUNCTION   *
\	************************************

	TMP1$ = " HOME CURSOR TEST "
	call setcur(11,10) : print SP;
	COL = int%((79-len(TMP1$))/2)
	call setcur(11,COL) : call prtrev(TMP1$)
	call HOME
	print " <=== Is the cursor at Row 0, Column 0 ?";
	call HOME
	call TST.OK(2)

\	***********************************
\	* (3)  TEST ERASE TO END OF LINE  *
\	***********************************

	TMP1$ = " ERASE TO END OF LINE "
	call BLK.FILL 
	COL = int%((79-len(TMP1$))/2)
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(10,4)  : call eraeol
	call setcur(11,4) : print \
	"Is the above line erased except for column # ? ";
	call TST.OK(3)

\	*************************************
\	* (4)  TEST ERASE TO END OF SCREEN  *
\	*************************************

	TMP1$ = " ERASE NEXT LINE TO END OF SCREEN "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(10,5) : print \
	" ===> hit any key to erase <=== ";
	I = inkey : call eraeos
	print "....OK ? "; : call TST.OK(4)

\	**********************************
\	* (5)  TEST SET CURSOR POSITION  *
\	**********************************

	TMP1$ = " SET CURSOR POSITION "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(9,0) : call prtrev(TL)
	call setcur(10,6) : print \
	" This message should begin with a space at Row 10, Col 6 ";
	call TST.OK(5)

\	******************************************
\	* (6)  TEST GET CURRENT CURSOR POSITION  *
\	******************************************

	TMP1$ = " GET CURRENT CURSOR POSITION "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL : COLS% = COL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(11,0) : call prtrev(TL)
	call setcur(12,15)
	print "  Hit any key to get current cursor position ";
	I = inkey  :  RET = getpos
	ROW = ret/256 : COL = ret-row*256
	call cls
	print TL;
	for I = 1 to 23
	  call prt.row.num(I)
	next I
	call setcur(2,COLS%) : call prtrev(TMP1$)
	call setcur(5,10) : print "ROW    =";ROW
	call setcur(7,10) : print "COLUMN =";COL
	call setcur(9,10)
	print "Is the above = ROW 12  COLUMN 60 ? ";
	call TST.OK(6)

\	*********************************
\	* (7)  TEST CURSOR UP FUNCTION  *
\	*********************************

	TMP1$ = " UP CURSOR COMMAND "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(5,10) : print \
	" This test will print a space on Row 10, Column 10 ";
	call setcur(6,10) : print \
	" It will then issue the UP CURSOR command          ";
	I = inkey
	call setcur(11,0) : call prtrev(TL)
	call setcur(10,10) : print " "; : call UPCUR : print \
	" This line should start with a space on Row 9, Column 11 ";
	call TST.OK(7)

\	***********************************
\	* (8)  TEST CURSOR DOWN FUNCTION  *
\	***********************************

	TMP1$ = " DOWN CURSOR COMMAND "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(5,10) : print \
	" This test will print a space on Row 10, Column 10 ";
	call setcur(6,10) : print \
	" It will then issue the DOWN CURSOR command        ";
	I = inkey
	call setcur(9,0) : call prtrev(TL)
	call setcur(10,10) : print " "; : call DWNCUR : print \
	" This line should start with a space on Row 11, Column 11 ";
	call TST.OK(8)

\	*********************************************
\	* (9)  TEST MOVING CURSOR RIGHT ONE COLUMN  *
\	*********************************************

	TMP1$ = " MOVE CURSOR RIGHT ONE COLUMN "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(5,10) : print \
	" This test will print a space on Row 10, Column 10 ";
	call setcur(6,10) : print \
	" It will then issue the CURSOR RIGHT command       ";
	I = inkey
	call setcur(9,0) : call prtrev(TL)
	call setcur(10,10) : print " "; : call CUR.RT : print \
	"This line will start on Row 10, Column 12 if OK ";
	call TST.OK(9)

\	********************************************
\	* (10) TEST MOVING CURSOR LEFT ONE COLUMN  *
\	********************************************

	TMP1$ = " MOVE CURSOR LEFT ONE COLUMN "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(5,10) : print \
	" This test will print a space on Row 10, Column 10 ";
	call setcur(6,10) : print \
	" It will then issue the CURSOR LEFT command        ";
	I = inkey : call setcur(9,0) : call prtrev(TL)
	call setcur(10,10) : print " "; : call CUR.LT : print \
	"This line will start on Row 10, Column 10 if OK ";
	call TST.OK(10)

\	*************************************************
\	* (11) TEST ADDING ONE LINE AND SCROLLING DOWN  *
\	*************************************************

	TMP1$ = " ADD LINE "
	COL = int%((79-len(TMP1$))/2)
	call BLK.FILL
	call setcur(2,COL) : call prtblnk(TMP1$)
	call setcur(5,10) : print \
	" This test will go to Row 10 and Insert a New Line ";
	call setcur(6,10) : print \
	" The 10th line and below will be scrolled down     ";
	I = inkey
	call setcur(10,0) : call ADDLINE
	call prtctr("Is this message on new line",getpos/256)
	call TST.OK(11)

\	****************************************************
\	* (12) TEST PRINTING STRING IN REVERSE VIDEO MODE  *
\	****************************************************

	call BLK.FILL : call setcur(10,4) : call ADDLINE
	TMP1$ = "     IS THIS IN REVERSE VIDEO     "
	COL = int%((79-len(TMP1$))/2)
	call setcur(10,COL) : call prtrev(TMP1$)
	call TST.OK(12)

\	*****************************************************
\	* (13) TEST PRINTING STRING IN BLINKING VIDEO MODE  *
\	*****************************************************

	call BLK.FILL : call setcur(10,5) : call ADDLINE
	call setcur(10,30) : call PRTBLNK("IS THIS BLINKING")
	call TST.OK(13)


	DS$  = " ***************************************"
	MSG$ = "====>  T E S T   C O M P L E T E  <===="
	call cls 
	H$ = chr$(6)
	HL$ = string$(78,H$)
	call setcur(1,1) : call prtblnk(HL$)
	for I = 2 to 21
	  call setcur(I,1) : call prtblnk(H$)
	  call setcur(I,78) : call prtblnk(H$)
	next I
	call setcur(22,1) : call prtblnk(HL$)

	call setcur(2,2) : print left$(HL$,76);
	for I = 3 to 20
	  call setcur(I,2) : print H$;
	  call setcur(I,77) : print H$;
	next I
	call setcur(21,2) : print left$(HL$,76);

	call prtctr(DS$,9)
	COL = int%((79-len(MSG$))/2)
	call setcur(10,COL) : call prtrev(MSG$)
	call prtctr(DS$,11)
	call setcur(23,0)
	stop
end
