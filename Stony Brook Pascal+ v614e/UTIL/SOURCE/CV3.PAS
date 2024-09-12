UNIT CV3;

INTERFACE

PROCEDURE FormattedCV3;

IMPLEMENTATION
(* formatted dumper for the "CV3" spec *)
(* i.e. <= MS C6.0 *)

USES Dos, Disk, Put, DumpCV;

CONST
    NB = ORD('N') + ORD('B') * 256;

    SstModule		= $101;
    SstPublics		= $102;
    SstTypes		= $103;
    SstSymbols		= $104;
    SstLines		= $105;
    SstSegLines		= $109;
    SstLibrary		= $106;
            
    BlockStart		= 0;
    ProcedureStart	= 1;
    BlockEnd		= 2;
    LocalVar		= 4;
    GlobalVar		= 5;
    CodeLabel		= 11;
    WithStart		= 12;
    RegisterVar		= 13;
    Constant		= 14;
    FortranEntry	= 15;
    Typedef		= 18;
    
    ProcedureTypeCode	= $75;
    NilTypeCode		= $80;
    StringTypeCode	= $60;
    ArrayTypeCode	= $78;
    RecordTypeCode	= $79;
    PointerTypeCode	= $7A;
    ScalarTypeCode	= $7B;
    ListTypeCode	= $7F;
    FarPointerCode	= $73;
    NearPointerCode	= $74;

    (* some extended debug types *)
    
    SetTypeCode		= $A1;
    SubrangeTypeCode	= $A2;
    VarParamTypeCode	= $AA;


TYPE
    String8	= STRING[8];

    HeaderEntry =
        RECORD
	nb	: WORD;
	vn	: ARRAY [0..1] OF CHAR;
	addr	: LONGINT;
	END;

    DirEntry =
        RECORD
	sst	: WORD;
	modIndex: WORD;
	start	: LONGINT;
	len	: WORD;
	END;

    ModuleEntry =
        RECORD
	codeSeg	: WORD;
	codeOff	: WORD;
	codeLen	: WORD;
	overlay	: WORD;
	library	: WORD;
	reserve	: WORD;
	namelen	: BYTE;
	END;

    PublicEntry =
        RECORD
	offset	: WORD;
	segment	: WORD;
	typ	: WORD;
	nameLen	: BYTE;
	END;

    LineEntry =
        RECORD
	number	: WORD;
	offset	: WORD;
	END;

    ModulePointer	= ^ModuleRecord;
    ModuleRecord=
	RECORD
	next		: ModulePointer;
	index		: WORD;
	codeSeg		: WORD;
	codeOff		: WORD;
	codeLen		: WORD;
	segLines	: BOOLEAN;
	lineStart	: LONGINT;
	lineEnd		: LONGINT;
	symbolsStart	: LONGINT;
	symbolsEnd	: LONGINT;
	typesStart	: LONGINT;
	typesEnd	: LONGINT;
	publicsStart	: LONGINT;
	publicsEnd	: LONGINT;
	overlay		: WORD;
	included	: BOOLEAN;
	shortName	: String8;
	fullName	: ^STRING;
	END;

VAR
    NumModules	: WORD;
    FirstModule	: ModulePointer;
    LastModule	: ModulePointer;

FUNCTION FindModuleByIndex(index : WORD) : ModulePointer;
VAR
    ptr : ModulePointer;
BEGIN
    ptr := FirstModule;
    WHILE (ptr <> NIL) AND (ptr^.index <> index) DO
	ptr := ptr^.next;
    FindModuleByIndex := ptr;
END;

FUNCTION FindModuleByName(name : STRING) : ModulePointer;
VAR
    ptr : ModulePointer;
BEGIN
    ptr := FirstModule;
    WHILE (ptr <> NIL) AND (ptr^.shortName <> name) DO
	ptr := ptr^.next;
    FindModuleByName := ptr;
END;

PROCEDURE StripDollarProc(long : STRING; VAR short : String8);
VAR
    i	: WORD;
    l	: WORD;
