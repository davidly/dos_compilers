--
-- MEMORY.ADA
--
-- Memory management package for Artek Ada
--
-- Copyright (C) 1986 Artek Corporation
-- Author: V. Thorsteinsson
--
-- This generic package enables users of Artek Ada to access all
-- 640 Kb of available memory under DOS.
--
-- It is implemented as a set of five operations:
-- ALLOCATE, DEALLOCATE, MODIFY_ALLOCATION, READ, and WRITE.
-- The allocated memory is modeled as an array (indexed from 0)
-- of the generic type DATA.  Elements of the array may be written
-- or read using the READ and WRITE operations.  The size
-- of the array may be set using ALLOCATE and the memory used
-- by the array can be freed with DEALLOCATE.  If the user
-- wishes to modify the size of an already allocated array,
-- he should use the MODIFY_ALLOCATION procedure.  This will
-- preserve the memory contents up to the latest original element
-- or the latest new element, whichever is lower in memory.
-- Any error in usage causes a MEMORY_ERROR exception to be
-- raised.
--
-- Example of usage:
--
-- with TEXT_IO; use TEXT_IO;
-- procedure MEMORY_DEMO is
--
--    type SYMBOL is record
--       IDENTIFIER : STRING (1..32);
--       SYMTYPE : (OBJECT, PROGRAM, LABEL);
--       CONTENTS : INTEGER;
--    end record;
--
--    package SYMTABLE is new MEMORY (SYMBOL);
--
--    S : SYMBOL;
--
-- begin
--    SYMTABLE.ALLOCATE (2000); -- This allocates about 70K of data
--    S . IDENTIFIER := "IDENTIFIER               ";
--    S . SYMTYPE := PROGRAM;
--    for I in 0..1999 loop -- NOTE: not 1 to 2000!
--       S . CONTENTS := I;
--       SYMTABLE.WRITE (I, S); -- Write S into array element I
--    end loop;
--    SYMTABLE.READ (1555, S); -- Read S from array element 1555
--    SYMTABLE.DEALLOCATE;
--    PUT_LINE (INTEGER'IMAGE (S . CONTENTS)); -- Should write 1555
-- exception
--    when MEMORY_ERROR =>
--       PUT_LINE ("Error while working with MEMORY package");
-- end MEMORY_DEMO;
--

with SYSTEM; use SYSTEM;

generic
   type DATA is private;
package MEMORY is
   procedure ALLOCATE (NUMBER_OF_ELEMENTS : in POSITIVE);
   procedure DEALLOCATE;
   procedure MODIFY_ALLOCATION (NUMBER_OF_ELEMENTS : in POSITIVE);
   procedure READ (NUMBER_OF_ELEMENT : in NATURAL; ELEMENT : out DATA);
   procedure WRITE (NUMBER_OF_ELEMENT : in NATURAL; ELEMENT : in DATA);
   MEMORY_ERROR : exception;
end MEMORY;

with DOS_INTERFACE; use DOS_INTERFACE;
with LONG_OPERATIONS; use LONG_OPERATIONS;
with SYSTEM;

package body MEMORY is

   use SYSTEM;

   type LONG_PTR is record
      OFF : WORD;
      SEG : WORD;
   end record;

   subtype SEGMENT is WORD;

   NIL : constant SEGMENT := 0;
   ELEMENT_SIZE : constant INTEGER := DATA'SIZE / STORAGE_UNIT;

   BASE : SEGMENT := NIL;
   POOLSIZE : NATURAL := 0;

   R : REG_8086;

   function DOS_ALLOCATE (SIZE : INTEGER) return SEGMENT is
   begin
      R . AX := 16#4800#;
      R . BX := WORD (SIZE);
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry set
         raise MEMORY_ERROR;
      end if;
      return R . AX;
   end;

   procedure DOS_DEALLOCATE (S : SEGMENT) is
   begin
      R . AX := 16#4900#;
      R . ES := S;
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then
         raise MEMORY_ERROR;
      end if;
   end;

   procedure DOS_MODIFY_ALLOCATION (S : SEGMENT; SIZE : INTEGER) is
   begin
      R . AX := 16#4A00#;
      R . ES := S;
      R . BX := WORD (SIZE);
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then
         raise MEMORY_ERROR;
      end if;
   end;

   procedure ALLOCATE (NUMBER_OF_ELEMENTS : in POSITIVE) is

      SIZE : LONG_INTEGER;

   begin
      if BASE /= NIL then
         raise MEMORY_ERROR;
      end if;
      SIZE := SHR (NUMBER_OF_ELEMENTS * ELEMENT_SIZE, 4);
      BASE := DOS_ALLOCATE (SIZE . LOW + 1);
      POOLSIZE := NUMBER_OF_ELEMENTS;
   end ALLOCATE;

   procedure DEALLOCATE is
   begin
      if BASE = NIL then
         raise MEMORY_ERROR;
      end if;
      DOS_DEALLOCATE (BASE);
      POOLSIZE := 0;
   end DEALLOCATE;

   procedure MODIFY_ALLOCATION (NUMBER_OF_ELEMENTS : in POSITIVE) is

      SIZE : LONG_INTEGER;

   begin
      if BASE = NIL then
         raise MEMORY_ERROR;
      end if;
      SIZE := SHR (NUMBER_OF_ELEMENTS * ELEMENT_SIZE, 4);
      DOS_MODIFY_ALLOCATION (BASE, SIZE . LOW + 1);
      POOLSIZE := NUMBER_OF_ELEMENTS;
   end MODIFY_ALLOCATION;

   procedure MOVE_SHORT_LONG (FROM : in INTEGER; TO : in LONG_INTEGER; SIZE : in INTEGER) is
   begin
      pragma NATIVE (
         16#55#, 16#06#, 16#8B#, 16#EE#, 16#8B#, 16#76#, 16#00#, 16#8B#,
         16#56#, 16#02#, 16#8B#, 16#FA#, 16#81#, 16#E7#, 16#0F#, 16#00#,
         16#81#, 16#E2#, 16#F0#, 16#FF#, 16#B1#, 16#04#, 16#D3#, 16#EA#,
         16#8B#, 16#46#, 16#04#, 16#B1#, 16#0C#, 16#D3#, 16#E0#, 16#0B#,
         16#C2#, 16#8B#, 16#4E#, 16#06#, 16#8E#, 16#C0#, 16#FC#, 16#F3#,
         16#A4#, 16#07#, 16#5D#);
      null;
   end MOVE_SHORT_LONG;

   procedure MOVE_LONG_SHORT (FROM : in LONG_INTEGER; TO : in INTEGER; SIZE : in INTEGER) is
   begin
      pragma NATIVE (
         16#1E#, 16#55#, 16#8B#, 16#EE#, 16#8B#, 16#7E#, 16#04#, 16#8B#,
         16#56#, 16#00#, 16#8B#, 16#F2#, 16#81#, 16#E6#, 16#0F#, 16#00#,
         16#81#, 16#E2#, 16#F0#, 16#FF#, 16#B1#, 16#04#, 16#D3#, 16#EA#,
         16#8B#, 16#46#, 16#02#, 16#B1#, 16#0C#, 16#D3#, 16#E0#, 16#0B#,
         16#C2#, 16#8B#, 16#4E#, 16#06#, 16#8E#, 16#D8#, 16#FC#, 16#F3#,
         16#A4#, 16#5D#, 16#1F#);
      null;
   end MOVE_LONG_SHORT;

   procedure READ (NUMBER_OF_ELEMENT : in NATURAL; ELEMENT : out DATA) is

      ADDRESS : LONG_INTEGER;

   begin
      if BASE = NIL or NUMBER_OF_ELEMENT >= POOLSIZE then
         raise MEMORY_ERROR;
      end if;
      ADDRESS := INTEGER (BASE) * 16;
      ADDRESS := NUMBER_OF_ELEMENT * ELEMENT_SIZE + ADDRESS;
      MOVE_LONG_SHORT (ADDRESS, ELEMENT'ADDRESS, ELEMENT_SIZE);
   end READ;

   procedure WRITE (NUMBER_OF_ELEMENT : in NATURAL; ELEMENT : in DATA) is

      ADDRESS : LONG_INTEGER;

   begin
      if BASE = NIL or NUMBER_OF_ELEMENT >= POOLSIZE then
         raise MEMORY_ERROR;
      end if;
      ADDRESS := INTEGER (BASE) * 16;
      ADDRESS := NUMBER_OF_ELEMENT * ELEMENT_SIZE + ADDRESS;
      MOVE_SHORT_LONG (ELEMENT'ADDRESS, ADDRESS, ELEMENT_SIZE);
   end WRITE;

end MEMORY;
