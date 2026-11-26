( BYTE magazine October 1982. Jerry Pournelle. Matrix multiply. )
( Integer version: these Forths have no floating point. The elements of )
( C fit in 16 bits; the sum is a double-cell number. Expected: 465880 )
20 CONSTANT ROWS
20 CONSTANT INNER
20 CONSTANT COLS
CREATE MA ROWS INNER * 2 * ALLOT
CREATE MB INNER COLS * 2 * ALLOT
CREATE MC ROWS COLS * 2 * ALLOT
CREATE SUMM 4 ALLOT
VARIABLE ROW
VARIABLE COL
: A-CELL ( row col -- addr ) SWAP INNER * + 2 * MA + ;
: B-CELL ( row col -- addr ) SWAP COLS * + 2 * MB + ;
: C-CELL ( row col -- addr ) SWAP COLS * + 2 * MC + ;
: MMI
    ROWS 0 DO INNER 0 DO
        J I + 2 + J I A-CELL !
    LOOP LOOP
    INNER 0 DO COLS 0 DO
        J I + 2 + I 1+ / J I B-CELL !
    LOOP LOOP
    MC ROWS COLS * 2 * 0 FILL
    ROWS 0 DO
        I ROW !
        COLS 0 DO
            I COL !
            INNER 0 DO
                ROW @ I A-CELL @ I COL @ B-CELL @ *
                ROW @ COL @ C-CELL +!
            LOOP
        LOOP
    LOOP
    0 0 SUMM 2!
    ROWS 0 DO COLS 0 DO
        SUMM 2@ J I C-CELL @ 0 D+ SUMM 2!
    LOOP LOOP
    ." summ is: " SUMM 2@ D. CR
;
