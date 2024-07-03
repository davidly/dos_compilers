program e;

const
   DIGITS = 200;

type
    arrayType = array[ 0..DIGITS ] of integer;

var
    high, n, x : integer;
    a : arrayType;

begin
    high := DIGITS;
    x := 0;

    n := high - 1;
    while n > 0 do begin
        a[ n ] := 1;
        n := n - 1;
    end;

    a[ 1 ] := 2;
    a[ 0 ] := 0;

    while high > 9 do begin
        high := high - 1;
        n := high;
        while 0 <> n do begin
            a[ n ] := x MOD n;
            x := 10 * a[ n - 1 ] + x DIV n;
            n := n - 1;
        end;

        Write( x );
    end;

    writeln;
    writeln( 'done' );
end.

