--
-- LONGOP.ADA
--
-- Operations on 32-bit values
--
-- (C) Copyright 1986 Artek Corporation
--
-- This package implements a few utility routines for
-- the manipulation of 32-bit quantities.  It is fairly
-- incomplete and is mainly intended for use with DIRECT_IO
-- and MEMORY.
--
-- All operations raise NUMERIC_ERROR if errors occur.
--
-- Note: Since LONG_INTEGER is implemented here as a record,
-- you cannot assign to it as if it were a normal integer.
-- Thus, you cannot say L := 1000 if L is a LONG_INTEGER.
-- However, you could use L := (1000, 0).
--

package LONG_OPERATIONS is

   type LONG_INTEGER is
      record
         LOW, HIGH : INTEGER;
      end record;

   function "*" (LEFT, RIGHT : in INTEGER) return LONG_INTEGER;
   function "/" (LEFT : in LONG_INTEGER; RIGHT : in INTEGER) return INTEGER;
   function "+" (LEFT : in LONG_INTEGER; RIGHT : in INTEGER) return LONG_INTEGER;
   function SHR (LEFT : in LONG_INTEGER; RIGHT : in NATURAL) return LONG_INTEGER;
   function "+" (LEFT, RIGHT : in LONG_INTEGER) return LONG_INTEGER;

end LONG_OPERATIONS;

package body LONG_OPERATIONS is

   function "*" (LEFT, RIGHT : in INTEGER) return LONG_INTEGER is
      L : LONG_INTEGER;
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#F7#, 16#6C#, 16#02#, 16#AB#, 16#8B#, 16#C2#,
         16#AB#);
      return L;
   end "*";

   function "/" (LEFT : in LONG_INTEGER; RIGHT : in INTEGER) return INTEGER is
      I : INTEGER;
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#8B#, 16#54#, 16#02#, 16#F7#, 16#7C#, 16#04#,
         16#AB#);
      return I;
   end "/";

   function "+" (LEFT : in LONG_INTEGER; RIGHT : in INTEGER) return LONG_INTEGER is
      L : LONG_INTEGER;
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#8B#, 16#54#, 16#02#, 16#03#, 16#44#, 16#04#,
         16#83#, 16#D2#, 16#00#, 16#89#, 16#05#, 16#89#, 16#55#, 16#02#);
      return L;
   end "+";

   function SHR (LEFT : in LONG_INTEGER; RIGHT : in NATURAL) return LONG_INTEGER is
      L : LONG_INTEGER;
   begin
      pragma NATIVE (
         16#8B#, 16#4C#, 16#04#, 16#E3#, 16#0B#, 16#8B#, 16#04#, 16#8B#,
         16#54#, 16#02#, 16#D1#, 16#EA#, 16#D1#, 16#D8#, 16#E2#, 16#FA#,
         16#AB#, 16#8B#, 16#C2#, 16#AB#);
      return L;
   end SHR;

   function "+" (LEFT, RIGHT : in LONG_INTEGER) return LONG_INTEGER is
      L : LONG_INTEGER;
   begin
      pragma NATIVE (
         16#8B#, 16#04#, 16#8B#, 16#54#, 16#02#, 16#03#, 16#44#, 16#04#,
         16#13#, 16#54#, 16#06#, 16#89#, 16#05#, 16#89#, 16#55#, 16#02#);
      return L;
   end "+";

end LONG_OPERATIONS;

