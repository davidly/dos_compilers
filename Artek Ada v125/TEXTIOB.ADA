--
-- T E X T   I N P U T / O U T P U T
--
-- Body of the Package Text_IO
--
-- According to ANSI/MIL-STD 1815A (1983)
-- Implemented for Artek Ada
--
-- Copyright (C) 1986, 1987 Artek Corporation
-- Authors : O. Karlsson & V. Thorsteinsson
--
--
-- Version: 1.00  February 1986
--                Deviations from the standard:
--
--                ENUMERATION_IO not implemented
--                FIXED_IO not implemented
--                CHARACTER PUT and GET accept 8 bit characters
--                GET and PUT floating point to/from string not implemented
--
-- Version: 1.01  June 1986
--                PUT and GET floating point to/from string implemented
--                GET_LINE for console input corrected
--
-- Version: 1.02  November 1986
--                ENUMERATION_IO implemented
--

with DOS_INTERFACE, SYSTEM;
use DOS_INTERFACE, SYSTEM, ASCII;

package body TEXT_IO is

   -- Data types and objects

   R : REG_8086;

   EOF : constant CHARACTER := CHARACTER (26);

   IN_CONSOLE_HANDLE  : constant INTEGER := 0;  -- DOS Handle for STDIN
   OUT_CONSOLE_HANDLE : constant INTEGER := 1;  -- DOS Handle for STDOUT

   DOS_INPUT, DOS_OUTPUT : FILE_TYPE;

   CURR_INPUT, CURR_OUTPUT : FILE_TYPE;

   DOS_IO_NAME : FILE_NAME_STRING :=
      (1 => 'C', 2 => 'O', 3 => 'N', others => ' ');  -- CON file

   PREV_CHAR : CHARACTER;
   UNGET_RAISED : BOOLEAN := FALSE;

--
-- Utility procedure to skip last character read from a file
-- Same as " lseek (file, -1) " relative from the file position
--

   procedure UNGET (FILE : in FILE_TYPE) is

   begin
      if FILE . HANDLE = 0 then -- Can't do UNGET on console input
         UNGET_RAISED := TRUE;
      else
         R . AX := 16#4201#;    -- DOS function 42, lseek
         R . BX := WORD (FILE . HANDLE);
         R . CX := -1;          -- Desired location from current position
         R . DX := -1;
         CALL_DOS (R);
         if R . FLAGS mod 2 = 1 then -- Carry was set
            raise USE_ERROR;         -- There should never be error here
         end if;
      end if;
   end UNGET;

--
-- procedures READ and WRITE are used internally
--

   procedure READ (FILE : in FILE_TYPE; ITEM : out CHARACTER) is

   begin
-- See comment at start of WRITE regarding checks on FILE
      if FILE . HANDLE = 0 and UNGET_RAISED then -- Called UNGET on console
         ITEM := PREV_CHAR;
         UNGET_RAISED := FALSE;
      elsif FILE . HANDLE = 0 then -- Input from console
         R . AX := 16#0100#;     -- DOS function 01, keyboard input
         CALL_DOS (R);
         PREV_CHAR := CHARACTER (R . AX mod 256);
         ITEM := PREV_CHAR;
      else
         R . AX := 16#3F00#;     -- DOS function 3F, read from a file or device
         R . BX := WORD (FILE . HANDLE);
         R . CX := 1;            -- Read one byte
         R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
         CALL_DOS (R);
         if R . AX = 0 then -- Read past EOF
            raise END_ERROR;
         end if;
         if R . FLAGS mod 2 = 1 then -- Carry set
            raise USE_ERROR;  -- Access denied or invalid file handle
         end if;
      end if;
   end READ;

   procedure WRITE (FILE : in FILE_TYPE; ITEM : in CHARACTER) is

   begin
