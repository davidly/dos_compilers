-- SAMPLE1.ADA uses the standard package TEXT_IO

with TEXT_IO; use TEXT_IO;

procedure SAMPLE1 is

   package INTIO is new INTEGER_IO (INTEGER);

   F : FILE_TYPE;

begin
   NEW_LINE (3);
   PUT_LINE ("This is a string output to the standard file CON.");
   NEW_LINE; -- No parameter means default file and default number of lines
   PUT ("Following this string is an integer => ");
   INTIO . PUT (100);        -- default width and base
   NEW_LINE;
   PUT ("... and the same integer in base 2 => ");
   INTIO . PUT (100, 10, 2); -- width 10 and base 2
   NEW_LINE (2);
   PUT_LINE ("Creating the file TEMP.TMP on default drive and directory.");
   CREATE (F, OUT_FILE, "TEMP.TMP"); -- No FORM
   for I in 1..15 loop
      PUT (F, "Line ");
      INTIO . PUT (F, I, 3);
      NEW_LINE (F);
   end loop;
   NEW_LINE;
   PUT_LINE ("The creation of TEMP.TMP was successful.");
   NEW_LINE (2);
exception
   when NAME_ERROR =>
      PUT_LINE ("This is an exception handler for NAME_ERROR.");
end SAMPLE1;

