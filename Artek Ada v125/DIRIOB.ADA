--
-- D I R E C T   I N P U T / O U T P U T
--
-- Body of the Package Direct_IO
--
-- According to ANSI/MIL-STD 1815A (1983)
-- Implemented for Artek Ada
--
-- Copyright (C) 1986 Artek Corporation
-- Author : O. Karlsson
--
--
-- Version: 1.01
-- Date last modified: 1986-05-01
--

with DOS_INTERFACE, SYSTEM, LONG_OPERATIONS;

package body DIRECT_IO is

   use DOS_INTERFACE, SYSTEM, ASCII, LONG_OPERATIONS;

   -- Data types and objects

   EOF : constant CHARACTER := CHARACTER (26);

   R : REG_8086;

--
-- Utility procedure to skip last character read from a file
-- Same as " lseek (file, -1) " relative from the file position
--

   procedure UNGET (FILE : in FILE_TYPE) is

   begin
      -- This procedure is only used internally and
      -- the file is always open
      R . AX := 16#4201#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE);
      R . CX := -1;          -- Desired location from current position
      R . DX := -1;
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- There should never be error here
      end if;
   end UNGET;

--
-- File management
--

   procedure CREATE (
      FILE : in out FILE_TYPE;
      MODE : in FILE_MODE := INOUT_FILE;
      NAME : in STRING := "";
      FORM : in STRING := "") is

      ASCIIZ_NAME : FILE_NAME_STRING;
      BLANK_NAME : FILE_NAME_STRING := (others => ' ');
      BLANK_FORM : FORM_NAME_STRING := (others => ' ');

