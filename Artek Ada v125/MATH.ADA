--
-- MATH.ADA
--
-- Mathematical routines for Artek Ada
--
-- Package body Copyright (C) 1986 Artek Corporation
-- Author: V. Thorsteinsson
--
-- The MATH package offers common exponential, logarithmic,
-- trigonometric and hyperbolic functions used in mathematical
-- calculation.
--
-- Most routines are implemented in assembly language for maximum
-- speed and accuracy.  An 8087/287/387 coprocessor is used if
-- present and emulated in software if not.
--
-- The routines raise the exception ARGUMENT_ERROR if their
-- arguments are out of bounds.
--
-- The trigonometric functions can accept an optional CYCLE parameter
-- that allows you to work in degrees or grads if you prefer them to
-- radians.  In this case, say for example:
--
--    A := SIN (90.0, CYCLE => 360.0);
--
-- to calculate the sine of a 90 degree angle.
--

generic

   type REAL is digits <>;

package MATH is

   PI : constant := 3.1415_92653_58979_32384_62643_38327_95029;
   EXP_1 : constant := 2.7182_81828_45904_52353_60287_47135_26625;

   function SQRT (X : REAL) return REAL;
   function LOG (X : REAL; BASE : REAL := EXP_1) return REAL;
   function EXP (X : REAL; BASE : REAL := EXP_1) return REAL;
   function SIN (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL;
   function COS (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL;
   function TAN (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL;
   function COT (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL;
   function ARCSIN (X : REAL) return REAL;
   function ARCCOS (X : REAL) return REAL;
   function ARCTAN (X : REAL; Y : REAL := 1.0) return REAL;
   function ARCCOT (X : REAL; Y : REAL := 1.0) return REAL;
   function SINH (X : REAL) return REAL;
   function COSH (X : REAL) return REAL;
   function TANH (X : REAL) return REAL;
   function COTH (X : REAL) return REAL;
   function ARCSINH (X : REAL) return REAL;
   function ARCCOSH (X : REAL) return REAL;
   function ARCTANH (X : REAL) return REAL;
   function ARCCOTH (X : REAL) return REAL;

   ARGUMENT_ERROR : exception;

end MATH;

package body MATH is

   function "rem" (LEFT, RIGHT : REAL) return REAL is
      RESULT : REAL;
      STATUS : INTEGER;
   begin
      pragma NATIVE (
         16#CD#, 16#39#, 16#44#, 16#08#, 16#CD#, 16#39#, 16#04#, 16#CD#,
         16#35#, 16#E4#, 16#33#, 16#C9#, 16#CD#, 16#39#, 16#7D#, 16#08#,
         16#CD#, 16#3D#, 16#8B#, 16#45#, 16#08#, 16#9E#, 16#73#, 16#05#,
         16#CD#, 16#35#, 16#E0#, 16#F7#, 16#D1#, 16#CD#, 16#35#, 16#F8#,
         16#CD#, 16#39#, 16#7D#, 16#08#, 16#CD#, 16#3D#, 16#8B#, 16#45#,
         16#08#, 16#9E#, 16#7A#, 16#F1#, 16#CD#, 16#39#, 16#D9#, 16#23#,
         16#C9#, 16#74#, 16#03#, 16#CD#, 16#35#, 16#E0#, 16#CD#, 16#39#,
         16#1D#, 16#CD#, 16#3D#);
      return RESULT;
   end "rem";

   function MYTAN (X : REAL) return REAL is
      RESULT : REAL;
      PIOVER4 : REAL := PI / 4.0;
      PIOVER2 : REAL := PI / 2.0;
      STATUS_WORD : INTEGER;
      ENVIRONMENT : array (1..8) of INTEGER;
   begin
      pragma NATIVE (
         16#CD#, 16#35#, 16#EB#, 16#CD#, 16#39#, 16#04#, 16#CD#, 16#35#,
         16#E4#, 16#33#, 16#DB#, 16#8B#, 16#CB#, 16#CD#, 16#39#, 16#7D#,
         16#18#, 16#CD#, 16#3D#, 16#8B#, 16#45#, 16#18#, 16#9E#, 16#73#,
         16#05#, 16#CD#, 16#35#, 16#E0#, 16#F7#, 16#D1#, 16#CD#, 16#35#,
         16#F8#, 16#CD#, 16#39#, 16#7D#, 16#18#, 16#CD#, 16#3D#, 16#8B#,
         16#45#, 16#18#, 16#9E#, 16#7A#, 16#F1#, 16#CD#, 16#39#, 16#D9#,
         16#CD#, 16#39#, 16#45#, 16#10#, 16#CD#, 16#35#, 16#C9#, 16#CD#,
         16#34#, 16#D1#, 16#CD#, 16#39#, 16#7D#, 16#18#, 16#CD#, 16#3D#,
         16#8B#, 16#45#, 16#18#, 16#9E#, 16#76#, 16#07#, 16#CD#, 16#34#,
         16#E1#, 16#F7#, 16#D3#, 16#F7#, 16#D1#, 16#CD#, 16#39#, 16#45#,
         16#08#, 16#CD#, 16#34#, 16#D9#, 16#CD#, 16#39#, 16#7D#, 16#18#,
         16#CD#, 16#3D#, 16#8B#, 16#45#, 16#18#, 16#9E#, 16#73#, 16#05#,
         16#CD#, 16#34#, 16#E9#, 16#F7#, 16#D3#, 16#CD#, 16#39#, 16#D9#,
         16#CD#, 16#35#, 16#F2#, 16#23#, 16#C9#, 16#74#, 16#03#, 16#CD#,
         16#35#, 16#E0#, 16#23#, 16#DB#, 16#74#, 16#05#, 16#CD#, 16#3A#,
         16#F1#, 16#EB#, 16#03#, 16#CD#, 16#3A#, 16#F9#, 16#CD#, 16#39#,
         16#1D#, 16#CD#, 16#3D#);
      return RESULT;
   end MYTAN;

   function MYCOT (X : REAL) return REAL is
   -- Cotangent with no checking
   begin
      return 1.0 / MYTAN (X);
   end MYCOT;

   function SQRT (X : REAL) return REAL is
      RESULT : REAL;
   begin
      if X < 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      pragma NATIVE (
         16#CD#, 16#39#, 16#04#, 16#CD#, 16#35#, 16#FA#, 16#CD#, 16#39#,
         16#1D#, 16#CD#, 16#3D#);
      return RESULT;
   end SQRT;

   function LN (X : REAL) return REAL is
      RESULT : REAL;
   begin
      pragma NATIVE (
         16#CD#, 16#35#, 16#ED#, 16#CD#, 16#39#, 16#04#, 16#CD#, 16#35#,
         16#F1#, 16#CD#, 16#39#, 16#1D#, 16#CD#, 16#3D#);
      return RESULT;
   end LN;

   function LOG (X : REAL; BASE : REAL := EXP_1) return REAL is
   begin
      if X <= 0.0 or BASE <= 0.0 or BASE = 1.0 then
         raise ARGUMENT_ERROR;
      end if;
      if BASE = EXP_1 then
         return LN (X);
      else
         return LN (X) / LN (BASE);
      end if;
   end LOG;

   function EXPONENTIAL (X : REAL) return REAL is
      RESULT : REAL;
      STATUS : INTEGER;
   begin
      pragma NATIVE (
         16#CD#, 16#39#, 16#04#, 16#CD#, 16#35#, 16#EA#, 16#CD#, 16#3A#,
         16#C9#, 16#CD#, 16#35#, 16#C0#, 16#CD#, 16#35#, 16#FC#, 16#CD#,
         16#35#, 16#C0#, 16#CD#, 16#34#, 16#EA#, 16#CD#, 16#35#, 16#E4#,
         16#CD#, 16#39#, 16#7D#, 16#08#, 16#CD#, 16#3D#, 16#8B#, 16#45#,
         16#08#, 16#9E#, 16#CD#, 16#35#, 16#E1#, 16#CD#, 16#35#, 16#F0#,
         16#CD#, 16#35#, 16#E8#, 16#CD#, 16#3A#, 16#C1#, 16#73#, 16#06#,
         16#CD#, 16#35#, 16#E8#, 16#CD#, 16#3A#, 16#F1#, 16#CD#, 16#35#,
         16#FD#, 16#CD#, 16#39#, 16#1D#, 16#CD#, 16#39#, 16#D8#, 16#CD#,
         16#39#, 16#D8#);
      return RESULT;
   end EXPONENTIAL;

   function EXP (X : REAL; BASE : REAL := EXP_1) return REAL is
   begin
      if BASE <= 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      if BASE = EXP_1 then
         return EXPONENTIAL (X);
      else
         return EXPONENTIAL (X * LN (BASE));
      end if;
   end EXP;

   function SIN (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL is
      CT : REAL;
      TX : REAL;
   begin
      if CYCLE = 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      TX := (X / CYCLE) * 2.0 * PI;
      TX := TX rem (2.0 * PI); -- Floating-point remainder
      if (TX = 0.0) or (TX = PI) then -- Avoid division by zero
         return 0.0;
      else
         CT := MYCOT (TX / 2.0); -- Argument has already been checked
         return (2.0 * CT) / (1.0 + CT * CT);
      end if;
   end SIN;

   function COS (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL is
      CT : REAL;
      TX : REAL;
   begin
      if CYCLE = 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      TX := (X / CYCLE) * 2.0 * PI;
      TX := TX rem (2.0 * PI);
      if (TX = 0.0) or (TX = PI) then -- Avoid division by zero
         return 1.0;
      else
         CT := MYCOT (TX / 2.0); -- Argument has already been checked
         return - (1.0 - CT * CT) / (1.0 + CT * CT);
      end if;
   end COS;

   function TAN (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL is

      TX : REAL;

   begin
      if CYCLE = 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      TX := (X / CYCLE) * 2.0 * PI;
      TX := TX rem (2.0 * PI);
      return MYTAN (TX);
   end TAN;

   function COT (X : REAL; CYCLE : REAL := 2.0 * PI) return REAL is
   begin
      return 1.0 / TAN (X, CYCLE);
   end COT;

   function ARCSIN (X : REAL) return REAL is
   begin
      if abs X > 1.0 then
         raise ARGUMENT_ERROR;
      end if;
      return ARCTAN (X / SQRT ((1.0 - X) * (1.0 + X)));
   end ARCSIN;

   function ARCCOS (X : REAL) return REAL is
   begin
      if abs X > 1.0 then
         raise ARGUMENT_ERROR;
      end if;
      return 2.0 * ARCTAN (SQRT ((1.0 - X) / (1.0 + X)));
   end ARCCOS;

   function ARCTAN (X : REAL; Y : REAL := 1.0) return REAL is

      PIOVER2 : constant REAL := PI / 2.0;

      function ATAN (X, Y : in REAL) return REAL is
         RESULT : REAL;
      begin
         pragma NATIVE (
            16#CD#, 16#39#, 16#04#, 16#CD#, 16#39#, 16#44#, 16#08#, 16#CD#,
            16#35#, 16#F3#, 16#CD#, 16#39#, 16#1D#, 16#CD#, 16#3D#);
         return RESULT;
      end ATAN;

   begin
      if X = 0.0 and Y = 0.0 then
         raise ARGUMENT_ERROR;
      end if;
      if X / Y < 0.0 then
         return - ARCTAN (-X, Y);
      elsif X > Y then
         return PIOVER2 - ATAN (Y, X);
      else
         return ATAN (X, Y);
      end if;
   end ARCTAN;

   function ARCCOT (X : REAL; Y : REAL := 1.0) return REAL is
   begin
      return ARCTAN (Y, X);
   end ARCCOT;

   function SINH (X : REAL) return REAL is
      EABSX : constant REAL := EXP (abs X);
      RESULT : REAL;
   begin
      RESULT := 0.5 * (EABSX - 1.0 + (EABSX - 1.0) / EABSX);
      if X >= 0.0 then
         return RESULT;
      else
         return - RESULT;
      end if;
   end SINH;

   function COSH (X : REAL) return REAL is
      EABSX : constant REAL := EXP (abs X);
   begin
      return 0.5 * (EABSX + 1.0 / EABSX);
   end COSH;

   function TANH (X : REAL) return REAL is
      E2ABSX : constant REAL := EXP (2.0 * abs X);
      RESULT : REAL;
   begin
      RESULT := (E2ABSX - 1.0) / (E2ABSX + 1.0);
      if X >= 0.0 then
         return RESULT;
      else
         return - RESULT;
      end if;
   end TANH;

   function COTH (X : REAL) return REAL is
   begin
      return 1.0 / TANH (X);
   end COTH;

   function ARCSINH (X : REAL) return REAL is

      ABSX : constant REAL := abs X;

      function ASINH (X : REAL) return REAL is
         SIGNX : constant INTEGER := INTEGER (X / ABSX);
         Z : constant REAL :=
            ABSX + ABSX / (1.0 / ABSX + SQRT (1.0 + (1.0 / ABSX / ABSX)));
         RESULT : REAL;
      begin
         pragma NATIVE (
            16#CD#, 16#3B#, 16#05#, 16#CD#, 16#35#, 16#ED#, 16#CD#, 16#3A#,
            16#C9#, 16#CD#, 16#39#, 16#45#, 16#02#, 16#CD#, 16#35#, 16#E8#,
            16#CD#, 16#3A#, 16#C1#, 16#CD#, 16#35#, 16#F1#, 16#CD#, 16#39#,
            16#5D#, 16#0A#, 16#CD#, 16#3D#);
         return RESULT;
      end ASINH;

   begin
      return ASINH (X);
   end ARCSINH;

   function ARCCOSH (X : REAL) return REAL is

      function ACOSH (X : REAL) return REAL is
         Z : constant REAL := X + SQRT ((X - 1.0) * (X + 1.0));
         RESULT : REAL;
      begin
         pragma NATIVE (
            16#CD#, 16#35#, 16#ED#, 16#CD#, 16#39#, 16#05#, 16#CD#, 16#35#,
            16#F1#, 16#CD#, 16#39#, 16#5D#, 16#08#, 16#CD#, 16#3D#);
         return RESULT;
      end ACOSH;

   begin
      if X < 1.0 then
         raise ARGUMENT_ERROR;
      end if;
      return ACOSH (X);
   end ARCCOSH;

   function ARCTANH (X : REAL) return REAL is

      ABSX : constant REAL := abs X;

      function ATANH (X : REAL) return REAL is
         SIGNX : constant INTEGER := INTEGER (X / ABSX);
         Z : constant REAL := 2.0 * ABSX / (1.0 - ABSX);
         RESULT : REAL;
      begin
         pragma NATIVE (
            16#CD#, 16#3B#, 16#05#, 16#CD#, 16#35#, 16#ED#, 16#CD#, 16#3A#,
            16#C9#, 16#CD#, 16#39#, 16#45#, 16#02#, 16#CD#, 16#35#, 16#E8#,
            16#CD#, 16#3A#, 16#C1#, 16#CD#, 16#35#, 16#F1#, 16#CD#, 16#39#,
            16#5D#, 16#0A#, 16#CD#, 16#3D#);
         return RESULT / 2.0;
      end ATANH;

   begin
      if abs X >= 1.0 then
         raise ARGUMENT_ERROR;
      end if;
      return ATANH (X);
   end ARCTANH;

   function ARCCOTH (X : REAL) return REAL is
   begin
      return ARCTANH (1.0 / X);
   end ARCCOTH;

end MATH;


