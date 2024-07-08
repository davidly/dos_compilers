-- SAMPLE5.ADA  Array and record aggregates

procedure SAMPLE5 is

   CONST : constant STRING (1..10) := "1234567890";

   type TEMP_TYPE is
      record
         FIELD1 : INTEGER;
         FIELD2 : CHARACTER;
         FIELD3 : STRING (1..10) := ('H', 'e', 'l', 'l', 'o', others => ' ');
      end record;

   type TABLE is array (1..10) of INTEGER;

   TEMP : TEMP_TYPE;
   TEMP_STR : TABLE := (2 | 4 | 10 => 1, others => 0);

-- TEMP_STR now contains 0 1 0 1 0 0 0 0 0 1

begin
   TEMP := (FIELD1 => 35, FIELD2 => 'Y', FIELD3 => CONST);
end SAMPLE5;

