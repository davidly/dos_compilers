BEGIN
COMMENT BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
        various bugs not found because dimensions are square fixed by David Lee.
        integer version: each element of C fits in 16 bits, the sum is kept in
        base 10000. Each element is under 10000, so one carry per add is enough;
    INTEGER ARRAY a[1:20,1:20], b[1:20,1:20], c[1:20,1:20];
    INTEGER summhi, summlo, p;

    PROCEDURE filla;
    BEGIN
        INTEGER i, j;
        FOR i := 1 STEP 1 UNTIL 20 DO
            FOR j := 1 STEP 1 UNTIL 20 DO
                a[ i, j ] := i + j
    END;

    PROCEDURE fillb;
    BEGIN
        INTEGER i, j;
        FOR i := 1 STEP 1 UNTIL 20 DO
            FOR j := 1 STEP 1 UNTIL 20 DO
                b[ i, j ] := ( i + j ) % j
    END;

    PROCEDURE fillc;
    BEGIN
        INTEGER i, j;
        FOR i := 1 STEP 1 UNTIL 20 DO
            FOR j := 1 STEP 1 UNTIL 20 DO
                c[ i, j ] := 0
    END;

    PROCEDURE matmult;
    BEGIN
        INTEGER i, j, k;
        FOR i := 1 STEP 1 UNTIL 20 DO
            FOR j := 1 STEP 1 UNTIL 20 DO
                FOR k := 1 STEP 1 UNTIL 20 DO
                    c[ i, j ] := c[ i, j ] + a[ i, k ] * b[ k, j ]
    END;

    PROCEDURE summit;
    BEGIN
        INTEGER i, j;
        FOR i := 1 STEP 1 UNTIL 20 DO
            FOR j := 1 STEP 1 UNTIL 20 DO
            BEGIN
                summlo := summlo + c[ i, j ];
                IF summlo >= 10000 THEN
                BEGIN
                    summlo := summlo - 10000;
                    summhi := summhi + 1
                END
            END
    END;

    summhi := 0;
    summlo := 0;
    filla;
    fillb;
    fillc;
    matmult;
    summit;
    COMMENT write puts a blank after a number, so the digits go out with chout;
    text(1,"summ is : ");
    p := 1;
up: IF summhi % ( p * 10 ) > 0 THEN BEGIN p := p * 10; GOTO up END;
hd: chout(1, 48 + summhi % p - ( summhi % ( p * 10 ) ) * 10);
    p := p % 10;
    IF p > 0 THEN GOTO hd;
    FOR p := 1000, 100, 10, 1 DO
        chout(1, 48 + summlo % p - ( summlo % ( p * 10 ) ) * 10);
    text(1,"*N");
    ioc(22)
END
FINISH
