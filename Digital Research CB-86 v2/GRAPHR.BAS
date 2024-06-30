REM	THIS IS A DEMONSTRATION PROGRAM FOR DRAWING
REM	PIE AND BAR CHARTS.
REM
REM	PROGRAM NAME: GRAPHR.BAS
REM
	%INCLUDE GRAPHCOM.BAS
	GRAPHIC OPEN 1
	CLEAR

	REM	If the device supports color fill, MAT FILL
	REM	statements are used. Otherwise, MAT PLOT
	REM	is used to draw figures.

IN.FL:	INPUT "DOES THIS DEVICE SUPPORT COLOR FILL? Y/N: ";FILL.FLG$
	IF FILL.FLG$ = "Y" OR FILL.FLG$ = "N" THEN GOTO OK.FL
	PRINT "ENTER Y OR N, PLEASE"
	GOTO IN.FL
OK.FL:	PRINT "THANK-YOU"

	REM	Initialize the arrays used for drawing the
	REM	slices in the pie chart. Two 100 element arrays
	REM	are constructed for drawing a full circle. Each
	REM	point in the arrays then represents one percent.

	PRINT "CALCULATING OCCURRING --- PLEASE WAIT"
	DIM X.ARRAY(100)
	DIM Y.ARRAY(100)
	DIM A.ARRAY(72)
	DIM B.ARRAY(72)
	A.ARRAY(0) = .5
	B.ARRAY(0) = .5
	L.CIR = 0
	FOR I.ANGLE = 0 TO 6.28-.0628 STEP .0628
		X.ARRAY(L.CIR) = .5 + (.5 * COS(I.ANGLE))
		Y.ARRAY(L.CIR) = .5 + (.5 * SIN(I.ANGLE))
		L.CIR = L.CIR + 1
		NEXT I.ANGLE

	REM	Close the circle

	X.ARRAY(L.CIR) = X.ARRAY(0)
	Y.ARRAY(L.CIR) = Y.ARRAY(0)
	GOTO START.IT

	REM	This function draws a slice beginning at the
	REM	point represented by BEG.PER and extending
	REM	through PER.CENT points. The color is set to
	REM	COL.OR and the ASCII.ID prints as an identifier
	REM	for the slice.

	REM	The function extracts the points from X.ARRAY
	REM	and Y.ARRAY and places them in A.ARRAY and
	REM	B.ARRAY. MAT FILL and MAT PLOT always begin
	REM 	drawing at the first elements of the arrays, so
	REM	the slice must be extracted from the arrays.

	REM	The function makes provision for slices that
	REM	exceed 71 points. MAT FILL and MAT PLOT allow
	REM 	a maximum element number of 72.

DEF DRAW.SLICE (BEG.PER,PER.CENT,COL.OR,ASCII.ID)
	REAL BEG.PER,PER.CENT,COL.OR
	STRING ASCII.ID
	L.CIR = 1
	SET COLOR COL.OR
	OVR.FLOW = 0

	REM	Setup for slices greater than 71 percent.

	IF PER.CENT > 71 THEN SAVE.PER = 71:OVR.FLOW = 1\
		ELSE SAVE.PER = PER.CENT

	REM	Extract points from circle array.

BAK.UP:	FOR CNT.ER = BEG.PER TO BEG.PER + SAVE.PER
		IN.DEX = CNT.ER
		IF CNT.ER > 100 THEN IN.DEX = CNT.ER - 100
		A.ARRAY(L.CIR) = X.ARRAY(IN.DEX)
		B.ARRAY(L.CIR) = Y.ARRAY(IN.DEX)
		L.CIR = L.CIR + 1
		NEXT CNT.ER

	REM	OVER.FLOW is 1 for a more than 71 percent slice.

	IF OVR.FLOW <> 1 THEN GOTO OVER.A

	REM	FILL.FLG$ is "N" for non-color-fill devices.

	IF FILL.FLG$ = "N" THEN MAT PLOT L.CIR-1: A.ARRAY,B.ARRAY\
		ELSE MAT FILL L.CIR-1: A.ARRAY,B.ARRAY
	OVR.FLOW = 0
	BEG.PER = BEG.PER + 71
	SAVE.PER = PER.CENT - 71
	IF FILL.FLG$ = "N" THEN L.CIR = 0 ELSE L.CIR = 1
	GOTO BAK.UP
