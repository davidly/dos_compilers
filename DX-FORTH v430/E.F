( comments refer to the Pascal implementation )

200 CONSTANT DIGITS              ( const DIGITS = 200; )
VARIABLE ARRAY DIGITS ALLOT      ( type arrayType = array[ 0..DIGITS ] of integer; var a : arrayType; )
VARIABLE X                       ( var x : integer )

: E
    0 X !
    ARRAY DIGITS 1 FILL          ( set all elements of array to 1 )
    0 ARRAY C!                   ( a[ 0 ] := 0; )
    2 1 ARRAY + C!               ( a[ 1 ] := 2; )

    DIGITS                       
    BEGIN DUP 9 > WHILE          ( while high > 9 do begin )
        1 -                      ( high := high - 1;  -- high is at the top of the stack)
        DUP                      ( n := high; -- put N on the top of the stack )
        BEGIN DUP 0 <> WHILE     ( while 0 <> n do begin )
            X @ OVER MOD         ( x MOD n; -- OVER copies n from one up the stack onto the stack )
            OVER ARRAY + C!      ( a[ n ] := mod result )
                                 ( statements below are for x := 10 * a[ n - 1 ] + x DIV n; )
            X @ OVER /           ( quotient = x DIV n )
            OVER 1 - ARRAY + C@  ( a[ n - 1 ] )
            10 * +               ( 10 * <array value> + quotient; )
            X !                  ( x := <math> )
            1 -                  ( n := n - 1; )
        REPEAT
        DROP                     ( remove n from the top of the stack so high is the only thing on the stack )
        X ?                      ( Write{ x }; )
    REPEAT
    CR                           ( writeln; )
    ." done"                     ( writeln{ 'done' } )
    ;                            ( end. )
