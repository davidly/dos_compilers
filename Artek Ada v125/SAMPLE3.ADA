-- SAMPLE3.ADA  Overloading

with TEXT_IO; use TEXT_IO;

procedure SAMPLE3 is

   procedure NAME (I : in INTEGER) is

   begin
      PUT_LINE ("Following is an integer => " & INTEGER'IMAGE (I));
      NEW_LINE (2);
   end NAME;

   procedure NAME (I : in STRING) is

   begin
      PUT_LINE ("Following is a string => " & I);
      NEW_LINE (2);
   end NAME;

   procedure NAME (I : in CHARACTER) is

   begin
      PUT_LINE ("Following is a character => " & I);
      NEW_LINE (2);
   end NAME;

begin
   NEW_LINE (2);
   NAME ('A');                 -- NAME with character parameter
   NAME ("This is a string");  -- NAME with string parameter
   NAME (100);                 -- NAME with integer parameter
end SAMPLE3;