OVER.A:	A.ARRAY(0) = .5
	B.ARRAY(0) = .5

	REM	The slice must be closed for MAT PLOT. MAT FILL
	REM	closes automatically.

	IF FILL.FLG$ = "N" THEN\
		A.ARRAY(L.CIR) = .5: \
		B.ARRAY(L.CIR) = .5: \
		MAT PLOT L.CIR: A.ARRAY,B.ARRAY \
		ELSE \
		MAT FILL L.CIR-1: A.ARRAY,B.ARRAY

	REM	Expand the viewport for printing the slice ID.
	REM	The minimum character height is used to adjust
	REM	the window so the slice ID will appear outside
	REM	the slice perimeter.

	SET VIEWPORT 1.0-Y.AXIS,1,0,1
	ADJ.IT = MIN.HGT/1.45
	SET WINDOW -ADJ.IT,1+ADJ.IT,-ADJ.IT,1+ADJ.IT

	REM	MID.PT is the center elements in the slice. This
	REM	is the position where the ID is printed.

	MID.PT = INT(BEG.PER+(PER.CENT/2))
	X.AXIS = X.ARRAY(MID.PT)
	Y.AXIS = Y.ARRAY(MID.PT)
	GRAPHIC PRINT AT (X.AXIS,Y.AXIS): ASCII.ID
	SET WINDOW 0,1,0,1
	RETURN
FEND

	REM	The first portion of the program allows entry
	REM	of up to 9 slices. Enter the item number (1-9)
	REM	and press the return key. Then type the slice
	REM	description (up to 6 characters), the dollar
	REM	value of the slice, and the color code for 
	REM	the slice.

	REM	The following entries are a good sample:

	REM	1 <return>
	REM	RENT,550,1 <return>
	REM	2 <return>
	REM	FOOD,450,2 <return>
	REM	3 <return>
	REM	CAR,225,3 <return>
	REM	4 <return>
	REM	OTHER,750,4 <return>

	REM	This sets up a graph of four items--rent of
	REM	$550 in color 1, food for $450 in color 2, etc.

	REM	Terminate the input by typing 0 in response
	REM	to the ITEM NUMBER(0 TO FINISH): prompt.

	REM	After the 0 entry, the program calculates the 
	REM	percentages and prints a listing of the entries.

	REM	Corrections may be made by entering the
	REM	item number to be corrected and inputting
	REM	the correct data.

START.IT: PRINT
	DIM ITM.DESC$(9)
	DIM ITM.VALUE(9)
	DIM ITM.COLOR(9)
	DIM ITM.PERC(9)
GO.A:	PRINT "ENTER AN ITEM NUMBER FROM 1 TO 9 TO ADD OR CHANGE"
	PRINT
	PRINT "THEN ENTER--DESCRIPTION,AMOUNT,COLOR,RETURN"
	PRINT
	PRINT "  DESCRIPTION IS THE SLICE DESCRIPTION"
	PRINT "  AMOUNT IS THE QUANTITY/AMOUNT OF THE SLICE"
	PRINT "  COLOR IS THE COLOR NUMBER TO USE FOR THE SLICE"
	PRINT "  RETURN MEANS TO PRESS THE RETURN KEY"
	PRINT
	PRINT "THE FIELDS ARE SEPARATED BY COMMAS"
	PRINT
IN.IT:	INPUT "ITEM NUMBER(0 TO FINISH): "; ITM.NUMBER%
	IF ITM.NUMBER% = 0 THEN GOTO PRT.EM
	IF ITM.NUMBER% > 0 AND ITM.NUMBER% < 10 THEN GOTO OKAY.IN
		PRINT "THE ITEM NUMBER MUST BE FROM 1 TO 9"
	GOTO IN.IT
OKAY.IN: IF ITM.VALUE(ITM.NUMBER%) = 0 THEN GOTO NEW.IN
	PRINT ITM.DESC$(ITM.NUMBER%),ITM.VALUE(ITM.NUMBER%),
	PRINT ITM.COLOR(ITM.NUMBER%)
NEW.IN:	INPUT "DESC,AMOUNT,COLOR: ";DESC.IN$,VAL.IN,CLR.IN%
	ITM.DESC$(ITM.NUMBER%) = DESC.IN$
	ITM.VALUE(ITM.NUMBER%) = VAL.IN
	ITM.COLOR(ITM.NUMBER%) = CLR.IN%
	PRINT
	GOTO IN.IT
