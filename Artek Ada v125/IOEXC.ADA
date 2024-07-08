--
-- Package IO_EXCEPTIONS
--
-- Standard Ada Input/Output exceptions
--
-- (C) 1985 Artek Corporation
--

package IO_EXCEPTIONS is

-- See ANSI/MIL-STD-1815A 1983

   STATUS_ERROR : exception;
   MODE_ERROR : exception;
   NAME_ERROR : exception;
   USE_ERROR : exception;
   DEVICE_ERROR : exception;
   END_ERROR : exception;
   DATA_ERROR : exception;
   LAYOUT_ERROR : exception;

end IO_EXCEPTIONS;

