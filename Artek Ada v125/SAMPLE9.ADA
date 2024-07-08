-- SAMPLE9.ADA  Use of DOS_INTERFACE

with DOS_INTERFACE; use DOS_INTERFACE;

procedure SAMPLE9 is

   R : REG_8086; -- 8086 registers to use for DOS calls

   procedure VERIFY_ON is

   begin
      R . AX := 16#2E01#; -- AH = function call 2E (Set/reset verify switch)
                          -- AL = 01 verify on, AL = 00 verify off
      R . DX := 16#0000#; -- DL must be 0 for this function call
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set, there is some error
         null;                    -- Error handling
      end if;
   end VERIFY_ON;

   procedure DELETE_FILE (F : in STRING) is

   begin
      R . AX := 16#4100#; -- Function call 41 (Delete file)
      R . DX := WORD (F'ADDRESS);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry set, error
         if R . AX = 2 then
            null;                 -- Error handling for file not found
         else
            null;                 -- Error handling for access error
         end if;
      end if;
   end DELETE_FILE;

begin
   VERIFY_ON;
   DELETE_FILE ("TEMP.TMP" & ASCII.NUL); -- Must be zero-terminated
end SAMPLE9;
