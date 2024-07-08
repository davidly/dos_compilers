--
-- D I R E C T   I N P U T / O U T P U T
--
-- Specification of the Package Direct_IO
--
-- Copyright (C) 1986 Artek Corporation
--

with IO_EXCEPTIONS;

generic

   type ELEMENT_TYPE is private;

package DIRECT_IO is

   type FILE_TYPE is limited private;

   type    FILE_MODE is (IN_FILE, INOUT_FILE, OUT_FILE);
   type    COUNT is range 0 .. INTEGER'LAST;
   subtype POSITIVE_COUNT is COUNT range 1 .. COUNT'LAST;

-- File Management

   procedure CREATE (FILE : in out FILE_TYPE;
                     MODE : in FILE_MODE := INOUT_FILE;
                     NAME : in STRING := "";
                     FORM : in STRING := "");

   procedure OPEN   (FILE : in out FILE_TYPE;
                     MODE : in FILE_MODE;
                     NAME : in STRING;
                     FORM : in STRING := "");

   procedure CLOSE  (FILE : in out FILE_TYPE);
   procedure DELETE (FILE : in out FILE_TYPE);
   procedure RESET  (FILE : in out FILE_TYPE; MODE : in FILE_MODE);
   procedure RESET  (FILE : in out FILE_TYPE);

   function MODE (FILE : in FILE_TYPE) return FILE_MODE;
   function NAME (FILE : in FILE_TYPE) return STRING;
   function FORM (FILE : in FILE_TYPE) return STRING;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN;

-- Input and output operations

   procedure READ
      (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE; FROM : POSITIVE_COUNT);
   procedure READ  (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE);

   procedure WRITE
      (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE; TO : POSITIVE_COUNT);
   procedure WRITE (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE);

   procedure SET_INDEX (FILE : in FILE_TYPE; TO : in POSITIVE_COUNT);

   function INDEX (FILE : in FILE_TYPE) return POSITIVE_COUNT;
   function SIZE  (FILE : in FILE_TYPE) return COUNT;

   function END_OF_FILE (FILE : in FILE_TYPE) return BOOLEAN;

-- Exceptions

   STATUS_ERROR : exception renames IO_EXCEPTIONS.STATUS_ERROR;
   MODE_ERROR   : exception renames IO_EXCEPTIONS.MODE_ERROR;
   NAME_ERROR   : exception renames IO_EXCEPTIONS.NAME_ERROR;
   USE_ERROR    : exception renames IO_EXCEPTIONS.USE_ERROR;
   DEVICE_ERROR : exception renames IO_EXCEPTIONS.DEVICE_ERROR;
   END_ERROR    : exception renames IO_EXCEPTIONS.END_ERROR;
   DATA_ERROR   : exception renames IO_EXCEPTIONS.DATA_ERROR;

private

   MAX_NAME_LEN : constant := 32; -- Complete name with paths
   MAX_FORM_LEN : constant := 10; -- The form is not used in MS-DOS

   subtype NAME_INDEX is INTEGER range 0..MAX_NAME_LEN;
   subtype FORM_INDEX is INTEGER range 0..MAX_FORM_LEN;

   subtype FILE_NAME_STRING is STRING (1..MAX_NAME_LEN);
   subtype FORM_NAME_STRING is STRING (1..MAX_FORM_LEN);

   type FILE_DESCR is
      record
         NAMELEN : NAME_INDEX;
         NAME    : FILE_NAME_STRING;
         MODE    : FILE_MODE;
         FORMLEN : FORM_INDEX;
         FORM    : FORM_NAME_STRING;
         INDEX   : POSITIVE_COUNT;
         HANDLE  : INTEGER;          -- DOS handle number, DOS 2 or later
      end record;

   type FILE_TYPE is access FILE_DESCR;

end DIRECT_IO;

