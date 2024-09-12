PROGRAM Log2Scr;
{$M 4096, 0, 0}
{$I-}

Uses Dos, Tables;

VAR
    InFile	: File OF LogRec;
    InFileName	: PathStr;
    
    OutFile	: Text;
    OutFileBuf	: ARRAY [1..512] OF BYTE;
    OutFileName	: PathStr;
    
    Data	: LogRec;
    
    GotOne	: BOOLEAN;
    i		: WORD;
BEGIN
    IF ParamCount() <> 1 THEN BEGIN
	WriteLn('Usage: Log2Scr name[.LOG]');
	WriteLn('will output to same name with .SCR extension');
	HALT(1);
    END;
    
    ConstructFileName(ParamStr(1), '.LOG', InFileName);
    ConstructFileName('.SCR', InFileName, OutFileName);
    
    Assign(InFile, InFileName);
    Reset(InFile);
    IF IOResult() <> 0 THEN BEGIN
	WriteLn('File not found: ', InFileName);
	HALT(1);
    END;
    
    Assign(OutFile, OutFileName);
    ReWrite(OutFile);
    IF IOResult() <> 0 THEN BEGIN
	WriteLn('Error creating: ', OutFileName);
	HALT(1);
    END;
    SetTextBuf(OutFile, OutFileBuf, SizeOf(OutFileBuf));
    
    GotOne := FALSE;
    REPEAT
	IF NOT GotOne THEN
	    Read(InFile, Data);
	
	GotOne := FALSE;
	IF (Data.key <= 255) AND
	   (Data.key <> 13) AND
	   (Data.key <> 27) AND
	   (Data.key <> 9) AND
	   (Data.key <> 8)
	THEN BEGIN
	    Write(OutFile, '"');

	    REPEAT
		Write(OutFile, CHAR(Data.key));
		IF NOT Eof(InFile) THEN
		    Read(InFile, Data);
	    UNTIL Eof(InFile) OR
	          (Data.key > 255) OR
		  (Data.key = 13) OR
		  (Data.key = 27) OR
		  (Data.key = 9) OR
		  (Data.key = 8);
	    
	    GotOne := NOT Eof(InFile);
	    WriteLn(OutFile, '"');
	END ELSE BEGIN
	    i := 0;
	    REPEAT
		INC(i);
	    UNTIL (Data.key = BuiltIns[i].key) OR (i > MaxBuiltIns);
	    
	    IF i <= MaxBuiltIns THEN
		WriteLn(OutFile, BuiltIns[i].name);
	END;
    UNTIL (NOT GotOne) AND Eof(InFile);

    Close(InFile);
    Close(OutFile);
END.
