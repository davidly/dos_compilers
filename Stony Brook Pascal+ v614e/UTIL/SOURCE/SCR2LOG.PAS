PROGRAM Scr2Log;
{$M 4096, 8192, 655530}
{$I-}

Uses Dos, Tables;

CONST
    MaxOutBufCount	= 32;
TYPE
    CommandPointer	= ^CommandRec;
    CommandRec =
	RECORD
	next	: CommandPointer;
	cursor	: WORD;
	start	: WORD;
	len	: WORD;
	curLine	: WORD;
	count	: WORD;
	isQuote	: BOOLEAN;
	isRepeat: BOOLEAN;
	data	: STRING;
	END;
VAR
    InFile	: Text;
    InFileBuf	: ARRAY [1..512] OF BYTE;
    InFileName	: PathStr;
    EndOfFile	: BOOLEAN;
    
    OutFile	: File;
    OutFileBuf	: ARRAY [1..MaxOutBufCount] OF LogRec;
    OutBufCount	: WORD;
    OutFileName	: PathStr;
    
    Command	: STRING;
    Stuff	: CommandRec;
    Mac		: MacroPointer;
    MacroDefinition	: BOOLEAN;
    
    OutData	: LogRec;
    
    i		: WORD;

PROCEDURE PushStuff(newCommand : STRING);
VAR
    push	: CommandPointer;
BEGIN
    NEW(push);
    push^ := Stuff;
    Stuff.next := push;
    
    Stuff.data := newCommand;
    Stuff.len := Length(newCommand);
    Stuff.cursor := 1;
    Stuff.start := 1;
    Stuff.curLine := push^.curLine;
    Stuff.isQuote := FALSE;
END;

PROCEDURE PopStuff;
BEGIN
    IF Stuff.next <> NIL THEN
	Stuff := Stuff.next^
    ELSE
	WriteLn('Error: Macro stack underflow');
END;

(* skip white space, empty data fields etc. *)

PROCEDURE SkipSpace;
VAR
    start : WORD;
