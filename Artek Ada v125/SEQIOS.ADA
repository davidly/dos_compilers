--
-- S E Q U E N T I A L   I N P U T / O U T P U T
--
-- Specification of the Package Sequential_IO
--
-- Copyright (C) 1986 Artek Corporation
--

with IO_EXCEPTIONS;

generic

   type ELEMENT_TYPE is private;

package SEQUENTIAL_IO is

   type FILE_TYPE is limited private;

   type FILE_MODE is (IN_FILE, OUT_FILE);

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
   procedure RESET  (FILE : in out FILE_TYPE; MODE : in FILE_MODE);
   procedure RESET  (FILE : in out FILE_TYPE);


   function MODE (FILE : in FILE_TYPE) return FILE_MODE;
   function NAME (FILE : in FILE_TYPE) return STRING;
   function FORM (FILE : in FILE_TYPE) return STRING;

   function IS_OPEN (FILE : in FILE_TYPE) return BOOLEAN;

-- Input and output operations

   procedure READ  (FILE : in FILE_TYPE; ITEM : out ELEMENT_TYPE);
   procedure WRITE (FILE : in FILE_TYPE; ITEM : in ELEMENT_TYPE);

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

   type FILE_TYPE is
      record
         NAMELEN : NAME_INDEX;
         NAME    : FILE_NAME_STRING;
         MODE    : FILE_MODE;
         FORMLEN : FORM_INDEX;
         FORM    : FORM_NAME_STRING;
         IS_OPEN : BOOLEAN := FALSE;
         HANDLE  : INTEGER;          -- DOS handle number, DOS 2 or later
      end record;

end SEQUENTIAL_IO;

