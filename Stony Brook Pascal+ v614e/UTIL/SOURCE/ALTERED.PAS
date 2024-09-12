PROGRAM altered;
{$M 4096, 0, 0}

USES Dos;

CONST
    TabPos	= 32;

CONST
    MaxCommands	= 4;
    Afternoon	: ARRAY [BOOLEAN] OF STRING[2] = ('am', 'pm');
    CommandSize	= 32;
VAR
    Commands	: ARRAY [1..MaxCommands] OF STRING[CommandSize];
    MaxCommand	: WORD;
    
    WorkString	: PathStr;
    
    Test	: LONGINT;
    DT		: DateTime;

    Dummy	: WORD;
    
    Entry	: SearchRec;

    i		: WORD;
    j		: WORD;
    pm		: BOOLEAN;

PROCEDURE ParseCommandLine;

VAR
    i		: WORD;
    j		: WORD;
    l		: WORD;
    k		: WORD;
    num		: WORD;
    start	: WORD;
    code	: INTEGER;
    cLine	: STRING[64];

    PROCEDURE WriteSyntax;
    BEGIN
	WriteLn('USAGE: altered [/Ddate][/Ttime] {pathSpec(s)}');
	WriteLn('where date is [month/]day[/year]');
	WriteLn('where time is hour');
	WriteLn('date time defaults to current day 4:00am');
	HALT;
    END;
    
    PROCEDURE GetVal;
    VAR
	j	: WORD;
	data	: STRING[5];
    BEGIN
	j := 1;
	WHILE (i <= l) AND (cLine[i] >= '0') AND (cLine[i] <= '9') DO BEGIN
	    data[j] := cLine[i];
	    INC(j);
	    INC(i);
	END;
	BYTE(data[0]) := j-1;
	Val(data, num, code);
	IF code <> 0 THEN BEGIN
	    WriteLn('Bad date number');
	    HALT;
	END;
    END;
    
    PROCEDURE ProcessQual;
    BEGIN
	IF UpCase(cLine[i]) = 'D' THEN BEGIN
	    INC(i);
	    GetVal;
	    IF (i <= l) AND (cLine[i] = '/') THEN BEGIN
		INC(i);
		DT.month := num;
		GetVal;
		DT.day := num;
		IF (i <= l) AND (cLine[i] = '/') THEN BEGIN
		    INC(i);
		    GetVal;
		    DT.year := num;
		    IF DT.year >= 1980 THEN
			DT.year := DT.year - 1980
		    ELSE BEGIN
			DT.year := DT.year - 80;
		    END;
		END;
	    END ELSE BEGIN
		DT.day := num;
	    END;
	END ELSE IF UpCase(cLine[i]) = 'T' THEN BEGIN
	    INC(i);
	    GetVal;
	    DT.hour := num;
	    IF (i <= l) AND (UpCase(cLine[i]) = 'P') THEN BEGIN
		INC(i);
		DT.hour := DT.hour + 12;
		IF (i <= l) AND (UpCase(cLine[i]) = 'M') THEN
		    INC(i);
	    END;
	END ELSE BEGIN
	    WriteLn('unknown qualifier');
	    WriteSyntax;
	END;
    END;
    
    PROCEDURE CopyCommand;
    VAR
	j : WORD;
    BEGIN
	INC(k);
	j := 1;
	REPEAT
	    Commands[k][j] := cLine[i];
	    INC(i);
	    INC(j);
	UNTIL (i > l) OR
	      (j > CommandSize) OR
	      (cLine[i] = '/');

	BYTE(Commands[k][0]) := BYTE(j-1);
    END;
    
BEGIN
    k := 0;
    FOR j := 1 TO ParamCount() DO BEGIN
	cLine := ParamStr(j);
	l := Length(cLine);
	i := 1;
	REPEAT
	    IF cLine[i] = '?' THEN
		WriteSyntax
	    ELSE IF cLine[i] = '/' THEN BEGIN
		INC(i);
		IF cLine[i] = '?' THEN
		    WriteSyntax;
		ProcessQual;
	    END ELSE BEGIN
		CopyCommand;
	    END;
	UNTIL i > l;
    END;
    
    IF k = 0 THEN
	WriteSyntax
    ELSE BEGIN
	MaxCommand := k;
    END;
END;

FUNCTION DirExists(name : STRING) : BOOLEAN;
VAR
    R		: REGISTERS;
    lstr	: STRING[80];
BEGIN
    lstr := name;
    lstr[Length(lstr)+1] := #0;
    R.AX := $4300;
    R.DS := Seg(lstr[1]);
    R.DX := Ofs(lstr[1]);
    MSDOS(R);
    IF (R.FLAGS AND FCarry) <> 0 THEN
	DirExists := FALSE
    ELSE BEGIN
	DirExists := (Directory AND R.CX) <> 0;
    END;
END;

FUNCTION Ignore() : BOOLEAN;
TYPE
    extName = STRING[4];
CONST
    list : ARRAY [0..6] OF extName =
	('.BAK', '.LST', '.INT', '.TPU', '.LIB', '.OBJ', '.EXE');
VAR
    i	: WORD;
    dir	: DirStr;
    name: NameStr;
    ext	: ExtStr;
BEGIN
    Ignore := FALSE;
    FOR i := 0 TO 6 DO BEGIN
	FSplit(Entry.Name, dir, name, ext);
	IF ext = list[i] THEN
	    Ignore := TRUE;
    END;
END;

PROCEDURE ConstructFileName(primary, default : STRING; VAR result : PathStr);
VAR
    dir1	: DirStr;
    dir2	: DirStr;
    name1	: NameStr;
    name2	: NameStr;
    ext1	: ExtStr;
    ext2	: ExtStr;
BEGIN
    FSplit(primary, dir1, name1, ext1);
    FSplit(default, dir2, name2, ext2);
    
    IF dir1 = '' THEN
	dir1 := dir2;
    IF name1 = '' THEN
	name1 := name2;
    IF ext1 = '' THEN
	ext1 := ext2;
    result := dir1 + name1 + ext1;
END;

BEGIN
    GetDate(DT.year, DT.month, DT.day, Dummy);
    DT.hour := 4;
    DT.min := 0;
    DT.sec := 0;

    ParseCommandLine;

    PackTime(dt, Test);

    FOR i := 1 TO MaxCommand DO BEGIN

	WorkString := Commands[i];
	IF DirExists(Commands[i]) THEN
	    WorkString := WorkString + '\*.*';
	
	FindFirst(WorkString, Archive, Entry);
	IF DosError = 0 THEN BEGIN
	    REPEAT
		IF (NOT Ignore()) AND (Entry.time >= Test) THEN BEGIN
		    ConstructFileName(Entry.Name, Commands[i], WorkString);

		    Write(WorkString);
		    FOR j := Length(WorkString) TO TabPos DO BEGIN
			Write('.');
		    END;
		    
		    UnpackTime(Entry.time, dt);
		    
		    pm := FALSE;
		    IF DT.hour > 12 THEN BEGIN
			DT.hour := DT.hour - 12;
			pm := TRUE;
		    END;

		    Write(DT.hour:2, ':');
		    Write(DT.min DIV 10, DT.min MOD 10);
		    Write(Afternoon[pm]);
		    Write('  ', DT.month:2, '/');
		    Write(DT.day DIV 10, DT.day MOD 10);
		    WriteLn('/', DT.year);
		END;
		FindNext(Entry);
	    UNTIL DosError <> 0;
	END;
    END;
END.
