PROGRAM hRand;

{ $DEFINE Storage}

{$IFDEF Storage}

{$M 4096, 0, 0}

Uses Dos, Storage;

{$ELSE}

{$M 4096}

Uses Dos;

{$ENDIF}

CONST
    Max	= 4;
TYPE
    Sizes = (Sixteen, NinetySix, SixtyFour, Eighty, Forty);
CONST
    MaxIter = 200;
    MaxElements = 2000;
    Blocks : ARRAY [Sizes] OF WORD = (16, 96, 64, 80, 40);

    cString16 : STRING[15] =
 'aaaaaaaaaaaaaaa';
    cString40 : STRING[39] =
 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
    cString64 : STRING[63] =
 'ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
    cString80 : STRING[79] =
 'ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';
    cString96 : STRING[95] =
 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee';

TYPE
    StringData	= STRING[95];
    StringType = ^StringData;

    ElementRec = RECORD
		   used : BOOLEAN;
		   size : Sizes;
		   adr : POINTER;
		 END;
VAR
    Stor : ARRAY [1..MaxElements] OF ElementRec;
    str, str2 : StringType;
    index : WORD;
    sentinel : WORD;
    iter : WORD;
    i, j : WORD;
    done : BOOLEAN;
    ch : CHAR;

CONST
    Top	= 55;
VAR
    ri		: WORD;
    rj		: WORD;
    OldStuff	: ARRAY [1..Top] OF WORD;
    
PROCEDURE Randomize(seed : WORD);
VAR
    r : REGISTERS;
    k : WORD;
BEGIN
    IF seed = 0 THEN BEGIN
	r.AH := $2C;
	INTR($21, r);
	seed := r.DX + r.CX;
    END;
    OldStuff[1] := seed;
    FOR k := 2 TO Top DO
	OldStuff[k] := OldStuff[k-1] * 9821 + 1;
    ri := 1;
    rj := 33;
END;

(* return 0..range-1 *)

FUNCTION Rnd(range : WORD) : WORD;
BEGIN
    INC(ri);
    INC(rj);
    IF ri > Top THEN
        ri := 1;
    IF rj > Top THEN
	rj := 1;
    OldStuff[ri] := OldStuff[ri] + OldStuff[rj];
    IF range = 0 THEN
	Rnd := OldStuff[ri]
    ELSE
	Rnd := OldStuff[ri] MOD range;
END;

(* returns low..high, including low and high *)

FUNCTION Random(low, high : WORD) : WORD;
BEGIN
    Random := low + Rnd(high - low + 1);
END;

BEGIN
    Randomize(999);
    {$IFDEF Storage}
    StorageInit;
    {$ENDIF}

    FOR i := 1 TO MaxElements DO BEGIN
	WITH Stor[i] DO BEGIN
	    size := Sizes(Random(0, Max));
	    GetMem(adr, Blocks[size]);
	    used := TRUE;
	    {$IFDEF TEST}
		CASE size OF
		    Sixteen:
			str := ADDR(cString16);
		    Forty:
			str := ADDR(cString40);
		    SixtyFour:
			str := ADDR(cString64);
		    Eighty:
			str := ADDR(cString80);
		    NinetySix:
			str := ADDR(cString96);
		END;
		Move(str^, adr^, Blocks[size]);
	    {$ENDIF}
	END;
    END;

    FOR iter := 1 TO MaxIter DO BEGIN
	Write('.');
	FOR i := 1 TO Random(MaxElements DIV 3, MaxElements DIV 4 * 3) DO BEGIN
	    index := Random(1, MaxElements);
	    sentinel := index;
	    done := FALSE;
	    REPEAT
		WITH Stor[index] DO BEGIN
		    IF used THEN BEGIN
			{$IFDEF TEST}
			str := adr;
			CASE size OF
			    Sixteen:
				str2 := ADDR(cString16);
			    Forty:
				str2 := ADDR(cString40);
			    SixtyFour:
				str2 := ADDR(cString64);
			    Eighty:
				str2 := ADDR(cString80);
			    NinetySix:
				str2 := ADDR(cString96);
			END;
			IF str^ <> str2^ THEN BEGIN
			    Write(#7);
			    HALT;
			END;
			{$ENDIF}
			FreeMem(adr, Blocks[size]);
			used := FALSE;
			done := TRUE;
		    END;
		END;
		INC(index);
		IF index > MaxElements THEN
		    index := 1;
	    UNTIL (sentinel = index) OR done;
	    IF NOT done THEN BEGIN
		Write(#7#7#7);
		HALT;
	    END;
	END;

	FOR i := 1 TO MaxElements DO BEGIN
	    WITH Stor[i] DO BEGIN
		IF NOT used THEN BEGIN
		    size := Sizes(Random(0, Max));
		    GetMem(adr, Blocks[size]);
		    used := TRUE;
		    {$IFDEF TEST}
			CASE size OF
			    Sixteen:
				str := ADDR(cString16);
			    Forty:
				str := ADDR(cString40);
			    SixtyFour:
				str := ADDR(cString64);
			    Eighty:
				str := ADDR(cString80);
			    NinetySix:
				str := ADDR(cString96);
			END;
			Move(str^, adr^, Blocks[size]);
		    {$ENDIF}
		END;
	    END;
	END;
    END;
END.
