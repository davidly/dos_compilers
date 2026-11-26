BEGIN
COMMENT BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
        various bugs not found because dimensions are square fixed by David Lee.
        A and B hold small whole numbers, so the sum is exactly 465880.
        RHA ALGOL reals (like RML Algol's) have a 3-byte mantissa and its
        arithmetic truncates, so the sum comes out 465879.8, and the program
        checks that it rounds to 465880;
    REAL ARRAY a[1:20,1:20], b[1:20,1:20], c[1:20,1:20];
    REAL summ, d;

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
                c[ i, j ] := 0.0
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
                summ := summ + c[ i, j ]
    END;

    summ := 0.0;
    filla;
    fillb;
    fillc;
    matmult;
    summit;
    text(1,"summ is : "); rwrite(1,summ,10,1); text(1,"*N");
    d := summ - 465880.0;
    IF d < 0.0 THEN d := -d;
    IF d < 1.0 THEN text(1,"summ rounds to 465880*N")
    ELSE text(1,"summ is not 465880*N");
    ioc(22)
END
FINISH
