BEGIN

PROCEDURE main;
BEGIN
    INTEGER ARRAY a[0:200];
    INTEGER high, n, x;

    high := 200;
    x := 0;
    
    n := high - 1;
    WHILE n > 0 DO BEGIN
        a[ n ] := 1;
        n := n - 1;
    END;
    
    a[ 1 ] := 2;
    a[ 0 ] := 0;
    
    WHILE high > 9 DO BEGIN
        n := high;
        high := high - 1;
        WHILE 0 # n DO BEGIN
            a[ n ] := x MOD n;
            x := 10 * a[ n - 1 ] + x % n;
            n := n - 1;
        END;
        write( 1, x );
    END;
    
    text( 1, "*Ndone*N" );
    ioc(22);
END;

main;

END
FINISH

