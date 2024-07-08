with TEXT_IO; use TEXT_IO;

procedure E is

h, n, x, d, y : integer;
a : Array(0..200) of integer;

begin
    h := 200;
    x := 0;
    n := h - 1;
    d := 0;
    y := 0;

    Put( "starting... " ); New_line;
    while n > 0 loop
        a( n ) := 1;
        n := n - 1;
    end loop;

    a( 1 ) := 2;
    a( 0 ) := 0;

    while h > 9 loop
        h := h - 1;
        n := h;
        while 0 /= n loop
            -- math simplified because complex expressions cause bad code to be generated
            a( n ) := x REM n;
            y := a( n - 1 );
            x := ( y * 10 ) + ( x / n );
            n := n - 1;
        end loop;

        Put( INTEGER'IMAGE( x ) );
    end loop;

    New_line;
    Put( "done" );
    New_line;
end e;

