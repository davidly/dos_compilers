{ Prime number generator }
{ Generates all the primes between 0 and 10000 }
program primes(output);

  var
    prime:      integer;
    rprime:     real4;
    i:          integer;
    sqrtp:      integer;
    notprime:   boolean;

  begin
    writeln('      2');
    writeln('      3');
    prime := 5;
    repeat
      rprime := prime;
      sqrtp := trunc(sqrt(rprime) + 1.0);
      i := 1;
      notprime := false;
      while (i < sqrtp) and (not notprime) do
        begin
          i := i + 2;
          notprime := (prime mod i = 0);
        end;
      if (not notprime) then writeln(prime:6);
      prime := prime + 2;
    until (prime > 10000);
  end.

