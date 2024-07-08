--
-- DOSINT.ADA
--
-- MS-DOS and PC-DOS interface package for Artek Ada
--
-- Copyright (C) 1985, 86, 87 Artek Corporation
-- Author: V. Thorsteinsson
--
-- This package provides a mechanism to call the operating system
-- directly from Ada programs.  A data type is declared which
-- allows the passing of all processor data registers and the
-- flags.
--
-- The package uses the binary file CALL_DOS.BIN, which is assembled
-- from CALL_DOS.ASM.  This file is included on the Artek Ada Utility
-- diskette.
--
-- To aid the user in writing low-level routines, a few utility
-- procedures and functions are included here.  They allow reading
-- and writing directly from/into memory, reading and writing I/O
-- port values, splitting 16-bit registers into halves and more.
-- All routines are documented below.
--

package DOS_INTERFACE is

   type WORD is new INTEGER;

   subtype BYTE is WORD range 0..255; -- Note: this is stored in 2 bytes

   type REG_8086 is
      record
         AX, BX, CX, DX, SI, DI, ES, FLAGS : WORD;
      end record;

   procedure CALL_DOS (REGS : in out REG_8086);

   -- The function CALL_DOS uses the REGS structure to fill
   -- the 8086 registers.  It then calls interrupt 21h.
   -- The registers after exit from DOS are put in the
   -- REGS structure again.

   function CURRENT_DATA_SEGMENT return WORD;
   -- This function returns the value of the DS segment register.
   -- It is provided for convenience when assigning to the ES field
   -- of the REG_8086 structure in certain DOS calls.

   procedure MERGE_REGISTERS (LO, HI : in BYTE; REG : out WORD);
   -- Assigns a 16-bit register with two 8-bit register halves.
   -- Example: MERGE_REGISTERS (16#00#, 16#4C#, REG . AX);
   -- This will set AX to 16#4C00#.

   procedure SPLIT_REGISTER (REG : in WORD; LO, HI : out BYTE);
   -- Splits a 16-bit register into two 8-bit halves.
   -- Example: SPLIT_REGISTER (16#4C00#, LOWPART, HIGHPART);
   -- This will set LOWPART to 16#00# and HIGHPART to 16#4C#.

   procedure POKE (SEGMENT, OFFSET : in WORD; VALUE : in BYTE);
   -- Writes the VALUE to memory at address SEGMENT:OFFSET.
   -- POKE (16#B000#, 16#0000#, 65) will put an A at the start of
   -- IBM PC screen memory.

   procedure POKE_WORD (SEGMENT, OFFSET : in WORD; VALUE : in WORD);
   -- Similar to POKE, except that a 16-bit value is written instead
   -- of an 8-bit value.  The low 8 bits of the value are written to
   -- offset OFFSET, and the high 8 bits are written to OFFSET+1.

   function PEEK (SEGMENT, OFFSET : in WORD) return BYTE;
   -- Reads an 8-bit BYTE value from memory at address SEGMENT:OFFSET.
   -- FIRSTBYTE := PEEK (16#B000#, 16#0000#); sets FIRSTBYTE to the
   -- ASCII value of the first character in the IBM PC screen memory.

   function PEEK_WORD (SEGMENT, OFFSET : in WORD) return WORD;
   -- Similar to PEEK, except that a 16-bit value is read.  The
   -- low 8 bits of the value are read from SEGMENT:OFFSET, while
   -- the high 8 bits are read from SEGMENT:OFFSET+1.

   procedure PORT_OUT (PORT : in WORD; VALUE : in BYTE);
   -- Outputs a byte to the I/O port whose number is in PORT.
   -- Port numbers and values are very hardware-specific.

   procedure PORT_OUT_WORD (PORT : in WORD; VALUE : in WORD);
   -- Outputs a word to the I/O port whose number is in PORT.
   -- Port numbers and values are very hardware-specific.

   function PORT_IN (PORT : in WORD) return BYTE;
   -- Inputs a byte from the I/O port whose number is in PORT.
   -- Port numbers and values are very hardware-specific.

   function PORT_IN_WORD (PORT : in WORD) return WORD;
   -- Inputs a word from the I/O port whose number is in PORT.
   -- Port numbers and values are very hardware-specific.

end DOS_INTERFACE;

package body DOS_INTERFACE is

   pragma SUPPRESS (ALL_CHECKS); -- This is low-level, high-speed code

   procedure CALL_DOS (REGS : in out REG_8086) is
   begin
      -- For a full assembly listing of the CALL_DOS code,
      -- refer to CALL_DOS.ASM on the Utility Diskette.
      pragma INCLUDE_BINARY ("call_dos.bin");
      null; -- Required for legal Ada syntax
   end CALL_DOS;

   function CURRENT_DATA_SEGMENT return WORD is
      RESULT : WORD;
   begin
      pragma NATIVE (16#8C#, 16#1D#); -- Just MOV [DI], DS
      return RESULT;
   end;

   procedure MERGE_REGISTERS (LO, HI : in BYTE; REG : out WORD) is
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#8B#, 16#54#, 16#02#, 16#8B#, 16#5C#, 16#04#,
         16#8A#, 16#E2#, 16#89#, 16#07#);
      null;
   end MERGE_REGISTERS;

   procedure SPLIT_REGISTER (REG : in WORD; LO, HI : out BYTE) is
   -- Splits a 16-bit register into
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#8B#, 16#5C#, 16#02#, 16#32#, 16#E4#, 16#89#,
         16#07#, 16#8B#, 16#04#, 16#8B#, 16#5C#, 16#04#, 16#86#, 16#C4#,
         16#32#, 16#E4#, 16#89#, 16#07#);
      null;
   end SPLIT_REGISTER;

   procedure POKE (SEGMENT, OFFSET : in WORD; VALUE : in BYTE) is
   begin
      pragma NATIVE (
         16#06#, 16#8E#, 16#04#, 16#8B#, 16#7C#, 16#02#, 16#8A#, 16#44#,
         16#04#, 16#AA#, 16#07#);
      null;
   end POKE;

   procedure POKE_WORD (SEGMENT, OFFSET : in WORD; VALUE : in WORD) is
   begin
      pragma NATIVE (
         16#06#, 16#8E#, 16#04#, 16#8B#, 16#7C#, 16#02#, 16#8B#, 16#44#,
         16#04#, 16#AB#, 16#07#);
      null;
   end POKE_WORD;

   function PEEK (SEGMENT, OFFSET : in WORD) return BYTE is
      RESULT : BYTE;
   begin
      pragma NATIVE (
         16#06#, 16#8E#, 16#04#, 16#8B#, 16#5C#, 16#02#, 16#26#, 16#8A#,
         16#07#, 16#88#, 16#05#, 16#07#);
      return RESULT;
   end PEEK;

   function PEEK_WORD (SEGMENT, OFFSET : in WORD) return WORD is
      RESULT : WORD;
   begin
      pragma NATIVE (
         16#06#, 16#8E#, 16#04#, 16#8B#, 16#5C#, 16#02#, 16#26#, 16#8B#,
         16#07#, 16#89#, 16#05#, 16#07#);
      return RESULT;
   end PEEK_WORD;

   procedure PORT_OUT (PORT : in WORD; VALUE : in BYTE) is
   begin
      pragma NATIVE (16#8B#, 16#14#, 16#8A#, 16#44#, 16#02#, 16#EE#);
      null;
   end PORT_OUT;

   procedure PORT_OUT_WORD (PORT : in WORD; VALUE : in WORD) is
   begin
      pragma NATIVE (16#8B#, 16#14#, 16#8B#, 16#44#, 16#02#, 16#EF#);
      null;
   end PORT_OUT_WORD;

   function PORT_IN (PORT : in WORD) return BYTE is
      RESULT : BYTE;
   begin
      pragma NATIVE (16#8B#, 16#14#, 16#EC#, 16#88#, 16#05#);
      return RESULT;
   end PORT_IN;

   function PORT_IN_WORD (PORT : in WORD) return WORD is
      RESULT : WORD;
   begin
      pragma NATIVE (16#8B#, 16#14#, 16#ED#, 16#89#, 16#05#);
      return RESULT;
   end PORT_IN_WORD;

end DOS_INTERFACE;
