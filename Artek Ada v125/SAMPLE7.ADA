-- SAMPLE7.ADA  Generic subprogram
with TEXT_IO; use TEXT_IO;

procedure SAMPLE7 is

   package INTIO is new INTEGER_IO (INTEGER);

   generic
      type ITEM is private;
   procedure SWAP (X, Y : in out ITEM);

   subtype STRING5 is STRING (1..5);
   I1 : INTEGER := 0;
   I2 : INTEGER := 4;
   C1 : CHARACTER := 'A';
   C2 : CHARACTER := 'B';
   S1 : STRING5 := "Artek";
   S2 : STRING5 := "abcde";

   procedure SWAP (X, Y : in out ITEM) is
      Z : ITEM;
   begin
      Z := X;
      X := Y;
      Y := Z;
   end SWAP;
   procedure SWAP_INT is new SWAP (ITEM => INTEGER);
   procedure SWAP_CHR is new SWAP (ITEM => CHARACTER);
   procedure SWAP_STR is new SWAP (ITEM => STRING5);
begin
   NEW_LINE (2);
   PUT ("Before => "); INTIO . PUT (I1); INTIO . PUT (I2);
   SWAP_INT (I1, I2); PUT (" After => "); INTIO . PUT (I1); INTIO . PUT (I2); NEW_LINE (2);
   PUT ("Before => "); PUT (C1); PUT (C2);
   SWAP_CHR (C1, C2); PUT (" After => "); PUT (C1); PUT (C2); NEW_LINE (2);
   PUT ("Before => "); PUT (S1); PUT (S2);
   SWAP_STR (S1, S2); PUT (" After => "); PUT (S1); PUT (S2); NEW_LINE (2);
end SAMPLE7;

