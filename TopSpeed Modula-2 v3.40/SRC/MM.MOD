(* BYTE magazine October 1982. Jerry Pournelle.
   various bugs not found because dimensions are square fixed by David Lee
   A and B hold small whole numbers, so every REAL format gets exactly 465880
   This library has no simple REAL output, so the program checks the sum itself.
   expected result: 465880 *)

MODULE mm;

FROM InOut IMPORT WriteString, WriteLn;

CONST
    L = 20; (* rows in A and resulting matrix C *)
    M = 20; (* columns in A and rows in B (must be identical) *)
    N = 20; (* columns in B and resulting matrix C *)

VAR
    A : ARRAY [ 1 .. L ], [ 1 .. M ] OF REAL;
    B : ARRAY [ 1 .. M ], [ 1 .. N ] OF REAL;
    C : ARRAY [ 1 .. L ], [ 1 .. N ] OF REAL;
    Summ : REAL;

PROCEDURE FillA;
VAR
    i, j : CARDINAL;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO M DO
            A[ i, j ] := FLOAT( i + j );
        END;
    END;
END FillA;

PROCEDURE FillB;
VAR
    i, j : CARDINAL;
BEGIN
    FOR i := 1 TO M DO
        FOR j := 1 TO N DO
            B[ i, j ] := FLOAT( ( i + j ) DIV j );
        END;
    END;
END FillB;

PROCEDURE FillC;
VAR
    i, j : CARDINAL;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO N DO
            C[ i, j ] := 0.0;
        END;
    END;
END FillC;

PROCEDURE MatMult;
VAR
    i, j, k : CARDINAL;
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
    i, j : CARDINAL;
BEGIN
    FOR i := 1 TO L DO
        FOR j := 1 TO N DO
            Summ := Summ + C[ i, j ];
        END;
    END;
END Summit;

BEGIN
    Summ := 0.0;

    FillA;
    FillB;
    FillC;
    MatMult;
    Summit;

    IF Summ = 465880.0 THEN
        WriteString( "summ is exactly 465880" );
    ELSE
        WriteString( "summ is not 465880" );
    END;
    WriteLn;
END mm.
