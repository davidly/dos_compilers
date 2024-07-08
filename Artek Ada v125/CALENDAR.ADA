
package CALENDAR is

   type TIME is private;

   subtype DURATION is FLOAT; -- Nonstandard

   subtype YEAR_NUMBER is INTEGER range 1901 .. 2099;
   subtype MONTH_NUMBER is INTEGER range 1 .. 12;
   subtype DAY_NUMBER is INTEGER range 1 .. 31;

   subtype DAY_DURATION is DURATION range 0.0 .. 86_400.0;

   function CLOCK return TIME;
   function YEAR (DATE : TIME) return YEAR_NUMBER;
   function MONTH (DATE : TIME) return MONTH_NUMBER;
   function DAY (DATE : TIME) return DAY_NUMBER;
   function SECONDS (DATE : TIME) return DAY_DURATION;

   procedure SPLIT (DATE     : in  TIME;
                    YEAR     : out YEAR_NUMBER;
                    MONTH    : out MONTH_NUMBER;
                    DAY      : out DAY_NUMBER;
                    SECONDS  : out DAY_DURATION);

   function TIME_OF (YEAR : YEAR_NUMBER;
                     MONTH : MONTH_NUMBER;
                     DAY : DAY_NUMBER;
                     SECONDS : DAY_DURATION := 0.0) return TIME;

   function "+"  (LEFT : TIME;      RIGHT : DURATION) return TIME;
   function "+"  (LEFT : DURATION;  RIGHT : TIME)     return TIME;
   function "-"  (LEFT : TIME;      RIGHT : DURATION) return TIME;
   function "-"  (LEFT : TIME;      RIGHT : TIME)     return DURATION;

   function "<"  (LEFT, RIGHT : TIME) return BOOLEAN;
   function "<=" (LEFT, RIGHT : TIME) return BOOLEAN;
   function ">"  (LEFT, RIGHT : TIME) return BOOLEAN;
   function ">=" (LEFT, RIGHT : TIME) return BOOLEAN;

   TIME_ERROR : exception;

private

   type TIME is
      record
         YEAR_FIELD : YEAR_NUMBER;
         MONTH_FIELD : MONTH_NUMBER;
         DAY_FIELD : DAY_NUMBER;
         SEC_FIELD : DAY_DURATION;
      end record;

end;

with DOS_INTERFACE; use DOS_INTERFACE;

