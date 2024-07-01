program tf( INPUT, OUTPUT );

var
    r, a, b, c : real;
    i, x : integer;

procedure phi;
var
    prev2, prev1, i, next : integer;
    v : real;
begin
    writeln( 'should tend towards 1.618033988749...' );
    prev1 := 1;
    prev2 := 1;

    for i := 1 to 21 do begin { integer overflow beyond this }
        next := prev1 + prev2;
        prev2 := prev1;
        prev1 := next;

        v := prev1 / prev2;
        writeln( '  at ', i, ' iterations: ', v );
    end;
end;

begin { tf }
    a := 1.1;
    b := 2.2;
    c := 3.3;
    for i := 1 to 8 do begin
        writeln( 'a, b, c, i: ', a, b, c, i );

        a := b * c;
        b := a * c;
        r := arctan( a );
        r := cos( a );
        { r := exp( a ); }
{        r := frac( a ); }
{        if a <= 32727.0 then r := int( a ); }
        r := ln( a );
        r := sin( a );
        r := sqr( a );
        r := sqrt( a );
        if a <= 32767.0 then x := round( a );
        if a <= 32767.0 then x := trunc( a );
    end;

    writeln;
    writeln( 'a, b, c: ', a, b, c );

    phi;
end. { tf }
