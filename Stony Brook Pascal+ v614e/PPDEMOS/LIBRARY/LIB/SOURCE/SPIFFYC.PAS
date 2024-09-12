UNIT SpiffyC;

(*$//NOMODINIT*)

INTERFACE

USES DOS;

VAR
    SpiffyStatus : INTEGER PUBLIC 'SpiffyStatus';

PROCEDURE SpiffyIn
    (channel : INTEGER; VAR str; VAR size : INTEGER)
    [C]; FAR; EXTERNAL 'SpiffyIn';

PROCEDURE SpiffyOut
    (channel : INTEGER; VAR str)
    [C]; FAR; EXTERNAL 'SpiffyOut';

IMPLEMENTATION    

TYPE
    StringType = ARRAY [0..255] OF CHAR;
    StringTypePtr = ^StringType;

PROCEDURE SpiffyIn (channel : INTEGER; VAR str; VAR size : INTEGER)
	[REVERSED, LEAVES, ALTERS(AX, BX, CX, DX, ES)];
    VAR
        R : REGISTERS;
    BEGIN
    
        (* do a dos read function *)
	
        R.AH := $3F;
	R.BX := channel;
	R.DX := Ofs(str);
	R.DS := Seg(str);
	R.CX := 255;
	INTR($21, R);
	
	(* check the status *)
	
	IF 1 AND R.FLAGS <> 0 THEN
	    BEGIN

		(* carry on, set the status and return 0 size *)
		
		SpiffyStatus := R.AX;
		size := 0
	    END
	ELSE
	    BEGIN

		(* successful read, return the size read, and set status to 0 *)
		
		size := R.AX;
		SpiffyStatus := 0
	    END;
	
	(* add a terminator to the string *)
	
	StringTypePtr(str)^[size] := #0;
    END;
    
PROCEDURE SpiffyOut (channel : INTEGER; VAR str)
	[REVERSED, LEAVES, ALTERS(AX, BX, CX, DX, ES)];

    VAR
        R : REGISTERS;
    BEGIN

        (* do the dos write function *)
	
        R.AH := $40;
	R.BX := channel;
	R.DX := Ofs(str);
	R.DS := Seg(str);
	R.CX := 0;
	REPEAT
	    INC(R.CX);
	UNTIL StringTypePtr(str)^[R.CX] = #0;
	INTR($21, R);
	
	(* set status to 0 if good, status if bad *)
	
	IF 1 AND R.FLAGS <> 0 THEN
	    SpiffyStatus := R.AX
	ELSE
	    SpiffyStatus := 0
    END;
    
END.
