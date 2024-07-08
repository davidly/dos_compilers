--
-- T E X T   I N P U T / O U T P U T
--
-- Specifications of the Package Text_IO
--
-- Text handling package for Artek Ada
-- Copyright (C) 1986 by Artek Corporation
--

with IO_EXCEPTIONS;

package TEXT_IO is

   type FILE_TYPE is limited private;

   type FILE_MODE is (IN_FILE, OUT_FILE);

   type COUNT is range 0..INTEGER'LAST;
   subtype POSITIVE_COUNT is COUNT range 1..COUNT'LAST;
   UNBOUNDED : constant COUNT := 0;

   subtype FIELD is INTEGER range 0..40;
   subtype NUMBER_BASE is INTEGER range 2..16;

   type TYPE_SET is (LOWER_CASE, UPPER_CASE);

-- File Management

   procedure CREATE (FILE : in out FILE_TYPE;
                     MODE : in FILE_MODE := OUT_FILE;
                     NAME : in STRING := "";
                     FORM : in STRING := "");

   procedure OPEN   (FILE : in out FILE_TYPE;
                     MODE : in FILE_MODE;
                     NAME : in STRING;
                     FORM : in STRING := "");

   procedure CLOSE  (FILE : in out FILE_TYPE);
   procedure DELETE (FILE : in out FILE_TYPE);
   procedure RESET (FILE : in out FILE_TYPE; MODE : in FILE_MODE);
   procedure RESET (FILE : in out FILE_TYPE);

   function MODE (FILE : in FILE_TYPE) return FILE_MODE;
   function NAME (FILE : in FILE_TYPE) return STRING;
   function FORM (FILE : in FILE_TYPE) return STRING;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN;

-- Control of default input and output files

   procedure SET_INPUT (FILE : in FILE_TYPE);
   procedure SET_OUTPUT (FILE : in FILE_TYPE);

   function STANDARD_INPUT return FILE_TYPE;
   function STANDARD_OUTPUT return FILE_TYPE;

   function CURRENT_INPUT return FILE_TYPE;
   function CURRENT_OUTPUT return FILE_TYPE;

-- Specifications of line and page lengths

   procedure SET_LINE_LENGTH (FILE : in FILE_TYPE; TO : in COUNT);
   procedure SET_LINE_LENGTH (TO : in COUNT);

   procedure SET_PAGE_LENGTH (FILE : in FILE_TYPE; TO : in COUNT);
   procedure SET_PAGE_LENGTH (TO : in COUNT);

   function LINE_LENGTH (FILE : in FILE_TYPE) return COUNT;
   function LINE_LENGTH return COUNT;

   function PAGE_LENGTH (FILE : in FILE_TYPE) return COUNT;
   function PAGE_LENGTH return COUNT;

-- Column, Line, and Page Control

   procedure NEW_LINE (FILE : in FILE_TYPE; SPACING : in POSITIVE_COUNT := 1);
   procedure NEW_LINE (SPACING : in POSITIVE_COUNT := 1);

   procedure SKIP_LINE (FILE : in FILE_TYPE; SPACING : in POSITIVE_COUNT := 1);
   procedure SKIP_LINE (SPACING : in POSITIVE_COUNT := 1);

   function END_OF_LINE (FILE : in FILE_TYPE) return BOOLEAN;
   function END_OF_LINE return BOOLEAN;

   procedure NEW_PAGE (FILE : in FILE_TYPE);
   procedure NEW_PAGE;

   procedure SKIP_PAGE (FILE : in FILE_TYPE);
   procedure SKIP_PAGE;

   function END_OF_PAGE (FILE : in FILE_TYPE) return BOOLEAN;
   function END_OF_PAGE return BOOLEAN;

   function END_OF_FILE (FILE : in FILE_TYPE) return BOOLEAN;
   function END_OF_FILE return BOOLEAN;

   procedure SET_COL (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT);
   procedure SET_COL (TO : in POSITIVE_COUNT);

   procedure SET_LINE (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT);
   procedure SET_LINE (TO : in POSITIVE_COUNT);

   function COL (FILE : in FILE_TYPE) return POSITIVE_COUNT;
   function COL return POSITIVE_COUNT;

   function LINE (FILE : in FILE_TYPE) return POSITIVE_COUNT;
   function LINE return POSITIVE_COUNT;

   function PAGE (FILE : in FILE_TYPE) return POSITIVE_COUNT;
   function PAGE return POSITIVE_COUNT;

