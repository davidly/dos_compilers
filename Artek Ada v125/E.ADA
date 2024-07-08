with TEXT_IO; use TEXT_IO;

procedure E is

package INTIO is new INTEGER_IO (INTEGER);

h, n, x, y : integer;
a : Array(0..200) of integer;

begin
    h := 200;
    x := 0;
    n := h - 1;

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
            a( n ) := x REM n;
            -- math simplified using local y because complex expressions cause bad code to be generated
            y := a( n - 1 );
            x := ( y * 10 ) + ( x / n );
            n := n - 1;
        end loop;

        if ( x >= 10 ) then
            INTIO.PUT( x, 2 );
        else
            INTIO.PUT( x, 1 );
        end if;
    end loop;

    New_line;
    Put( "done" );
    New_line;
end e;

