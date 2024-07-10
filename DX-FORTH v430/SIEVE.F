( comments refer to the Pascal implementation )

8190 CONSTANT SIZE                          ( const size = 8190; )
VARIABLE FLAGS SIZE ALLOT                   ( flagType = array[ 0..size ] of boolean; var flags : flagType )

: SIEVE                                     ( program sieve{ OUTPUT }; )
    10 0 DO                                 ( for iter := 1 to 10 do begin )
        FLAGS SIZE -1 FILL                  ( for i := 0 to size do flags[ i ] := true; )
        0                                   ( count := 0;  -- push it on the stack )
        SIZE 0 DO                           ( for i := 0 to size do begin )
            I FLAGS + C@ IF                 ( if flags[ i ] then begin -- do loop index is i, c@ reads byte from flags element i )
                I I + 3 +                   ( prime := i + i + 3; )
                DUP I +                     ( k := i + prime; -- DUP duplicates the top of stack )
                BEGIN DUP SIZE < WHILE      ( while k <= size do begin )
                    DUP FLAGS + 0 SWAP C!   ( flags[ k ] := false; -- c! writes to address with value both on stack )
                    OVER +                  ( k := k + prime; -- OVER copies second item [prime] to the top )
                REPEAT
                DROP DROP                   ( remove k and prime from stack )
                1 +                         ( count := count + 1; -- count is on the top of the stack )
                THEN                        ( end the if block )
        LOOP
    LOOP                                    
    ." count of primes: " .                 ( writeln{ 'count of primes: ', count }; )
    ;                                       ( end. )

