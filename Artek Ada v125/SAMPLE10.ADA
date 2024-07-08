
with TEXT_IO; use TEXT_IO;

procedure SAMPLE10 is

   package INTIO is new INTEGER_IO (INTEGER);

   type BYTE is array (0..7) of BOOLEAN;

   A, B, C : BYTE;

   procedure PUT (B : in BYTE) is

   begin
      for I in B'RANGE loop
         INTIO . PUT (INTEGER (B (I)), WIDTH => 1);
      end loop;
      NEW_LINE;
   end PUT;

begin
   PUT_LINE ("Boolean array operator test");
   A := (FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE);
   B := (TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE);
   PUT (A);
   PUT (B);
   PUT (A and B);
   PUT (A or B);
   PUT (A xor B);
   PUT (not A);
   PUT (not B);
end SAMPLE10;