package body CALENDAR is

   type MONTH_ARRAY is array (MONTH_NUMBER) of DAY_NUMBER;
   DAYS_IN_MONTH : constant MONTH_ARRAY :=
      (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   FEBRUARY : constant MONTH_NUMBER := 2;
   DAYS_IN_FEB_WHEN_LEAP : constant DAY_NUMBER := 29;

   function IS_LEAP_YEAR (YEAR : YEAR_NUMBER) return BOOLEAN is
   begin
      return (YEAR rem 4) = 0; -- 2000 is a leap year
   end IS_LEAP_YEAR;

   function CLOCK return TIME is
      HOUR_DURATION : constant DURATION := 3600.0; -- 1 hour in seconds
      MINUTE_DURATION : constant DURATION := 60.0; -- 1 minute in seconds
      SECOND_DURATION : constant DURATION := 1.0;  -- 1 second
      HUNDREDTH_DURATION : constant DURATION := 0.01; -- 1/100 second
      R : REG_8086;
      T : TIME;
   begin
      R . AX := 16#2A00#; -- Get date from DOS
      CALL_DOS (R);
      T . YEAR_FIELD := YEAR_NUMBER (R . CX); -- CX contains year
      T . MONTH_FIELD := MONTH_NUMBER (R . DX / 256); -- DH contains month
      T . DAY_FIELD := DAY_NUMBER (R . DX rem 256); -- DL contains day
      R . AX := 16#2C00#; -- Get time from DOS
      CALL_DOS (R);
      T . SEC_FIELD :=
           HOUR_DURATION      * FLOAT (R . CX / 256)    -- CH contains hour
         + MINUTE_DURATION    * FLOAT (R . CX rem 256)  -- CL contains minute
         + SECOND_DURATION    * FLOAT (R . DX / 256)    -- DH contains second
         + HUNDREDTH_DURATION * FLOAT (R . DX rem 256); -- DL contains hundredth
      return T;
   end CLOCK;

   function YEAR (DATE : TIME) return YEAR_NUMBER is
   begin
      return DATE . YEAR_FIELD;
   end YEAR;

   function MONTH (DATE : TIME) return MONTH_NUMBER is
   begin
      return DATE . MONTH_FIELD;
   end MONTH;

   function DAY (DATE : TIME) return DAY_NUMBER is
   begin
      return DATE . DAY_FIELD;
   end DAY;

   function SECONDS (DATE : TIME) return DAY_DURATION is
   begin
      return DATE . SEC_FIELD;
   end SECONDS;

   procedure SPLIT (DATE     : in  TIME;
                    YEAR     : out YEAR_NUMBER;
                    MONTH    : out MONTH_NUMBER;
                    DAY      : out DAY_NUMBER;
                    SECONDS  : out DAY_DURATION) is
   begin
      YEAR := DATE . YEAR_FIELD;
      MONTH := DATE . MONTH_FIELD;
      DAY := DATE . DAY_FIELD;
      SECONDS := DATE . SEC_FIELD;
   end SPLIT;

   function TIME_OF (YEAR : YEAR_NUMBER;
                     MONTH : MONTH_NUMBER;
                     DAY : DAY_NUMBER;
                     SECONDS : DAY_DURATION := 0.0) return TIME is

      function DAYS_IN (YEAR : in YEAR_NUMBER; MONTH : in MONTH_NUMBER)
         return DAY_NUMBER is
      begin
         if IS_LEAP_YEAR (YEAR) and MONTH = FEBRUARY then
            return DAYS_IN_FEB_WHEN_LEAP;
         else
            return DAYS_IN_MONTH (MONTH);
         end if;
      end DAYS_IN;

   begin
      if DAY > DAYS_IN (YEAR, MONTH) then
         raise TIME_ERROR;
      else
         return TIME'(YEAR, MONTH, DAY, SECONDS);
      end if;
   end TIME_OF;

   function "+" (LEFT : TIME; RIGHT : DURATION) return TIME is
   begin
      return LEFT;
   end "+";

   function "+" (LEFT : DURATION; RIGHT : TIME) return TIME is
   begin
      return RIGHT;
   end "+";

   function "-" (LEFT : TIME; RIGHT : DURATION) return TIME is
   begin
      return LEFT;
   end "-";

   function "-" (LEFT : TIME; RIGHT : TIME) return DURATION is
   begin
      return 0.0;
   end "-";

   function "<" (LEFT, RIGHT : TIME) return BOOLEAN is
   begin
      if LEFT . YEAR_FIELD = RIGHT . YEAR_FIELD then
         if LEFT . MONTH_FIELD = RIGHT . MONTH_FIELD then
            if LEFT . DAY_FIELD = RIGHT . DAY_FIELD then
               return LEFT . SEC_FIELD < RIGHT . SEC_FIELD;
            else
               return LEFT . DAY_FIELD < RIGHT . DAY_FIELD;
            end if;
         else
            return LEFT . MONTH_FIELD < RIGHT . MONTH_FIELD;
         end if;
      end if;
      return LEFT . YEAR_FIELD < RIGHT . YEAR_FIELD;
   end "<";

   function "<=" (LEFT, RIGHT : TIME) return BOOLEAN is
   begin
      if LEFT . YEAR_FIELD = RIGHT . YEAR_FIELD then
         if LEFT . MONTH_FIELD = RIGHT . MONTH_FIELD then
            if LEFT . DAY_FIELD = RIGHT . DAY_FIELD then
               return LEFT . SEC_FIELD <= RIGHT . SEC_FIELD;
            else
               return LEFT . DAY_FIELD < RIGHT . DAY_FIELD;
            end if;
         else
            return LEFT . MONTH_FIELD < RIGHT . MONTH_FIELD;
         end if;
      end if;
      return LEFT . YEAR_FIELD < RIGHT . YEAR_FIELD;
   end "<=";

   function ">" (LEFT, RIGHT : TIME) return BOOLEAN is
   begin
      if LEFT . YEAR_FIELD = RIGHT . YEAR_FIELD then
         if LEFT . MONTH_FIELD = RIGHT . MONTH_FIELD then
            if LEFT . DAY_FIELD = RIGHT . DAY_FIELD then
               return LEFT . SEC_FIELD > RIGHT . SEC_FIELD;
            else
               return LEFT . DAY_FIELD > RIGHT . DAY_FIELD;
            end if;
         else
            return LEFT . MONTH_FIELD > RIGHT . MONTH_FIELD;
         end if;
      end if;
      return LEFT . YEAR_FIELD > RIGHT . YEAR_FIELD;
   end ">";

   function ">=" (LEFT, RIGHT : TIME) return BOOLEAN is
   begin
      if LEFT . YEAR_FIELD = RIGHT . YEAR_FIELD then
         if LEFT . MONTH_FIELD = RIGHT . MONTH_FIELD then
            if LEFT . DAY_FIELD = RIGHT . DAY_FIELD then
               return LEFT . SEC_FIELD >= RIGHT . SEC_FIELD;
            else
               return LEFT . DAY_FIELD > RIGHT . DAY_FIELD;
            end if;
         else
            return LEFT . MONTH_FIELD > RIGHT . MONTH_FIELD;
         end if;
      end if;
      return LEFT . YEAR_FIELD > RIGHT . YEAR_FIELD;
   end ">=";

end CALENDAR;

