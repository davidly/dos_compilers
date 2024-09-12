PROGRAM sbdump;
{$M 4096, 16384, 655000}
{$I-}

(* possible speed improvement, only when redirected of course *)
(* get rid of Text I/O, use a File type and handle the buffer ourselves *)

USES Dos, Put, Disk, DumpOMF, DumpExe, DumpIntSym, DumpCV, LibStats;

TYPE
    FileTypes	= (
                   What{?},
		   ObjectFile,
		   ObjectLibrary,
		   PascalInt,
		   M2Sym,
		   ExeFile,
		   CodeView,
		   HexDump
		  );

CONST
    DefaultExt	: ARRAY [FileTypes] OF STRING[3] =
	    (
	     (#255#255#255),
	     ('OBJ'),
	     ('LIB'),
	     ('INT'),
	     ('SYM'),
	     ('EXE'),
	     ('EXE'),
	     (#255#255#255)
	    );
VAR    
    FileType	: FileTypes;
    StartAddress: LONGINT;
    
    DoLibStats	: BOOLEAN;

PROCEDURE SetConsole;
VAR
    R : REGISTERS;
    BiosLines : BYTE ABSOLUTE $40:$84;
BEGIN
    IsConsole := FALSE;
    R.AX := $4400;
    R.BX := 1;
    INTR($21, R);
    IF (129 AND R.DX) = 129 THEN (* bit [0,7] *)
	IsConsole := TRUE;

    ScreenLines := BiosLines;
    
    (* big buffer helps when we are redirected *)
    
    SetTextBuf(OutPut, OutBuf, SizeOf(OutBuf));
END;

PROCEDURE ParseCommandLine;
VAR
    i		: WORD;
    j		: WORD;
    l		: WORD;
    k		: WORD;
    ch		: CHAR;
    ext		: STRING[3];
    f		: FileTypes;
    cmd		: STRING[64];
    value	: STRING[20];

    PROCEDURE Usage;
    CONST
	Syntax : ARRAY [1..21] OF STRING[60] =
	    (
	     'Usage: sbdump FileSpec [ModuleWanted]',
	     'formatted dumps available for OBJ, LIB, INT, SYM and EXE files',
	     'hex dumps are done for unknown file types',
	     'ModuleWanted will limit a CodeView dump to that module',
	     'Switches can be anywhere on the commandline',
	     '/P pauses per screenfull',
	     '/H performs, or forces, a hex dump',
	     '/E forces a EXE dump',
	     '/L forces a Library OMF dump',
	     '/LS dumps various statistics of a LIB file',
	     '/O forces an OMF dump',
	     '/V verbose gives more detail on some dumps',
	     '/T terse gives a list of OBJ files in a LIB file',
	     '/CV[:[T][S][P][D]] forces a CodeView dump',
	     '    T will give Type information only',
	     '    S will give symbolic information only',
	     '    P will give Public symbol information only',
	     '    D will dive the Debug directory only',
	     '    L will give line number information only',
	     '/A:address. address is a hex or decimal number',
	     '   address is the starting file address to dump'
	    );
    VAR
	i : WORD;
    BEGIN
	FOR i := 1 TO 21 DO
	    WriteLn(Syntax[i]);
	HALT;
    END;
    
    PROCEDURE GetSwitchVal;
    VAR
	i : WORD;
	k : WORD;
    BEGIN
	BYTE(value[0]) := 0;
	IF (j < l) AND (cmd[j] = ':') THEN BEGIN
	    i := j+1;
	    k := 1;
	    WHILE (i <= l) AND (cmd[i] <> '/') DO BEGIN
		value[k] := cmd[i];
		INC(k);
		INC(i);
	    END;
	    IF (i <= l) AND (cmd[i] = '/') THEN
		DEC(i);
	    j := i;
	    BYTE(value[0]) := k-1;
	END;
    END;
    
    PROCEDURE GetHexVal;
    VAR
	valStart	: WORD;
	valEnd		: WORD;
	i		: WORD;
	num		: LONGINT;
    BEGIN
	valStart := 1;
	valEnd := Length(value);
	IF value[1] = '$' THEN
	    INC(valStart)
	ELSE
	    DEC(valEnd);
	
	num := 0;
	FOR i := valStart TO valEnd DO BEGIN
	    num := num * 16;
	    ch := UpCase(value[i]);
	    IF (ch >= '0') AND (ch <= '9') THEN
		num := num + (ORD(ch) - ORD('0'))
	    ELSE IF (ch >= 'A') AND (ch <= 'F') THEN
		num := num + (ORD(ch) - (ORD('A') - 10))
	    ELSE BEGIN
		WriteLn('Bad hex number');
		EXIT;
	    END;
	END;
	StartAddress := num;
    END;
    
    PROCEDURE GetStartAddress;
    VAR
	code : INTEGER;
    BEGIN
	IF (value[1] = '$') OR (UpCase(value[Length(value)]) = 'H') THEN
	    GetHexVal
	ELSE BEGIN
	    Val(value, StartAddress, code);
	    IF code <> 0 THEN BEGIN
		StartAddress := 0;
		WriteLn('Bad start address: ', code);
	    END;
	END;
    END;
    
BEGIN
    IF ParamCount() = 0 THEN
	Usage;
    
    DoLibStats := FALSE;
    StartAddress := 0;
    FileType := What{?};
    InFileName := '';
    
    FOR i := 1 TO ParamCount() DO BEGIN
	cmd := ParamStr(i);
	IF cmd[1] = '/' THEN BEGIN
	    j := 1;
	    l := Length(cmd);
	    WHILE (j <= l) AND (cmd[j] = '/') DO BEGIN
		INC(j);
		ch := UpCase(cmd[j]);
		IF ch = 'H' THEN
		    FileType := HexDump
		ELSE IF ch = 'E' THEN
		    FileType := ExeFile
		ELSE IF ch = 'O' THEN
		    FileType := ObjectFile
		ELSE IF ch = 'L' THEN BEGIN
		    FileType := ObjectLibrary;
		    IF (j+1 <= l) AND (UpCase(cmd[j+1]) = 'S') THEN BEGIN
			DoLibStats := TRUE;
			INC(j);
		    END;
		END ELSE IF ch = 'P' THEN
		    Pause := TRUE
		ELSE IF ch = 'V' THEN
		    Detail := TRUE
		ELSE IF ch = 'T' THEN
		    Terse := TRUE
		ELSE IF ch = 'A' THEN BEGIN
		    INC(j);
		    GetSwitchVal;
		    IF Length(value) = 0 THEN
			Usage;
		    GetStartAddress;
		END ELSE IF (j+1 <= l) AND
		        (ch = 'C') AND
			(UpCase(cmd[j+1]) = 'V')
		THEN BEGIN
		    FileType := CodeView;
		    j := j + 2;
		    GetSwitchVal;
		    IF Length(value) = 0 THEN BEGIN
			DumpTypes := TRUE;
			DumpSymbols := TRUE;
			DumpPublics := TRUE;
			DumpLines := TRUE;
		    END ELSE BEGIN
			k := 1;
			WHILE k <= Length(value) DO BEGIN
			    ch := UpCase(value[k]);
			    IF ch = 'T' THEN
				DumpTypes := TRUE
			    ELSE IF ch = 'S' THEN
				DumpSymbols := TRUE
			    ELSE IF ch = 'D' THEN
				DumpDirectory := TRUE
			    ELSE IF ch = 'P' THEN
				DumpPublics := TRUE
			    ELSE IF ch = 'L' THEN
				DumpLines := TRUE
			    ELSE BEGIN
				Usage;
			    END;
			    INC(k);
			END;
		    END;
		    IF (j <= l) AND (cmd[j] = '/') THEN
			DEC(j);
		END ELSE BEGIN
		    Usage;
		END;
		INC(j);
	    END;
	END ELSE IF (cmd[1] <> '?') AND (InFileName = '') THEN
	    InFileName := cmd
	ELSE IF (cmd[1] <> '?') AND (ModuleWanted = '') THEN
	    ModuleWanted := cmd
	ELSE BEGIN
	    Usage
	END;
    END;
    
    IF InFileName = '' THEN
	Usage;
    
    IF FileType = What{?} THEN BEGIN
	j := Length(InFileName);
	l := j;
	WHILE (j >= 1) AND (InFileName[j] <> '.') DO
	    DEC(j);
	ext := '';

	IF j+3 = l THEN BEGIN
	    INC(j);
	    FOR k := 1 TO 3 DO BEGIN
		ext[k] := UpCase(InFileName[j]);
		INC(j);
	    END;
	    BYTE(ext[0]) := 3;
	END;

	WHILE (FileType <> HexDump) AND (DefaultExt[FileType] <> ext) DO
	    INC(FileType);
    END;
    
    FOR i := 1 TO Length(ModuleWanted) DO
	ModuleWanted[i] := UpCase(ModuleWanted[i]);
END;

PROCEDURE FormattedHex;
VAR
    ch		: CHAR;
    i		: WORD;
    line	: ARRAY [1..16] OF BYTE;
BEGIN
    REPEAT
	PutLongHex(DiskAddr);
	PutString(':  ');

	Nibble(line, SizeOf(line));

	FOR i := 1 TO Count DO BEGIN
	    PutChar(' ');
	    PutHex(line[i], 2);
	    
	    IF i = 8 THEN
		PutChar(' ');
	END;
	
	TabTo(62);
	
	FOR i := 1 TO Count DO BEGIN
	    ch := CHAR(line[i]);
	    IF NOT (ch IN Printable) THEN
		ch := '.';
	    PutChar(ch);
	END;
	
	Flush;
    UNTIL EndOfFile;
END;

BEGIN
    ParseCommandLine;
    
    Assign(InFile, InFileName);
    Reset(InFile, 1);
    IF IOResult() <> 0 THEN BEGIN
	WriteLn('Error: could not open file, ', InFileName);
	HALT;
    END;
    
    SetConsole;
    
    Position(StartAddress);

    IF FileType = HexDump THEN
	FormattedHex
    ELSE IF FileType = ObjectFile THEN
	FormattedOBJ
    ELSE IF FileType = ObjectLibrary THEN BEGIN
	IF DoLibStats THEN
	    DumpLibStats
	ELSE
	    FormattedLIB;
    END ELSE IF FileType = ExeFile THEN
	FormattedEXE
    ELSE IF (FileType = PascalInt) OR (FileType = M2Sym) THEN
	FormattedIntSym
    ELSE IF FileType = CodeView THEN
	FormattedCV;
    
    Close(InFile);
END.