-- Character Input-Output

   procedure GET (FILE : in FILE_TYPE; ITEM : out CHARACTER);
   procedure GET (ITEM : out CHARACTER);

   procedure PUT (FILE : in FILE_TYPE; ITEM : in CHARACTER);
   procedure PUT (ITEM : in CHARACTER);

-- String Input-Output

   procedure GET (FILE : in FILE_TYPE; ITEM : out STRING);
   procedure GET (ITEM : out STRING);

   procedure PUT (FILE : in FILE_TYPE; ITEM : in STRING);
   procedure PUT (ITEM : in STRING);

   procedure GET_LINE (FILE : in FILE_TYPE; ITEM : out STRING; LAST : out NATURAL);
   procedure GET_LINE (ITEM : out STRING; LAST : out NATURAL);
   procedure PUT_LINE (FILE : in FILE_TYPE; ITEM : in STRING);
   procedure PUT_LINE (ITEM : in STRING);

-- Integer Input-Output

   generic

      type NUM is range <>;

   package INTEGER_IO is

      DEFAULT_WIDTH : FIELD := NUM'WIDTH;
      DEFAULT_BASE : NUMBER_BASE := 10;

      procedure GET
         (FILE : in FILE_TYPE; ITEM : out NUM; WIDTH : in FIELD := 0);
      procedure GET (ITEM : out NUM; WIDTH : in FIELD := 0);

      procedure PUT (
         FILE : in FILE_TYPE;
         ITEM : in NUM;
         WIDTH : in FIELD := DEFAULT_WIDTH;
         BASE : in NUMBER_BASE := DEFAULT_BASE);
      procedure PUT (
         ITEM : in NUM;
         WIDTH : in FIELD := DEFAULT_WIDTH;
         BASE : in NUMBER_BASE := DEFAULT_BASE);

      procedure GET (
         FROM : in STRING;
         ITEM : out NUM;
         LAST : out POSITIVE);
      procedure PUT (
         TO : out STRING;
         ITEM : in NUM;
         BASE : in NUMBER_BASE := DEFAULT_BASE);

   end INTEGER_IO;

-- Floating-point Input/Output

   generic

      type NUM is digits <>;

   package FLOAT_IO is

      DEFAULT_FORE : FIELD := 2;
      DEFAULT_AFT : FIELD := NUM'DIGITS - 1;
      DEFAULT_EXP : FIELD := 3;

      procedure GET (FILE : in FILE_TYPE; ITEM : out NUM; WIDTH : in FIELD := 0);
      procedure GET (ITEM : out NUM; WIDTH : in FIELD := 0);

      procedure PUT (
         FILE : in FILE_TYPE;
         ITEM : in NUM;
         FORE : in FIELD := DEFAULT_FORE;
         AFT : in FIELD := DEFAULT_AFT;
         EXP : in FIELD := DEFAULT_EXP);
      procedure PUT (
         ITEM : in NUM;
         FORE : in FIELD := DEFAULT_FORE;
         AFT : in FIELD := DEFAULT_AFT;
         EXP : in FIELD := DEFAULT_EXP);

      procedure GET (FROM : in STRING; ITEM : out NUM; LAST : out POSITIVE);
      procedure PUT (
         TO : out STRING;
         ITEM : in NUM;
         AFT : in FIELD := DEFAULT_AFT;
         EXP : in FIELD := DEFAULT_EXP);

   end FLOAT_IO;

