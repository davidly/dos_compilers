(*$S-*)
(*$R-*)
(*$T-*)

MODULE e;

FROM SYSTEM IMPORT WORD, BYTE, ADDRESS;
FROM NumberConversion IMPORT StringToCard;
FROM Strings IMPORT Assign;
FROM InOut IMPORT WriteLn, WriteInt, WriteCard, WriteString;
FROM Clock IMPORT GetTime, Time;

CONST
   DIGITS = 200;

VAR
    high, n, x : CARDINAL;
    a : ARRAY [ 0..DIGITS ] OF CARDINAL;

BEGIN
    high := DIGITS;
    x := 0;

    n := high - 1;
    WHILE n > 0 DO
        a[ n ] := 1;
        n := n - 1;
    END;

    a[ 1 ] := 2;
    a[ 0 ] := 0;

    WHILE high > 9 DO
        high := high - 1;
        n := high;
        WHILE 0 <> n DO
            a[ n ] := x MOD n;
            x := 10 * a[ n - 1 ] + x DIV n;
            n := n - 1;
        END;

        WriteCard( x, 0 );
    END;

    WriteLn;
    WriteString( "done" );
    WriteLn;
END e.

