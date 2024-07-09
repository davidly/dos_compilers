8190 CONSTANT SIZE
VARIABLE FLAGS SIZE ALLOT

: SIEVE
  ." primes 10 iterations: "
  10 0 DO
      FLAGS SIZE -1 FILL
      0 SIZE 0 DO
        I FLAGS + C@ IF
          I 2 * 3 + DUP I + BEGIN
            DUP SIZE < WHILE
              DUP FLAGS + 0 SWAP C! OVER +
          REPEAT DROP DROP 1+
      THEN LOOP
  LOOP
  . ;

