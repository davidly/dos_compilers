8190 CONSTANT SIZE
VARIABLE FLAGS SIZE ALLOT

: SIEVE
    0                           ( retain only the final pass count )
    10 0 DO
        FLAGS SIZE -1 FILL
        DROP 0                  ( reset count for this pass )
        SIZE 0 DO
            I FLAGS + C@ IF
                I DUP + 3 + DUP I +  ( prime first-multiple )
                DUP SIZE < IF
                    SIZE SWAP DO
                        0 I FLAGS + C!
                        DUP
                    +LOOP
                ELSE
                    DROP
                THEN
                DROP 1+
            THEN
        LOOP
    LOOP
    ." count of primes: " . CR ;