PRT.EM:	TOT.VAL = 0

	REM	Calculate the total for percentages.

	FOR CNT.R = 1 TO 9
		TOT.VAL = TOT.VAL + ITM.VALUE(CNT.R)
		NEXT CNT.R
	PRINT

	REM	Print the item list with percentages.

	FOR CNT.R = 1 TO 9
		IF ITM.VALUE(CNT.R) <> 0 THEN\
			ITM.PERC(CNT.R) = ITM.VALUE(CNT.R)/TOT.VAL:\
			ITM.PERC(CNT.R) = INT((100*ITM.PERC(CNT.R))+.5):\
			PRINT CNT.R;"-";ITM.DESC$(CNT.R),ITM.VALUE(CNT.R),:\
			PRINT ITM.COLOR(CNT.R);" ";ITM.PERC(CNT.R);"%"
		NEXT CNT.R
	PRINT:PRINT "TOTAL VALUE: ";TOT.VAL
	PRINT:INPUT "DRAW THE GRAPH? ";Y.N$
	IF Y.N$ <> "Y" THEN GOTO IN.IT
	CLEAR
	BEG.PER = 0

	REM	THE MINIMUM CHARACTER HEIGHT FOR THE DEVICE
	REM	IS USED TO ESTABLISH A BORDER AROUND THE CIRCLE
	REM	WHERE THE SLICE ID (THE ITEM NUMBER) CAN BE
	REM	PRINTED.

	SET CHARACTER HEIGHT 0
	ASK CHARACTER HEIGHT MIN.HGT
	MIN.HGT = 2 * MIN.HGT
	FOR CNT.R = 1 TO 9
		IF ITM.VALUE(CNT.R) = 0 THEN GOTO NXT.CNT

	REM	Determine the aspect ratio and square the device.
	REM	A border is left around the viewport for the
	REM	slice ID. The viewport is set to the right
	REM	of the device.

		ASK DEVICE X.AXIS,Y.AXIS
		SET VIEWPORT 1-Y.AXIS+MIN.HGT,1-MIN.HGT,MIN.HGT,1-MIN.HGT
		DESC.IN$ = ITM.DESC$(CNT.R)
		VAL.IN = ITM.VALUE(CNT.R)
		CLR.IN% = ITM.COLOR(CNT.R)
		PER.CENT = ITM.PERC(CNT.R)
		CALL DRAW.SLICE (BEG.PER,PER.CENT,CLR.IN%,STR$(CNT.R))
		BEG.PER = BEG.PER + PER.CENT
		SET VIEWPORT 0,1,0,1
		S.1$ = DESC.IN$+" "+STR$(PER.CENT)+"%"
		GRAPHIC PRINT AT (0,1-(CNT.R/10)):S.1$
NXT.CNT:	NEXT CNT.R

	REM	Is the graph filled? The percentage calculation
	REM	can be less than 100 percent due to roundoff.

	IF BEG.PER >= 100 THEN GOTO BAR.A
	PER.CENT = 100 - BEG.PER
	DESC.IN$ = " "
	ASK DEVICE X.AXIS,Y.AXIS
	SET VIEWPORT 1-Y.AXIS+MIN.HGT,1-MIN.HGT,MIN.HGT,1-MIN.HGT
	CALL DRAW.SLICE (BEG.PER,PER.CENT,CLR.IN%,DESC.IN$)

	REM	This routine draws a simple bar chart of the
	REM	data. The window range is set to 1/3 greater
	REM	than the largest item in the array. This
	REM	technique makes the largest bar draw across
	REM	75% of the viewport.

BAR.A:	KEY%=CONCHAR%
	DIM BAR.X(4)
	DIM BAR.Y(4)
	SET VIEWPORT 0,1,0,1
	SET WINDOW 0,1,0,1
	SET CHARACTER HEIGHT 0
	ASK CHARACTER HEIGHT MIN.HGT
	CLEAR
	SET JUSTIFY .5,0
	SET COLOR 1
	GRAPHIC PRINT AT (.5,.99-MIN.HGT):"BAR CHART"
	SET JUSTIFY 0,0
	MAX.VAL = 0

	REM	Determine the maximum percentage.

	FOR CNT.R = 1 TO 9
		IF MAX.VAL < ITM.PERC(CNT.R) THEN\
			MAX.VAL = ITM.PERC(CNT.R)
		NEXT CNT.R
	MAX.VAL = 1.33 * MAX.VAL

	REM	Scale the window. The X axis is 1/3 larger
	REM	than the largest item to be graphed.
	REM	The Y axis is scaled to 10 lines.

	SET WINDOW 0,MAX.VAL,0,10
	SET CHARACTER HEIGHT 0
	ASK CHARACTER HEIGHT MIN.HGT

	REM	Draw the items.

	FOR CNT.R = 1 TO 9
		IF ITM.VALUE(CNT.R) = 0 THEN GOTO NXT.A
		SET COLOR ITM.COLOR(CNT.R)
		P.LINE = 10 - CNT.R
		S.1$ = ITM.DESC$(CNT.R)+"-"+STR$(ITM.PERC(CNT.R))+"%"
		IF ITM.VALUE(CNT.R) <> ITM.PERC(CNT.R) THEN\
			S.1$ = S.1$+" $"+STR$(ITM.VALUE(CNT.R))
		GRAPHIC PRINT AT (0,P.LINE): S.1$

	REM	Setup the BAR.X and BAR.Y arrays to draw the
	REM	bar. MAX.VAL is the percentage for the item.
	REM	The window scaling automatically scales the
	REM	bar. No special calculations are required.

		MAX.VAL = ITM.PERC(CNT.R)
		TOP = P.LINE - .1
		BOT = TOP - .4
		BAR.Y(0) = BOT
		BAR.Y(1) = TOP
		BAR.X(2) = MAX.VAL
		BAR.Y(2) = TOP
		BAR.X(3) = MAX.VAL
		BAR.Y(3) = BOT
		BAR.Y(4) = BOT
		IF FILL.FLG$ = "N" THEN MAT PLOT 4: BAR.X,BAR.Y\
			ELSE MAT FILL 3: BAR.X,BAR.Y
NXT.A:		NEXT CNT.R
		KEY% = CONCHAR%
		STOP
	END
