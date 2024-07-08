--
-- QPUT.ADA
--
-- Quick console output procedure for Artek Ada
--
-- Copyright (C) 1986 Artek Corporation
--
-- This procedure uses the DOS Quick Write Interrupt
-- (29h) to achieve fast console output.
--
-- Example of usage:
--
-- with QPUT;
-- procedure EXAMPLE is
-- begin
--    QPUT ("Hello, world!");
-- end EXAMPLE;
--

procedure QPUT (S : in STRING) is

begin
--
-- The pragma below represents the following assembly language code:
--
-- CGROUP  GROUP CODE
-- CODE    SEGMENT 'CODE'
-- ASSUME  CS:CGROUP, DS:NOTHING, ES:NOTHING
--
-- QPUT    PROC    FAR
--
--         MOV     CX, [SI+4]           ; Load S . SUBSIZE
--         JCXZ    ENDQP                ; Size is zero; don't print
--         MOV     SI, [SI]             ; Load S . ADDRESS
-- QPLOOP:
--         LODSB
--         INT     29h                  ; Quick Write interrupt
--         LOOP    QPLOOP
-- ENDQP:
--
-- QPUT    ENDP
--
-- CODE    ENDS
--
--        END     QPUT
--
   pragma NATIVE (
      16#8B#, 16#4C#, 16#04#, 16#E3#, 16#07#, 16#8B#, 16#34#, 16#AC#,
      16#CD#, 16#29#, 16#E2#, 16#FB#);
   null; -- For correct Ada syntax
end QPUT;

