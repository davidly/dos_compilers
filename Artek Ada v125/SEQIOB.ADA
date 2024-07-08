--
-- S E Q U E N T I A L   I N P U T / O U T P U T
--
-- Body of the Package Sequential_IO
--
-- According to ANSI/MIL-STD 1815A (1983)
-- Implemented for Artek Ada
--
-- Copyright (C) 1986 Artek Corporation
-- Author : O. Karlsson
--
--
-- Version: 1.00
--

with DOS_INTERFACE, SYSTEM;

package body SEQUENTIAL_IO is

   use DOS_INTERFACE, SYSTEM, ASCII;

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
      if R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- There should never be error here
      end if;
   end UNGET;

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

-- See chapter 14.2.1

   begin -- Concatenate a null character
      if FILE . IS_OPEN then
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
      FILE :=
         (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          MODE => MODE, IS_OPEN => TRUE,
          HANDLE => INTEGER (R . AX));
      FILE . NAME (1..NAME'LENGTH) := NAME;
      FILE . NAME (1..FORM'LENGTH) := FORM;
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
      if FILE . IS_OPEN then
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
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         if R . AX > 3 then
            raise USE_ERROR; -- Access denied or to many files open
         else
            raise NAME_ERROR; -- File not found
         end if;
      end if;
      FILE :=
          (NAMELEN => NAME'LENGTH, NAME => BLANK_NAME,
          FORMLEN => FORM'LENGTH, FORM => BLANK_FORM,
          MODE => MODE, IS_OPEN => TRUE,
          HANDLE => INTEGER (R . AX));
      FILE . NAME (1..NAME'LENGTH) := NAME;
      FILE . NAME (1..FORM'LENGTH) := FORM;
   end OPEN;

   procedure CLOSE (FILE : in out FILE_TYPE) is

-- See chapter 14.2.1

      CH : CHARACTER := EOF;

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      end if;
      if FILE . MODE = OUT_FILE then -- Put EOF at end of file
         R . AX := 16#4000#;     -- DOS function 40, write to a file or device
         R . BX := WORD (FILE . HANDLE);  -- The file handle
         R . CX := 1;                     -- Write one byte
         R . DX := WORD (CH'ADDRESS);
         CALL_DOS (R);
         if R . AX = 0 then -- No output made, probably disk full error
            raise USE_ERROR;
         end if;
         if abs R . FLAGS mod 2 = 1 then -- Carry set
            raise USE_ERROR;  -- Access denied or invalid file handle
         end if;
      end if;
      R . AX := 16#3E00#;    -- DOS function 3E, Close a file handle
      R . BX := WORD (FILE . HANDLE);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR; -- Invalid handle.  This error should never
      end if;             -- occur.  Something is wrong in the file system.
      FILE . IS_OPEN := FALSE;
   end CLOSE;

   procedure DELETE (FILE : in out FILE_TYPE) is

      ASCIIZ_NAME : FILE_NAME_STRING;

-- See chapter 14.2.1

   begin
      CLOSE (FILE);
      ASCIIZ_NAME (1..FILE . NAMELEN) := FILE . NAME (1..FILE . NAMELEN);
      ASCIIZ_NAME (FILE . NAMELEN + 1) := NUL;
      R . AX := 16#4100#; -- DOS function 41, delete a file
      R . DX := WORD (ASCIIZ_NAME'ADDRESS);
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;         -- Access denied
      end if;
   end DELETE;

   procedure RESET (FILE : in out FILE_TYPE; MODE : in FILE_MODE) is

-- See chapter 14.2.1

   begin
      CLOSE (FILE); -- Must close and reopen since MODE changes
      OPEN (FILE, MODE, FILE . NAME, FILE . FORM);
   end RESET;

   procedure RESET (FILE : in out FILE_TYPE) is

-- See chapter 14.2.1

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      end if;
      -- Do an LSEEK (FILE, 0);
      R . AX := 16#4200#;    -- DOS function 42, lseek
      R . BX := WORD (FILE . HANDLE); -- File handle
      R . CX := 0;           -- Desired location from BOF
      R . DX := 0;
      CALL_DOS (R);
      if abs R . FLAGS mod 2 = 1 then -- Carry was set
         raise USE_ERROR;
      end if;
   end RESET;

   function MODE (FILE : in FILE_TYPE) return FILE_MODE is

-- See chapter 14.2.1

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      end if;
      return FILE . MODE;
   end MODE;

   function NAME (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.2.1

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      end if;
      return FILE . NAME;
   end NAME;

   function FORM (FILE : in FILE_TYPE) return STRING is

-- See chapter 14.2.1

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      end if;
      return FILE . FORM;
   end FORM;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN is

-- See chapter 14.2.1

   begin
      return FILE . IS_OPEN;
   end IS_OPEN;

--
-- Input and output operations
--

   procedure READ (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE) is

-- See chapter 14.2.2

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#3F00#;     -- DOS function 3F, read from a file or device
      R . BX := WORD (FILE . HANDLE);  -- The file handle
      R . CX := WORD (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX = 0 then -- Read past EOF
         raise END_ERROR;
      end if;
      if abs R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
   end READ;

   procedure WRITE (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE) is

-- See chapter 14.2.2

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      elsif FILE . MODE /= OUT_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#4000#;    -- DOS function 40, write to a file or device
      R . BX := WORD (FILE . HANDLE); -- The file handle
      R . CX := WORD (ELEMENT_TYPE'SIZE / STORAGE_UNIT);
      R . DX := WORD (ITEM'ADDRESS); -- Address of ITEM
      CALL_DOS (R);
      if R . AX = 0 then -- No output made, probably disk full error
         raise USE_ERROR;
      end if;
      if abs R . FLAGS mod 2 = 1 then -- Carry set
         raise USE_ERROR;  -- Access denied or invalid file handle
      end if;
   end WRITE;

   function END_OF_FILE (FILE : in FILE_TYPE) return BOOLEAN is

      CH : CHARACTER;

-- See chapter 14.2.2

   begin
      if not FILE . IS_OPEN then
         raise STATUS_ERROR;
      elsif FILE . MODE /= IN_FILE then
         raise MODE_ERROR;
      end if;
      R . AX := 16#3F00#;     -- DOS function 3F, read from a file or device
      R . BX := WORD (FILE . HANDLE);  -- The file handle
      R . CX := 1;                     -- Read one byte
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

end SEQUENTIAL_IO;

