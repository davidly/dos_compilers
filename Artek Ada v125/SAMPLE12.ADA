
--
-- ENUMERATION_IO demo
--
-- This program may require more than 384 Kb of RAM memory to compile,
-- depending on your hardware.  (The twin instantiations below are
-- memory-hungry while they're being processed.)  If you have problems,
-- de-install all RAM-resident software and try again.
--

with IO_EXCEPTIONS, TEXT_IO;
use TEXT_IO;

procedure SAMPLE12 is

   type COLORS is (BLACK, BLUE, BROWN, GREEN, RED, WHITE, YELLOW);
   type INVENTORY is array (COLORS) of INTEGER;

   package EIO is new ENUMERATION_IO (COLORS); use EIO;
   package INTIO is new INTEGER_IO (INTEGER); use INTIO;

   INV : INVENTORY := (others => 20); -- Initial stock is 20 of each
   WHICH_COLOR : COLORS; 
   HOW_MANY : INTEGER;

begin
   PUT_LINE ("Inventory control program");
   loop
      PUT_LINE ("The current inventory is as follows:");
      for I in COLORS loop
         PUT (I, WIDTH => 8);
      end loop;
      NEW_LINE;
      for I in COLORS loop
         PUT (INV (I), WIDTH => 8);
      end loop;
      NEW_LINE;
      loop
         begin
            PUT ("How many items (0 to exit) => ");
            GET (HOW_MANY);
            exit; -- Exit from loop if no exception
         exception
            when DATA_ERROR =>
               NEW_LINE;
               PUT_LINE ("Illegal integer.  Please reenter.");
         end;
      end loop;
      NEW_LINE;
      exit when HOW_MANY = 0;
      loop
         begin
            PUT ("Which color do you want to sell/buy => ");
            GET (WHICH_COLOR);
            exit; -- Exit from loop if no exception
         exception
            when DATA_ERROR =>
               NEW_LINE;
               PUT_LINE ("Illegal color.  Please reenter.");
         end;
      end loop;
      NEW_LINE;
      INV (WHICH_COLOR) := INV (WHICH_COLOR) - HOW_MANY;
   end loop;
   PUT_LINE ("End of program.  Have a nice day.");
end SAMPLE12;

