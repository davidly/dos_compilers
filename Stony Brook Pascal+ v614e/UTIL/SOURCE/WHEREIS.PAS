PROGRAM whereis;
{$M 4096, 2048, 8192}
{$V-}

USES Dos, Crt;

TYPE
    String12	= STRING[12];
VAR
    Command	: String[32];
    
    Entry	: SearchRec;

    Drive	: STRING[2];
    Drives	: WORD;
    CurDrive	: WORD;
    
    i		: WORD;

PROCEDURE PrepareName(VAR theName : String12);
VAR
    name	: STRING[8];
    ext		: STRING[4];
    i		: WORD;
    j		: WORD;
    k		: WORD;
BEGIN
    ext := '.???';
    name := '????????';
    
    k := Length(theName);

    i := 1;
    WHILE (i <= k) AND (theName[i] <> '.') AND (theName[i] <> '*') DO BEGIN
	IF i <= SizeOf(name)-1 THEN
	    name[i] := UpCase(theName[i]);
	INC(i);
    END;
    
    IF i <= k THEN BEGIN
	j := SizeOf(name);

	IF theName[i] = '*' THEN
	    INC(i)
	ELSE IF theName[i] = '.' THEN
	    j := i;

	INC(i);
    END ELSE
	j := i;

    WHILE j <= SizeOf(name)-1 DO BEGIN
	name[j] := #1;
	INC(j);
    END;

    j := 2;
    WHILE (i <= k) AND (theName[i] <> '*') DO BEGIN
	IF j <= SizeOf(ext)-1 THEN BEGIN
	    ext[j] := UpCase(theName[i]);
	    INC(j);
	END;
	INC(i);
    END;
    
    IF (i > k) OR ((i <= k) AND (theName[i] <> '*')) THEN BEGIN
	WHILE j <= SizeOf(ext)-1 DO BEGIN
	    ext[j] := #1;
	    INC(j);
	END;
    END;
    
    theName := name + ext;
END;

FUNCTION Match() : BOOLEAN;
VAR
    foundOne	: BOOLEAN;
    i		: WORD;
BEGIN
    i := 1;
    foundOne := TRUE;
    REPEAT
	IF (Entry.name[i] <> '?') AND (Command[i] <> '?') THEN BEGIN
	    IF Entry.name[i] <> Command[i] THEN
		foundOne := FALSE;
	END;
	INC(i);
    UNTIL (NOT foundOne) OR (i > 12);
    Match := foundOne;
END;

FUNCTION SearchDirectory(searchDir : STRING) : BOOLEAN;
TYPE
    DirPointer = ^DirRec;
    DirRec =
	RECORD
	    next : DirPointer;
	    name : STRING[12];
	END;
VAR
    abort	: BOOLEAN;
    valid	: BOOLEAN;
    ch		: CHAR;
    firstDir	: DirPointer;
    lastDir	: DirPointer;
    dir		: DirPointer;
    workingPath : PathStr;
BEGIN
    firstDir := NIL;
    workingPath := searchDir + '\*.*';
    abort := FALSE;
    FindFirst(workingPath, AnyFile, Entry);
    REPEAT
	IF Entry.Name[1] <> '.' THEN BEGIN
	    IF (Directory AND Entry.attr) <> 0 THEN BEGIN
		NEW(dir);
		dir^.next := NIL;
		dir^.name := Entry.Name;
		IF firstDir = NIL THEN
		    firstDir := dir
		ELSE BEGIN
		    lastDir^.next := dir;
		END;
		lastDir := dir;
	    END;

	    workingPath := Entry.Name;
	    PrepareName(Entry.Name);
	    IF Match() THEN BEGIN
		Write(searchDir, '\', workingPath, '  -> More (Y/N)');
		REPEAT
		    valid := TRUE;
		    ch := UpCase(ReadKey());
		    IF ch = 'N' THEN
			abort := TRUE
		    ELSE IF ch <> 'Y' THEN BEGIN
			valid := FALSE;
			Write(#7);
		    END;
		UNTIL valid;
		WriteLn;
	    END;
	END;
	FindNext(Entry);
    UNTIL (DosError <> 0) OR abort;
    
    dir := firstDir;
    WHILE (NOT abort) AND (dir <> NIL) DO BEGIN
	workingPath := searchDir;
	INC(workingPath[0]);
	workingPath[ORD(workingPath[0])] := '\';
	workingPath := workingPath + dir^.name;

	IF NOT SearchDirectory(workingPath) THEN
	    abort := TRUE;
	dir := dir^.next;
    END;

    WHILE firstDir <> NIL DO BEGIN
	dir := firstDir^.next;
	DISPOSE(firstDir);
	firstDir := dir;
    END;

    SearchDirectory := NOT abort;
END;

FUNCTION GetCurrentDrive() : WORD;
VAR
    r : REGISTERS;
BEGIN
    r.AH := $19;
    MSDOS(r);
    GetCurrentDrive := ORD(r.AL);
END;

PROCEDURE GetMaxDrives;
VAR
    r : REGISTERS;
BEGIN
    IF Drive[1] <> '?' THEN BEGIN
	CurDrive := ORD(Drive[1]) - ORD('A');
	Drives := CurDrive;
    END ELSE BEGIN
	CurDrive := 2;
	r.AH := $0E;
	r.DL := GetCurrentDrive();
	MSDOS(r);
	Drives := ORD(r.AL)-1
    END;
END;

BEGIN
    WriteLn;
    
    IF ParamCount() <> 1 THEN BEGIN
	WriteLn('USAGE: whereis [d:]fileSpec');
	WriteLn('       assumes .* if not supplied');
	WriteLn('?: is a special case where ALL drives >= c: are searched');
	HALT;
    END;

    Command := ParamStr(1);
    i := 1;
    WHILE (i <= Length(Command)) AND (Command[i] <> '.') DO
	INC(i);
    
    IF i > Length(Command) THEN
	Command := Command + '.*';
    
    BYTE(Drive[0]) := 2;
    Drive[2] := ':';

    IF Command[2] = ':' THEN BEGIN
	Drive[1] := UpCase(Command[1]);
	Delete(Command, 1, 2);
    END ELSE BEGIN
	Drive[1] := CHAR(GetCurrentDrive() + ORD('A'));
    END;
    GetMaxDrives;

    PrepareName(Command);

    WHILE CurDrive <= Drives DO BEGIN
	Drive[1] := CHAR(CurDrive + ORD('A'));
	IF NOT SearchDirectory(Drive) THEN
	    CurDrive := Drives;
	INC(CurDrive);
    END;
END.
