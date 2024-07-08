--
-- CONIO.ADA
--
-- Console input/output package for Artek Ada
-- (Revision 1.1)
--
-- Copyright (C) 1986, 1987 Artek Corporation
--
-- Conio contains screen manipulation routines
-- using ANSI standard cursor sequences.
-- The package requires ANSI.SYS or a similar
-- device driver to be installed.
-- To install ANSI.SYS, insert this line in the
-- CONFIG.SYS file on the root directory:
--
-- DEVICE=ANSI.SYS
--

package CON_IO is

   -- IBM PC specific constants

   X_SIZE : constant := 80;
   Y_SIZE : constant := 24;
   NUM_COLORS : constant := 8;

   subtype X_COORDINATE is INTEGER range 0 .. X_SIZE - 1;
   subtype Y_COORDINATE is INTEGER range 0 .. Y_SIZE - 1;
   subtype COLOR_NUMBER is INTEGER range 0 .. NUM_COLORS - 1;

   procedure CLS;
   procedure CURSOR (X : in X_COORDINATE; Y : in Y_COORDINATE);
   procedure CURSOR_UP (LINES : in POSITIVE := 1);
   procedure CURSOR_DOWN (LINES : in POSITIVE := 1);
   procedure CURSOR_LEFT (COLUMNS : in POSITIVE := 1);
   procedure CURSOR_RIGHT (COLUMNS : in POSITIVE := 1);
   procedure COLOR (C : in COLOR_NUMBER);
   procedure BACKGROUND (C : in COLOR_NUMBER);
   procedure REV_VIDEO;
   procedure INTENSITY;
   procedure UNDERLINE;
   procedure BLINK;
   procedure ALL_OFF;
   procedure GET (S : in out STRING);
   procedure GET (C : in out CHARACTER);
   procedure PUT (S : in STRING);
   procedure PUT (C : in CHARACTER);
   procedure PUT_LINE (S : in STRING);
   procedure PUT_LINE (C : in CHARACTER);
   procedure BOX (
      X_UPPER : in X_COORDINATE; Y_UPPER : in Y_COORDINATE;
      X_LOWER : in X_COORDINATE; Y_LOWER : in Y_COORDINATE;
      DOUBLE : in BOOLEAN := FALSE);

end;

with QPUT, QGET;

