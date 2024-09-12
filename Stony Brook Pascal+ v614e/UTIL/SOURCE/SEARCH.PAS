PROGRAM search;
{$M 4096, 0, 0}
(*$//INLINE:N*)

USES Dos;

CONST CapTable : ARRAY [#0..#255] OF CHAR =
    (
	#0, #1, #2, #3, #4, #5, #6, #7,
	#8, #9, #10, #11, #12, #13, #14, #15,
	#16, #17, #18, #19, #20, #21, #22, #23,
	#24, #25, #26, #27, #28, #29, #30, #31,
	#32, #33, #34, #35, #36, #37, #38, #39,
	#40, #41, #42, #43, #44, #45, #46, #47,
	#48, #49, #50, #51, #52, #53, #54, #55,
	#56, #57, #58, #59, #60, #61, #62, #63,
	#64, #65, #66, #67, #68, #69, #70, #71,
	#72, #73, #74, #75, #76, #77, #78, #79,
	#80, #81, #82, #83, #84, #85, #86, #87,
	#88, #89, #90, #91, #92, #93, #94, #95,
	#96, #65, #66, #67, #68, #69, #70, #71,
	#72, #73, #74, #75, #76, #77, #78, #79,
	#80, #81, #82, #83, #84, #85, #86, #87,
	#88, #89, #90, #123, #124, #125, #126, #127,
	#128, #129, #130, #131, #132, #133, #134, #135,
	#136, #137, #138, #139, #140, #141, #142, #143,
	#144, #145, #146, #147, #148, #149, #150, #151,
	#152, #153, #154, #155, #156, #157, #158, #159,
	#160, #161, #162, #163, #164, #165, #166, #167,
	#168, #169, #170, #171, #172, #173, #174, #175,
	#176, #177, #178, #179, #180, #181, #182, #183,
	#184, #185, #186, #187, #188, #189, #190, #191,
	#192, #193, #194, #195, #196, #197, #198, #199,
	#200, #201, #202, #203, #204, #205, #206, #207,
	#208, #209, #210, #211, #212, #213, #214, #215,
	#216, #217, #218, #219, #220, #221, #222, #223,
	#224, #225, #226, #227, #228, #229, #230, #231,
	#232, #233, #234, #235, #236, #237, #238, #239,
	#240, #241, #242, #243, #244, #245, #246, #247,
	#248, #249, #250, #251, #252, #253, #254, #255
    );

VAR
    Commands	: ARRAY [1..4] OF STRING[32];
    MaxCommand	: WORD;

    MatchData	: ARRAY [0..32] OF CHAR;
    MatchAlias	: WORD ABSOLUTE MatchData;
    LastChar	: CHAR;
    MatchString	: STRING[32];
    MatchLength	: WORD;
    
    Buf		: ARRAY [0..4095] OF CHAR;
    Bp		: WORD;
    Be		: WORD;
    CurFile	: File;
    EndOfFile	: BOOLEAN;
    
    Line	: ARRAY [0..512] OF CHAR;
    LineLength	: WORD;
    LineNum	: WORD;
    ColumnNum	: WORD;
    Count	: WORD;
    CountInFile	: WORD;
    TotalLines	: LONGINT;
    
    Entry	: SearchRec;
    WorkString	: PathStr;
    CurrentFile	: PathStr;
    i, j	: WORD;

(* this match procedure effectively tests the first three characters AND *)
(* the last character before going into any loop, in 3 memory ops *)

(*$//OPT:T*) (* I want top testing on the while loop *)
FUNCTION Match() : WORD;
TYPE
    NEARWORDPTR = ^WORD NEAR;
VAR
    done	: BOOLEAN;
    endPos	: WORD;
    i		: WORD;
    j		: WORD;
    k		: WORD;
    LineAlias	: ^WORD NEAR; (* DS relative pointer *)
BEGIN
    Match := SizeOf(Line);
    i := 0;
    done := FALSE;
    IF MatchLength <= LineLength THEN BEGIN
	endPos := MatchLength-1;
	REPEAT

	    LineAlias := @Line[i];
	    IF (LineAlias^ = MatchAlias) AND (Line[endPos] = LastChar)
	    THEN BEGIN

		j := 2;
		k := i + 2;
		WHILE (MatchData[j] = Line[k]) AND (j < MatchLength) DO BEGIN
		    INC(k);
		    INC(j);
		END;

		IF j = MatchLength THEN BEGIN
		    Match := i;
		    done := TRUE;
		END;
	    END;
	    INC(i);
	    INC(endPos);
	UNTIL done OR (endPos = LineLength);
    END;
END;
(*$//REVERT*)

FUNCTION Filter() : BOOLEAN;
CONST
    maxFiltered = 6;
    filteredExt : ARRAY [0..maxFiltered] OF STRING[3] =
	(
	 'BAK',
	 'LST',
	 'TPU',
	 'INT',
	 'OBJ',
	 'LIB',
	 'EXE'
	);
VAR
    i : WORD;
    j : WORD;
    l : WORD;
    ext : STRING[3];
    fudgeExt : LONGINT ABSOLUTE ext;
    fudgeFiltered : ARRAY [0..maxFiltered] OF LONGINT ABSOLUTE filteredExt;
BEGIN
    Filter := TRUE;
    
    i := 1;
    l := Length(Entry.name);
    ext := #255#255#255;

    WHILE i < l DO BEGIN
	IF Entry.name[i] = '.' THEN BEGIN
	    INC(i);
	    j := 0;
	    WHILE i <= l DO BEGIN
		IF j < 3 THEN BEGIN
		    INC(j);
		    ext[j] := CapTable[Entry.name[i]];
		END;
		INC(i);
	    END;
	    BYTE(ext[0]) := j;
	END;
	INC(i);
    END;
    
    FOR i := 0 TO maxFiltered DO BEGIN
	(* yea this is ugly, but I gotta have some fun *)
	
	IF fudgeExt = fudgeFiltered[i] THEN BEGIN
	    Filter := FALSE;
	    EXIT;
	END;
    END;
END;

PROCEDURE ReadLine;
VAR
    done: BOOLEAN;
    i	: WORD;
    ch	: CHAR;
    lbp	: WORD;
BEGIN
    i := 0;
    lbp := Bp;
    REPEAT
	IF lbp < Be THEN BEGIN
	
	    ch := CapTable[Buf[lbp]];

	    IF i < SizeOf(Line) THEN BEGIN
		Line[i] := ch;
		INC(i);
	    END ELSE BEGIN
		Bp := lbp;
		LineLength := 512;
		Line[512] := #0;
		INC(TotalLines);
		EXIT;
	    END;

	    INC(lbp);

	    IF ch = #10 THEN BEGIN
		Bp := lbp;
		LineLength := i;
		Line[i] := #0;
		INC(TotalLines);
		EXIT;
	    END;
	END ELSE BEGIN
	    IF Eof(CurFile) THEN BEGIN
		Bp := lbp;
		EndOfFile := TRUE;
		Line[i] := #0;
		LineLength := i;
		EXIT;
	    END;
	    BlockRead(CurFile, Buf, SizeOf(Buf), Be);
	    IF IOResult() <> 0 THEN BEGIN
		WriteLn('...file read error...');
		HALT;
	    END;
	    lbp := 0;
	END;
    UNTIL FALSE;
END;

FUNCTION DirExists(name : PathStr) : BOOLEAN;
VAR
    R		: REGISTERS;
    temp	: STRING[80];
BEGIN
    temp := name;
    INC(temp[0]);
    temp[ORD(temp[0])] := #0;
    
    R.AX := $4300;
    R.DX := Ofs(temp[1]);
    R.DS := Seg(temp[1]);
    MSDOS(R);
    DirExists := FALSE;
    IF ((R.FLAGS AND 1) = 0) AND ((Directory AND R.CX) <> 0) THEN
	DirExists := TRUE;
END;

PROCEDURE ConstructFileName(pri, def : PathStr; VAR result : PathStr);
VAR
    priPath, defPath : DirStr;
    priName, defName : NameStr;
    priExt, defExt : ExtStr;
BEGIN
    FSplit(pri, priPath, priName, priExt);
    FSplit(def, defPath, defName, defExt);
    
    IF priPath = '' THEN
	result := defPath
    ELSE
	result := priPath;
	
    IF priName = '' THEN
	result := result + defName
    ELSE
	result := result + priName;
	
    IF priExt = '' THEN
	result := result + defExt
    ELSE
	result := result + priExt;
	
END;

PROCEDURE ParseCommandLine;
VAR
    i		: WORD;
    j		: WORD;
    numParams	: WORD;
BEGIN
    numParams := ParamCount();
    
    IF (numParams <= 1) OR (numParams > 5) THEN BEGIN
	WriteLn('USAGE: search pathSpec {pathSpec(s)} matchString');
	WriteLn('       up to 4 paths may be supplied');
	WriteLn('       the "\" character is converted to a " " character');
	HALT;
    END;
    
    MaxCommand := numParams-1;
    
    FOR i := 1 TO numParams-1 DO BEGIN
	Commands[i] := ParamStr(i);
	
	FOR j := 1 TO Length(Commands[i]) DO
	    Commands[i, j] := CapTable[Commands[i, j]];
    END;

    MatchString := ParamStr(numParams);
    
    FOR i := 1 TO Length(MatchString) DO BEGIN
	IF MatchString[i] = '\' THEN
	    MatchData[i-1] := ' '
	ELSE
	    MatchData[i-1] := CapTable[MatchString[i]];
    END;
    MatchLength := Length(MatchString);
    LastChar := CapTable[MatchString[MatchLength]];
END;

var
    iores : INTEGER;
    filterFile	: BOOLEAN;
BEGIN
    ParseCommandLine;

    TotalLines := 0;
    CurrentFile := '';
    Count := 0;
    CountInFile := 0;

    FOR i := 1 TO MaxCommand DO BEGIN
	filterFile := FALSE;
	IF DirExists(Commands[i]) THEN BEGIN
	    Commands[i] := Commands[i] + '\*.*';
	    filterFile := TRUE;
	END;

	FindFirst(Commands[i], Archive OR ReadOnly, Entry);
	IF DosError = 0 THEN BEGIN
	    REPEAT
		IF (NOT filterFile) OR Filter() THEN BEGIN
		    BYTE(WorkString[0]) := Length(CurrentFile);
		    INC(WorkString[0], 10);
		    IF BYTE(WorkString[0]) > 79 THEN
			BYTE(WorkString[0]) := 79;
    
		    FOR j := 1 TO Length(WorkString) DO
			WorkString[j] := ' ';
		    Write(#13, WorkString, #13);
		    
		    CountInFile := 0;

		    ConstructFileName(Entry.name, Commands[i], CurrentFile);
		    Assign(CurFile, CurrentFile);
		    Reset(CurFile, 1);
		    iores := IOResult();
		    IF iores <> 0 THEN BEGIN
			WriteLn('...file open error...');
			WriteLn(CurrentFile, ' ', iores);
			HALT;
		    END;
		    
		    Write('Searching ', CurrentFile);
		    
		    Bp := 0;
		    Be := 0;
		    LineNum := 0;
		    EndOfFile := FALSE;
		    REPEAT
			INC(LineNum);
			ReadLine;
			ColumnNum := Match(); 
			IF ColumnNum < SizeOf(Line) THEN BEGIN
			    INC(Count);
			    INC(CountInFile);
			END;
		    UNTIL EndOfFile;
		    Close(CurFile);
		    
		    IF CountInFile <> 0 THEN
			WriteLn(' ', CountInFile, ' Matches');
		END;
		FindNext(Entry);
	    UNTIL DosError <> 0;
	    
	    IF CountInFile = 0 THEN
		Write(#13'                                        '#13);
	END;
    END;
    
    WriteLn(#13#10);
    WriteLn('Found ', Count, ' total occurances of ', MatchString);
    WriteLn('In ', TotalLines, ' total lines scanned');
END.
