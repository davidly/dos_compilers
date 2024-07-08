-- SAMPLE4.ADA  Strings

with TEXT_IO; use TEXT_IO;

procedure SAMPLE4 is

   CONST : constant STRING (1..5) := "Artek";

   subtype STR10 is STRING (1..10);

   S4  : STRING (1..4) := " Ada";
   S10 : STR10 := ('C', 'o', 'm', 'p', 'i', 'l', 'e', 'r', others => ' ');
   S20 : STRING (1..21) := (others => ' ');

begin
   S20 (S20'FIRST .. CONST'LAST) := CONST;
   S20 (CONST'LAST + 1 .. CONST'LAST + S4'LAST + S10'LAST + 1) :=
      S4 & " " & S10;
   NEW_LINE (2);
   PUT_LINE (S20);
end SAMPLE4;