BEGIN
    REPEAT
	start := Stuff.cursor;

	WHILE (Stuff.cursor <= Stuff.len) AND
	      (
	       (Stuff.data[Stuff.cursor] = ' ')
	       OR
	       (Stuff.data[Stuff.cursor] = #9)
	      )
	DO BEGIN
	    INC(Stuff.cursor);
	END;
	
	WHILE (Stuff.cursor <= Stuff.len) AND
	      (Stuff.data[Stuff.cursor] = ',')
	DO BEGIN
	    INC(Stuff.cursor);
	END;
    UNTIL (start = Stuff.cursor) OR (Stuff.cursor > Stuff.len);
END;

PROCEDURE ReadSomeStuff;
VAR
    i : WORD;
BEGIN
    MacroDefinition := FALSE;

    IF (Stuff.cursor > Stuff.len) AND (Stuff.next <> NIL) THEN BEGIN
	PopStuff;
	IF Stuff.cursor > Stuff.len THEN
	    ReadSomeStuff;
    END ELSE IF Eof(InFile) THEN
	EndOfFile := TRUE
    ELSE BEGIN
	REPEAT
	    ReadLn(InFile, Stuff.data);
	    EndOfFile := Eof(InFile);
	    Stuff.cursor := 1;
	    Stuff.len := Length(Stuff.data);
	    INC(Stuff.curLine);
	    SkipSpace;
	UNTIL EndOfFile OR
	      ((Stuff.len <> 0) AND (Stuff.data[Stuff.cursor] <> ';'));
	
	IF EndOfFile AND
	   ((Stuff.len <> 0) AND (Stuff.data[Stuff.cursor] <> ';'))
	THEN
	    EndOfFile := FALSE;
	
	i := Stuff.cursor;
	WHILE i <= Stuff.len DO BEGIN
	    IF Stuff.data[i] = '=' THEN BEGIN
		MacroDefinition := TRUE;
		i := Stuff.len + 1;
		Stuff.cursor := i;
	    END;
	    INC(i);
	END;
    END;
END;

PROCEDURE GetCommand;
VAR
    termChar	: CHAR;
    i		: WORD;
    l		: WORD;
BEGIN
    Command := '';
    
    IF Stuff.cursor > Stuff.len THEN
	ReadSomeStuff;
    
    IF MacroDefinition OR EndOfFile THEN
	EXIT;
    
    SkipSpace;
    
    l := Stuff.len;
    i := Stuff.cursor;
    
    termChar :=  ',';
    Stuff.isQuote := FALSE;
    Stuff.isRepeat := FALSE;
    
    IF (i <= l) AND
       (
        (Stuff.data[i] = '"') OR (Stuff.data[i] = '''')
       )
    THEN BEGIN
	termChar := Stuff.data[i];
	Stuff.isQuote := TRUE;
	INC(i);
    END ELSE IF (i <= l) AND (Stuff.data[i] = '(') THEN BEGIN
	Stuff.isRepeat := TRUE;

	termChar := ')';
	INC(i);
	Stuff.count := ORD(Stuff.data[i]) - ORD('0');
	INC(i);

	IF (Stuff.data[i] >= '0') AND (Stuff.data[i] <= '9') THEN BEGIN
	    Stuff.count := Stuff.count * 10;
	    Stuff.count := Stuff.count + ORD(Stuff.data[i])-ORD('0');
	    INC(i);
	END;

	IF Stuff.data[i] <> ':' THEN BEGIN
	    WriteLn('Error: bad repeat block');
	    EndOfFile := TRUE;
	    EXIT;
	END;

	INC(i);
    END;
    
    Stuff.start := i;
    WHILE (i <= l) AND (Stuff.data[i] <> termChar) DO
	INC(i);
    
    IF Stuff.start < l THEN BEGIN
	Command := Copy(Stuff.data, Stuff.start, i-Stuff.start);
	
	IF Stuff.isQuote OR Stuff.isRepeat THEN BEGIN
	    IF (i > l) OR (Stuff.data[i] <> termChar) THEN BEGIN
		Write('Error: at line ', Stuff.curLine);
		WriteLn(' bad quote or repeat command');
		EndOfFile := TRUE;
		Command := '';
		EXIT;
	    END;
	    INC(i);
	END;
	
	SkipSpace;
	
    END;

    Stuff.cursor := i;
    
    IF Stuff.isQuote THEN
	Stuff.count := Length(Command)
    ELSE BEGIN
	FOR i := 1 TO Length(Command) DO
	    Command[i] := UpCase(Command[i]);
    END;
END;

PROCEDURE PutRecord;
BEGIN
    IF OutBufCount = MaxOutBufCount THEN BEGIN
	BlockWrite(OutFile, OutFileBuf, OutBufCount);
	OutBufCount := 0;
    END;
    
    INC(OutBufCount);
    OutFileBuf[OutBufCount] := OutData;
END;

VAR
    tempStr : STRING;
BEGIN
    IF ParamCount() <> 1 THEN BEGIN
	WriteLn('Usage: Scr2Log name[.SCR]');
	WriteLn('will output to same name with .LOG extension');
	HALT(1);
    END;
    
    ReadMacros;
    
    OutData.WasMouse := FALSE;
    
    ConstructFileName(ParamStr(1), '.SCR', InFileName);
    ConstructFileName('.LOG', InFileName, OutFileName);
    
    Assign(InFile, InFileName);
    Reset(InFile);
    IF IOResult() <> 0 THEN BEGIN
	WriteLn('File not found: ', InFileName);
	HALT(1);
    END;
    SetTextBuf(InFile, InFileBuf, SizeOf(InFileBuf));
    EndOfFile := FALSE;
    
    Assign(OutFile, OutFileName);
    ReWrite(OutFile, SizeOf(LogRec));
    IF IOResult() <> 0 THEN BEGIN
	WriteLn('Error creating: ', OutFileName);
	HALT(1);
    END;
    OutBufCount := 0;
    
    Stuff.cursor := 1;
    Stuff.len := 0;
    Stuff.curLine := 0;
    Stuff.next := NIL;
    REPEAT
	GetCommand;
	
	IF MacroDefinition THEN
	    AddMacro(Stuff.data, Stuff.curLine)
	ELSE IF Command <> '' THEN BEGIN
	    (* quotes are always basic commands *)
	    
	    IF Stuff.isQuote THEN BEGIN
		FOR i := 1 TO Stuff.count DO BEGIN
		    OutData.key := ORD(Command[i]);
		    PutRecord;
		END;
	    END ELSE IF Stuff.isRepeat THEN BEGIN
		tempStr := Command;
		FOR i := 2 TO Stuff.count DO
		    tempStr := tempStr + ',' + Command;
		PushStuff(tempStr);
	    END ELSE BEGIN
		
		(* check for basic command *)
		
		i := 0;
		REPEAT
		    INC(i);
		UNTIL (i > MaxBuiltIns) OR (Command = BuiltIns[i].name);
		
		IF i > MaxBuiltIns THEN BEGIN
		    
		    (* nope, maybe it is a macro *)
		    
		    Mac := FirstMacro;
		    WHILE (Mac <> NIL) AND (Mac^.name <> Command) DO BEGIN
			Mac := Mac^.next;
		    END;
		    
		    IF Mac <> NIL THEN BEGIN
			PushStuff(Mac^.data);
		    END ELSE BEGIN
			WriteLn('Error: Unknown command');
			WriteLn(Stuff.data);
			FOR i := 2 TO Stuff.start DO
			    Write(' ');
			WriteLn('^');
		    END;
		END ELSE BEGIN
		    OutData.key := BuiltIns[i].key;
		    PutRecord;
		END;
	    END;
	END;
    UNTIL EndOfFile;
    
    Close(InFile);

    IF OutBufCount <> 0 THEN
	BlockWrite(OutFile, OutFileBuf, OutBufCount);

    Close(OutFile);
END.