-- The following checks are not needed since WRITE is never called
-- if one of the conditions is true
--      if FILE = null then
--         raise STATUS_ERROR;
--      elsif FILE . MODE /= OUT_FILE then
--         raise MODE_ERROR;
--      end if;
      R . AX := 16#4000#;    -- DOS function 40, write to a file or device
      R . BX := WORD (FILE . HANDLE);
      R . CX := 1;           -- Write one byte
      R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX = 0 then -- No output made, probably disk full error
         raise USE_ERROR;
      end if;
      if R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
   end WRITE;

   procedure WRITE_STRING (FILE : in FILE_TYPE; ITEM : in STRING) is

   begin
      R . AX := 16#4000#;    -- DOS function 40, write to a file or device
      R . BX := WORD (FILE . HANDLE);
      R . CX := WORD (ITEM'LENGTH);  -- Write LENGTH bytes
      R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX /= WORD (ITEM'LENGTH) then -- Probably disk full error
         raise USE_ERROR;
      end if;
      if R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
   end WRITE_STRING;

--
-- File management
--

   procedure CREATE (
      FILE : in out FILE_TYPE;
      MODE : in FILE_MODE := OUT_FILE;
      NAME : in STRING := "";
      FORM : in STRING := "") is

      ASCIIZ_NAME : FILE_NAME_STRING;
      BLANK_NAME : FILE_NAME_STRING := (others => ' ');
      BLANK_FORM : FORM_NAME_STRING := (others => ' ');

-- See chapter 14.3.1

   begin -- Concatenate a null character
      if FILE /= null then   -- Already open
         raise STATUS_ERROR;
      end if;
      ASCIIZ_NAME (1..NAME'LENGTH) := NAME;
      ASCIIZ_NAME (NAME'LENGTH + 1) := NUL;
      R . AX := 16#3C00#; -- Function 3C, Create a file
      R . DX := WORD (ASCIIZ_NAME'ADDRESS); -- Address of the filename
      R . CX := 16#0000#; -- No attributes
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry was set
         if R . AX > 3 then       -- 4 = Too many open files, 5 = access denied
            raise USE_ERROR;
         else
            raise NAME_ERROR;     -- 3 = Path not found
         end if;
      end if;
      FILE := new FILE_DESCR'
         (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          MODE => MODE,
          COL => 1, LINE => 1, PAGE => 1,
          LINE_LENGTH => UNBOUNDED, PAGE_LENGTH => UNBOUNDED,
          HANDLE => INTEGER (R . AX));
      FILE . NAME (1..NAME'LENGTH) := NAME;
      FILE . FORM (1..FORM'LENGTH) := FORM;
   end CREATE;

   procedure OPEN (
      FILE : in out FILE_TYPE;
      MODE : in FILE_MODE;
      NAME : in STRING;
      FORM : in STRING := "") is

      ASCIIZ_NAME : FILE_NAME_STRING;
      BLANK_NAME : FILE_NAME_STRING := (others => ' ');
      BLANK_FORM : FORM_NAME_STRING := (others => ' ');

-- See chapter 14.3.1

   begin
      if FILE /= null then    -- File already open
         raise STATUS_ERROR;
      end if;
      ASCIIZ_NAME (1..NAME'LENGTH) := NAME;
      ASCIIZ_NAME (NAME'LENGTH + 1) := NUL;
      case MODE is
         when IN_FILE => R . AX := 16#3D00#;  -- AH = 3D, Open a file
         when OUT_FILE => R . AX := 16#3D01#; -- AL = 00, Open for input
      end case;                               -- AL = 01, Open for output
      R . DX := WORD (ASCIIZ_NAME'ADDRESS);
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry was set
         if R . AX > 3 then
            raise USE_ERROR; -- Access denied and to many files open
         else
            raise NAME_ERROR; -- File not found
         end if;
      end if;
      FILE := new FILE_DESCR'
         (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          COL => 1, LINE => 1, PAGE => 1,
          LINE_LENGTH => UNBOUNDED, PAGE_LENGTH => UNBOUNDED,
          MODE => MODE,
          HANDLE => INTEGER (R . AX));
      FILE . NAME (1..NAME'LENGTH) := NAME;
      FILE . FORM (1..FORM'LENGTH) := FORM;
   end OPEN;

   procedure CLOSE (FILE : in out FILE_TYPE) is

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      if FILE . MODE = OUT_FILE then
         NEW_PAGE (FILE);
         WRITE (FILE, EOF);
      end if;
      R . AX := 16#3E00#;    -- DOS function 3E, Close a file handle
      R . BX := WORD (FILE . HANDLE);
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR; -- Invalid handle.  This error should never
      end if;             -- occur.  Something is wrong in the file system.
      FILE := null;
   end CLOSE;

   procedure DELETE (FILE : in out FILE_TYPE) is

      ASCIIZ_NAME : FILE_NAME_STRING;

-- See chapter 14.3.1

   begin
      CLOSE (FILE);
      ASCIIZ_NAME (1..FILE . NAMELEN) := FILE . NAME (1..FILE . NAMELEN);
      ASCIIZ_NAME (FILE . NAMELEN + 1) := NUL;
      R . AX := 16#4100#; -- DOS function 41, delete a file
      R . DX := WORD (ASCIIZ_NAME'ADDRESS);
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- Access denied
      end if;
   end DELETE;

   procedure RESET (FILE : in out FILE_TYPE; MODE : in FILE_MODE) is

      TL, TP : COUNT;

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif (FILE = CURR_INPUT and MODE /= IN_FILE) or
         (FILE = CURR_OUTPUT and MODE /= OUT_FILE) then
         raise MODE_ERROR;
      end if;
      TL := FILE . LINE_LENGTH;
      TP := FILE . PAGE_LENGTH;
      CLOSE (FILE); -- Must close and reopen since MODE changes
      OPEN (FILE, MODE, FILE . NAME, FILE . FORM);
      if FILE . MODE = IN_FILE then  -- Restore line and page lengths
         FILE . LINE_LENGTH := TL;
         FILE . PAGE_LENGTH := TP;
      end if;
   end RESET;

   procedure RESET (FILE : in out FILE_TYPE) is

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      if FILE . MODE = OUT_FILE then
         NEW_PAGE (FILE);
         WRITE (FILE, EOF);
      end if;
      -- Do an LSEEK (FILE, 0);
      R . AX := 16#4200#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE);
      R . CX := 0;           -- Desired location from BOF
      R . DX := 0;
      CALL_DOS (R);
      if R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;
      end if;
      FILE . COL := 1;
      FILE . LINE := 1;
      FILE . PAGE := 1;
   end RESET;

   function MODE (FILE : in FILE_TYPE) return FILE_MODE is

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . MODE;
   end MODE;

   function NAME (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . NAME;
   end NAME;

   function FORM (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.3.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . FORM;
   end FORM;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN is

-- See chapter 14.3.1

   begin
      return FILE /= null;
   end IS_OPEN;

--
-- Control of default input and output files
--

   procedure SET_INPUT (FILE : in FILE_TYPE) is

-- See chapter 14.3.2

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      CURR_INPUT := FILE;
   end SET_INPUT;

   procedure SET_OUTPUT (FILE : in FILE_TYPE) is

-- See chapter 14.3.2

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      CURR_OUTPUT := FILE;
   end SET_OUTPUT;

   function STANDARD_INPUT return FILE_TYPE is

-- See chapter 14.3.2

   begin
      return DOS_INPUT;
   end STANDARD_INPUT;

   function STANDARD_OUTPUT return FILE_TYPE is

-- See chapter 14.3.2

   begin
      return DOS_OUTPUT;
   end STANDARD_OUTPUT;

   function CURRENT_INPUT return FILE_TYPE is

-- See chapter 14.3.2

   begin
      return CURR_INPUT;
   end CURRENT_INPUT;

   function CURRENT_OUTPUT return FILE_TYPE is

-- See chapter 14.3.2

   begin
      return CURR_OUTPUT;
   end CURRENT_OUTPUT;

--
-- Specification of line and page lengths
--

   procedure SET_LINE_LENGTH (FILE : in FILE_TYPE; TO : in COUNT) is

-- See chapter 14.3.3

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      FILE . LINE_LENGTH := TO;
   end SET_LINE_LENGTH;

   procedure SET_LINE_LENGTH (TO : in COUNT) is

-- See chapter 14.3.3

   begin
      SET_LINE_LENGTH (CURR_OUTPUT, TO);
   end SET_LINE_LENGTH;

   procedure SET_PAGE_LENGTH (FILE : in FILE_TYPE; TO : in COUNT) is

-- See chapter 14.3.3

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      FILE . PAGE_LENGTH := TO;
   end SET_PAGE_LENGTH;

   procedure SET_PAGE_LENGTH (TO : in COUNT) is

-- See chapter 14.3.3

   begin
      SET_PAGE_LENGTH (CURR_OUTPUT, TO);
   end SET_PAGE_LENGTH;

   function LINE_LENGTH (FILE : in FILE_TYPE) return COUNT is

-- See chapter 14.3.3

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      return FILE . LINE_LENGTH;
   end LINE_LENGTH;

   function LINE_LENGTH return COUNT is

-- See chapter 14.3.3

   begin
      return LINE_LENGTH (CURR_OUTPUT);
   end LINE_LENGTH;

   function PAGE_LENGTH (FILE : in FILE_TYPE) return COUNT is

-- See chapter 14.3.3

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      return FILE . PAGE_LENGTH;
   end PAGE_LENGTH;

   function PAGE_LENGTH return COUNT is

-- See chapter 14.3.3

   begin
      return PAGE_LENGTH (CURR_OUTPUT);
   end PAGE_LENGTH;

--
-- Column, Line, and Page Contril
--

   procedure NEW_LINE (FILE : in FILE_TYPE;
      SPACING : in POSITIVE_COUNT := 1) is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      else
         for I in 1 .. SPACING loop
            WRITE (FILE, CR);
            WRITE (FILE, LF);
            FILE . LINE := FILE . LINE + 1;
            if (FILE . PAGE_LENGTH /= UNBOUNDED) and
               (FILE . LINE >= FILE . PAGE_LENGTH) then
               WRITE (FILE, FF);
               FILE . PAGE := FILE . PAGE + 1;
            end if;
         end loop;
         FILE . COL := 1;
      end if;
   end NEW_LINE;

   procedure NEW_LINE (SPACING : in POSITIVE_COUNT := 1) is

-- See chapter 14.3.4

   begin
      NEW_LINE (CURR_OUTPUT, SPACING);
   end NEW_LINE;

   procedure SKIP_LINE (FILE : in FILE_TYPE;
      SPACING : in POSITIVE_COUNT := 1) is

      PREVCH, CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      for I in 1..SPACING loop
         PREVCH := ' ';
         loop
            READ (FILE, CH);
            case CH is
               when CR =>
                  FILE . COL := 1;
                  if FILE . HANDLE = 0 then -- Input from console
                     FILE . LINE := FILE . LINE + 1;
                     if (FILE . PAGE_LENGTH /= UNBOUNDED) and
                        (FILE . LINE >= FILE . PAGE_LENGTH) then
                        FILE . PAGE := FILE . PAGE + 1;
                        FILE . LINE := 1;
                     end if;
                     exit;
                  end if;
               when LF =>
                  FILE . LINE := FILE . LINE + 1;
                  if (FILE . PAGE_LENGTH /= UNBOUNDED) and
                     (FILE . LINE >= FILE . PAGE_LENGTH) then
                     FILE . PAGE := FILE . PAGE + 1;
                     FILE . LINE := 1;
                  end if;
               when FF =>
                  FILE . PAGE := FILE . PAGE + 1;
                  FILE . COL := 1;
                  FILE . LINE := 1;
               when EOF =>
                  if (PREVCH = CR) or (PREVCH = LF) or (PREVCH = FF) then
                     UNGET (FILE);
                     exit;
                  else
                     raise END_ERROR;
                  end if;
               when others =>
                  if (PREVCH = CR) or (PREVCH = LF) or (PREVCH = FF) then
                     UNGET (FILE);
                     exit;
                  end if;
            end case;
            PREVCH := CH;
         end loop;
      end loop;
   end SKIP_LINE;

   procedure SKIP_LINE (SPACING : in POSITIVE_COUNT := 1) is

-- See chapter 14.3.4

   begin
      SKIP_LINE (CURR_INPUT, SPACING);
   end SKIP_LINE;

   function END_OF_LINE (FILE : in FILE_TYPE) return BOOLEAN is

      CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      READ (FILE, CH);
      UNGET (FILE);
      return (CH = CR) or (CH = LF) or (CH = EOF);
   exception
      when END_ERROR => -- If already EOF return TRUE
         UNGET (FILE);
         return TRUE;
   end END_OF_LINE;

   function END_OF_LINE return BOOLEAN is

-- See chapter 14.3.4

   begin
      return END_OF_LINE (CURR_INPUT);
   end END_OF_LINE;

   procedure NEW_PAGE (FILE : in FILE_TYPE) is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      if (FILE . COL > 1) or (FILE . COL = 1 and FILE . LINE = 1) then
         NEW_LINE (FILE); -- Sets FILE . COL := 1
      end if;
      WRITE (FILE, FF); -- Form Feed
      FILE . LINE := 1;
      FILE . PAGE := FILE . PAGE + 1;
   end NEW_PAGE;

   procedure NEW_PAGE is

-- See chapter 14.3.4

   begin
      NEW_PAGE (CURR_OUTPUT);
   end NEW_PAGE;

   procedure SKIP_PAGE (FILE : in FILE_TYPE) is

      CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      loop
         READ (FILE, CH);
         if CH = EOF then
            raise END_ERROR;
         end if;
         exit when CH = FF;
      end loop;
      FILE . LINE := 1;
      FILE . COL := 1;
      FILE . PAGE := FILE . PAGE + 1;
   end SKIP_PAGE;

   procedure SKIP_PAGE is

-- See chapter 14.3.4

   begin
      SKIP_PAGE (CURR_INPUT);
   end SKIP_PAGE;

   function END_OF_PAGE (FILE : in FILE_TYPE) return BOOLEAN is

      CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      READ (FILE, CH);  -- returns TRUE if (CR LF FF), (FF) or (EOF)
      if CH = CR or CH = LF then
         READ (FILE, CH);
         if CH = CR or CH = LF then
            READ (FILE, CH);
            UNGET (FILE);
         end if;
         UNGET (FILE);
      end if;
      UNGET (FILE);
      return CH = FF or CH = EOF;
   exception
      when END_ERROR =>
         UNGET (FILE);
         return TRUE;
   end END_OF_PAGE;

   function END_OF_PAGE return BOOLEAN is

-- See chapter 14.3.4

   begin
      return END_OF_PAGE (CURR_INPUT);
   end END_OF_PAGE;

   function END_OF_FILE (FILE : in FILE_TYPE) return BOOLEAN is

      CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      READ (FILE, CH);  -- returns TRUE if (CR LF FF EOF), (FF EOF)
                        -- or (CR LF EOF) or (EOF)
      if CH = CR or CH = LF or CH = FF then
         READ (FILE, CH);
         if CH = CR or CH = LF or CH = FF then
            READ (FILE, CH);
            if CH = CR or CH = LF or CH = FF then
               READ (FILE, CH);
               UNGET (FILE);
            end if;
            UNGET (FILE);
         end if;
         UNGET (FILE);
      end if;
      UNGET (FILE);
      return CH = EOF;
   exception
      when END_ERROR =>
         UNGET (FILE);
         return TRUE;
   end END_OF_FILE;

   function END_OF_FILE return BOOLEAN is

-- See chapter 14.3.4

   begin
      return END_OF_FILE (CURR_INPUT);
   end;

   procedure SET_COL (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT) is

      CH : CHARACTER;

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = OUT_FILE and FILE . LINE_LENGTH /= UNBOUNDED
         and TO > FILE . LINE_LENGTH then
         raise LAYOUT_ERROR;
      end if;
      if FILE . MODE = IN_FILE then
         if FILE . COL /= TO then
            loop
               READ (FILE, CH);      -- Read until (FILE . COL = TO) or EOF
               case CH is
                  when CR =>
                     FILE . COL := 1;
                  when LF =>
                     FILE . LINE := FILE . LINE + 1;
                     if (FILE . PAGE_LENGTH /= UNBOUNDED) and
                        (FILE . LINE >= FILE . PAGE_LENGTH) then
                        FILE . PAGE := FILE . PAGE + 1;
                        FILE . LINE := 1;
                     end if;
                  when FF =>
                     FILE . PAGE := FILE . PAGE + 1;
                     FILE . COL := 1;
                     FILE . LINE := 1;
                  when EOF =>
                     raise END_ERROR;
                  when others =>
                     FILE . COL := FILE . COL + 1;
               end case;
               exit when FILE . COL = TO;
            end loop;
         end if;
      else                             -- For file in OUT_MODE
         if FILE . COL > TO then
            NEW_LINE (FILE);
         end if;
         if FILE . COL < TO then
            for I in FILE . COL .. TO - 1 loop
               WRITE (FILE, ' ');
               FILE . COL := FILE . COL + 1;
            end loop;
         end if;
      end if;
   end SET_COL;

   procedure SET_COL (TO : in POSITIVE_COUNT) is

-- See chapter 14.3.4

   begin
      SET_COL (CURR_OUTPUT, TO); -- Default output file, see page 14-15
   end SET_COL;

   procedure SET_LINE (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT) is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = OUT_FILE and FILE . PAGE_LENGTH /= UNBOUNDED
         and TO > FILE . PAGE_LENGTH then
         raise LAYOUT_ERROR;
      end if;
      if FILE . MODE = IN_FILE then
         if FILE . LINE /= TO then
            loop
               SKIP_LINE (FILE);        -- This raises END_ERROR if EOF
               exit when FILE . LINE = TO;
            end loop;
         end if;
      else                              -- FILE . MODE = OUT_FILE
         if FILE . LINE < TO then
            loop
               NEW_LINE (FILE);         -- Spacing 1, see page 14-16
               exit when FILE . LINE = TO;
            end loop;
         elsif FILE . LINE > TO then
            NEW_PAGE (FILE);
            NEW_LINE (FILE, TO - 1);
         end if;
      end if;
   end SET_LINE;

   procedure SET_LINE (TO : in POSITIVE_COUNT) is

-- See chapter 14.3.4

   begin
      SET_LINE (CURR_OUTPUT, TO);
   end SET_LINE;

   function COL (FILE : in FILE_TYPE) return POSITIVE_COUNT is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . COL;
   end COL;

   function COL return POSITIVE_COUNT is

-- See chapter 14.3.4

   begin
      return COL (CURR_OUTPUT);  -- Def. current output file, see page 14-15
   end COL;

   function LINE (FILE : in FILE_TYPE) return POSITIVE_COUNT is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . LINE;
   end LINE;

   function LINE return POSITIVE_COUNT is

-- See chapter 14.3.4


   begin
      return LINE (CURR_OUTPUT);  -- Def. current output file, see page 14-15
   end LINE;

   function PAGE (FILE : in FILE_TYPE) return POSITIVE_COUNT is

-- See chapter 14.3.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . PAGE;
   end PAGE;

   function PAGE return POSITIVE_COUNT is

-- See chapter 14.3.4

   begin
      return PAGE (CURR_OUTPUT);  -- Def. curr. output file, see page 14-15
   end PAGE;

--
-- Character input/output
--

   procedure GET (FILE : in FILE_TYPE; ITEM : out CHARACTER) is

      INCHAR : CHARACTER;

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      loop
         READ (FILE, INCHAR); -- There is no DATA_ERROR eight bit characters
         case INCHAR is
            when CR =>
               FILE . COL := 1;
            when LF =>
               FILE . LINE := FILE . LINE + 1;
               if (FILE . PAGE_LENGTH /= UNBOUNDED) and
                  (FILE . LINE >= FILE . PAGE_LENGTH) then
                  FILE . PAGE := FILE . PAGE + 1;
                  FILE . LINE := 1;
               end if;
            when FF =>
               FILE . PAGE := FILE . PAGE + 1;
               FILE . COL := 1;
               FILE . LINE := 1;
            when EOF =>
               raise END_ERROR;
            when others =>
               FILE . COL := FILE . COL + 1;
               exit; -- This is a legal character
         end case;
      end loop;
      ITEM := INCHAR;
   end GET;

   procedure GET (ITEM : out CHARACTER) is

-- See chapter 14.3.6

   begin
      GET (CURR_INPUT, ITEM);
   end GET;

   procedure PUT (FILE : in FILE_TYPE; ITEM : in CHARACTER) is

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = IN_FILE then
         raise MODE_ERROR;
      end if;
      if FILE . LINE_LENGTH /= UNBOUNDED and
         FILE . COL >= FILE . LINE_LENGTH then
         if FILE . PAGE_LENGTH /= UNBOUNDED and
            FILE . PAGE_LENGTH >= FILE . PAGE then
            NEW_PAGE (FILE);
         else
            NEW_LINE (FILE);
         end if;
      end if;
      WRITE (FILE, ITEM);
      FILE . COL := FILE . COL + 1;
   end PUT;

   procedure PUT (ITEM : in CHARACTER) is

-- See chapter 14.3.6

   begin
      PUT (CURR_OUTPUT, ITEM);
   end PUT;

--
-- String input/output
--

   procedure GET (FILE : in FILE_TYPE; ITEM : out STRING) is

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      for I in ITEM'RANGE loop
         GET (FILE, ITEM (I));
      end loop;
   end GET;

   procedure GET (ITEM : out STRING) is

-- See chapter 14.3.6

   begin
      GET (CURR_INPUT, ITEM);
   end GET;

   procedure PUT (FILE : in FILE_TYPE; ITEM : in STRING) is

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      if FILE . LINE_LENGTH /= UNBOUNDED and
         FILE . COL >= FILE . LINE_LENGTH then
         if FILE . PAGE_LENGTH /= UNBOUNDED and
            FILE . PAGE_LENGTH >= FILE . PAGE then
            NEW_PAGE (FILE);
         else
            NEW_LINE (FILE);
         end if;
      end if;
      WRITE_STRING (FILE, ITEM);
      FILE . COL := FILE . COL + COUNT (ITEM'LENGTH);
   end PUT;

   procedure PUT (ITEM : in STRING) is

-- See chapter 14.3.6

   begin
      PUT (CURR_OUTPUT, ITEM);
   end;

   procedure GET_LINE (FILE : in FILE_TYPE;
      ITEM : out STRING; LAST : out NATURAL) is

      INCHAR : CHARACTER;
      POINTER : NATURAL := ITEM'FIRST - 1;

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      loop
         READ (FILE, INCHAR);
         case INCHAR is
            when CR | LF =>
               UNGET (FILE);
               SKIP_LINE (FILE);
               if FILE . HANDLE = 0 then -- Input from console
                  if INCHAR = CR then
                     PUT (DOS_OUTPUT, LF);
                  else
                     PUT (DOS_OUTPUT, CR);
                  end if;
               end if;
               exit;
            when FF =>
               UNGET (FILE);
               SKIP_PAGE (FILE);
               exit;
            when EOF =>
               exit;
            when others =>
               FILE . COL := FILE . COL + 1;
               POINTER := POINTER + 1;
               ITEM (POINTER) := INCHAR;
               exit when POINTER = ITEM'LAST;
         end case;
      end loop;
      LAST := POINTER;
   end GET_LINE;

   procedure GET_LINE (ITEM : out STRING; LAST : out NATURAL) is

-- See chapter 14.3.6

   begin
      GET_LINE (CURR_INPUT, ITEM, LAST);
   end GET_LINE;

   procedure PUT_LINE (FILE : in FILE_TYPE; ITEM : in STRING) is

-- See chapter 14.3.6

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      PUT (FILE, ITEM);
      NEW_LINE (FILE);
   end PUT_LINE;

   procedure PUT_LINE (ITEM : in STRING) is

-- See chapter 14.3.6

   begin
      PUT_LINE (CURR_OUTPUT, ITEM);
   end PUT_LINE;

--
-- Integer I/O
--
-- The following utility procedures are not included in
-- the INTEGER_IO package in order to decrease instantiation overhead.
--

   function VALID_INT (BASE : in NUMBER_BASE;
                       CH : in CHARACTER) return INTEGER is

      N : INTEGER;

   begin
      if CH >= 'a' then
         N := INTEGER (CH) - INTEGER ('a') + 10;
      elsif CH >= 'A' then
         N := INTEGER (CH) - INTEGER ('A') + 10;
      else
         N := INTEGER (CH) - INTEGER ('0');
      end if;
      if N > BASE - 1 then -- illegal digit for base
         return -1;
      else
         return N;
      end if;
   end VALID_INT;

   procedure READ_INT (FILE      : in FILE_TYPE;
                       MAX_WIDTH : in FIELD;
                       INT       : out INTEGER;
                       BASE      : in out NUMBER_BASE;
                       HAS_EXP   : in BOOLEAN := FALSE) is

      COUNTER      : INTEGER := 0;
      BASE_CHANGED : BOOLEAN := FALSE;
      INCHAR       : CHARACTER;
      TEMP         : INTEGER;
      MINUS        : BOOLEAN := FALSE;
      ONUM         : INTEGER;

   begin
      ONUM := 0;
      loop
         READ (FILE, INCHAR);
         COUNTER := COUNTER + 1;
         case INCHAR is
            when '0'..'9' | 'a'..'f' | 'A'..'F' =>
               if not BASE_CHANGED and (INCHAR = 'e' or INCHAR = 'E') then
                  UNGET (FILE);
                  exit;
               else
                  TEMP := VALID_INT (BASE, INCHAR);
                  if TEMP > -1 then
                     ONUM := BASE * ONUM + TEMP;
                     FILE . COL := FILE . COL + 1;
                  else                     -- Illegal character
                     raise DATA_ERROR;
                  end if;
               end if;
            when '#' | ':' =>
               FILE . COL := FILE . COL + 1;
               if not BASE_CHANGED and not HAS_EXP and
                  (ONUM > 1 and ONUM < 17) then -- We have read the base
                  BASE := ONUM;
                  ONUM := 0;
                  BASE_CHANGED := TRUE;
               elsif BASE_CHANGED and not HAS_EXP then
                  exit;
               elsif MAX_WIDTH = 0 or
                  (MAX_WIDTH > 0 and COUNTER = MAX_WIDTH) then
                  exit;
               else
                  raise DATA_ERROR;
               end if;
            when '-' =>
               FILE . COL := FILE . COL + 1;
               if HAS_EXP then
                  MINUS := TRUE;
               else
                  exit;
               end if;
            when '+' =>
               FILE . COL := FILE . COL + 1;
               if not HAS_EXP then
                  exit;
               end if;
            when CR | LF | FF | EOF =>
               UNGET (FILE);
               exit;
            when others =>
               if MAX_WIDTH = 0 then
                  UNGET (FILE);
                  exit;
               else
                  raise DATA_ERROR;
               end if;
         end case;
         exit when COUNTER = MAX_WIDTH and MAX_WIDTH > 0;
      end loop;
      if MINUS then
         ONUM := - ONUM;
      end if;
      INT := ONUM;
   end READ_INT;

   procedure GET (FILE : in FILE_TYPE;
                  ITEM : out INTEGER;
                  WIDTH : in FIELD;
                  INBASE : NUMBER_BASE) is

      COUNTER  : INTEGER := 0;
      INCHAR   : CHARACTER;
      BASE     : NUMBER_BASE := INBASE;
      INT      : INTEGER;
      ONUM     : INTEGER;
      ALREADY_SOMETHING : BOOLEAN := FALSE;

-- See chapter 14.3.7

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      ONUM:= 0;
      loop
         READ (FILE, INCHAR);
         case INCHAR is
            when FF | CR | LF =>
               if WIDTH /= 0 or ALREADY_SOMETHING then
                  UNGET (FILE);
                  exit;
               end if;
            when EOF =>
               UNGET (FILE);
               exit;
            when ' ' =>
               FILE . COL := FILE . COL + 1;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
            when '-' =>
               if ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               FILE . COL := FILE . COL + 1;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               READ_INT (FILE, WIDTH - COUNTER, ONUM, BASE);
               ONUM := - ONUM;
               ALREADY_SOMETHING := TRUE;
            when '+' =>
               if ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               FILE . COL := FILE . COL + 1;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               READ_INT (FILE, WIDTH - COUNTER, ONUM, BASE);
               ALREADY_SOMETHING := TRUE;
            when '0' .. '9' =>
               UNGET (FILE);
               READ_INT (FILE, WIDTH - COUNTER, ONUM, BASE);
               ALREADY_SOMETHING := TRUE;
            when 'e' | 'E' =>
               if not ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               FILE . COL := FILE . COL + 1;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               READ_INT (FILE, WIDTH - COUNTER, INT, BASE, TRUE);
               ONUM := ONUM * BASE ** INT;
               exit;
            when others =>
               raise DATA_ERROR;
         end case;
         exit when COUNTER = WIDTH and WIDTH > 0;
      end loop;
      ITEM := ONUM;
   exception
      when NUMERIC_ERROR =>
         raise DATA_ERROR;
   end GET;

   procedure PUT (
      FILE : in FILE_TYPE;
      ITEM : in INTEGER;
      WIDTH : in FIELD;
      BASE : in NUMBER_BASE) is

      IMAGE : STRING (1..19); -- Max possible is "-2#[15 bits]#"
      DIGIT : constant STRING (1..16) := "0123456789ABCDEF";
      POINTER : POSITIVE := IMAGE'LAST;
      REST : INTEGER := abs ITEM;

-- See chapter 14.3.7

   begin
      if BASE /= 10 then -- Make Ada standard based literal syntax
         IMAGE (POINTER) := '#';
         POINTER := POINTER - 1;
      end if;
      if REST = 0 then
         IMAGE (POINTER) := '0';
         POINTER := POINTER - 1;
      end if;
      while REST /= 0 loop -- Code the digits
         IMAGE (POINTER) := DIGIT ((REST mod BASE) + 1);
         POINTER := POINTER - 1;
         REST := REST / BASE;
      end loop;
      if BASE /= 10 then
         IMAGE (POINTER) := '#';
         POINTER := POINTER - 1;
         REST := BASE; -- Code the base itself
         while REST /= 0 loop
            IMAGE (POINTER) := DIGIT ((REST mod 10) + 1);
            POINTER := POINTER - 1;
            REST := REST / 10;
         end loop;
      end if;
      if ITEM < 0 then -- Put minus sign
         IMAGE (POINTER) := '-';
         POINTER := POINTER - 1;
      end if;
      for I in IMAGE'LAST - POINTER + 1 .. WIDTH loop -- Put preceding spaces
         PUT (FILE, ' ');
      end loop;
      PUT (FILE, IMAGE (POINTER + 1 .. IMAGE'LAST)); -- Put the slice
   end PUT;

   procedure GET_INT (FROM  : in STRING;
                      INDEX : in out POSITIVE;
                      INT   : out INTEGER;
                      BASE  : in out NUMBER_BASE;
                      HAS_EXP : in BOOLEAN := FALSE) is

      BASE_CHANGED : BOOLEAN := FALSE;
      INCHAR       : CHARACTER;
      TEMP         : INTEGER;
      MINUS        : BOOLEAN := FALSE;
      ONUM         : INTEGER;

   begin
      ONUM := 0;
      loop
         INCHAR := FROM (INDEX);
         case INCHAR is
            when '0'..'9' | 'a'..'f' | 'A'..'F' =>
               if not BASE_CHANGED and (INCHAR = 'e' or INCHAR = 'E') then
                  exit;
               else
                  TEMP := VALID_INT (BASE, INCHAR);
                  if TEMP > -1 then
                     ONUM := BASE * ONUM + TEMP;
                  else
                     raise DATA_ERROR;
                  end if;
               end if;
            when '#' | ':' =>
               if not BASE_CHANGED and not HAS_EXP and
                  (ONUM > 1 and ONUM < 17) then -- We have read the base
                  BASE := ONUM;
                  ONUM := 0;
                  BASE_CHANGED := TRUE;
               else
                  INDEX := INDEX + 1;
                  exit;
               end if;
            when '-' =>
               if HAS_EXP then
                  MINUS := TRUE;
               else
                  exit;
               end if;
            when '+' =>
               if not HAS_EXP then
                  exit;
               end if;
            when others =>
               exit;
         end case;
         exit when INDEX = FROM'LAST;
         INDEX := INDEX + 1;
      end loop;
      if MINUS then
         ONUM := - ONUM;
      end if;
      INT := ONUM;
   end GET_INT;

   procedure GET (
      FROM : in STRING;
      ITEM : out INTEGER;
      LAST : out POSITIVE;
      INBASE : in NUMBER_BASE) is

      INT : INTEGER;
      BASE : NUMBER_BASE := INBASE;
      L : POSITIVE;
      ONUM : INTEGER;
      ALREADY_SOMETHING : BOOLEAN := FALSE;

-- See chapter 14.3.7

   begin
      L := FROM'FIRST;
      loop
         case FROM (L) is
            when ' ' =>
               L := L + 1;
               if ALREADY_SOMETHING then
                  exit;
               end if;
            when '-' =>
               if ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               L := L + 1;
               GET_INT (FROM, L, ONUM, BASE);
               ONUM := - ONUM;
               ALREADY_SOMETHING := TRUE;
            when '+' =>
               if ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               L := L + 1;
               GET_INT (FROM, L, ONUM, BASE);
               ALREADY_SOMETHING := TRUE;
            when '0' .. '9' =>
               GET_INT (FROM, L, ONUM, BASE);
               ALREADY_SOMETHING := TRUE;
            when 'e' | 'E' =>
               if not ALREADY_SOMETHING then
                  raise DATA_ERROR;
               end if;
               L := L + 1;
               GET_INT (FROM, L, INT, BASE, TRUE);
               ONUM := ONUM * BASE ** INT;
               exit;
            when others =>
               raise DATA_ERROR;
         end case;
         exit when L = FROM'LAST;
      end loop;
      LAST := L;
      ITEM := ONUM;
   exception
      when NUMERIC_ERROR =>
         raise DATA_ERROR;
   end GET;

   procedure PUT (
      TO : out STRING;
      ITEM : in INTEGER;
      BASE : in NUMBER_BASE) is

      DIGIT : constant STRING (1..16) := "0123456789ABCDEF";
      POINTER : POSITIVE := TO'LAST;
      REST : INTEGER := abs ITEM;

-- See chapter 14.3.7

   begin
      if BASE /= 10 then -- Make Ada standard based literal syntax
         TO (POINTER) := '#';
         POINTER := POINTER - 1;
      end if;
      if REST = 0 then
         TO (POINTER) := '0';
         POINTER := POINTER - 1;
      end if;
      while REST /= 0 loop -- Code the digits
         TO (POINTER) := DIGIT ((REST mod BASE) + 1);
         POINTER := POINTER - 1;
         REST := REST / BASE;
      end loop;
      if BASE /= 10 then
         TO (POINTER) := '#';
         POINTER := POINTER - 1;
         REST := BASE; -- Code the base itself
         while REST /= 0 loop
            TO (POINTER) := DIGIT ((REST mod 10) + 1);
            POINTER := POINTER - 1;
            REST := REST / 10;
         end loop;
      end if;
      if ITEM < 0 then -- Put minus sign
         TO (POINTER) := '-';
         POINTER := POINTER - 1;
      end if;
      TO (TO'FIRST .. POINTER) := (others => ' ');
   end PUT;

   package body INTEGER_IO is

      procedure GET (FILE : in FILE_TYPE;
                     ITEM : out NUM;
                     WIDTH : in FIELD := DEFAULT_WIDTH) is

         ONUM : INTEGER;

      begin
         GET (FILE, ONUM, WIDTH, DEFAULT_BASE);
         ITEM := NUM (ONUM);
      end GET;

      procedure GET (ITEM : out NUM; WIDTH : in FIELD := 0) is

         ONUM : INTEGER;

      begin
         GET (CURR_INPUT, ONUM, WIDTH, DEFAULT_BASE);
         ITEM := NUM (ONUM);
      end GET;

      procedure PUT (
         FILE : in FILE_TYPE;
         ITEM : in NUM;
         WIDTH : in FIELD := DEFAULT_WIDTH;
         BASE : in NUMBER_BASE := DEFAULT_BASE) is
      begin
         PUT (FILE, INTEGER (ITEM), WIDTH, BASE);
      end PUT;

      procedure PUT (
         ITEM : in NUM;
         WIDTH : in FIELD := DEFAULT_WIDTH;
         BASE : in NUMBER_BASE := DEFAULT_BASE) is

      begin
         PUT (CURR_OUTPUT, INTEGER (ITEM), WIDTH, BASE);
      end PUT;

      procedure GET (
         FROM : in STRING;
         ITEM : out NUM;
         LAST : out POSITIVE) is

         ONUM : INTEGER;

      begin
         GET (FROM, ONUM, LAST, DEFAULT_BASE);
         ITEM := NUM (ONUM);
      end GET;

      procedure PUT (
         TO : out STRING;
         ITEM : in NUM;
         BASE : in NUMBER_BASE := DEFAULT_BASE) is

      begin
         PUT (TO, INTEGER (ITEM), BASE);
      end PUT;

   end INTEGER_IO;

--
-- Floating point I/O
--
-- The following utility procedures are not included in the body
-- of FLOAT_IO to decrease instantiation overhead.

   type SUCCESS_TYPE is
      (NOTHING, BEFORE_PERIOD, AFTER_PERIOD, EXPONENT);

   procedure READ_INT (FILE      : in FILE_TYPE;
                       MAX_WIDTH : in FIELD;
                       BASE      : in out NUMBER_BASE;
                       NUMBER    : in out FLOAT;
                       WHERE     : in SUCCESS_TYPE;
                       COUNTER   : out INTEGER;
                       STR       : in STRING;
                       STR_INDEX : in out INTEGER;
                       USE_STRING: in BOOLEAN) is

      BASE_CHANGED : BOOLEAN := FALSE;
      INCHAR       : CHARACTER;
      INT          : INTEGER := 0;
      TEMP         : INTEGER;
      MINUS        : BOOLEAN := FALSE;
      CTR          : INTEGER;

   begin
      CTR := 0;
      STR_INDEX := STR_INDEX - 1;
      loop
         STR_INDEX := STR_INDEX + 1;
         if USE_STRING then
            INCHAR := STR (STR_INDEX);
         else
            READ (FILE, INCHAR);
         end if;
         CTR := CTR + 1;
         case INCHAR is
            when '0'..'9' | 'a'..'f' | 'A'..'F' =>
               if not BASE_CHANGED and (INCHAR = 'e' or INCHAR = 'E') then
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               else
                  TEMP := VALID_INT (BASE, INCHAR);
                  if TEMP > -1 then
                     case WHERE is
                        when BEFORE_PERIOD =>
                           NUMBER := BASE * NUMBER + FLOAT (TEMP);
                        when AFTER_PERIOD =>
                           NUMBER := NUMBER + TEMP * FLOAT (BASE)
                              **(- CTR);
                        when EXPONENT =>
                           INT := INT * 10 + TEMP; -- Get the exponent
                        when NOTHING => -- This should not happen
                           raise DATA_ERROR;
                     end case;
                     if not USE_STRING then
                        FILE . COL := FILE . COL + 1;
                     end if;
                  else                     -- Illegal character
                     raise DATA_ERROR;
                  end if;
               end if;
            when '#' | ':' =>
               if not USE_STRING then
                  FILE . COL := FILE . COL + 1;
               end if;
               if not BASE_CHANGED and WHERE = BEFORE_PERIOD and
                  (INT > 1 and INT < 17) then -- We have read the base
                  BASE := INT;
                  INT := 0;
                  BASE_CHANGED := TRUE;
               elsif WHERE = AFTER_PERIOD then
                  exit;
               else
                  raise DATA_ERROR;
               end if;
            when '-' =>
               if WHERE = EXPONENT then
                  MINUS := TRUE;
                  if not USE_STRING then
                     FILE . COL := FILE . COL + 1;
                  end if;
               else
                  raise DATA_ERROR;
               end if;
            when '+' =>
               if WHERE /= EXPONENT then
                  raise DATA_ERROR;
               end if;
               if not USE_STRING then
                  FILE . COL := FILE . COL + 1;
               end if;
            when '.' =>
               if WHERE = BEFORE_PERIOD or MAX_WIDTH = 0 then
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               else
                  raise DATA_ERROR;
               end if;
            when CR | LF | FF | EOF => -- Termination of input
               if WHERE = BEFORE_PERIOD then
                  raise DATA_ERROR;
               else
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               end if;
            when others =>
               if MAX_WIDTH = 0 then -- Termination of input
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               else
                  raise DATA_ERROR;
               end if;
         end case;
         exit when (CTR = MAX_WIDTH and MAX_WIDTH > 0) or
            (USE_STRING and STR_INDEX = STR'LAST);
      end loop;
      if WHERE = EXPONENT then
         if MINUS then
            INT := - INT;
         end if;
         NUMBER := NUMBER * FLOAT (BASE) ** INT;
      end if;
      COUNTER := CTR;
   end READ_INT;

   function EXPO (F : in FLOAT) return INTEGER is

   -- Returns the binary exponent of an IEEE floating-point
   -- number.  The bias (1023) is subtracted.

      E : INTEGER;

   begin
      pragma NATIVE (
         16#8B#, 16#44#, 16#06#, 16#25#, 16#F0#, 16#7F#, 16#D1#, 16#E8#,
         16#D1#, 16#E8#, 16#D1#, 16#E8#, 16#D1#, 16#E8#, 16#2D#, 16#FF#,
         16#03#, 16#89#, 16#05#);
      return E;
   end EXPO;

   procedure GET_STR_FILE (FILE       : in FILE_TYPE;
                           ITEM       : out FLOAT;
                           WIDTH      : in FIELD := 0;
                           STR        : in STRING;
                           STR_INDEX  : in out INTEGER;
                           USE_STRING : in BOOLEAN) is

      SUCCESS : SUCCESS_TYPE := NOTHING;
      INDEX   : INTEGER;
      COUNTER : INTEGER := 0;
      INCHAR  : CHARACTER;
      BASE    : NUMBER_BASE := 10;
      ONUM    : FLOAT;
      MINUS   : BOOLEAN := FALSE;

-- See chapter 14.3.8

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      STR_INDEX := STR'FIRST - 1;
      ONUM := 0.0;
      loop
         STR_INDEX := STR_INDEX + 1;
         if USE_STRING then
            INCHAR := STR (STR_INDEX);
         else
            READ (FILE, INCHAR);
         end if;
         case INCHAR is
            when FF | CR | LF =>
               if WIDTH /= 0 or SUCCESS = AFTER_PERIOD or
                  SUCCESS = EXPONENT then
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               end if;
            when EOF =>
               if USE_STRING then
                  STR_INDEX := STR_INDEX - 1;
               else
                  UNGET (FILE);
               end if;
               exit;
            when ' ' =>
               if SUCCESS = NOTHING then
                  if not USE_STRING then
                     FILE . COL := FILE . COL + 1;
                  end if;
                  if WIDTH > 0 then
                     COUNTER := COUNTER + 1;
                  end if;
               elsif SUCCESS = AFTER_PERIOD then
                  if USE_STRING then
                     STR_INDEX := STR_INDEX - 1;
                  else
                     UNGET (FILE);
                  end if;
                  exit;
               else
                  raise DATA_ERROR;
               end if;
            when '-' =>
               if SUCCESS = NOTHING then
                  SUCCESS := BEFORE_PERIOD;
               else
                  raise DATA_ERROR;
               end if;
               if USE_STRING then
                  STR_INDEX := STR_INDEX + 1;
               else
                  FILE . COL := FILE . COL + 1;
               end if;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               READ_INT (FILE, WIDTH - COUNTER, BASE, ONUM,
                  SUCCESS, INDEX, STR, STR_INDEX, USE_STRING);
               if WIDTH > 0 then
                  COUNTER := COUNTER + INDEX;
               end if;
               MINUS := TRUE;
            when '+' =>
               if SUCCESS = NOTHING then
                  SUCCESS := BEFORE_PERIOD;
               else
                  raise DATA_ERROR;
               end if;
               if USE_STRING then
                  STR_INDEX := STR_INDEX + 1;
               else
                  FILE . COL := FILE . COL + 1;
               end if;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               READ_INT (FILE, WIDTH - COUNTER, BASE, ONUM,
                  SUCCESS, INDEX, STR, STR_INDEX, USE_STRING);
               if WIDTH > 0 then
                  COUNTER := COUNTER + INDEX;
               end if;
            when '0' .. '9' =>
               if SUCCESS = NOTHING then
                  SUCCESS := BEFORE_PERIOD;
               end if;
               if not USE_STRING then
                  UNGET (FILE);
               end if;
               READ_INT (FILE, WIDTH - COUNTER, BASE, ONUM,
                  SUCCESS, INDEX, STR, STR_INDEX, USE_STRING);
               if WIDTH > 0 then
                  COUNTER := COUNTER + INDEX;
               end if;
            when '.' =>
               if USE_STRING then
                  STR_INDEX := STR_INDEX + 1;
               else
                  FILE . COL := FILE . COL + 1;
               end if;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               if SUCCESS = BEFORE_PERIOD then
                  SUCCESS := AFTER_PERIOD;
                  READ_INT (FILE, WIDTH - COUNTER, BASE, ONUM,
                     SUCCESS, INDEX, STR, STR_INDEX, USE_STRING);
                  if WIDTH > 0 then
                     COUNTER := COUNTER + INDEX;
                  end if;
               else
                  raise DATA_ERROR;
               end if;
            when 'e' | 'E' =>
               if USE_STRING then
                  STR_INDEX := STR_INDEX + 1;
               else
                  FILE . COL := FILE . COL + 1;
               end if;
               if WIDTH > 0 then
                  COUNTER := COUNTER + 1;
               end if;
               if SUCCESS = AFTER_PERIOD then
                  SUCCESS := EXPONENT;
                  READ_INT (FILE, WIDTH - COUNTER, BASE, ONUM,
                     SUCCESS, INDEX, STR, STR_INDEX, USE_STRING);
                  if WIDTH > 0 then
                     COUNTER := COUNTER + INDEX;
                  end if;
               else
                  raise DATA_ERROR;
               end if;
            when others =>
               raise DATA_ERROR;
         end case;
         exit when (COUNTER >= WIDTH and WIDTH > 0) or (SUCCESS = EXPONENT) or
            (USE_STRING and STR_INDEX = STR'LAST);
      end loop;
      if MINUS then
         ONUM := - ONUM;
      end if;
      ITEM := ONUM;
   exception
      when NUMERIC_ERROR =>
         raise DATA_ERROR;
   end GET_STR_FILE;

   INDEX : INTEGER;             -- Index for FLOAT_STR
   FLOAT_STR : STRING (1..30);  -- Temporary string for PUT FLOAT to
                                -- a file or a string

   procedure PUT_STR
      (ITEM : in FLOAT;
      FORE, AFT, EXP : in FIELD) is

      X : FLOAT := ITEM;
      T : FLOAT;
      E, TEMP_INDEX : INTEGER;
      D : INTEGER range 0..9;
      MINUS_NUM : BOOLEAN;
      AFTER : FIELD := AFT;

-- See chapter 14.3.8

      function TEN (EX : in INTEGER) return FLOAT is

      begin
         return 10.0 ** EX;
      end TEN;

      function CUT_SPACE (S : in STRING) return STRING is

      begin
         return S (2..S'LAST);
      end CUT_SPACE;

      function LENGTH (S : in STRING) return INTEGER is

      begin
         return S'LENGTH;
      end;

   begin -- PUT for FLOAT
      FLOAT_STR (FLOAT_STR'FIRST .. FLOAT_STR'LAST) := (others => ' ');
      INDEX := 1;
      if AFTER = 0 then
         AFTER := 1;
      end if;
      MINUS_NUM := X < 0.0;
      X := abs X;
      if X = 0.0 then -- Avoid peculiar exponent if zero
         E := 0;
      else
         E := EXPO (FLOAT (X)); -- Process exponent
      end if;
      if X /= 0.0 then
         E := ((E + 1) * 77) / 256; -- Convert to base 10 exponent
      end if;
      if TEN (E) > X then
         E := E - 1; -- Correct integer arithmetic error
      end if;
      if EXP > 0 then
         X := X / TEN (E);
      end if;
      if X /= 0.0 then
         X := X + 0.5 * TEN (- AFTER); -- Rounding
      end if;
      if EXP > 0 and X >= 10.0 then
         X := X / 10.0;
         E := E + 1;
      elsif EXP = 0 and X >= TEN (E + 1) then
         E := E + 1;
      end if;
      -- Handle FORE
      if X = 0.0 then               -- X = 0: Special case
         for I in 2 .. FORE loop
            FLOAT_STR (INDEX) := ' ';
            INDEX := INDEX + 1;
         end loop;
         FLOAT_STR (INDEX) := '0';
         INDEX := INDEX + 1;
      elsif EXP > 0 then            -- EXP > 0: Only one digit in FORE
         if MINUS_NUM then
            for I in 3 .. FORE loop
               FLOAT_STR (INDEX) := ' ';
               INDEX := INDEX + 1;
            end loop;
            FLOAT_STR (INDEX) := '-';
            INDEX := INDEX + 1;
         else
            for I in 2 .. FORE loop
               FLOAT_STR (INDEX) := ' ';
               INDEX := INDEX + 1;
            end loop;
         end if;
         D := INTEGER (X - 0.5); -- Convert to TRUNC
         if X - FLOAT (D) >= 1.0 then -- Rounded too much
            D := D + 1; -- Add one to digit
         end if;
         FLOAT_STR (INDEX) := CHARACTER (D + 48);
         INDEX := INDEX + 1;
         X := (X - FLOAT (D)) * 10.0;
      else                         -- EXP = 0: Put all digits in FORE
         if E < 0 then
            if MINUS_NUM then
               for I in 3 .. FORE loop
                  FLOAT_STR (INDEX) := ' ';
                  INDEX := INDEX + 1;
               end loop;
               FLOAT_STR (INDEX) := '-';
               INDEX := INDEX + 1;
               FLOAT_STR (INDEX) := '0';
               INDEX := INDEX + 1;
            else
               for I in 2 .. FORE loop
                  FLOAT_STR (INDEX) := ' ';
                  INDEX := INDEX + 1;
               end loop;
               FLOAT_STR (INDEX) := '0';
               INDEX := INDEX + 1;
            end if;
         elsif MINUS_NUM then -- E > 0
            for I in E + 3 .. FORE loop
               FLOAT_STR (INDEX) := ' ';
               INDEX := INDEX + 1;
            end loop;
            FLOAT_STR (INDEX) := '-';
            INDEX := INDEX + 1;
         else -- E > 0
            for I in E + 2 .. FORE loop
               FLOAT_STR (INDEX) := ' ';
               INDEX := INDEX + 1;
            end loop;
         end if;
         for I in reverse 0 .. E loop -- Take all the digits
            T := TEN (I);
            D := INTEGER (X / T - 0.5); -- Convert to TRUNC
            X := X - D * T;
            if X >= T then -- Rounded too much
               D := D + 1;
               X := X - T;
            end if;
            FLOAT_STR (INDEX) := CHARACTER (D + 48);
            INDEX := INDEX + 1;
         end loop;
         X := X * 10.0; -- Prepare for AFT
      end if;
      -- Handle AFT
      FLOAT_STR (INDEX) := '.';
      INDEX := INDEX + 1;
      for I in 1..AFTER loop -- Put the mantissa
         D := INTEGER (X - 0.5); -- Convert to TRUNC
         if X - FLOAT (D) >= 1.0 then -- Rounded too much
            D := D + 1; -- Add one to digit
         end if;
         FLOAT_STR (INDEX) := CHARACTER (D + 48);
         INDEX := INDEX + 1;
         X := (X - FLOAT (D)) * 10.0;
      end loop;
   -- Handle EXP
      if EXP > 0 then
         FLOAT_STR (INDEX) := 'E';
         INDEX := INDEX + 1;
         if E >= 0 then
            FLOAT_STR (INDEX) := '+';
            INDEX := INDEX + 1;
         else
            FLOAT_STR (INDEX) := '-';
            INDEX := INDEX + 1;
         end if;
         if E > 99 then
            for I in 5 .. EXP loop
               FLOAT_STR (INDEX) := '0';
               INDEX := INDEX + 1;
            end loop;
         elsif E > 9 then
            for I in 4 .. EXP loop
               FLOAT_STR (INDEX) := '0';
               INDEX := INDEX + 1;
            end loop;
         else
            for I in 3 .. EXP loop
               FLOAT_STR (INDEX) := '0';
               INDEX := INDEX + 1;
            end loop;
         end if;
         TEMP_INDEX := INDEX + LENGTH (INTEGER'IMAGE (abs E)) - 2;
         FLOAT_STR (INDEX..TEMP_INDEX) := CUT_SPACE (INTEGER'IMAGE (abs E));
         INDEX := TEMP_INDEX + 1;
      end if;
      INDEX := INDEX - 1;
   end PUT_STR;

   package body FLOAT_IO is

      procedure GET (FILE : in FILE_TYPE;
                     ITEM : out NUM;
                     WIDTH : in FIELD := 0) is

         ONUM : FLOAT;
         DUMMY: INTEGER;

      begin
         GET_STR_FILE (FILE, ONUM, WIDTH, "", DUMMY, FALSE);
         ITEM := NUM (ONUM);
      end GET;

      procedure GET (ITEM : out NUM; WIDTH : in FIELD := 0) is

-- See chapter 14.3.8

         ONUM  : FLOAT;
         DUMMY : INTEGER;

      begin
         GET_STR_FILE (CURR_INPUT, ONUM, WIDTH, "", DUMMY, FALSE);
         ITEM := NUM (ONUM);
      end GET;

      procedure PUT
         (FILE : in FILE_TYPE;
         ITEM : in NUM;
         FORE : in FIELD := DEFAULT_FORE;
         AFT : in FIELD := DEFAULT_AFT;
         EXP : in FIELD := DEFAULT_EXP) is

      begin
         PUT_STR (FLOAT (ITEM), FORE, AFT, EXP);
         PUT (FILE, FLOAT_STR (FLOAT_STR'FIRST..INDEX));
      end PUT;

      procedure PUT (ITEM : in NUM;
                     FORE : in FIELD := DEFAULT_FORE;
                     AFT : in FIELD := DEFAULT_AFT;
                     EXP : in FIELD := DEFAULT_EXP) is

-- See chapter 14.3.8

      begin
         PUT_STR (FLOAT (ITEM), FORE, AFT, EXP);
         PUT (CURR_OUTPUT, FLOAT_STR (FLOAT_STR'FIRST..INDEX));
      end PUT;

      procedure GET (FROM : in STRING;
                    ITEM  : out NUM;
                    LAST  : out POSITIVE) is

-- See chapter 14.3.8

         ONUM : FLOAT;
         LEN  : INTEGER;

      begin
         GET_STR_FILE (CURR_INPUT, ONUM, 0, FROM, LEN, TRUE);
         ITEM := NUM (ONUM);
         LAST := POSITIVE (LEN);
      end GET;

      procedure PUT (TO   : out STRING;
                     ITEM : in NUM;
                     AFT  : in FIELD := DEFAULT_AFT;
                     EXP  : in FIELD := DEFAULT_EXP) is

-- See chapter 14.3.8

         LEN : INTEGER;

      begin
         LEN := FLOAT_STR'LENGTH - AFT - EXP - 3; -- 3 is for . E sign of E
         if EXP = 0 then
            LEN := LEN + 2;
         end if;
         PUT_STR (FLOAT (ITEM), LEN, AFT, EXP);
         if TO'LENGTH = FLOAT_STR'LENGTH then
            TO := FLOAT_STR;
         elsif TO'LENGTH < FLOAT_STR'LENGTH then
            TO := FLOAT_STR (FLOAT_STR'LAST - TO'LENGTH + 1..FLOAT_STR'LAST);
         else
            TO (TO'FIRST .. TO'LAST - FLOAT_STR'LENGTH) := (others => ' ');
            TO (TO'LAST - FLOAT_STR'LENGTH + 1 .. TO'LAST) := FLOAT_STR;
         end if;
      end PUT;

   end FLOAT_IO;

--
-- Input / Output for Enumeration Types
--

-- The following utility subprograms are not included
-- in the body of ENUMERATION_IO to decrease instantiation overhead

   function LEGAL_ID_CHAR
      (CH : in CHARACTER; FIRST : in BOOLEAN) return BOOLEAN is

   begin
      if FIRST and CH in '0'..'9' then -- Id cannot begin with digit
         return FALSE;
      end if;
      case CH is
         when 'a'..'z' | 'A'..'Z' | '0'..'9' | '_' =>
            return TRUE;
         when others =>
            return FALSE;
      end case;
   end LEGAL_ID_CHAR;

   procedure ASSIGN_STR
      (S1 : out STRING; S2 : in STRING; L : out INTEGER) is

   begin
      L := S2'LENGTH;
      S1 (S2'RANGE) := S2;
   end ASSIGN_STR;

   package body ENUMERATION_IO is

      MAX_IDENT_LENGTH : constant := 132;

      procedure GET (FILE : in FILE_TYPE; ITEM : out ENUM) is

-- See chapter 14.3.9

         CH : CHARACTER;
         STR : STRING (1..MAX_IDENT_LENGTH);
         I : INTEGER := 0;

      begin
         GET (FILE, CH); -- Skipped leading garbage
         if CH = ''' then   -- Special case: Character literal, f.ex 'A'
            STR (1) := CH;  -- if TEXT_IO . ENUMERATION (CHARACTER)
            READ (FILE, STR (2));  -- has been instantiated
            READ (FILE, STR (3));
            FILE . COL := FILE . COL + 2;
            I := 3;
         else -- Input an identifier
            while LEGAL_ID_CHAR (CH, I = 0) loop
               I := I + 1;
               STR (I) := CH;
               READ (FILE, CH);
               FILE . COL := FILE . COL + 2;
            end loop; -- The identifier is now in STR (1..I)
            UNGET (FILE);
         end if;
         ITEM := ENUM'VALUE (STR (1..I));
      exception
         when CONSTRAINT_ERROR => -- Raised by ENUM'VALUE
            raise DATA_ERROR;     -- This was an illegal enum identifier
      end;

      procedure GET (ITEM : out ENUM) is

-- See chapter 14.3.9

      begin
         GET (CURR_INPUT, ITEM);
      end GET;

      procedure PUT (FILE  : in FILE_TYPE;
                     ITEM  : in ENUM;
                     WIDTH : in FIELD := DEFAULT_WIDTH;
                     SET   : in TYPE_SET := DEFAULT_SETTING) is

-- See chapter 14.3.9

         STR : STRING (1..MAX_IDENT_LENGTH);
         LENGTH : INTEGER;

      begin
         ASSIGN_STR (STR, ENUM'IMAGE (ITEM), LENGTH);
         if (SET = LOWER_CASE) AND (STR (1) /= ''') then
            for J in 1..LENGTH loop
               if STR (J) in 'A'..'Z' then -- Convert to lower case
                  STR (J) := CHARACTER (INTEGER (STR (J)) + 32);
               end if;
            end loop;
         end if;
         PUT (FILE, STR (1..LENGTH));
         for I in LENGTH + 1..WIDTH loop
            PUT (FILE, ' ');
         end loop;
      end PUT;

      procedure PUT (ITEM  : in ENUM;
                     WIDTH : in FIELD := DEFAULT_WIDTH;
                     SET   : in TYPE_SET := DEFAULT_SETTING) is

-- See chapter 14.3.9

      begin
         PUT (CURR_OUTPUT, ITEM, WIDTH, SET);
      end PUT;

      procedure GET (FROM : in STRING;
                     ITEM : out ENUM;
                     LAST : out POSITIVE) is

-- See chapter 14.3.9

         CH : CHARACTER;
         I : INTEGER := FROM'FIRST;
         FI : INTEGER;
         L : POSITIVE;

      begin
         loop
            CH := FROM (I);
            exit when (CH /= LF) or (CH /= CR) or (CH /= FF) or
               (CH /= ' ') or (I = FROM'LAST);
            I := I + 1;
         end loop; -- Skipped leading blanks and line and page terminators
         FI := I;
         if CH = ''' then   -- Special case: Character literal, for example 'A'
            L := FI + 3;
            ITEM := ENUM'VALUE (FROM (FI..L));
         else -- Input an identifier
            while LEGAL_ID_CHAR (FROM (I), I = FI) AND (I < FROM'LAST) loop
               I := I + 1;
            end loop;
            if I = FROM'LAST then
               L := I;
            else
               L := I - 1;
            end if;
            ITEM := ENUM'VALUE (FROM (FI..L));
         end if;
         LAST := L;
      exception
         when CONSTRAINT_ERROR => -- Raised by ENUM'VALUE
            raise DATA_ERROR;     -- This was an illegal enum identifier
      end GET;

      procedure PUT (
         TO   : out STRING;
         ITEM : in ENUM;
         SET  : in TYPE_SET := DEFAULT_SETTING) is

-- See chapter 14.3.9

         LENGTH : INTEGER;
         STR : STRING (1..MAX_IDENT_LENGTH);

      begin
         ASSIGN_STR (STR, ENUM'IMAGE (ITEM), LENGTH);
         if LENGTH > TO'LENGTH then
            raise LAYOUT_ERROR;
         end if;
         if (SET = LOWER_CASE) AND (STR (1) /= ''') then
            for J in 1..LENGTH loop
               if STR (J) in 'A'..'Z' then -- Convert to lower case
                  STR (J) := CHARACTER (INTEGER (STR (J)) + 32);
               end if;
            end loop;
         end if;
         TO (TO'FIRST..TO'FIRST + LENGTH - 1) := STR (1..LENGTH);
         for I in TO'FIRST + LENGTH..TO'LAST loop
            TO (I) := ' ';
         end loop;
      end PUT;

   end ENUMERATION_IO;

begin
   -- Pre-opened files
   DOS_INPUT := new FILE_DESCR'(
       NAMELEN => 3, NAME => DOS_IO_NAME,
       FORMLEN => 0, FORM => (others => ' '),
       MODE => IN_FILE,
       COL => 1,
       LINE => 1, LINE_LENGTH => UNBOUNDED,
       PAGE => 1, PAGE_LENGTH => UNBOUNDED,
       HANDLE => IN_CONSOLE_HANDLE);
   DOS_OUTPUT := new FILE_DESCR'(
       NAMELEN => 3, NAME => DOS_IO_NAME,
       FORMLEN => 0, FORM => (others => ' '),
       MODE => OUT_FILE,
       COL => 1,
       LINE => 1, LINE_LENGTH => UNBOUNDED,
       PAGE => 1, PAGE_LENGTH => UNBOUNDED,
       HANDLE => OUT_CONSOLE_HANDLE);
   CURR_INPUT := DOS_INPUT;
   CURR_OUTPUT := DOS_OUTPUT;
end TEXT_IO;