-- Fixed-point Input/Output - Not implemented in version 1.00
--
--   generic
--
--      type NUM is delta <>;
--
--   package FIXED_IO is
--
--      DEFAULT_FORE : FIELD := NUM'FORE;
--      DEFAULT_AFT  : FIELD := NUM'AFT;
--      DEFAULT_EXP  : FIELD := 0;
--
--      procedure GET (FILE : in FILE_TYPE; ITEM : out NUM; WIDTH : in FIELD := 0);
--      procedure GET (ITEM : out NUM; WIDTH : in FIELD := 0);
--
--      procedure PUT (
--         FILE : in FILE_TYPE;
--         ITEM : in NUM;
--         FORE : in FIELD := DEFAULT_FORE;
--         AFT : in FIELD := DEFAULT_AFT;
--         EXP : in FIELD := DEFAULT_EXP);
--      procedure PUT (
--         ITEM : in NUM;
--         FORE : in FIELD := DEFAULT_FORE;
--         AFT : in FIELD := DEFAULT_AFT;
--         EXP : in FIELD := DEFAULT_EXP);
--
--      procedure GET (FROM : in STRING; ITEM : out FLOAT; LAST : out POSITIVE);
--      procedure PUT (
--         TO : out STRING;
--         ITEM : in NUM;
--         AFT : in FIELD := DEFAULT_AFT;
--         EXP : in FIELD := DEFAULT_EXP);
--
--   end FIXED_IO;

-- Enumeration Input/Output - Not implemented in version 1.00

   generic

      type ENUM is (<>);

   package ENUMERATION_IO is

      DEFAULT_WIDTH   : FIELD := 0;
      DEFAULT_SETTING : TYPE_SET := UPPER_CASE;

      procedure GET (FILE : in FILE_TYPE; ITEM : out ENUM);
      procedure GET (ITEM : out ENUM);

      procedure PUT (
         FILE  : in FILE_TYPE;
         ITEM  : in ENUM;
         WIDTH : in FIELD    := DEFAULT_WIDTH;
         SET   : in TYPE_SET := DEFAULT_SETTING);
      procedure PUT (
         ITEM  : in ENUM;
         WIDTH : in FIELD    := DEFAULT_WIDTH;
         SET   : in TYPE_SET := DEFAULT_SETTING);

      procedure GET (FROM : in STRING; ITEM : out ENUM; LAST : out POSITIVE);
      procedure PUT (
         TO   : out STRING;
         ITEM : in ENUM;
         SET  : in TYPE_SET := DEFAULT_SETTING);

   end ENUMERATION_IO;

-- Exceptions

   STATUS_ERROR : exception renames IO_EXCEPTIONS.STATUS_ERROR;
   MODE_ERROR   : exception renames IO_EXCEPTIONS.MODE_ERROR;
   NAME_ERROR   : exception renames IO_EXCEPTIONS.NAME_ERROR;
   USE_ERROR    : exception renames IO_EXCEPTIONS.USE_ERROR;
   DEVICE_ERROR : exception renames IO_EXCEPTIONS.DEVICE_ERROR;
   END_ERROR    : exception renames IO_EXCEPTIONS.END_ERROR;
   DATA_ERROR   : exception renames IO_EXCEPTIONS.DATA_ERROR;
   LAYOUT_ERROR : exception renames IO_EXCEPTIONS.LAYOUT_ERROR;

private

   MAX_NAME_LEN : constant := 32; -- Complete name with paths
   MAX_FORM_LEN : constant := 10; -- The form is not used in MS-DOS

   subtype NAME_INDEX is INTEGER range 0..MAX_NAME_LEN;
   subtype FORM_INDEX is INTEGER range 0..MAX_FORM_LEN;

   subtype FILE_NAME_STRING is STRING (1..MAX_NAME_LEN);
   subtype FORM_NAME_STRING is STRING (1..MAX_FORM_LEN);

   type FILE_DESCR is
      record
         NAMELEN     : NAME_INDEX;
         NAME        : FILE_NAME_STRING;
         MODE        : FILE_MODE;
         FORMLEN     : FORM_INDEX;
         FORM        : FORM_NAME_STRING;
         COL         : POSITIVE_COUNT;
         LINE        : POSITIVE_COUNT;
         PAGE        : POSITIVE_COUNT;
         LINE_LENGTH : COUNT;
         PAGE_LENGTH : COUNT;
         HANDLE      : INTEGER;
      end record;

   type FILE_TYPE is access FILE_DESCR;

end TEXT_IO;

