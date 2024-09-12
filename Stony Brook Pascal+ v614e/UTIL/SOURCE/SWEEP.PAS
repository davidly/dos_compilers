PROGRAM sweep;
{$M 4096, 2048, 8192}
{$X+}

USES Dos;

VAR
    Entry	: SearchRec;
    Command	: STRING[127];
    Dir		: DirStr;
    OrigDir	: DirStr;
    
    Shell	: PathStr;
    
    temp	: STRING[127];

PROCEDURE DoCommand(dir : STRING);
BEGIN
    WriteLn('  Executing (', Command, ') in >> ', dir);
    ChDir(dir);
    IF IOResult() = 0 THEN BEGIN
	temp := '/C ' + Command;
	Exec(Shell, temp);
	IF (DosError <> 0) OR (DosExitCode() <> 0) THEN BEGIN
	    WriteLn('...failed exec... ', DosError, ' ', DosExitCode);
	    WriteLn(Shell, ' ', temp);
	    HALT;
	END;
    END ELSE BEGIN
	WriteLn('...failed change dir...');
	HALT;
    END;
END;

PROCEDURE Action(curDir : STRING);
VAR
    temp : STRING[80];
BEGIN
    temp := curDir;
    INC(temp[0]);
    temp[ORD(temp[0])] := '\';
    temp := temp + Entry.Name;
    DoCommand(temp);
END;

PROCEDURE SearchDirectories(startPath : STRING);
TYPE
    DirPointer = ^DirRec;
    DirRec =
	RECORD
	    next : DirPointer;
	    name : STRING[12];
	END;
VAR
    firstDir	: DirPointer;
    lastDir	: DirPointer;
    dir		: DirPointer;
    workingPath : PathStr;
BEGIN
    firstDir := NIL;
    workingPath := startPath + '\*.*';
    FindFirst(workingPath, Directory, Entry);
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
	    Action(startPath);
	END;
	FindNext(Entry);
    UNTIL DosError <> 0;
    
    dir := firstDir;
    WHILE dir <> NIL DO BEGIN
	workingPath := startPath;
	INC(workingPath[0]);
	workingPath[ORD(workingPath[0])] := '\';
	workingPath := workingPath + dir^.name;
	SearchDirectories(workingPath);
	dir := dir^.next;
    END;

    WHILE firstDir <> NIL DO BEGIN
	dir := firstDir^.next;
	DISPOSE(firstDir);
	firstDir := dir;
    END;
END;

VAR
    i : WORD;
BEGIN
    IF ParamCount() = 0 THEN BEGIN
	WriteLn('USAGE: sweep anyCommandOrProgram');
	HALT;
    END;

    Shell := GetEnv('COMSPEC');
    IF Shell = '' THEN
	Shell := 'COMMAND.COM';
    
    Command := '';
    FOR i := 1 TO ParamCount() DO BEGIN
	INC(Command[0]);
	Command[ORD(Command[0])] := ' ';
	Command := Command + ParamStr(i);
    END;
    
    GetDir(0, Dir);
    OrigDir := Dir;
    
    DoCommand(Dir);
    
    IF Length(Dir) = 3 THEN
	DEC(Dir[0]);

    SearchDirectories(Dir);
    ChDir(OrigDir);
END.
