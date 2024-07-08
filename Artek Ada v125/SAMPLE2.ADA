-- SAMPLE2.ADA  Packages

package SAMPLE2_PACK is      -- Following is the specification of the package

   type T is limited private;

   procedure PROC1 (I : in INTEGER := 1);
   procedure PROC2 (TEMP : out T);

private
    type T is range 1..10;
end SAMPLE2_PACK;

with TEXT_IO; use TEXT_IO;

package body SAMPLE2_PACK is -- Following is the implementation of the package

   procedure PROC1 (I : in INTEGER := 1) is
   begin
      PUT (INTEGER'IMAGE (I));
   end PROC1;

   procedure PROC2 (TEMP : out T) is
   begin
      TEMP := 2;
   end PROC2;

end SAMPLE2_PACK;

with TEXT_IO, SAMPLE2_PACK; use TEXT_IO, SAMPLE2_PACK;

procedure SAMPLE2 is         -- Following is a program that uses the package
   S : T;
begin
   PROC1;      -- Default parameter
   PROC2 (S);
   -- PUT (S);    -- Error because S is limited private
end SAMPLE2;

