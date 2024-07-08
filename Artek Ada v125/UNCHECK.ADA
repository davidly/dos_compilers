--
-- UNCHECK.ADA
--
-- Unchecked programming procedures for Artek Ada
--
-- Copyright (C) 1986 Artek Corporation
--
-- These utility procedures are implemented in accordance
-- with the Ada standard.
--

generic
   type OBJECT is limited private;
   type NAME is access OBJECT;
procedure UNCHECKED_DEALLOCATION (X : in out NAME);

with ACODES; use ACODES;
procedure UNCHECKED_DEALLOCATION (X : in out NAME) is

begin
   pragma ACODE (NOP, 00, 00, 00);
   pragma ACODE (LOAD2); -- Load pointer to X
   pragma ACODE (CVABS);
   pragma ACODE (LOAD2); -- Load contents of X
   pragma ACODE (HDISP, 00, 00, 00); -- Dispose the element pointed to by X
   pragma ACODE (LOAD2); -- Load pointer to X
   pragma ACODE (CVABS, 00, 00);
   pragma ACODE (STORE2); -- Store NULL in it
   null; -- To make this legal Ada syntax
end UNCHECKED_DEALLOCATION;

generic
   type SOURCE is limited private;
   type TARGET is limited private;
function UNCHECKED_CONVERSION (S : SOURCE) return TARGET;

with ACODES; use ACODES;
function UNCHECKED_CONVERSION (S : SOURCE) return TARGET is

   type TARGET_ACCESS is access TARGET;
   TARGET_POINTER : TARGET_ACCESS;

   function SOURCE_ADDRESS return TARGET_ACCESS is
      A : TARGET_ACCESS;
   begin
      pragma ACODE (NOP, 00, 00, 00, 01, 00, 00); -- A'ADDRESS, S'ADDRESS
      pragma ACODE (ADR); -- Convert S to 16-bit offset
      pragma ACODE (STORE2); -- and store in A
      return A;
   end SOURCE_ADDRESS;

begin
   if SOURCE'SIZE /= TARGET'SIZE then
      raise CONSTRAINT_ERROR;
   else
      TARGET_POINTER := SOURCE_ADDRESS;
      return TARGET_POINTER . all; -- Return the target (read from the source!)
   end if;
end UNCHECKED_CONVERSION;