package body CON_IO is

   use ASCII;

   procedure CLS is
   begin
      QPUT (ESC & "[2J");
   end CLS;

   function BUTFIRST (S : in STRING) return STRING is
   -- Used to cut the initial space from INTEGER'IMAGE
   begin
      return S (2..S'LAST);
   end BUTFIRST;

   procedure CURSOR (X : in X_COORDINATE; Y : in Y_COORDINATE) is
   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (Y + 1)) & ';' &
         BUTFIRST (INTEGER'IMAGE (X + 1)) & 'H');
   end CURSOR;

   procedure CURSOR_UP (LINES : in POSITIVE := 1) is
   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (LINES)) & 'A');
   end CURSOR_UP;

   procedure CURSOR_DOWN (LINES : in POSITIVE := 1) is
   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (LINES)) & 'B');
   end CURSOR_DOWN;

   procedure CURSOR_RIGHT (COLUMNS : in POSITIVE := 1) is
   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (COLUMNS)) & 'C');
   end CURSOR_RIGHT;

   procedure CURSOR_LEFT (COLUMNS : in POSITIVE := 1) is
   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (COLUMNS)) & 'D');
   end CURSOR_LEFT;

   procedure REV_VIDEO is
   begin
      QPUT (ESC & "[7m");
   end REV_VIDEO;

   procedure INTENSITY is
   begin
      QPUT (ESC & "[1m");
   end INTENSITY;

   procedure UNDERLINE is
   begin
      QPUT (ESC & "[4m");
   end UNDERLINE;

   procedure BLINK is
   begin
      QPUT (ESC & "[5m");
   end BLINK;

   procedure ALL_OFF is
   begin
      QPUT (ESC & "[0m");
   end ALL_OFF;

   procedure COLOR (C : in COLOR_NUMBER) is

   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (C + 30)) & 'm');
   end COLOR;

   procedure BACKGROUND (C : in COLOR_NUMBER) is

   begin
      QPUT (ESC & '[' & BUTFIRST (INTEGER'IMAGE (C + 40)) & 'm');
   end BACKGROUND;

   procedure GET (S : in out STRING) is
   -- This procedure gets a string from the console.
   -- Backspacing is allowed.
   -- The value in the parameter S is used to initialize the
   -- field and is written to the screen before input takes place.

      PLACE : INTEGER := S'FIRST;
      C : CHARACTER;

   begin
      QPUT (S);
      CURSOR_LEFT (S'LENGTH);
      loop
         QGET (C);
         case C is
            when CR => -- End entry by hitting ENTER key
               exit;
            when BS | DEL => -- Erase last character entered
               if PLACE > S'FIRST then
                  PLACE := PLACE - 1;
                  CURSOR_LEFT;
                  S (PLACE) := ' ';
                  QPUT (" ");
                  CURSOR_LEFT;
               end if;
            when NUL => -- "Swallow" IBM extended ASCII code
               QGET (C);
            when HT | LF | ESC => -- Ignore control characters
               null;
            when others => -- Allow any other character to be entered
               S (PLACE) := C;
               QPUT (C & ""); -- This converts C into a STRING
               if PLACE < S'LAST then
                  PLACE := PLACE + 1;
               else
                  CURSOR_LEFT;
               end if;
         end case;
      end loop;
   end GET;

   procedure GET (C : in out CHARACTER) is
      S : STRING (1..1) := (1 => C);
   begin
      GET (S);
      C := S (1);
   end GET;

   procedure PUT (S : in STRING) is
   begin
      QPUT (S);
   end PUT;

   procedure PUT (C : in CHARACTER) is
      S : STRING (1..1) := (1 => C);
   begin
      QPUT (S);
   end PUT;

   procedure PUT_LINE (S : in STRING) is
      CRLF : STRING (1..2) := (CR, LF);
   begin
      QPUT (S & CRLF);
   end PUT_LINE;

   procedure PUT_LINE (C : in CHARACTER) is
      S : STRING (1..3) := (C, CR, LF);
   begin
      QPUT (S);
   end PUT_LINE;

   procedure BOX (
      X_UPPER : in X_COORDINATE; Y_UPPER : in Y_COORDINATE;
      X_LOWER : in X_COORDINATE; Y_LOWER : in Y_COORDINATE;
      DOUBLE : in BOOLEAN := FALSE) is

      HORIZONTAL_LINE : CHARACTER := CHARACTER'VAL (196);
      UPPER_LEFT_CORNER : CHARACTER := CHARACTER'VAL (218);
      UPPER_RIGHT_CORNER : CHARACTER := CHARACTER'VAL (191);
      VERTICAL_LINE : CHARACTER := CHARACTER'VAL (179);
      LOWER_LEFT_CORNER : CHARACTER := CHARACTER'VAL (192);
      LOWER_RIGHT_CORNER : CHARACTER := CHARACTER'VAL (217);

   begin
      if X_UPPER >= X_LOWER or Y_UPPER >= Y_LOWER then
         raise CONSTRAINT_ERROR;
      end if;
      if DOUBLE then
         null;
      end if;
      declare
         NORMAL_HORIZON : STRING (1..X_LOWER - X_UPPER - 1) :=
            (others => HORIZONTAL_LINE);
      begin
         CURSOR (X_UPPER, Y_UPPER);
         PUT (UPPER_LEFT_CORNER & NORMAL_HORIZON & UPPER_RIGHT_CORNER);
         for I in Y_UPPER + 1 .. Y_LOWER - 1 loop
            CURSOR (X_UPPER, I);
            PUT (VERTICAL_LINE);
            CURSOR_RIGHT (X_LOWER - X_UPPER - 1);
            PUT (VERTICAL_LINE);
         end loop;
         CURSOR (X_UPPER, Y_LOWER);
         PUT (LOWER_LEFT_CORNER & NORMAL_HORIZON & LOWER_RIGHT_CORNER);
      end;
   end;

end;

