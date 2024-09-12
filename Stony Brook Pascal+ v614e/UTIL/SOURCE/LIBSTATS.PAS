UNIT LibStats;

INTERFACE

PROCEDURE DumpLibStats;

IMPLEMENTATION

USES Dos, Disk, Put;

CONST
    THEADR	=	$80;
    PUBDEF	=	$90;
    EXTDEF	=	$8C;
    MODEND	=	$8A;
    COMENT	=	$88;
    LIBHDR	=	$F0;
    LIBEND	=	$F1;

VAR
    RecType		: BYTE;
    RecSize		: WORD;
    RecStart		: LONGINT;
    
    WhiteSpace		: LONGINT;
    WhiteSpaceRecords	: LONGINT;
    
    SLVMSpace		: LONGINT;
    SLVMRecords		: LONGINT;

    RecordSpace		: LONGINT;
    NumberRecords	: LONGINT;
    
    ObjectsSpace	: LONGINT;
    Objects		: LONGINT;
    
    Modulus		: WORD;
    FileLength		: LONGINT;
    IndexPos		: LONGINT;
    IndexBlocks		: WORD;
    CaseSensitive	: BOOLEAN;

PROCEDURE SkipToModuleStart;
VAR
    b : CHAR;
BEGIN
    INC(WhiteSpaceRecords);
    WHILE Pos() MOD LONGINT(Modulus) <> 0 DO BEGIN
	Nibble(b, 1);
	INC(WhiteSpace);
    END;
END;

PROCEDURE GetRecord;
VAR
    p : LONGINT;
    b : BYTE;
BEGIN
    RecStart := Pos();
    Nibble(RecType, 1);
    Nibble(RecSize, 2);
    p := Pos() + LONGINT(RecSize);

    IF RecType = COMENT THEN BEGIN
	Nibble(b, 1);
	Nibble(b, 1);
	IF b = $DE THEN BEGIN
	    INC(SLVMRecords);
	    SLVMSpace := SLVMSpace + LONGINT(RecSize);
	END;
    END;

    Position(p);
END;

PROCEDURE DumpLibStats;
VAR
    b : BYTE;
    start : LONGINT;
BEGIN
    WhiteSpace := 0;
    WhiteSpaceRecords := 0;
    
    SLVMSpace := 0;
    SLVMRecords := 0;

    RecordSpace := 0;
    NumberRecords := 0;
    
    ObjectsSpace := 0;
    Objects := 0;
    
    FileLength := FileSize(inFile);
    
    Nibble(b, 1);
    IF b <> LIBHDR THEN BEGIN
	PutString('not a library file');
	Flush;
	HALT(1);
    END;
    
    Nibble(Modulus, 2);
    Modulus := Modulus+3;
    
    Nibble(IndexPos, 4);
    Nibble(IndexBlocks, 2);
    Nibble(CaseSensitive, 1);

    REPEAT
	SkipToModuleStart;
	GetRecord;
	IF RecType = THEADR THEN BEGIN
	    start := RecStart;
	    RecordSpace := RecordSpace + LONGINT(RecSize);
	    INC(NumberRecords);
	    
	    REPEAT
		GetRecord;
		RecordSpace := RecordSpace + LONGINT(RecSize);
		INC(NumberRecords);
	    UNTIL RecType = MODEND;

	    INC(Objects);
	    ObjectsSpace := ObjectsSpace + (Pos() - start);
	END;
    UNTIL RecType = LIBEND;
    
    PutString('        File length = ');
    PutLong(FileLength);
    Flush;
    
    PutString('            Modulus = ');
    PutWord(Modulus);
    Flush;
    
    PutString('     Index position = ');
    PutLong(IndexPos);
    PutString(' (');
    PutLongHex(IndexPos);
    PutString('h)');
    Flush;
    
    PutString('       Index blocks = ');
    PutWord(IndexBlocks);
    Flush;
    
    PutString('      ');
    IF NOT CaseSensitive THEN
	PutString('NOT ');
    PutString('Case sensitive');
    Flush;
    
    PutString('      Total records = ');
    PutLong(NumberRecords);
    Flush;
    PutString('       Average size = ');
    PutWord(RecordSpace DIV NumberRecords);
    Flush;
    
    PutString('      Total objects = ');
    PutLong(Objects);
    Flush;
    PutString('       Average size = ');
    PutWord(ObjectsSpace DIV Objects);
    Flush;
    
    PutString('    Whitespace size = ');
    PutLong(WhiteSpace);
    Flush;
    PutString('       % whitespace = ');
    WhiteSpace := WhiteSpace * 1000 DIV FileLength;
    PutLong(WhiteSpace DIV 10);
    PutString('.');
    PutLong(WhiteSpace MOD 10);
    Flush;
     
    IF SLVMSpace <> 0 THEN BEGIN
	PutString('         SLVM size  = ');
	PutLong(SLVMSpace);
	Flush;
	PutString('      SLVM records  = ');
	PutLong(SLVMRecords);
	Flush;
	PutString('       Average size = ');
	PutWord(SLVMSpace DIV SLVMRecords);
	Flush;
    END;
END;

END.
