UNIT DumpCV;

INTERFACE

TYPE
    CodeViewVersion	= (
			    NB00, NB01, NB02, NB03,
			    NB04, NB05, NB06, NB07
			  );

VAR
    DumpDirectory	: BOOLEAN;
    DumpSymbols		: BOOLEAN;
    DumpTypes		: BOOLEAN;
    DumpPublics		: BOOLEAN;
    DumpLines		: BOOLEAN;
    
    ModuleWanted	: STRING[32];
    
    DbgBase		: LONGINT;
    DbgDir		: LONGINT;
    NumEntries		: WORD;
    CodeView		: CodeViewVersion;
    
PROCEDURE FormattedCV;

FUNCTION GetCvVersion() : BOOLEAN;

IMPLEMENTATION

USES Dos, Disk, CV3;

FUNCTION GetCvVersion() : BOOLEAN;
CONST
    NB = ORD('N') + ORD('B') * 256;
TYPE
    HeaderEntry =
        RECORD
	nb	: WORD;
	vn	: ARRAY [0..1] OF CHAR;
	addr	: LONGINT;
	END;
VAR
    header	: HeaderEntry;
    lastRead	: WORD;
BEGIN
    GetCvVersion := FALSE;
    
    Seek(InFile, FileSize(InFile)-8);
    BlockRead(InFile, header, SizeOf(header), lastRead);
    IF (lastRead <> SizeOf(header)) OR (header.nb <> NB) THEN
	EXIT;
    
    DbgBase := FileSize(InFile) - header.addr;	

    Seek(InFile, DbgBase);
    BlockRead(InFile, header, SizeOf(header), lastRead);
    IF (lastRead <> SizeOf(header)) OR (header.nb <> NB) THEN
	EXIT;
    
    CodeView := CodeViewVersion(ORD(header.vn[1])-ORD('0'));
    DbgDir := DbgBase + header.addr;

    Seek(InFile, DbgDir);
    BlockRead(InFile, NumEntries, 2);
    DbgDir := DbgDir + 2;

    GetCvVersion := TRUE;
END;

PROCEDURE FormattedCV;
BEGIN
    IF GetCvVersion() THEN BEGIN
	IF CodeView > NB02 THEN
	    WriteLn('only <= CodeView NB02 supported currently')
	ELSE
	    FormattedCV3;
    END ELSE
	WriteLn('No CodeView information present');
END;

BEGIN
    ModuleWanted := '';
    DumpTypes := FALSE;
    DumpDirectory := FALSE;
    DumpSymbols := FALSE;
    DumpPublics := FALSE;
    DumpLines := FALSE;
END.
