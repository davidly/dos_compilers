MODULE FileIO;
(* Program to demonstrate basic file I/O *)

FROM Terminal IMPORT Read, ReadAgain, ReadString, WriteString, WriteLn, Write;
FROM CardinalIO IMPORT ReadCardinal, WriteCardinal;
FROM LogiFile IMPORT File, Open, OpenMode, ReadChar, WriteChar, EndFile,
                     EOL, Close, Delete, Create;

CONST ESC = 33C;

VAR ch : CHAR;
    linesToCopy, linesCopied : CARDINAL;
    inFile, outFile : File;
    ok : BOOLEAN;
    

PROCEDURE SpecifyFile (VAR file : File;
                           mode : OpenMode;
                           prompt : ARRAY OF CHAR;
                       VAR result : BOOLEAN);
  VAR fileName : ARRAY [0..80] OF CHAR;
      ch       : CHAR;
      done     : BOOLEAN;
BEGIN
  result := FALSE;
  REPEAT
    WriteLn;
    WriteString (prompt);
    ReadString (fileName);
    WriteLn;
    ReadAgain; Read (ch); (* read the terminating character *)
    IF ch=ESC THEN RETURN END; (* allow to quit the program *)
    Open (file, fileName, mode, done);
    IF mode <> ReadOnly THEN
      IF done THEN 
        (* the output file exists already *)
        WriteString (" --- exists already. delete (y/-) ? ");
        Read (ch); Write (ch); WriteLn;
        done := FALSE;
        IF CAP (ch) = 'Y' THEN
          Delete (file, done);
        END;
        IF NOT done THEN RETURN END;
      END;
      Create (file, fileName, done);
    END;
    IF NOT done THEN 
      WriteString (" --- cannot open the file"); WriteLn;
    END;
  UNTIL done; (* keep trying until open is successful *)
  result := TRUE;
END SpecifyFile;


BEGIN (* Example3 *)
  WriteString (" This program copies the specified number of lines from ");
  WriteLn;
  WriteString (" the input file to the output file and to the screen. ");
  WriteLn;

  SpecifyFile (inFile, ReadOnly, "Enter input file name:", ok);
  IF NOT ok THEN RETURN END;
  
  WriteString ("Lines to copy> ");
  ReadCardinal (linesToCopy);
  Read(ch); (* read terminator of ReadCardinal *)
  IF ch=ESC THEN 
    Close (inFile, ok);
    RETURN; (* allow to quit the program at any moment *)
  END;

  SpecifyFile (outFile, WriteOnly, "Enter output file name:", ok);
  IF ok THEN
    linesCopied := 0; ch := EOL;
    WriteLn; 

    LOOP
      IF ch = EOL THEN 
        IF linesCopied >= linesToCopy THEN EXIT END;
        INC (linesCopied);
        WriteCardinal (linesCopied,4); WriteString (": ");
      END;
      ReadChar (inFile, ch);             (* Read from input file, *)
      IF EndFile (inFile) THEN EXIT END; (* check for EOF, otherwise *)
      WriteChar (outFile, ch);           (* copy the char to the file *)
      Write (ch);                        (* and to the screen. *)
    END; (* LOOP *)

    WriteLn;
    IF linesCopied < linesToCopy THEN
      WriteString("[Only ");
      WriteCardinal(linesCopied,0);
      WriteString(" lines in file]"); WriteLn;
    ELSE
      WriteCardinal(linesCopied,0);
      WriteString (" lines copied");
    END; (* IF *)
    Close (outFile, ok);
  END; (* IF *)
  Close (inFile, ok);
END FileIO.
