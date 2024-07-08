
with TEXT_IO; use TEXT_IO;

procedure SIEVE is

ITERATIONS : constant := 10;
SIZE : constant := 8190; -- 1024;

type FLAG_TYPE is array (INTEGER range 0..SIZE) of BOOLEAN;

PRIME, K, COUNT : INTEGER;
FLAGS : FLAG_TYPE;

begin
   PUT (INTEGER'IMAGE (ITERATIONS)); PUT_LINE (" iterations");
   for ITER in 1..ITERATIONS loop
      COUNT := 0;
--      PUT ('.'); -- Should be commented out for accurate timing
      FLAGS := (others => TRUE);
      for I in FLAGS'RANGE loop
         if FLAGS (I) then
            PRIME := I + I + 3;
            K := I + PRIME;
            while K <= SIZE loop
               FLAGS (K) := FALSE;
               K := K + PRIME;
            end loop;
            COUNT := COUNT + 1;
         end if;
      end loop;
   end loop;
   PUT (INTEGER'IMAGE (COUNT)); PUT_LINE (" primes");
end SIEVE;
