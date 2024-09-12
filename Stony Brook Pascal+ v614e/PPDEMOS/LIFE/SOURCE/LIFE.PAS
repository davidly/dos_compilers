PROGRAM life;

USES DOS;

CONST
    Black	= 0;
    Green	= 2;
    Red		= 4;
    LightGray	= 7;
    
TYPE
    WordSet	= SET OF 0..15;
    World	= ARRAY [0..26] OF ARRAY [0..5] OF WordSet;
    Screen	= ARRAY [1..25, 1..80] OF
			RECORD
			    ch	: CHAR;
			    at  : CHAR;
			END;
VAR
    State	: World;
    Next	: World;
    
    OffColor	: BYTE;
    OnColor	: BYTE;
    
    Scr		: ^Screen;

PROCEDURE UpdateScreen;
VAR
    i, j : WORD;
BEGIN
    FOR i := 1 TO 25 DO
	FOR j := 1 TO 80 DO
	    IF (j MOD 16) IN Next[i, j DIV 16] THEN
		Scr^[i, j].at := CHR(OnColor*16)
	    ELSE
		Scr^[i, j].at := CHR(OffColor*16);
END;
    
PROCEDURE Update;
VAR
    i, j : WORD;
VAR
    l	: WORD;
    n	: WORD;
    k	: WORD;
    m	: WORD;
    s1	: WordSet;
    s2	: WordSet;
BEGIN
    State := Next;
    FOR i := 1 TO 25 DO BEGIN
	FOR j := 1 TO 80 DO BEGIN
	    n := 0;
	    m := (j-1) MOD 16;
	    IF m <= 13 THEN BEGIN
		s1 := State[i, (j-1) DIV 16];
		IF m IN s1 THEN
		    INC(n);
		IF m+2 IN s1 THEN
		    INC(n);
		s1 := State[i-1, (j-1) DIV 16];
		s2 := State[i+1, (j-1) DIV 16];
		k := m;
		REPEAT
		    IF k IN s1 THEN
			INC(n);
		    IF k IN s2 THEN
			INC(n);
		    INC(k);
		UNTIL k > m+2;
	    END ELSE BEGIN
		l := j-1;
		REPEAT
		    IF (l MOD 16) IN State[i-1, l DIV 16] THEN
			INC(n);
		    IF (l MOD 16) IN State[i+1, l DIV 16] THEN
			INC(n);
		    INC(l);
		UNTIL l > (j+1);
		
		IF ((j-1) MOD 16) IN State[i, (j-1) DIV 16] THEN
		    INC(n);
		IF ((j+1) MOD 16) IN State[i, (j+1) DIV 16] THEN
		    INC(n);
	    END;

	    CASE n OF
		3:
		    Next[i, j DIV 16] := Next[i, j DIV 16] + [j MOD 16];
		2:
	    ELSE
		Next[i, j DIV 16] :=  Next[i, j DIV 16] - [j MOD 16];
	    END;
	END;
    END;
END;

PROCEDURE ScreenInit;
VAR
    r : REGISTERS;
BEGIN
    r.AH := 15;
    INTR($10, r);
    IF r.AL = 7 THEN
	BEGIN
	OffColor := Black;
	OnColor := LightGray;
	Scr := PTR($B000, 0);
	END
    ELSE
	BEGIN
	OffColor := Green;
	OnColor := Red;
	Scr := PTR($B800, 0);
	END;
END;

PROCEDURE ClearScreen;
VAR
    i, j : WORD;
BEGIN
    FOR i := 1 TO 25 DO
	FOR j := 1 TO 80 DO
	    BEGIN
	    Scr^[i, j].ch := ' ';
	    Scr^[i, j].at := CHR(7);
	    END;
END;

FUNCTION KeyPressed : BOOLEAN;
VAR
    r : REGISTERS;
BEGIN
    r.AH := 1;
    INTR($16, r);
    IF (fzero AND r.flags) = 0 THEN
	BEGIN
	r.AH := 0;
	INTR($16, r);
	KeyPressed := TRUE;
	END
    ELSE
	KeyPressed := FALSE;
END;

VAR
    i, j, n : WORD;
    
BEGIN
    ScreenInit;
    ClearScreen;
    
    FOR i := 0 TO 26 DO
	FOR j := 0 TO 5 DO
	    Next[i, j] := [];

    n := 12345;
    FOR i := 1 TO 25 DO
	FOR j := 1 TO 80 DO
	    BEGIN
	    IF n < 32767 THEN
		Next[i, j DIV 16] := Next[i, j DIV 16] + [j MOD 16];
	    n := n * 437;
	    END;
    
    REPEAT
	UpdateScreen;
	Update;
    UNTIL KeyPressed;
    
    ClearScreen;
END.
