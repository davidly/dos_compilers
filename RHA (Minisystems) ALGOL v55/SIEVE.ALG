BEGIN

COMMENT
  BYTE magazine's CLASSIC SIEVE OF ERATOSTHENES;

INTEGER o, limit, i, k, count, prime;
BOOLEAN ARRAY flags[0:8190];
limit := 8190;

FOR o := 1 STEP 1 UNTIL 10 DO
BEGIN
    FOR i := 0 STEP 1 UNTIL limit DO
        flags[i] := TRUE;
    
    count := 0;
    FOR i := 0 STEP 1 UNTIL limit DO
    BEGIN
        IF flags[i] THEN
        BEGIN
            prime := i + i + 3;
            IF prime < limit THEN
            BEGIN
                FOR k := (i + prime) STEP prime UNTIL limit DO
                    flags[k] := FALSE;
            END;
            count := count + 1;
        END;
    END;
END;

text( 1, " PRIMES FOUND: ");
write( 1, count );
text( 1, "*N" );
ioc(22);

END
FINISH

