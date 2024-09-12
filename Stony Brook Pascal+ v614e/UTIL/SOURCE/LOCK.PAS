PROGRAM lock;
{$M 4096, 0, 0}
{$I-}

USES Dos;

TYPE
    LibHeader =
	RECORD
	id		: LONGINT;
	version		: WORD;
	numModules	: WORD;
	closed		: BOOLEAN;
	locked		: BOOLEAN;
	END;
CONST
    Id			: ARRAY [0..3] OF CHAR = 'SBLB';
    MajorVersion	= 5;
    MinorVersion	= 2;
    ThisVersion		= (256 * MajorVersion) + MinorVersion;
VAR
    cLine	: PathStr;
    header	: LibHeader;
    f		: File;
    count	: WORD;

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

BEGIN
    IF ParamCount() <> 1 THEN BEGIN
	WriteLn('USAGE: lock filespec');
	HALT(1);
    END;
    cLine := ParamStr(1);
    
    ConstructFileName(cLine, '.SBL', cLine);
    Assign(f, cLine);
    Reset(f, 1);
    IF IOResult() = 0 THEN BEGIN
	BlockRead(f, header, SizeOf(header), count);
	IF (header.id <> LONGINT(Id)) OR (count <> SizeOf(header)) THEN
	    WriteLn('Not a Stony Brook library')
	ELSE IF header.version <> ThisVersion THEN
	    WriteLn('Library version is incorrect for lock utility')
	ELSE BEGIN
	    header.locked := TRUE;
	    Seek(f, 0);
	    BlockWrite(f, header, SizeOf(header));
	    WriteLn('Library ', cLine, ' is locked');
	END;
	Close(f);
    END ELSE
	WriteLn('Could not open file: ', cLine);
END.
