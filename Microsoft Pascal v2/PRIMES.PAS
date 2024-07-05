(* BYTE Benchmark, 9/81, Eratosthenes Sieve Prime Maker *)
PROGRAM prime (output);   (*$DEBUG-   added, of course  *)
CONST
  size = 8190;

VAR
  flags : ARRAY [0..size] OF boolean;
  i,prime,k,count,iter : integer;

PROCEDURE fillc (loc: adrmem;  len: word;  val: char); extern;

BEGIN
writeln ('10 iterations');
FOR iter := 1 TO 10 DO BEGIN
	count := 0;
	fillc (adr flags, sizeof(flags), chr(true));
	FOR i := 0 TO size DO
		IF flags[i] THEN BEGIN
			prime := i+i+3;
			k := i + prime;
			WHILE k <= size DO BEGIN
				flags[k] := false;
				k := k + prime
				END;
			count := count + 1;
			(* writeln(prime) *)
			END;
	END;
writeln(count,' primes')
END.
