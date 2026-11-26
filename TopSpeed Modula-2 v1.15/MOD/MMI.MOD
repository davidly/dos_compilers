(* BYTE magazine October 1982. Jerry Pournelle.
   various bugs not found because dimensions are square fixed by David Lee
   integer version: each C element fits in 16 bits; sum kept in base 10000
   expected result: 465880 *)

(*$S-*)
(*$R-*)
(*$T-*)

MODULE mmi;

FROM InOut IMPORT WriteString, WriteLn, WriteInt;

CONST
    L = 20; (* rows in A and resulting matrix C *)
    M = 20; (* columns in A and rows in B (must be identical) *)
    N = 20; (* columns in B and resulting matrix C *)

VAR
    A : ARRAY [ 1 .. L ], [ 1 .. M ] OF INTEGER;
    B : ARRAY [ 1 .. M ], [ 1 .. N ] OF INTEGER;
    C : ARRAY [ 1 .. L ], [ 1 .. N ] OF INTEGER;
    SummHi, SummLo : INTEGER;

PROCEDURE FillA;
VAR
    i, j : INTEGER;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO M DO
            A[ i, j ] := i + j;
        END;
    END;
END FillA;

PROCEDURE FillB;
VAR
    i, j : INTEGER;
BEGIN
    FOR i := 1 TO M DO
        FOR j := 1 TO N DO
            B[ i, j ] := ( i + j ) DIV j;
        END;
    END;
END FillB;

PROCEDURE FillC;
VAR
    i, j : INTEGER;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO N DO
            C[ i, j ] := 0;
        END;
    END;
END FillC;

PROCEDURE MatMult;
VAR
    i, j, k : INTEGER;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO N DO
            FOR k := 1 TO M DO
                C[ i, j ] := C[ i, j ] + A[ i, k ] * B[ k, j ];
            END;
        END;
    END;
END MatMult;

PROCEDURE Summit;
VAR
    i, j : INTEGER;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO N DO
            SummLo := SummLo + C[ i, j ];
            WHILE SummLo >= 10000 DO
                SummLo := SummLo - 10000;
                SummHi := SummHi + 1;
            END;
        END;
    END;
END Summit;

BEGIN
    SummHi := 0;
    SummLo := 0;

    FillA;
    FillB;
    FillC;
    MatMult;
    Summit;

    WriteString( "summ is : " );
    WriteInt( SummHi, 1 );
    IF SummLo < 1000 THEN WriteString( "0" ); END;
    IF SummLo < 100 THEN WriteString( "0" ); END;
    IF SummLo < 10 THEN WriteString( "0" ); END;
    WriteInt( SummLo, 1 );
    WriteLn;
END mmi.
