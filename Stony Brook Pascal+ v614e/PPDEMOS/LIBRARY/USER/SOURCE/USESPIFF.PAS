PROGRAM UseSpiffy;

USES Spiffy;

CONST
    Error : ARRAY [0..19] OF CHAR = '*** input error ***' + #0;
VAR
    str : ARRAY [0..255] OF CHAR;
    count  : INTEGER;

BEGIN
    SpiffyIn(0, str, count);
    IF SpiffyStatus = 0 THEN
        SpiffyOut(1, str)
    ELSE
        SpiffyOut(1, Error);
END.
