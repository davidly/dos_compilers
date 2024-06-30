program sieve;

const
    size = 8190;

type
    flagType = array[ 0..size ] of boolean;

var
    i, k, prime, count, iter : integer;
    flags : flagType;

begin
    for iter := 1 to 10 do begin
        count := 0;
        for i := 0 to size do flags[ i ] := true;
        for i := 0 to size do begin
            if flags[ i ] then begin
                prime := i + i + 3;
                k := i + prime;
                while k <= size do begin
                    flags[ k ] := false;
                    k := k + prime;
                end;
                count := count + 1;
            end;
        end;
    end;

    writeln( 'count of primes: ', count );
end.