-- See chapter 14.2.1

   begin -- Concatenate a null character
      if FILE /= null then
         raise STATUS_ERROR;
      end if;
      ASCIIZ_NAME (1..NAME'LENGTH) := NAME;
      ASCIIZ_NAME (NAME'LENGTH + 1) := NUL;
      R . AX := 16#3C00#; -- Function 3C, Create a file
      R . DX := WORD (ASCIIZ_NAME'ADDRESS); -- Address of the filename
      R . CX := 16#0000#; -- No attributes
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         if R . AX > 3 then       -- 4 = Too many open files, 5 = access denied
            raise USE_ERROR;
         else
            raise NAME_ERROR;     -- 3 = Path not found
         end if;
      end if;
      FILE := new FILE_DESCR'
         (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          MODE => MODE, INDEX => 1,
          HANDLE => INTEGER (R . AX));  -- AX contains the file handle after call 3C
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

-- See chapter 14.2.1

   begin
      if FILE /= null then
         raise STATUS_ERROR;
      end if;
      ASCIIZ_NAME (1..NAME'LENGTH) := NAME;
      ASCIIZ_NAME (NAME'LENGTH + 1) := NUL;
      case MODE is
         when IN_FILE    => R . AX := 16#3D00#; -- AH = 3D, Open a file
         when OUT_FILE   => R . AX := 16#3D01#; -- AL = 00, Open for input
         when INOUT_FILE => R . AX := 16#3D02#; -- AL = 01, Open for output
      end case;                                 -- AL = 02, Open for in- or out
      R . DX := WORD (ASCIIZ_NAME'ADDRESS);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         if R . AX > 3 then
            raise USE_ERROR; -- Access denied and to many files open
         else
            raise NAME_ERROR; -- File not found
         end if;
      end if;
      FILE := new FILE_DESCR'
         (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          MODE => MODE, INDEX => 1,
          HANDLE => INTEGER (R . AX));  -- AX contains the file handle
      FILE . NAME (1..NAME'LENGTH) := NAME;
      FILE . FORM (1..FORM'LENGTH) := FORM;
   end OPEN;

   procedure CLOSE (FILE : in out FILE_TYPE) is

-- See chapter 14.2.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      R . AX := 16#3E00#;    -- DOS function 3E, Close a file handle
      R . BX := WORD (FILE . HANDLE);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR; -- Invalid handle.  This error should never
      end if;             -- occur.  Something is wrong in the file system.
      FILE := null;
   end CLOSE;

   procedure DELETE (FILE : in out FILE_TYPE) is

      ASCIIZ_NAME : FILE_NAME_STRING;

-- See chapter 14.2.1

   begin
      ASCIIZ_NAME (1..FILE . NAMELEN) := FILE . NAME (1..FILE . NAMELEN);
      ASCIIZ_NAME (FILE . NAMELEN + 1) := NUL;
      CLOSE (FILE);
      R . AX := 16#4100#; -- DOS function 41, delete a file
      R . DX := WORD (ASCIIZ_NAME'ADDRESS);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- Access denied
      end if;
   end DELETE;

   procedure RESET (FILE : in out FILE_TYPE; MODE : in FILE_MODE) is

-- See chapter 14.2.1

      NAME : FILE_NAME_STRING;
      FORM : FORM_NAME_STRING;
      NAMELEN : NAME_INDEX;
      FORMLEN : FORM_INDEX;

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      if FILE . MODE = MODE then
         RESET (FILE);
      else
         NAME := FILE . NAME;
         FORM := FILE . FORM;
         NAMELEN := FILE . NAMELEN;
         FORMLEN := FILE . FORMLEN;
         CLOSE (FILE); -- Must close and reopen since MODE changes
         OPEN (FILE, MODE, NAME (1 .. NAMELEN), FORM (1..FORMLEN));
      end if;
   end RESET;

   procedure RESET (FILE : in out FILE_TYPE) is

-- See chapter 14.2.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      -- Do an LSEEK (FILE, 0);
      R . AX := 16#4200#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE);
      R . CX := 0;           -- Desired location from BOF
      R . DX := 0;
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;
      end if;
      FILE . INDEX := 1;
   end RESET;

   function MODE (FILE : in FILE_TYPE) return FILE_MODE is

-- See chapter 14.2.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . MODE;
   end MODE;

   function NAME (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.2.1


   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . NAME (1..FILE . NAMELEN);
   end NAME;

   function FORM (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.2.1

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . FORM (1 .. FILE . FORMLEN);
   end FORM;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN is

-- See chapter 14.2.1

   begin
      return FILE /= null;
   end IS_OPEN;

--
-- Input and output operations
--

   procedure SET_INDEX (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT) is

      BYTE_INDEX : LONG_INTEGER;

-- See chapter 14.2.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      R . AX := 16#4200#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE);
      BYTE_INDEX := INTEGER (TO - 1) *
         INTEGER (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . CX := WORD (BYTE_INDEX . HIGH); -- Desired location from BOF
      R . DX := WORD (BYTE_INDEX . LOW);
      CALL_DOS (R);
      FILE . INDEX := TO;
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- There should never be error here
      end if;
   exception
      when NUMERIC_ERROR =>
         raise USE_ERROR;
   end SET_INDEX;

   procedure FREAD (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE) is

      MYITEM : ELEMENT_TYPE;

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = OUT_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#3F00#;     -- DOS function 3F, read from a file or device
      R . BX := WORD (FILE . HANDLE);
      R . CX := WORD (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . DX := WORD (MYITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX = 0 then -- Read past EOF
         raise END_ERROR;
      end if;
      if abs R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
      FILE . INDEX := FILE . INDEX + 1;
      ITEM := MYITEM;
   end FREAD;

   procedure READ (FILE : in FILE_TYPE;
                   ITEM : out ELEMENT_TYPE;
                   FROM : in POSITIVE_COUNT) is

-- See chapter 14.2.4

   begin
      SET_INDEX (FILE, FROM);
      FREAD (FILE, ITEM);
   end READ;

   procedure READ (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE) is

-- See chapter 14.2.4

   begin
      FREAD (FILE, ITEM);
   end READ;

   procedure FWRITE (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE) is

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = IN_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#4000#;    -- DOS function 40, write to a file or device
      R . BX := WORD (FILE . HANDLE);
      R . CX := WORD (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX = 0 then -- No output made, probably disk full error
         raise USE_ERROR;
      end if;
      if abs R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
      FILE . INDEX := FILE . INDEX + 1;
   end FWRITE;

   procedure WRITE (FILE : in FILE_TYPE;
                    ITEM : in ELEMENT_TYPE;
                    TO   : in POSITIVE_COUNT) is

-- See chapter 14.2.4

   begin
      SET_INDEX (FILE, TO);
      FWRITE (FILE, ITEM);
   end WRITE;

   procedure WRITE (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE) is

-- See chapter 14.2.4

   begin
      FWRITE (FILE, ITEM);
   end WRITE;

   function INDEX (FILE : in FILE_TYPE) return POSITIVE_COUNT is

-- See chapter 14.2.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      return FILE . INDEX;
   end INDEX;

   function SIZE (FILE : in FILE_TYPE) return COUNT is

      BYTE_INDEX : LONG_INTEGER;
      C : COUNT;

-- See chapter 14.2.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      end if;
      R . AX := 16#4202#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE);
      R . CX := 0;           -- Desired location from EOF
      R . DX := 0;
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;             -- There should never be error here
      end if;
      BYTE_INDEX . HIGH := INTEGER (R . DX);
      BYTE_INDEX . LOW  := INTEGER (R . AX);
      C := COUNT (BYTE_INDEX / (ELEMENT_TYPE'SIZE / STORAGE_UNIT)); -- Keep the size
      R . AX := 16#4200#;                  -- Return to the previous location
      R . BX := WORD (FILE . HANDLE);
      BYTE_INDEX := INTEGER (FILE . INDEX - 1) *
         INTEGER (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . CX := WORD (BYTE_INDEX . HIGH);
      R . DX := WORD (BYTE_INDEX . LOW);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- There should never be error here
      end if;
      return C;
   exception
      when NUMERIC_ERROR =>
         raise USE_ERROR;
   end SIZE;

   function END_OF_FILE (FILE : in FILE_TYPE) return BOOLEAN is

      CH : CHARACTER;

-- See chapter 14.2.4

   begin
      if FILE = null then
         raise STATUS_ERROR;
      elsif FILE . MODE = OUT_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#3F00#;     -- DOS function 3F, read from a file or device
      R . BX := WORD (FILE . HANDLE);
      R . CX := 1;            -- Read one byte
      R . DX := WORD (CH'ADDRESS);
      CALL_DOS (R);
      if R . AX = 0 then -- Read past EOF
         UNGET (FILE);
         return TRUE;
      end if;
      if abs R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
      UNGET (FILE);
      return CH = EOF;
   end END_OF_FILE;

end DIRECT_IO;

