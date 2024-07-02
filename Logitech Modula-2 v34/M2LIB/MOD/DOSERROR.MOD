(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    DOSError, give string corr. to DOS error code                        *)
(*                                                                         *)
(*    Release :    Dec 89                                                  *)
(*                                                                         *)
(*    Copyright (C)  1987, 1989 Logitech, All rights reserved              *)
(*                                                                         *)
(*    Permission is hereby granted to registered users to use or abstract  *)
(*    the following program in the implementation of customized versions.  *)
(*    This permission does not include the right to redistribute the       *)
(*    source code of this program.                                         *)
(*                                                                         *)
(***************************************************************************)
IMPLEMENTATION MODULE DosError;

  FROM Strings IMPORT ConstAssign;

  TYPE 
    ErrorMessage = ARRAY [0 .. 79] OF CHAR;

  VAR
    i      : CARDINAL;
    meaning: ARRAY [1 .. 88] OF ErrorMessage;
    
  
  PROCEDURE GetErrorMessage (errorCode        : CARDINAL;
                             VAR errorMessage : ARRAY OF CHAR);
   (* errorCode is an error number returned by DOS functions
      errorMessage is at most ConstAssign ("x character long *)
   BEGIN
     IF (errorCode < 1) OR (errorCode > 88) THEN
       ConstAssign ("Illegal error code", errorMessage);
     ELSE
       ConstAssign (meaning [errorCode], errorMessage);
     END;
   END GetErrorMessage;

  BEGIN
    FOR i := 1 TO 88 DO
      ConstAssign ("Illegal error code",                  meaning [i]);
    END;

  (* Version 2 file-function errors: *)
    ConstAssign ("Invalid function number",               meaning [01]);
    ConstAssign ("File not found",                        meaning [02]);
    ConstAssign ("Path not found",                        meaning [03]);
    ConstAssign ("Too many open files",                   meaning [04]);
    ConstAssign ("Access denied",                         meaning [05]);
    ConstAssign ("Invalid handle",                        meaning [06]);
    ConstAssign ("Memory control blocks destroyed",       meaning [07]);
    ConstAssign ("Insufficient memory",                   meaning [08]);
    ConstAssign ("Invalid memory block address",          meaning [09]);
    ConstAssign ("Invalid environment",                   meaning [10]);
    ConstAssign ("Invalid format",                        meaning [11]);
    ConstAssign ("Invalid access code",                   meaning [12]);
    ConstAssign ("Invalid data",                          meaning [13]);
    ConstAssign ("Invalid disk drive",                    meaning [15]);
    ConstAssign ("Attempt to remove current directory",   meaning [16]);
    ConstAssign ("Not same device",                       meaning [17]);
    ConstAssign ("No more files",                         meaning [18]);

  (* Mapping to critical error handler: *)
    ConstAssign ("Disk write-protected",                  meaning [19]);
    ConstAssign ("Unknown disk unit",                     meaning [20]);
    ConstAssign ("drive not ready",                       meaning [21]);
    ConstAssign ("Unknown command",                       meaning [22]);
    ConstAssign ("Data error (CRC)",                      meaning [23]);
    ConstAssign ("Bad request structure length",          meaning [24]);
    ConstAssign ("Seek error",                            meaning [25]);
    ConstAssign ("Unknown media type",                    meaning [26]);
    ConstAssign ("Sector not found",                      meaning [27]);
    ConstAssign ("Printer out of paper",                  meaning [28]);
    ConstAssign ("Write fault",                           meaning [29]);
    ConstAssign ("Read fault",                            meaning [30]);
    ConstAssign ("General failure",                       meaning [31]);

  (* Version 3 additional error codes: *)
    ConstAssign ("Sharing violation",                     meaning [32]);
    ConstAssign ("Lock violation",                        meaning [33]);
    ConstAssign ("Invalid disk change",                   meaning [34]);
    ConstAssign ("FCB unavailable",                       meaning [35]);
    ConstAssign ("Sharing buffer overflow",               meaning [36]);
    ConstAssign ("Network request not supported",         meaning [50]);
    ConstAssign ("Remote computer not listening",         meaning [51]);
    ConstAssign ("Duplicate name on network",             meaning [52]);
    ConstAssign ("Network name not found",                meaning [53]);
    ConstAssign ("Network busy",                          meaning [54]);
    ConstAssign ("Network device no longer exists",       meaning [55]);
    ConstAssign ("Network BIOS command limit exceeded",   meaning [56]);
    ConstAssign ("Network adaptater hardware error",      meaning [57]);
    ConstAssign ("Incorrect response from network",       meaning [58]);
    ConstAssign ("Unexpected network error",              meaning [59]);
    ConstAssign ("Incompatible remote adaptater",         meaning [60]);
    ConstAssign ("Print queue full",                      meaning [61]);
    ConstAssign ("Print queue not full",                  meaning [62]);
    ConstAssign ("Print file deleted (not enough space)", meaning [63]);
    ConstAssign ("Network name deleted",                  meaning [64]);
    ConstAssign ("Access denied",                         meaning [65]);
    ConstAssign ("Network device type incorrect",         meaning [66]);
    ConstAssign ("Network name not found",                meaning [67]);
    ConstAssign ("Network name limit exceeded",           meaning [68]);
    ConstAssign ("Network BIOS session limit exceeded",   meaning [69]);
    ConstAssign ("Temporarily paused",                    meaning [70]);
    ConstAssign ("Network request not accepted",          meaning [71]);
    ConstAssign ("Print or disk redirection paused",      meaning [72]);
    ConstAssign ("File already exists",                   meaning [80]);
    ConstAssign ("Cannot make directory entry",           meaning [82]);
    ConstAssign ("Failure on Int 24H",                    meaning [83]);
    ConstAssign ("Too many redirections",                 meaning [84]);
    ConstAssign ("Duplicate redirection",                 meaning [85]);
    ConstAssign ("Invalid password",                      meaning [86]);
    ConstAssign ("Invalid parameter",                     meaning [87]);
    ConstAssign ("Network device fault",                  meaning [88]);

END DosError.