BEGIN
    l := Length(long);
    IF l > 8 THEN
	l := 8;

    i := 1;
    WHILE (i <= l) AND (long[i] <> '$') DO BEGIN
	short[i] := UpCase(long[i]);
	INC(i);
    END;
    BYTE(short[0]) := i-1;
END;

FUNCTION ReadModuleTable() : BOOLEAN;
VAR
    i		: WORD;
    modu	: ModulePointer;
    entry	: DirEntry;
    module	: ModuleEntry;
    pub		: PublicEntry;
    line	: LineEntry;
    header	: HeaderEntry;
    lastRead	: WORD;
    modName	: STRING;
    dir		: DirStr;
    name	: NameStr;
    ext		: ExtStr;
    namePtr	: ^STRING;
BEGIN
    ReadModuleTable := FALSE;

    (*
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
    IF CodeView > NB02 THEN BEGIN
	WriteLn('only <= CodeView NB02 supported currently');
	EXIT;
    END;

    DbgDir := DbgBase + header.addr;

    Seek(InFile, DbgDir);
    BlockRead(InFile, NumEntries, 2);
    DbgDir := DbgDir + 2;
    *)
    
    BufferSize := 512;
    Position(DbgDir);
    FirstModule := NIL;
    
    FOR i := 1 TO NumEntries DO BEGIN
	Nibble(entry, SizeOf(entry));
	IF Count = 0 THEN BEGIN
	    PutString('Error reading Debug directory');
	    Flush;
	END ELSE BEGIN
	    IF entry.sst = SstModule THEN BEGIN
		
		Seek(InFile, DbgBase+entry.start);
		BlockRead(InFile, module, SizeOf(module));
		BlockRead(InFile, modName[1], module.namelen);
		BYTE(modName[0]) := module.namelen;
		
		NEW(modu);
		modu^.next := NIL;
		modu^.index := entry.modindex;
		modu^.overlay := module.overlay;
		modu^.codeSeg := module.codeSeg;
		modu^.codeOff := module.codeOff;
		modu^.codeLen := module.codeLen;
		modu^.segLines := FALSE;
		modu^.lineStart := 0;
		modu^.symbolsStart := 0;
		modu^.typesStart := 0;
		modu^.publicsStart := 0;
		modu^.overlay := 0;
		modu^.included := FALSE;
		
		GetMem(modu^.fullName, 1+Length(modName));
		Move(modname, modu^.fullName^, 1+Length(modName));
		
		FSplit(modName, dir, name, ext);
		StripDollarProc(name, modu^.shortName);
		
		IF FirstModule = NIL THEN
		    FirstModule := modu
		ELSE
		    LastModule^.next := modu;
		LastModule := modu;
    
	    END ELSE IF (entry.sst = SstLines) OR (entry.sst = SstSegLines)
	    THEN BEGIN
		LastModule^.segLines := entry.sst = SstSegLines;
		LastModule^.lineStart := entry.start+DbgBase;
		LastModule^.lineEnd := entry.start+DbgBase+entry.len;
	    END ELSE IF entry.sst = SstSymbols THEN BEGIN
		LastModule^.symbolsStart := entry.start+DbgBase;
		LastModule^.symbolsEnd := entry.start+DbgBase+entry.len;
	    END ELSE IF entry.sst = SstTypes THEN BEGIN
		LastModule^.typesStart := entry.start+DbgBase;
		LastModule^.typesEnd := entry.start+DbgBase+entry.len;
	    END ELSE IF entry.sst = SstPublics THEN BEGIN
		LastModule^.publicsStart := entry.start+DbgBase;
		LastModule^.publicsEnd := entry.start+DbgBase+entry.len;
	    END;
	END;
    END;
    ReadModuleTable := TRUE;
END;

FUNCTION ReadNumber() : LONGINT;
VAR
    c	: BYTE;
    si	: SHORTINT;
    w	: WORD;
    i	: INTEGER;
    num	: LONGINT;
BEGIN
    Nibble(c, 1);

    IF c <= $7F THEN
	num := c
    ELSE IF c = $88 THEN BEGIN
	Nibble(si, 1);
	num := si;
    END ELSE IF c = $89 THEN BEGIN
	Nibble(i, 2);
	num := i;
    END ELSE IF (c = $8A) OR (c = $86) THEN
	Nibble(num, 4)
    ELSE IF (c = $85) OR (c = $83) THEN BEGIN
	Nibble(w, 2);
	num := w;
    END;
    ReadNumber := num;
