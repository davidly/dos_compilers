-- SAMPLE6.ADA  Derived types

with TEXT_IO; use TEXT_IO;

procedure SAMPLE6 is

   type DOLLAR_TYPE is new INTEGER;
   type POUND_TYPE  is new INTEGER;

   A, B   : INTEGER     := 2;
   D1, D2 : DOLLAR_TYPE := 4;  -- Unique integer type
   P1, P2 : POUND_TYPE  := 8;  -- Unique integer type

   function "*" (X, Y : DOLLAR_TYPE) return DOLLAR_TYPE is

   -- Multiply dollars only

   begin
      PUT_LINE ("Multiplying two DOLLAR variables");
      return DOLLAR_TYPE (INTEGER (X) * INTEGER (Y)); -- Prevent recursion
   end;

begin
   NEW_LINE (2);
   P1 := P1 * P2;
   D1 := D1 * D2;
   -- A := B + D1;   -- Illegal
   -- D2 := D1 - P1; -- Illegal
   -- P2 := A;       -- Illegal
end SAMPLE6;

