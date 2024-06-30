(* Eratosthenes Sieve Prime Number Program in Pascal *)
(* From September, 1981 Byte magazine, page 182 *)
PROGRAM PRIME (OUTPUT);   (*$DEBUG-   added, of course  *)
CONST
  SIZE = 8190;

VAR
  FLAGS : ARRAY [0..SIZE] OF BOOLEAN;
  I,PRIME,K,COUNT,ITER : INTEGER;

PROCEDURE FILLC(LOC: ADRMEM; LEN: WORD; VAL: CHAR); EXTERN;

BEGIN
WRITELN ('10 iterations');
FOR ITER := 1 TO 10 DO BEGIN
	COUNT := 0;
	FILLC(ADR FLAGS,SIZEOF(FLAGS),CHR(TRUE));
	FOR I := 0 TO SIZE DO
		IF FLAGS[I] THEN BEGIN
			PRIME := I+I+3;
			K := I + PRIME;
			WHILE K <= SIZE DO BEGIN
				FLAGS[K] := FALSE;
				K := K + PRIME
				END;
			COUNT := COUNT + 1
			(* WRITELN(PRIME) *)
			END;
	END;
WRITELN(COUNT,' primes')
END.