END;

FUNCTION ReadBitSize() : WORD;
BEGIN
    ReadBitSize := (ReadNumber() + 7) DIV 8;
END;

PROCEDURE DoSymbols(modu : ModulePointer);
VAR
    c		: BYTE;
    symbolLength: WORD;
    symbolEnd	: LONGINT;
    symbolStart	: LONGINT;
    num		: LONGINT;
    reg		: BYTE;
    Reg1	: WORD;
    Reg2	: WORD;
    offset	: WORD;
    segment	: WORD;
    start	: WORD;
    length	: WORD;
    typ		: WORD;
    prolog	: WORD;
    epilog	: WORD;
    zero	: WORD;
    nf		: BYTE;
    name	: STRING;
	    
CONST
    Regs : ARRAY [0..11] OF STRING[2] =
	('AX', 'CX', 'DX', 'BX', 'SP', 'BP', 'SI', 'DI',
	 'ES', 'CS', 'SS', 'DS');
	
    PROCEDURE readName;
    BEGIN
	Nibble(name[0], 1);
	IF BYTE(name[0]) > 0 THEN
	    Nibble(name[1], ORD(name[0]));
    END;
	
BEGIN
    IF modu^.symbolsStart = 0 THEN
	EXIT;
    Position(modu^.symbolsStart);
    
    BlankLine(2);
    PutString('Symbolic info for module ');
    PutString(modu^.fullName^);
    PutString(' pos=');
    PutLong(modu^.symbolsStart);
    PutString(' end=');
    PutLong(modu^.symbolsEnd);
    Flush;
    BlankLine(1);
    
    WHILE Pos() < modu^.symbolsEnd DO BEGIN
	
	Nibble(c, 1);
	symbolLength := ORD(c);
	symbolStart := Pos();
	symbolEnd := symbolStart + symbolLength;

	Nibble(c, 1);
	CASE c OF
	    BlockStart:
	    BEGIN
		Nibble(start, 2);
		Nibble(length, 2);
		PutString('Block start=');
		PutHex(start, 4);
		PutString(' length=');
		PutHex(length, 4);
		PutString(' name=');
		IF symbolLength > 5 THEN BEGIN
		    readName;
		    PutString(name);
		END;
		Flush;
	    END;
	    WithStart:
	    BEGIN
		Nibble(start, 2);
		Nibble(length, 2);
		PutString('Start block start=');
		PutHex(start, 4);
		PutString(' length=');
		PutHex(length, 4);
		readName;
		PutString(' expr=');
		PutString(name);
		Flush;
	    END;
	    ProcedureStart, FortranEntry:
	    BEGIN
		Nibble(start, 2);
		Nibble(typ, 2);
		Nibble(length, 2);
		Nibble(prolog, 2);
		Nibble(epilog, 2);
		Nibble(zero, 2);
		Nibble(nf, 1);
		readName;
		PutString('PROC ');
		PutString(name);
		PutString(' typ=');
		PutHex(typ, 4);
		PutString(' strt=');
		PutHex(start, 4);
		PutString(' len=');
		PutHex(length, 4);
		PutString(' pro=');
		PutHex(prolog, 4);
		PutString(' epi=');
		PutHex(epilog, 4);
		IF nf = 0 THEN
		    PutString(' near')
		ELSE IF ORD(nf) = 4 THEN
		    PutString(' far')
		ELSE BEGIN
		    Flush;
		    PutString('***** error: invalid near/far flag');
		END;
		Flush;
		IF zero <> 0 THEN BEGIN
		    PutString('***** error: zero field is non zero');
		    Flush;
		END;
	    END;
	    BlockEnd:
	    BEGIN
		PutString('End block');
		Flush;
	    END;
	    LocalVar: (* BP relative *)
	    BEGIN
		Nibble(offset, 2);
		Nibble(typ, 2);
		readName;
		PutString('Local variable ');
		PutString(name);
		PutString(' offset=');
		PutHex(offset, 4);
		PutString(' type=');
		PutHex(typ, 4);
		Flush;
	    END;
	    GlobalVar: (* Static for you C type people *)
	    BEGIN
		Nibble(offset, 2);
		Nibble(segment, 2);
		Nibble(typ, 2);
		readName;
		PutString('Global/Static variable ');
		PutString(name);
		PutString(' addr=');
		PutHex(segment, 4);
		PutString(':');
		PutHex(offset, 4);
		PutString(' type=');
		PutHex(typ, 4);
		Flush;
	    END;
	    RegisterVar:
	    (* the 2 register, register variable is an extension *)
	    (* nobody else will enregister 32bit types *)
	    (* in any combination of 16bit registers, no guts no glory *)
	    BEGIN
		Nibble(typ, 2);
		Nibble(reg, 1);
		Reg1 := ORD(reg) MOD 16 - 8;
		Reg2 := ORD(reg) DIV 16;
		readName;
		PutWord(reg);
		PutString(' Register variable ');
		PutString(name);
		PutString(' ');
		IF Reg2 <> 0 THEN BEGIN
		    PutString(Regs[Reg2]);
		    PutString(':');
		END;
		PutString(Regs[Reg1]);
		PutString(' type=');
		PutHex(typ, 4);
		Flush;
	    END;
	    Constant:
	    (* this is output only in extended debug info *)
	    (* debuggers don't seem to agree on how this is implemented *)
	    (* thus an extended type, I love standards <grin> *)
	    BEGIN
		Nibble(typ, 2);
		num := ReadNumber();
		PutString('Constant ');
		IF typ <> 0 THEN BEGIN
		    readName;
		    PutString(name);
		    PutString(' type=');
		    PutHex(typ, 4);
		    PutString(' value=');
		    PutLong(num);
		END;
		Flush;
	    END;
	    Typedef:
	    (* TDUMP 3.0 still does not know what this record is *)
	    BEGIN
		Nibble(typ, 2);
		readName;
		PutString('Type ');
		PutString(name);
		PutString(' type=');
		PutHex(typ, 4);
		Flush;
	    END;
	    CodeLabel: (* assemblers will use this *)
	    BEGIN
		Nibble(offset, 2);
		Nibble(c, 1);
		readName;
		PutString('Code Label ');
		PutString(name);
		PutString(' offset=');
		PutHex(offset, 4);
		IF c = 0 THEN
		    PutString(' NEAR')
		ELSE
		    PutString(' FAR');
		Flush;
	    END;
	ELSE
	    BEGIN
		PutString('***** Invalid DST, bad record type: ');
		PutHex(ORD(c), 2);
		Flush;
	    END;
	END;
	IF Pos() <> symbolEnd THEN BEGIN
	    Position(symbolEnd);
	    PutString('***** error: position is not correct');
	    Flush;
	END;
    END;
END;

PROCEDURE DoTypes(modu : ModulePointer);
VAR
    c		: BYTE;
    n		: WORD;
    l		: WORD;
    endrec	: LONGINT;
    t		: WORD;
    i		: WORD;
    name	: STRING;
    
    PROCEDURE DoNameIfPresent;
    VAR
	c : BYTE;
    BEGIN
	Nibble(c, 1);
	IF c = $82 THEN BEGIN
	    Nibble(c, 1);
	    IF c <> 0 THEN
		Nibble(name[1], c);
	    BYTE(name[0]) := c;
	    PutString(' typename=');
	    PutString(name);
	END;
    END;
BEGIN
	
    IF modu^.typesStart = 0 THEN
	EXIT;
	    
    Flush;
    PutString('Types for module: ');
    PutString(modu^.fullName^);
    PutString(' pos=');
    PutLong(modu^.typesStart);
    PutString(' end=');
    PutLong(modu^.typesEnd);
    Flush;
    BlankLine(1);
    
    Position(modu^.typesStart);
    
    n := $200;
    WHILE Pos() < modu^.typesEnd DO BEGIN
	Nibble(c, 1);
	IF c <> 1 THEN BEGIN
	    PutString('***** error:  type does not begin with 1');
	    Flush;
	    EXIT;
	END;
	
	Nibble(l, 2);
	endrec := Pos() + l;
	
	PutHex(n, 4);
	PutString(': ');
	PutHex(l, 4);
	
	Nibble(c, 1);
	
	CASE c OF
	    NilTypeCode: (* "easy" leaf *)
	    BEGIN
		PutString(' Nil ');
		Flush;
	    END;
	    ProcedureTypeCode:
	    BEGIN
		PutString(' PROCEDURE ');

		Nibble(c, 1);
		IF c <> $80 THEN
		    PutString('***** error: Nil field not there');

		Nibble(c, 1);
		IF c <> $83 THEN
		    PutString('***** error: Type list code not there');
		Nibble(t, 2);
		PutString(' typ=');
		PutHex(t, 4);

		Nibble(c, 1);
		CASE c OF
		    $63: PutString(' Near C ');
		    $64: PutString(' Far C ');
		    $73: PutString(' Far Pascal ');
		    $74: PutString(' Near Pascal ');
		    $95: PutString(' Near FastCall ');
		    $96: PutString(' Far FastCall ');
		    $99: PutString(' Inline ');
		ELSE
		    BEGIN
			Flush;
			PutString('***** error: bad calling type ');
			Flush;
		    END;
		END;
		PutString(' Num params: ');
		PutWord(ReadNumber());

		Nibble(c, 1);
		IF c <> $83 THEN
		    PutString('***** bad param type index ');
		Nibble(t, 2);
		PutString(' params=');
		PutHex(t, 4);
		Flush;
	    END;
	    ArrayTypeCode:
	    BEGIN
		PutString(' ARRAY size=');
		PutLong(ReadBitSize());
		PutString(' element=');
		PutHex(ReadNumber(), 4);
		PutString(' subs=');
		PutHex(ReadNumber(), 4);
		DoNameIfPresent;
		Flush;
	    END;
	    RecordTypeCode: (* Struct for you C type people *)
	    BEGIN
		PutString(' RECORD size=');
		PutLong(ReadBitSize());
		PutString(' numfields=');
		PutWord(ReadNumber());
		PutString(' types=');
		PutHex(ReadNumber(), 4);
		PutString(' names=');
		PutHex(ReadNumber(), 4);
		DoNameIfPresent;
		Flush;
	    END;
	    ScalarTypeCode:
	    (* scalars can be used for just about anything *)
	    (* Stony Brook uses them for *)
	    (* ARRAY subscript definition *)
	    (* Enumeration definition *)
	    BEGIN
		PutString(' Scalar size=');
		PutLong(ReadBitSize());

		Nibble(c, 1);
		CASE c OF
		    $6C: PutString(' (boolean) ');
		    $6F: PutString(' (character) ');
		    $70: PutString(' (integer) ');
		    $7C: PutString(' (unsigned) ');
		    $7D: PutString(' (signed) ');
		    $83:
		    BEGIN
			PutString(' daddy= ');
			Nibble(t, 2);
			PutHex(t, 4);
		    END;
		    $80: PutString(' nil ');
		ELSE
		    PutString('***** Invalid type **');
		END;

		Nibble(c, 1);
		IF c = $82 THEN BEGIN
		    PutString('type name is: ');
		    Nibble(c, 1);
		    FOR i := 1 TO ORD(c) DO BEGIN
			Nibble(c, 1);
			PutChar(CHAR(c));
		    END;
		END ELSE IF c <> $80 THEN BEGIN
		    PutString('***** Inavlid name **');
		END;
		
		Nibble(c, 1);
		IF c = $83 THEN BEGIN
		    PutString(' names=');
		    Nibble(t, 2);
		    PutHex(t, 4);
		END ELSE IF c <> $80 THEN BEGIN
		    PutString('***** invalid representation type **');
		END;

		PutString(' low=');
		PutWord(ReadNumber());
		PutString(' high=');
		PutWord(ReadNumber());
		Flush;
	    END;
	    PointerTypeCode:
	    BEGIN
		PutString(' POINTER typ=');

		Nibble(c, 1);
		IF c = FarPointerCode THEN
		    PutString('FAR')
		ELSE IF c = NearPointerCode THEN
		    PutString('NEAR')
		ELSE BEGIN
		    PutString('***** bad');
		END;

		PutString(' bastyp=');
		PutHex(ReadNumber(), 4);
		DoNameIfPresent;
		Flush;
	    END;
	    SubrangeTypeCode:
	    (* an Extension *)
	    (* no longer output, Scalar used instead *)
	    (* Modula-2 2.0 and 2.1 used this *)
	    BEGIN
		PutString(' SUBRANGE of=');
		PutHex(ReadNumber(), 4);
		PutString(' ');
		PutWord(ReadNumber());	
		PutString('..');
		PutLong(ReadNumber());
		Flush;
	    END;
	    SetTypeCode:
	    (* an Extension *)
	    (* only output with extended debug information *)
	    (* if C is so great, how come it doesn't have a SET type *)
	    (* chuckle when I see a "bit vector" C article in the rags *)
	    BEGIN
		PutString(' SET size=');
		PutLong(ReadNumber());
		PutString(' bastyp=');
		PutHex(ReadNumber(), 4);
		DoNameIfPresent;
		Flush;
	    END;
	    ListTypeCode:
	    (* used for enumeration name lists *)
	    (* record field lists *)
	    BEGIN
		PutString(' LIST ');
		Flush;
		WHILE Pos() < endrec DO BEGIN
		    PutString('    ');

		    Nibble(c, 1);
		    IF c = $82 THEN BEGIN
			PutString('name: ');

			Nibble(c, 1);
			FOR i := 1 TO ORD(c) DO BEGIN
			    Nibble(c, 1);
			    PutChar(CHAR(c));
			END;

			PutString(' offset=');
			PutLong(ReadNumber());
		    END ELSE IF c = $83 THEN BEGIN
			PutString('type: ');
			Nibble(t, 2);
			PutHex(t, 4);
		    END ELSE BEGIN
			PutString('***** error: bad list item code');
		    END;
		    Flush;
		END;
	    END;
	    VarParamTypeCode:
	    (* an Extension *)
	    (* only output with extended debug information *)
	    (* basically just tells the debugger to auto dereference a *)
	    (* pointer type *)
	    BEGIN
		PutString(' PARAM typ=');
		PutHex(ReadNumber(), 4);
		DoNameIfPresent;
		Flush;
	    END;
	    StringTypeCode:
	    (* Pascal Length Byte strings *)       
	    (* basically an Extension *)
	    (* the CV leaf exists, there is no definition for that leaf *)
	    (* so we gave it one *)
	    (* only output with extended debug information *)
	    BEGIN
		PutString(' STRING  len=');
		PutLong(ReadBitSize());
		Flush;
	    END;
	ELSE
	    BEGIN
		PutString(' ***** INVALID: ');
		PutHex(c, 2);
		Flush;
	    END;
	END;
	Position(endrec);
	INC(n);
    END;
END;

PROCEDURE DoPublics(modu : ModulePointer);
VAR
    pubEntry	: PublicEntry;
    name	: STRING;
BEGIN
    IF modu^.publicsStart = 0 THEN
	EXIT;
    
    BlankLine(1);
    PutString('Public symbols for ');
    PutString(modu^.fullName^);
    Flush;
    BlankLine(1);
    
    Position(modu^.publicsStart);
    
    WHILE Pos() < modu^.publicsEnd DO BEGIN
	Nibble(pubEntry, SizeOf(pubEntry));

	PutString('  addr=');
	PutHex(pubentry.segment, 4);
	PutChar(':');
	PutHex(pubentry.offset, 4);

	PutString(' type=');
	PutWord(pubentry.typ);

	Nibble(name[1], pubEntry.nameLen);
	BYTE(name[0]) := pubEntry.nameLen;
	PutString(' name=');
	PutString(name);

	Flush;
    END;
END;

PROCEDURE DoLines(modu : ModulePointer);
VAR
    i		: WORD;
    j		: WORD;
    l		: WORD;
    count	: WORD;
    line	: WORD;
    offset	: WORD;
    name	: STRING;
BEGIN
    IF modu^.lineStart = 0 THEN
	EXIT;
    
    BlankLine(1);
    PutString('Line number info for ');
    PutString(modu^.fullName^);
    Flush;
    BlankLine(1);
    
    Position(modu^.lineStart);
    
    WHILE Pos() < modu^.lineEnd DO BEGIN
	Nibble(name[0], 1);
	Nibble(name[1], ORD(name[0]));
	PutString(name);
	IF modu^.segLines THEN BEGIN
	    Nibble(count, 2);
	    PutString(' segment = ');
	    PutHex(count, 4);
	END;
	Flush;
	Nibble(count, 2);
	
	i := 1;
	WHILE count <> 0 DO BEGIN
	    l := count;
	    IF l > 5 THEN
		l := 5;
		
	    FOR j := 1 TO l DO BEGIN
		Nibble(line, 2);
		Nibble(offset, 2);
		PutString('    ');
		PutWord(line);
		PutString(': ');
		PutHex(offset, 4);
	    END;
	    Flush;
	    count := count - l;
	END;
    END;
END;

PROCEDURE DoDirectory;
    PROCEDURE NewLine;
    BEGIN
	IF BuildLine <> '' THEN
	    Flush;
	PutString('    ');
    END;

VAR
    modu	: ModulePointer;
BEGIN
    modu := FirstModule;
    WHILE modu <> NIL DO BEGIN
	PutString('Module ');
	PutString(modu^.fullName^);

	NewLine;
	PutString('index    = ');
	PutWord(modu^.index);

	NewLine;
	PutString('overlay  = ');
	PutWord(modu^.overlay);

	NewLine;
	PutString('addr     = ');
	PutHex(modu^.codeSeg, 4);
	PutChar(':');
	PutHex(modu^.codeOff, 4);
	PutString(', ');
	PutWord(modu^.codeLen);

	NewLine;
	PutString('symbols  = ');
	PutLong(modu^.symbolsStart);
	IF modu^.symbolsStart <> 0 THEN BEGIN
	    PutString(', ');
	    PutWord(modu^.symbolsEnd-modu^.symbolsStart);
	END;

	NewLine;
	PutString('types    = ');
	PutLong(modu^.typesStart);
	IF modu^.typesStart <> 0 THEN BEGIN
	    PutString(', ');
	    PutWord(modu^.typesEnd-modu^.typesStart);
	END;

	NewLine;
	PutString('publics  = ');
	PutLong(modu^.publicsStart);
	IF modu^.publicsStart <> 0 THEN BEGIN
	    PutString(', ');
	    PutWord(modu^.publicsEnd-modu^.publicsStart);
	END;

	NewLine;
	PutString('lines    = ');
	PutLong(modu^.lineStart);
	IF modu^.lineStart <> 0 THEN BEGIN
	    PutString(', ');
	    PutWord(modu^.lineEnd-modu^.lineStart);
	END;
	
	Flush;
	
	modu := modu^.next;
    END;
END;

PROCEDURE FormattedCV3;
VAR
    modu	: ModulePointer;
BEGIN
    IF ReadModuleTable() THEN BEGIN
	modu := FirstModule;
	WHILE modu <> NIL DO BEGIN
	    IF (ModuleWanted = '') OR (ModuleWanted = modu^.shortName) THEN
		modu^.included := TRUE;
	    modu := modu^.next;
	END;

	IF DumpDirectory THEN
	    DoDirectory;
	
	modu := FirstModule;
	WHILE modu <> NIL DO BEGIN
	    IF modu^.included THEN BEGIN
		IF DumpSymbols THEN
		    DoSymbols(modu);
    
		IF DumpTypes THEN
		    DoTypes(modu);
    
		IF DumpPublics THEN
		    DoPublics(modu);
    
		IF DumpLines THEN
		    DoLines(modu);
	    END;
	    modu := modu^.next;
	END;
    END;
END;

BEGIN
    ModuleWanted := '';
    DumpTypes := FALSE;
    DumpDirectory := FALSE;
    DumpSymbols := FALSE;
    DumpPublics := FALSE;
    DumpLines := FALSE;
END.
