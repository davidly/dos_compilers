PROGRAM killdir;
{$M 4096, 2048, 8192}
{$X+}

USES Dos, Crt;

VAR
    Command	: STRING[12];
    Entry	: SearchRec;
    DeleteAll	: BOOLEAN;

    ZapEm	: BOOLEAN;
    ZapBuffer	: ARRAY [0..2047] OF BYTE;

PROCEDURE Zap(name : STRING);
VAR
    f		: File;
    size	: WORD;
    remain	: LONGINT;
BEGIN
    Assign(f, name);
    Reset(f, 1);
    IF IOResult() = 0 THEN BEGIN
	remain := FileSize(f);

	WHILE remain <> 0 DO BEGIN
	    size := remain;
	    IF remain > SizeOf(ZapBuffer) THEN
		size := SizeOf(ZapBuffer);
	    BlockWrite(f, ZapBuffer, size);
	    remain := remain - size;
	END;

	Close(f);
    END;
END;

FUNCTION ClearAttributes(name : STRING) : BOOLEAN;
VAR
    r		: REGISTERS;
    lstr	: STRING[80];
BEGIN
    lstr := name;
    lstr[Length(lstr)+1] := #0;
    r.AH := $43;
    r.AL := 1;
    r.DS := Seg(lstr[1]);
    r.DX := Ofs(lstr[1]);
    r.CX := 0;
    MSDOS(r);
    ClearAttributes := (r.FLAGS AND FCarry) = 0; 
END;

FUNCTION DeleteFile(name : STRING) : BOOLEAN;
VAR
    r		: REGISTERS;
    lstr	: STRING[80];
BEGIN
    lstr := name;
    lstr[Length(lstr)+1] := #0;
    r.AH := $41;
    r.DS := Seg(lstr[1]);
    r.DX := Ofs(lstr[1]);
    MSDOS(r);
    DeleteFile := (r.FLAGS AND FCarry) = 0; 
END;

FUNCTION RemoveDir(name : STRING) : BOOLEAN;
VAR
    r		: REGISTERS;
    lstr	: STRING[80];
BEGIN
    lstr := name;
    lstr[Length(lstr)+1] := #0;
    r.AH := $3A;
    r.DS := Seg(lstr[1]);
    r.DX := Ofs(lstr[1]);
    MSDOS(r);
    RemoveDir := (r.FLAGS AND FCarry) = 0; 
END;

FUNCTION DoIt(curDir : STRING) : BOOLEAN;
TYPE
    DirPointer = ^DirRec;
    DirRec =
	RECORD
	    next : DirPointer;
	    name : STRING[12];
	END;
VAR
    abort	: BOOLEAN;
    firstDir	: DirPointer;
    lastDir	: DirPointer;
    dir		: DirPointer;
    workingPath : PathStr;
BEGIN
    abort := FALSE;
    firstDir := NIL;

    workingPath := curDir + '\*.*';
    FindFirst(workingPath, Directory, Entry);
    IF DosError = 0 THEN BEGIN
	REPEAT
	    IF (Entry.name[1] <> '.') AND ((Directory AND Entry.attr) <> 0)
	    THEN BEGIN
		NEW(dir);
		dir^.next := NIL;
		dir^.name := Entry.name;
		IF firstDir = NIL THEN
		    firstDir := dir
		ELSE BEGIN
		    lastDir^.next := dir;
		END;
		lastDir := dir;
	    END;
	    FindNext(Entry);
	UNTIL DosError <> 0;
    END;
    
    dir := firstDir;
    WHILE (NOT abort) AND (dir <> NIL) DO BEGIN
	workingPath := curDir;
	INC(workingPath[0]);
	workingPath[ORD(workingPath[0])] := '\';
	workingPath := workingPath + dir^.name;

	abort := DoIt(workingPath);
	dir := dir^.next;
    END;

    WriteLn('Removing >> ', curDir);

    workingPath := curDir + '\*.*';
    FindFirst(workingPath, AnyFile XOR Directory, Entry);
    IF (NOT abort) AND (DosError = 0) THEN BEGIN
	REPEAT
	    workingPath := curDir;
	    INC(workingPath[0]);
	    workingPath[ORD(workingPath[0])] := '\';
	    workingPath := workingPath + Entry.Name;

	    IF DeleteAll THEN
		ClearAttributes(workingPath);
	    
	    IF ZapEm THEN
		Zap(workingPath);
		
	    IF NOT DeleteFile(workingPath) THEN BEGIN
		WriteLn('...could not remove file ', workingPath);
		abort := TRUE;
	    END;

	    FindNext(Entry);
	UNTIL (DosError <> 0) OR abort;
    END;

    IF (NOT abort) AND (NOT RemoveDir(curDir)) THEN BEGIN
	WriteLn('...could not remove dir ', curDir);
	abort := TRUE;
    END;

    WHILE firstDir <> NIL DO BEGIN
	dir := firstDir^.next;
	DISPOSE(firstDir);
	firstDir := dir;
    END;

    DoIt := abort;
END;

PROCEDURE ParseCommandLine;
    PROCEDURE WriteSyntax;
    BEGIN
	WriteLn('USAGE: killdir [/A][/Z] DirName');
	WriteLn('/A will delete files with ReadOnly, Hidden etc. attributes');
	WriteLn('/Z will "zap" the file with zeros before deleting the file');
	HALT;
    END;

VAR
    i		: WORD;
    j		: WORD;
    c		: WORD;
    cLine	: STRING[79];
BEGIN
    c := ParamCount();
    IF c = 0 THEN
	WriteSyntax;

    Command := '';
    DeleteAll := FALSE;
    ZapEm := FALSE;
    
    FOR j := 1 TO c DO BEGIN
	cLine := ParamStr(j);
	IF cLine[1] = '/' THEN BEGIN
	    i := 1;
	    WHILE (i <= Length(cLine)) AND (cLine[i] = '/') DO BEGIN
		INC(i);
		IF UpCase(cLine[i]) = 'A' THEN
		    DeleteAll := TRUE
		ELSE IF UpCase(cLine[i]) = 'Z' THEN
		    ZapEm := TRUE
		ELSE BEGIN
		    WriteLn('...unknown qualifier...');
		    WriteSyntax;
		END;
		INC(i);
	    END;
	END ELSE IF Command = '' THEN
	    Command := cLine
	ELSE BEGIN
	    WriteSyntax;
	END;
    END;
    
    FOR i := 0 TO SizeOf(ZapBuffer)-1 DO
	ZapBuffer[i] := 0;
END;

VAR
    ch		: CHAR;
    valid	: BOOLEAN;
BEGIN
    ParseCommandLine;
    
    Write(#7, 'Are you sure you want to delete ', Command, ' (Y/N)');
    REPEAT
	valid := TRUE;
	ch := UpCase(ReadKey());
	IF (ch <> 'Y') AND (ch <> 'N') THEN
	    valid := FALSE;
    UNTIL valid;
    WriteLn;
    
    IF ch = 'Y' THEN
	DoIt(Command);
END.
