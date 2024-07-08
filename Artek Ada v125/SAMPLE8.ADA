-- SAMPLE8.ADA  Dynamic arrays

with TEXT_IO; use TEXT_IO;

procedure SAMPLE8 is

   subtype INDEX is INTEGER range 1..10;
   type ARRAY1_TYPE is array (INDEX range <>) of CHARACTER;
   subtype T is ARRAY1_TYPE (INDEX);
   type ARRAY2_TYPE is array (INTEGER range <>, INTEGER range <>) of INTEGER;

   ARR1 : ARRAY1_TYPE (5..8);
   ARR2 : ARRAY2_TYPE (0..1, 0..5);
   CH   : CHARACTER := 'A';

begin
   NEW_LINE (2);
   for I in ARR1'RANGE loop
      ARR1 (I) := CH;
      PUT (ARR1 (I));
      CH := CHARACTER'SUCC (CH);
   end loop;
   NEW_LINE (2);
   for I in 0..1 loop
      for J in 0..5 loop
         ARR2 (I, J) := J;
         PUT (INTEGER'IMAGE (ARR2 (I, J)));
      end loop;
      NEW_LINE;
   end loop;
end SAMPLE8;

