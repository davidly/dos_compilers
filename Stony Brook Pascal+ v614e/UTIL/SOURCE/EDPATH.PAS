PROGRAM edpath;
{$M 4096, 0, 0}

USES Dos;

CONST
    PathName	: ARRAY [0..4] OF CHAR = 'PATH=';
TYPE
    EnvArray	= ARRAY [0..32767] OF CHAR;
VAR
    EnvEnd	: WORD;
    Environment	: ^EnvArray;
    
    PathStart	: WORD;
    PathEnd	: WORD;
    
    Path	: STRING;

FUNCTION GetPath() : BOOLEAN;
VAR
    done	: BOOLEAN;
    adr		: ^WORD;
    owner	: WORD;
    envSeg	: WORD;
    i, j	: WORD;
    size	: WORD;
    matched	: BOOLEAN;
BEGIN
    GetPath := FALSE;
    
    adr := Ptr(0, $2E * 4 + 2);
    
    (* 2Eh points to command.com *)
    
    owner := adr^;
    
    (* now get environment segment of command.com *)
    
    adr := Ptr(owner, $2C);
    
    envSeg := adr^;
    IF envSeg = 0 THEN BEGIN
	WriteLn('...zero envSeg method...');
	adr := Ptr(owner-1, 3);
	envSeg := owner + adr^ + 1;
    END;
    
    (* get length of env segment by looking at MCB datastructure *)
    
    adr := Ptr(envSeg-1, 3);

    EnvEnd := adr^ * 16 - 1;
    
    Environment := Ptr(envSeg, 0);
    
    (* now search for PATH *)
    
    i := 0;
    
    WHILE Environment^[i] <> #0 DO BEGIN
	matched := TRUE;
	j := 0;
	PathStart := i;
	done := FALSE;
	REPEAT
	    IF j = 4 THEN
		done := TRUE
	    ELSE IF Environment^[i] = '=' THEN BEGIN
		matched := FALSE;
		done := TRUE;
	    END ELSE IF PathName[j] <> Environment^[i] THEN BEGIN
		matched := FALSE;
		done := TRUE;
	    END ELSE BEGIN
		INC(i);
		INC(j);
	    END;
	UNTIL done;

	IF matched THEN BEGIN
	    IF Environment^[i] = '=' THEN BEGIN
		REPEAT
		    INC(I);
		UNTIL Environment^[i] = #0;
		PathEnd := i;
		size := PathEnd-PathStart-4;
		IF size > 255 THEN BEGIN
		    WriteLn('Path too large');
		    EXIT;
		END;
		Move(Environment^[PathStart+5], Path[1], size);
		
		(* don't want the null term for now *)
		
		BYTE(Path[0]) := BYTE(size-1);
		GetPath := TRUE;
		EXIT;
	    END;
	END;

	WHILE Environment^[i] <> #0 DO
	    INC(i);
	INC(i);
    END;
    WriteLn('...could not find PATH...');
END;

PROCEDURE SetPath;
VAR
    i : WORD;
BEGIN
    Move(Environment^[PathEnd+1], Environment^[PathStart], EnvEnd-PathEnd+1);
    
    (* find the double zero *)
    
    i := 0;
    WHILE Environment^[i] <> #0 DO BEGIN
	REPEAT
	    INC(i);
	UNTIL Environment^[i] = #0;
	INC(i);
    END;
    
    Move(PathName, Environment^[i], 5);
    Move(Path[1], Environment^[i+5], ORD(Path[0]));
    FOR i := i + 5 + ORD(Path[0]) TO EnvEnd DO
	Environment^[i] := #0;
END;

PROCEDURE Position(x, y : WORD);
VAR
    R : REGISTERS;
BEGIN
    R.AH := 2;
    R.BH := 0;
    R.DH := BYTE(Y);
    R.DL := BYTE(X);
    INTR($10, R);
END;

PROCEDURE WriteLn;
VAR
    R : REGISTERS;
BEGIN
    R.AH := $E;
    R.AL := 13;
    R.BX := 7;
    INTR($10, R);

    R.AH := $E;
    R.AL := 10;
    R.BX := 7;
    INTR($10, R);
END;

FUNCTION GetKey() : WORD;
VAR
    R : REGISTERS;
BEGIN
    R.AH := 0;
    INTR($16, R);
    IF R.AL = 0 THEN BEGIN
	GetKey := 256 + ORD(R.AH);
    END ELSE
	GetKey := ORD(R.AL);
END;


FUNCTION EditPath() : BOOLEAN;
CONST
    LeftArrow	= 331;
    RightArrow	= 333;
    HomeKey	= 327;
    EndKey	= 335;
    Ins		= 338;
    Del		= 339;
    
    maxCol	= 79;
TYPE
    ScreenArray	= ARRAY [0..160] OF CHAR;
VAR
    insmode	: BOOLEAN;
    xPos	: WORD;	(* screen x*)
    yPos	: WORD;	(* screen y *)
    l		: WORD;	(* length *)
    x		: WORD;	(* cursor position *)
    i		: WORD;	(* string position *)
    startPos	: WORD;	(* displayed part *)
    endPos	: WORD;	(* displayed part *)
    key		: WORD;
    ch		: CHAR;
    k		: WORD;
    R		: REGISTERS;
    Screen	: ^ScreenArray;
    biosMode	: BYTE ABSOLUTE $40:$49;
BEGIN
    EditPath := FALSE;
    
    WriteLn;
    
    R.AH := 3;
    R.BH := 0;
    INTR($10, R);
    xPos := ORD(R.DL);
    yPos := ORD(R.DH);
    
    
    IF biosMode = 7 THEN
	Screen := Ptr($B000, 0)
    ELSE
	Screen := Ptr($B800, 0);
    WORD(Screen) := yPos*160 + xPos*2;
    
    i := 0;
    x := 0;
    insmode := TRUE;
    WHILE TRUE DO BEGIN
	l := Length(Path);
	startPos := 0;
	endPos := l;
	IF l > maxCol THEN BEGIN
	    startPos := i - x;
	    IF startPos+maxCol > l THEN
		startPos := startPos - (maxCol-startPos);
	    endPos := startPos + maxCol;
	END;
	
	FOR k := 0 TO maxCol DO BEGIN
	    IF startPos+k < endPos THEN
		Screen^[k*2] := Path[startPos+k+1]
	    ELSE
		Screen^[k*2] := ' ';
	END;

	Position(xPos+x, yPos);
	
	key := GetKey();
	ch := CHAR(key);
	
	CASE key OF
	8:
	BEGIN
	    IF i <> 0 THEN BEGIN
		DEC(i);
		Delete(Path, i+1, 1);
		IF l <= maxCol THEN
		    DEC(x);
	    END;
	END;
	Del:
	BEGIN
	    IF (l <> 0) AND (l <> i) THEN
		Delete(Path, i+1, 1);
	END;
	27:
	    EXIT;
	LeftArrow:
	BEGIN
	    IF i > 0 THEN BEGIN
		IF x > 0 THEN
		    DEC(x);
		DEC(i);
	    END;
	END;
	RightArrow:
	BEGIN
	    IF i < l THEN BEGIN
		IF x < maxCol THEN
		    INC(x);
		INC(i);
	    END;
	END;
	HomeKey:
	BEGIN
	    x := 0;
	    i := 0;
	END;
	EndKey:
	BEGIN
	    IF l > maxCol THEN
		x := maxCol
	    ELSE
		x := l;
	    i := l;
	END;
	Ins:
	    insmode := NOT insmode;
	13:
	BEGIN
	    BYTE(Path[0]) := l+1;
	    Path[l+1] := #0;
	    EditPath := TRUE;
	    EXIT;
	END;
	ELSE
	    IF (key < 255) AND (l < 255) THEN BEGIN
		IF insmode THEN
		    Insert(ch, Path, i+1)
		ELSE BEGIN
		    Path[i+1] := ch;
		    IF (i = l) AND (i < 254) THEN
		       Path[i+2] := #0;
		END;
		INC(x);
		INC(i);
	    END;
	END;
    END;
END;

BEGIN
    IF GetPath() THEN BEGIN
	IF EditPath() THEN BEGIN
	    WriteLn;
	    SetPath;
	END;
    END;
END.
