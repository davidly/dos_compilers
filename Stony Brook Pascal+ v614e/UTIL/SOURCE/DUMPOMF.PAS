UNIT DumpOMF;

INTERFACE

VAR
    Terse	: BOOLEAN;
    
PROCEDURE FormattedOBJ;

PROCEDURE FormattedLIB;

IMPLEMENTATION

USES Disk, Put;

CONST
    THEADR	= $80;
    LNAMES	= $96;

    SEGDEF	= $98;
    SEGD32	= $99;

    GRPDEF	= $9A;

    PUBDEF	= $90;
    PUBD32	= $91;

    LPUBDEF	= $B6;
    LPUBD32	= $B7;

    COMDEF	= $B0;
    LCOMDEF	= $B8;

    EXTDEF	= $8C;
    LEXTDEF	= $B4;

    LINNUM	= $94;
    LINN32	= $95;

    LEDATA	= $A0;
    LEDA32	= $A1;

    LIDATA	= $A2;
    LIDA32	= $A3;

    FIXUPP	= $9C;
    FIXU32	= $9D;

    MODEND	= $8A;
    MODE32	= $8B;
    
    COMENT	= $88;
    
    (* we don't handle these *)
    
    BAKPAT1	= $B2;
    BAKPAT2	= $B3;
    OBJNAM	= $AC;
    LOCSYM	= $92;
    
    (* LIB record types *)

    LIBHDR	= $F0;
    LIBEND	= $F1;
        	    
TYPE
    Bytes	= ARRAY [0..1] OF BYTE;
    Words	= ARRAY [0..1] OF WORD;
    ByteSet	= SET OF 0..7;

    NamePointer	= ^NameRec;
    NameRec	=
	RECORD
	next	: NamePointer;
	name	: STRING;
	END;

    ThreadRec	=
	RECORD
	method	: WORD;
	data	: WORD;
	END;

CONST
    MaxRecSize	= 4096;
    BadName	: NameRec = (next:NIL; name:'BAD#NAME');
    NoName	: NameRec = (next:NIL; name:'<NONAME>');

VAR
    RecAddr	: LONGINT;
    ModuleAddr	: LONGINT;
    RecData	: ARRAY [0..MaxRecSize-1] OF BYTE;
    RecCursor	: WORD;
    
    Threads	: ARRAY [0..7] OF ThreadRec;
    
    MicrosoftExtensions	: BOOLEAN;

    Modulus		: LONGINT;
    Padding		: WORD;
    DictionaryAddr	: LONGINT;
    DictionarySize	: WORD;
    LibFlags		: BYTE;
    
    RecordType		: BYTE;
    RecordLength	: WORD;
    CheckSum		: BYTE;
    FixupNumber		: WORD;
    
    FirstName		: NamePointer;
    LastName		: NamePointer;
    MaxNames		: WORD;

    FirstExtName	: NamePointer;
    LastExtName		: NamePointer;
    MaxExtNames		: WORD;

    FirstGroupName	: NamePointer;
    LastGroupName	: NamePointer;
    MaxGroups		: WORD;

    FirstSegName	: NamePointer;
    LastSegName		: NamePointer;
    MaxSegments		: WORD;

PROCEDURE ObjectError(s : STRING);
VAR
    hs	: HexString;
BEGIN
    WriteLn(s);
    ConvertHex(RecAddr, 8, hs);
    WriteLn('offset from start of file = ', hs);
    ConvertHex(RecAddr-ModuleAddr, 8, hs);
    WriteLn('offset from start of module = ', hs);
END;

PROCEDURE StartDataLine;
BEGIN
    TabTo(4);
END;

PROCEDURE PutRecAddr;
BEGIN
    PutLongHex(RecAddr);
    PutString(':  ');
END;

PROCEDURE ReadName(VAR name : STRING);
VAR
    l : WORD;
    i : WORD;
BEGIN
    l := ORD(RecData[RecCursor]);
    INC(RecCursor);
    name := '';
    
    IF l > 0 THEN BEGIN
	Move(RecData[RecCursor], name[1], l);
	BYTE(name[0]) := l;
	RecCursor := RecCursor + l;
    END;
END;

PROCEDURE AddName(s : STRING);
VAR
    newName : NamePointer;
BEGIN
    IF s <> 'BAD#NAME' THEN BEGIN
	GetMem(newName, 5+Length(s));
	newName^.next := NIL;
	Move(s, newName^.name, Length(s)+1);
	
	IF FirstName = NIL THEN
	    FirstName := newName
	ELSE
	    LastName^.next := newName;
	LastName := newName;
	INC(MaxNames);
    END;
END;

PROCEDURE AddExtName(s : STRING);
VAR
    newName : NamePointer;
BEGIN
    IF s <> 'BAD#NAME' THEN BEGIN
	GetMem(newName, 5+Length(s));
	newName^.next := NIL;
	Move(s, newName^.name, Length(s)+1);
	
	IF FirstExtName = NIL THEN
	    FirstExtName := newName
	ELSE
	    LastExtName^.next := newName;
	LastExtName := newName;
	INC(MaxExtNames);
    END;
END;

PROCEDURE AddGroupName(s : STRING);
VAR
    newName : NamePointer;
BEGIN
    IF s <> 'BAD#NAME' THEN BEGIN
	GetMem(newName, 5+Length(s));
	newName^.next := NIL;
	Move(s, newName^.name, Length(s)+1);
	
	IF FirstGroupName = NIL THEN
	    FirstGroupName := newName
	ELSE
	    LastGroupName^.next := newName;
	LastGroupName := newName;
	INC(MaxGroups);
    END;
END;

PROCEDURE AddSegName(s : STRING);
VAR
    newName : NamePointer;
BEGIN
    IF s <> 'BAD#NAME' THEN BEGIN
	GetMem(newName, 5+Length(s));
	newName^.next := NIL;
	Move(s, newName^.name, Length(s)+1);
	
	IF FirstSegName = NIL THEN
	    FirstSegName := newName
	ELSE
	    LastSegName^.next := newName;
	LastSegName := newName;
	INC(MaxSegments);
    END;
END;

FUNCTION GetName(index : WORD) : NamePointer;
VAR
    i 		: WORD;
    name	: NamePointer;
BEGIN
    GetName := ADDR(BadName);
    
    IF (index = 0) OR (index > MaxNames) THEN BEGIN
	IF index = 0 THEN
	    GetName := ADDR(NoName)
	ELSE
	    ObjectError('Bad name index');
	    
	EXIT;
    END;
    
    name := FirstName;
    FOR i := 2 TO index DO
	name := name^.next;
    
    GetName := name;
END;

FUNCTION GetExtName(index : WORD) : NamePointer;
VAR
    i 		: WORD;
    name	: NamePointer;
BEGIN
    GetExtName := ADDR(BadName);
    
    IF (index = 0) OR (index > MaxExtNames) THEN BEGIN
	IF index = 0 THEN
	    GetExtName := ADDR(NoName)
	ELSE
	    ObjectError('Bad name index');
	    
	EXIT;
    END;
    
    name := FirstExtName;
    FOR i := 2 TO index DO
	name := name^.next;
    
    GetExtName := name;
END;

FUNCTION GetGroupName(index : WORD) : NamePointer;
VAR
    i 		: WORD;
    name	: NamePointer;
BEGIN
    GetGroupName := ADDR(BadName);
    
    IF (index = 0) OR (index > MaxGroups) THEN BEGIN
	IF index = 0 THEN
	    GetGroupName := ADDR(NoName)
	ELSE
	    ObjectError('Bad name index');
	    
	EXIT;
    END;
    
    name := FirstGroupName;
    FOR i := 2 TO index DO
	name := name^.next;
    
    GetGroupName := name;
END;

FUNCTION GetSegName(index : WORD) : NamePointer;
VAR
    i 		: WORD;
    name	: NamePointer;
BEGIN
    GetSegName := ADDR(BadName);
    
    IF (index = 0) OR (index > MaxSegments) THEN BEGIN
	IF index = 0 THEN
	    GetSegName := ADDR(NoName)
	ELSE
	    ObjectError('Bad name index');
	    
	EXIT;
    END;
    
    name := FirstSegName;
    FOR i := 2 TO index DO
	name := name^.next;
    
    GetSegName := name;
END;

FUNCTION GetByte() : BYTE;
BEGIN
    GetByte := RecData[RecCursor];
    INC(RecCursor);
END;

FUNCTION GetWord() : WORD;
VAR
    i : WORD;
BEGIN
    Bytes(i)[0] := RecData[RecCursor];
    INC(RecCursor);
    Bytes(i)[1] := RecData[RecCursor];
    INC(RecCursor);
    GetWord := i;
END;

FUNCTION GetDword() : LONGINT;
VAR
    li : LONGINT;
BEGIN
    Words(li)[0] := GetWord();
    Words(li)[1] := GetWord();
    GetDword := li;
END;

FUNCTION GetIndex() : WORD;
VAR
    i : WORD;
BEGIN
    i := ORD(RecData[RecCursor]);
    INC(RecCursor);
    IF i > 127 THEN BEGIN
	i := (i - 128) * 256 + ORD(RecData[RecCursor]);
	INC(RecCursor);
    END;
    GetIndex := i;
END;

PROCEDURE DumpRecordAsHex;
VAR
    recOffset	: WORD;
    top		: WORD;
    i		: WORD;
    ch		: CHAR;
    line	: ARRAY [1..16] OF BYTE;
BEGIN
    recOffset := 0;
    WHILE RecCursor < RecordLength DO BEGIN
	
	StartDataLine;
	PutChar(' ');
	PutHex(recOffset, 3);
	PutString(': ');

	i := 1;
	WHILE (RecCursor < RecordLength) AND (i <= 16) DO BEGIN
	    line[i] := GetByte();
	    INC(i);
	END;
	top := i-1;
	recOffset := recOffset + top;
	
	FOR i := 1 TO top DO BEGIN
	    PutChar(' ');
	    PutHex(line[i], 2);
	    
	    IF i = 8 THEN
		PutChar(' ');
	END;
	
	TabTo(62);
	
	FOR i := 1 TO top DO BEGIN
	    ch := CHAR(line[i]);
	    IF NOT (ch IN Printable) THEN
		ch := '.';
	    PutChar(ch);
	END;
	
	Flush;
    END;
END;

PROCEDURE HandleTHEADR;
VAR
    name	: STRING;
BEGIN
    PutRecAddr;
    PutString('THEADR ');
    ReadName(name);
    PutQuote(name);
    Flush;
END;

PROCEDURE HandleLNAMES;
VAR
    name : STRING;
BEGIN
    IF Detail THEN BEGIN
	PutRecAddr;
	PutString('LNAMES');
	Flush;
    END;
    WHILE RecCursor < RecordLength DO BEGIN
	ReadName(name);
	AddName(name);
	IF Detail THEN BEGIN
	    StartDataLine;
	    PutWord(MaxNames);
	    PutString(': ');
	    PutQuote(name);
	    Flush;
	END;
    END;
END;

PROCEDURE HandleGRPDEF;
VAR
    grpName	: WORD;
    name	: NamePointer;
    typ		: BYTE;
    segIx	: WORD;
BEGIN
    PutRecAddr;
    PutString('GRPDEF ');
    
    grpName := GetIndex();
    name := GetName(grpName);
    AddGroupName(name^.name);
    PutWord(MaxGroups);
    PutString(': ');
    PutQuote(name^.name);
	
    Flush;
    
    WHILE RecCursor < RecordLength DO BEGIN
	typ := GetByte();
	segIx := GetIndex();
	name := GetSegName(segIx);

	StartDataLine;
	PutWord(segIx);
	PutString(': ');
	PutQuote(name^.name);
	Flush;
    END;
END;

PROCEDURE HandleSEGDEF;
CONST
    bigBit	= 1;
    use32Bit	= 0;
    
    AlignNames	: ARRAY [0..5] OF STRING[5] =
	('ABS  ', 'BYTE ', 'WORD ', 'PARA ', 'PAGE ', 'DWORD');
    CombineNames: ARRAY [0..7] OF STRING[8] =
	(
	 'PRIVATE',
	 'BOGUS  ',
	 'PUBLIC ',
	 'BOGUS  ',
	 'PUBLIC ',
	 'STACK  ',
	 'COMMON ',
	 'PUBLIC '
	);
VAR
    ACBP	: BYTE;
    segLen	: LONGINT;
    segName	: WORD;
    segClass	: WORD;
    ovrName	: WORD;
    combine	: BYTE;
    align	: BYTE;
    frame	: WORD;
    offset	: BYTE;
    big		: BOOLEAN;
    use32	: BOOLEAN;
    name	: NamePointer;
BEGIN
    PutRecAddr;
    IF RecordType = SEGD32 THEN
	PutString('SEGD32 ')
    ELSE
	PutString('SEGDEF ');
    
    ACBP := GetByte();
    
    align := ACBP SHR 5;
    combine := (ACBP SHR 2) AND 7;
    
    big := bigBit IN ByteSet(ACBP);
    use32 := use32Bit IN ByteSet(ACBP);
    
    IF align = 0 THEN BEGIN
	frame := GetWord();
	offset := GetByte();
    END;
    
    IF RecordType = SEGD32 THEN
	segLen := GetDword()
    ELSE
	segLen := GetWord();
	
    segName := GetIndex();
    segClass := GetIndex();
    ovrName := GetIndex();
    
    name := GetName(segName);
    AddSegName(name^.name);
	
    PutWord(MaxSegments);
    PutString(': ');
    PutQuote(name^.name);
    
    TabTo(38);

    name := GetName(segClass);
    PutQuote(name^.name);
    
    TabTo(50);

    IF use32 THEN
	PutString(' USE32');

    PutChar(' ');
    PutString(AlignNames[align]);
    PutChar(' ');
    PutString(CombineNames[combine]);
    PutChar(' ');
    
    IF RecordType = SEGD32 THEN
	PutLongHex(segLen)
    ELSE BEGIN
	IF (segLen = 0) AND big THEN
	    PutString('10000')
	ELSE
	    PutHex(segLen, 4);
    END;
    Flush;
END;

PROCEDURE DoPublics;
VAR
    groupIx	: WORD;
    segIx	: WORD;
    frameNum	: WORD;
    name	: NamePointer;
    pubName	: STRING;
    pubOffs	: LONGINT;
    pubTypeIx	: WORD;
BEGIN
    groupIx := GetIndex();
    segIx := GetIndex();
    
    IF (groupIx = 0) AND (segIx = 0) THEN BEGIN
	frameNum := GetWord();
	PutString('Frame=');
	PutWord(frameNum);
    END ELSE BEGIN
	PutString('Group=');
	IF groupIx <> 0 THEN BEGIN
	    name := GetGroupName(groupIx);
	    PutQuote(name^.name);
	END ELSE BEGIN
	    PutString('none');
	END;
	
	PutString(' Segment=');
	IF segIx <> 0 THEN BEGIN
	    name := GetSegName(segIx);
	    PutQuote(name^.name);
	END ELSE BEGIN
	    PutString('none');
	END;
    END;
    Flush;
    
    WHILE RecCursor < RecordLength DO BEGIN
	ReadName(pubName);
	
	IF RecordType AND 1 = 1 THEN
	    pubOffs := GetDword()
	ELSE
	    pubOffs := GetWord();
	    
	pubTypeIx := GetIndex();

	StartDataLine;
	PutQuote(pubName);
	TabTo(46);
	PutString('Offset=');
	
	IF RecordType AND 1 = 1 THEN
	    PutLongHex(pubOffs)
	ELSE
	    PutHex(pubOffs, 4);
	PutString(' TypeIx=');
	PutWord(pubTypeIx);
	Flush;
    END;
END;

PROCEDURE HandlePUBDEF;
BEGIN
    PutRecAddr;
    IF RecordType = PUBD32 THEN
	PutString('PUBD32 ')
    ELSE
	PutString('PUBDEF ');
    DoPublics;
END;

PROCEDURE HandleLPUBDEF;
BEGIN
    PutRecAddr;
    IF RecordType = LPUBD32 THEN
	PutString('LPUBD32 ')
    ELSE
	PutString('LPUBD32 ');
    DoPublics;
END;

PROCEDURE HandleCOMDEF;

    FUNCTION GetNum() : LONGINT;
    TYPE
	variant =
	    RECORD
		CASE BYTE OF
		0: (b0,b1,b2,b3 : BYTE);
		1: (w0,w1 : WORD);
		2: (l : LONGINT);
	    END;
    VAR
	v 	: variant;
	i	: BYTE;
    BEGIN
	v.l := 0;

	i := GetByte();

	IF i < $80 THEN BEGIN
	    v.b0 := i;
	    GetNum := v.l;
	    EXIT;
	END;
	
	v.w0 := GetWord();
	IF i = $84 THEN
	    v.b3 := GetByte()
	ELSE IF i = $88 THEN
	    v.w1 := GetWord()
	ELSE IF i <> $81 THEN BEGIN
	    ObjectError('bad COMDEF record');
	    v.l := 0;
	END;
	GetNum := v.l;
    END;

VAR
    comName	: STRING;
    comTypeIx	: WORD;
    nearFar	: BYTE;
    varSize	: LONGINT;
    elements	: LONGINT;
    elementSize	: LONGINT;
BEGIN
    PutRecAddr;
    PutString('COMDEF');
    Flush;
    
    IF NOT MicrosoftExtensions THEN BEGIN
	ObjectError('Microsoft extensions not declared for COMDEF');
	EXIT;
    END;
    
    WHILE RecCursor < RecordLength DO BEGIN
	ReadName(comName);
	comTypeIx := GetIndex();
	nearFar := GetByte();
	
	PutQuote(comName);
	IF nearFar = $61 THEN BEGIN (* FAR *)
	    elements := GetNum();
	    elementSize := GetNum();

	    PutString('  FAR, Elements');
	    PutLong(elements);
	    PutString(' ElementSize=');
	    PutLong(elementSize);
	END ELSE BEGIN
	    varSize := GetNum();

	    PutString(' NEAR, VariableSize=');
	    PutLong(varSize);
	END;
	PutString(' TypeIx=');
	PutWord(comTypeIx);
	Flush;
    END;
END;

PROCEDURE DoExternalNames;
VAR
    typeIndex	: WORD;
    name	: STRING;
BEGIN
    WHILE RecCursor < RecordLength DO BEGIN
	ReadName(name);
	AddExtName(name);
	typeIndex := GetIndex();

	StartDataLine;
	PutWord(MaxExtNames);
	PutString(': ');
	PutQuote(name);
	PutString(' TypeIx = ');
	PutWord(typeIndex);
	Flush;
    END;
END;

PROCEDURE HandleEXTDEF;
BEGIN
    PutRecAddr;
    PutString('EXTDEF');
    Flush;
    DoExternalNames;
END;

PROCEDURE HandleLEXTDEF;
BEGIN
    PutRecAddr;
    PutString('LEXTDEF');
    Flush;
    DoExternalNames;
END;

PROCEDURE HandleLINNUM;
VAR
    segIx	: WORD;
    groupIx	: WORD;
    lineNum	: ARRAY [1..5] OF WORD;
    lineOffs	: ARRAY [1..5] OF LONGINT;
    i		: WORD;
    j		: WORD;
    columns	: WORD;
    name	: NamePointer;
BEGIN
    PutRecAddr;
    IF RecordType = LINN32 THEN
	PutString('LINN32 ')
    ELSE
	PutString('LINNUM ');
    
    groupIx := GetByte();
    segIx := GetIndex();
    
    PutString('Segment=');
    name := GetSegName(segIx);
    PutQuote(name^.name);
    Flush;
    
    IF Detail THEN BEGIN
	columns := 5;
	IF RecordType = LINN32 THEN
	    columns := 4;
	    
	WHILE RecCursor < RecordLength DO BEGIN
	    i := 0;
	    WHILE (i <> columns) AND (RecCursor < RecordLength) DO BEGIN
		INC(i);
		lineNum[i] := GetWord();
		
		IF RecordType = LINN32 THEN
		    lineOffs[i] := GetDword()
		ELSE
		    lineOffs[i] := GetWord();
	    END;
	    
	    IF i <> 0 THEN
		StartDataLine;
	    FOR j := 1 TO i DO BEGIN
		PutWord(lineNum[j]);
		PutChar(':');
		
		IF RecordType = LINN32 THEN
		    PutLongHex(lineOffs[j])
		ELSE BEGIN
		    PutHex(lineOffs[j], 4);
		END;
		PutString('    ');
	    END;
	    IF i <> 0 THEN
		Flush;
	END;
    END;
END;

PROCEDURE HandleLEDATA;
VAR
    segIx	: WORD;
    offset	: LONGINT;
    name	: NamePointer;
BEGIN
    PutRecAddr;
    IF RecordType = LEDA32 THEN
	PutString('LEDA32 ')
    ELSE
	PutString('LEDATA ');
    
    segIx := GetIndex();
    
    IF RecordType = LEDA32 THEN
	offset := GetDword()
    ELSE
	offset := GetWord();
	
    name := GetSegName(segIx);
    PutString('Segment=');
    PutQuote(name^.name);
    PutString(' Offset=');
    IF RecordType = LEDA32 THEN
	PutLongHex(offset)
    ELSE
	PutHex(offset, 4);
    PutString(' Length=');
    PutHex(RecordLength-RecCursor, 3);
    Flush;
    
    IF Detail THEN
	DumpRecordAsHex;
END;

PROCEDURE HandleLIDATA;

    PROCEDURE DoIteratedData(level : WORD);
    VAR
	repCount	: LONGINT;
	blockCount	: WORD;
	dataBytes	: BYTE;
	foo		: BYTE;
	i		: WORD;
    BEGIN
	WHILE RecCursor < RecordLength DO BEGIN
	    IF RecordType = LIDA32 THEN
		repCount := GetDword()
	    ELSE
		repCount := GetWord();
		
	    blockCount := GetWord();
	    
	    StartDataLine;
	    FOR i := 1 TO level DO
		PutString('  ');
    
	    PutString('Repeat=');
	    IF RecordType = LIDA32 THEN
		PutLong(repCount)
	    ELSE
		PutWord(repCount);

	    IF blockCount <> 0 THEN BEGIN
		PutString(' BlockCount=');
		PutWord(blockCount);
		Flush;
		FOR i := 1 TO blockCount DO
		    DoIteratedData(level+1);
	    END ELSE BEGIN
		dataBytes := GetByte();
		PutString(' BlockSize=');
		PutWord(dataBytes);
		FOR i := 1 TO ORD(dataBytes) DO
		    dataBytes := GetByte();
		Flush;
	    END;
	END;
    END;
VAR
    segIx	: WORD;
    offset	: LONGINT;
    name	: NamePointer;
BEGIN
    PutRecAddr;
    IF RecordType = LIDA32 THEN
	PutString('LIDA32 ')
    ELSE
	PutString('LIDATA ');

    segIx := GetIndex();
    
    IF RecordType = LIDA32 THEN
	offset := GetDword()
    ELSE
	offset := GetWord();
	
    name := GetSegName(segIx);
    PutString('Segment=');
    PutQuote(name^.name);
    PutString(' Offset=');

    IF RecordType = LIDA32 THEN
	PutLongHex(offset)
    ELSE
	PutHex(offset, 4);

    Flush;
    
    IF Detail THEN
	DoIteratedData(0);
END;

PROCEDURE HandleFIXUPP;
CONST
    pBit	= 2;
    tBit	= 3;
    fBit	= 7;
    
    locNames	: ARRAY [0..5] OF STRING[9] =
	(
	 'LowByte  ',
	 'Offset   ',
	 'Segment  ',
	 'Pointer  ',
	 'HighByte ',
	 'LoadOffs '
	);
    modes	: ARRAY [BOOLEAN] OF STRING[4] = ('Self', 'Seg ');
    
VAR
    b		: BYTE;
    segmentRel	: BOOLEAN;
    
    loc		: WORD;
    fixOffset	: WORD;
    
    frameIx	: WORD;
    targIx	: WORD;
    frameMethod	: WORD;
    targMethod	: WORD;
    targOffset	: LONGINT;
    
    threadNum	: WORD;
    
    fname	: STRING[80];
    tname	: STRING[80];
    name	: NamePointer;
BEGIN
    PutRecAddr;
    IF RecordType = FIXU32 THEN
	PutString('FIXU32')
    ELSE
	PutString('FIXUPP');
    Flush;
    
    WHILE RecCursor < RecordLength DO BEGIN
	IF 7 IN ByteSet(RecData[RecCursor]) THEN BEGIN (* fixup *)
	    INC(FixupNumber);
	    
	    b := GetByte();

	    segmentRel := 6 IN ByteSet(b);

	    loc := (b SHR 2) AND 7;

	    Bytes(fixOffset)[1] := b AND 3;
	    Bytes(fixOffset)[0] := GetByte();
	    
	    b := GetByte();
	    
	    frameMethod := (b SHR 4) AND 7;
	    IF fBit IN ByteSet(b) THEN BEGIN
		frameMethod := frameMethod AND 3 + 4;
		frameIx := Threads[frameMethod].data;
		frameMethod := Threads[frameMethod].method;
	    END;
	    
	    targMethod := b AND 3;
	    IF tBit IN ByteSet(b) THEN BEGIN
		targIx := Threads[targMethod].data;
		targMethod := Threads[targMethod].method AND 3;
	    END;
	    
	    targOffset := 0;
	    
	    StartDataLine;

	    PutString('FIX ');
	    PutHex(fixOffset, 3);

	    PutString(' Mode=');
	    PutString(Modes[SegmentRel]);

	    PutString(' Location=');
	    PutString(LocNames[loc]);
	    
	    CASE frameMethod OF
		0:
		BEGIN
		    IF NOT (fBit IN ByteSet(b)) THEN
			frameIx := GetIndex();
		    
		    name := GetSegName(frameIx);
		    fname := '"' + name^.name + '"';
		END;
		1:
		BEGIN
		    IF NOT (fBit IN ByteSet(b)) THEN
			frameIx := GetIndex();

		    name := GetGroupName(frameIx);
		    fname := '"' + name^.name + '"';
		END;
		2:
		BEGIN
		    IF NOT (fBit IN ByteSet(b)) THEN
			frameIx := GetIndex();

		    name := GetExtName(frameIx);
		    fname := '"' + name^.name + '"';
		END;
		3:
		    fname := '????';
		4:
		    fname := 'LOCATION';
		5:
		    fname := 'TARGET';
	    ELSE
		fname := 'SHIT';
	    END;
	    
	    
	    IF NOT (tBit IN ByteSet(b)) THEN
		targIx := GetIndex();

	    IF NOT (pBit IN ByteSet(b)) THEN BEGIN
		IF RecordType = FIXU32 THEN
		    targOffset := GetDword()
		ELSE
		    targOffset := GetWord();
	    END;

	    CASE targMethod OF
		0,4:
		BEGIN
		    name := GetSegName(targIx);
		    tname := '"' + name^.name + '"';
		END;
		1,5:
		BEGIN
		    name := GetGroupName(targIx);
		    tname := '"' + name^.name + '"';
		END;
		2,6:
		BEGIN
		    name := GetExtName(targIx);
		    tname := '"' + name^.name + '"';
		END;
		3,7:
		    tname := '????';
	    ELSE
		tname := 'SHIT';
	    END;
	    
	    IF targOffset <> 0 THEN BEGIN
		PutString('Disp=');
		
		IF RecordType = FIXU32 THEN
		    PutLongHex(targOffset)
		ELSE
		    PutHex(targOffset, 4);
	    END;

	    PutString(' N=');
	    PutWord(FixupNumber);

	    Flush;

	    StartDataLine;
	    PutString('    ');

	    PutString('FRAME=');
	    PutString(fname);
	    TabTo(34);
	    PutString('TARGET=');
	    PutString(tname);
	    Flush;
	END ELSE BEGIN
	    b := GetByte();
	    threadNum := WORD(b MOD 4);
	    IF 6 IN ByteSet(b) THEN
		threadNum := ThreadNum + 4;

	    StartDataLine;
	    PutString('THREAD: ');
	    IF threadNum > 3 THEN
		PutString(' FRAME[')
	    ELSE
		PutString('TARGET[');
	    PutWord(threadNum AND 3);
	    PutString('] = ');
	    
	    Threads[threadNum].method := WORD(b SHR 2 AND 7);
	    CASE Threads[threadNum].method OF
		0,4:
		BEGIN
		    Threads[threadNum].data := GetIndex();
		    name := GetSegName(Threads[threadNum].data);
		    tname := '"' + name^.name + '"';
		END;
		1,5:
		BEGIN
		    Threads[threadNum].data := GetIndex();
		    name := GetGroupName(Threads[threadNum].data);
		    tname := '"' + name^.name + '"';
		END;
		2,6:
		BEGIN
		    Threads[threadNum].data := GetIndex();
		    name := GetExtName(Threads[threadNum].data);
		    tname := '"' + name^.name + '"';
		END;
		3,7:
		BEGIN
		    Threads[threadNum].data := GetWord();
		    tname := 'EXPLICIT FRAME';
		END;
	    END;
	    
	    PutString(tname);
	    Flush;
	END;
    END;
END;

PROCEDURE HandleMODEND;
CONST
    mainModule		= 7;
    startAddress	= 6;
    relocate		= 0;
VAR
    modType : ByteSet;
BEGIN
    PutRecAddr;
    IF RecordType = MODE32 THEN
	PutString('MODE32 ')
    ELSE
	PutString('MODEND ');

    modType := ByteSet(RecData[RecCursor]);
    INC(RecCursor);
    IF 7 IN modType THEN
	PutString('Main Module');
    IF 6 IN modType THEN
	PutString(', Start');
    IF 0 IN modType THEN
	PutString(', Relocatable');
    Flush;
END;

PROCEDURE HandleCOMENT;
    PROCEDURE DoBorlandComents(class : WORD);
    BEGIN
	PutString('Borland COMENT records not yet implemented');
	Flush;
    END;

    PROCEDURE PutComentName(s : STRING);
    BEGIN
	PutString(s);
	PutChar('"');
	WHILE RecCursor < RecordLength DO BEGIN
	    PutChar(CHAR(RecData[RecCursor]));
	    INC(RecCursor);
	END;
	PutChar('"');
    END;
    
    PROCEDURE PutName(s : STRING);
    VAR
	l : WORD;
	i : WORD;
    BEGIN
	StartDataLine;
	PutString(s);
	l := GetByte();
	IF l = 0 THEN
	    PutString('SAME')
	ELSE BEGIN
	    PutChar('"');
	    FOR i := 1 TO l DO
		PutChar( CHAR(GetByte()) );
	    PutChar('"');
	END;
	Flush;
    END;

CONST
    purge	= 7;
    list	= 6;
    Ordinal	= 7;
    ResName	= 6;
    NoData	= 5;
VAR
    attrib	: BYTE;
    class	: BYTE;
    subClass	: BYTE;
    save	: BYTE;
    flag	: BYTE;
    w		: WORD;
BEGIN
    PutRecAddr;
    PutString('COMENT ');
    
    attrib := GetByte();

    IF 7 IN ByteSet(attrib) THEN
	PutString('No ');
    PutString('Purge,');

    IF 6 IN ByteSet(attrib) THEN
	PutString('No ');
    PutString('List,');

    class := GetByte();
    
    PutString('class = ');
    PutHex(class, 2);
    Flush;
    
    StartDataLine;
    save := Length(BuildLine);
    CASE class OF
    0:
	PutComentName('Compiler name ');
    1:
	PutComentName('Copyright notice ');
    $9E:
	PutString('DOSSEG');
    $9F:
	PutComentName('Default library ');
    $A0:
    BEGIN
	subClass := GetByte();
	IF subClass = 1 THEN BEGIN
	    flag := GetByte();
	    PutString('IMPDEF');
	    Flush;
	    
	    PutName('Internal name ');
	    PutName('  Module name ');
	    
	    IF flag <> 0 THEN BEGIN
		w := GetWord();
		StartDataLine;
		PutString(' Ordinal number=');
		PutWord(w);
	    END ELSE BEGIN
		PutName('Exported name ');
		BYTE(BuildLine[0]) := save;
	    END;
	END ELSE IF subClass = 2 THEN BEGIN
	    flag := GetByte();
	    PutString('EXPDEF');
	    Flush;
	    PutName('Exported name ');
	    PutName('Internal name ');

	    StartDataLine;
	    IF NOT (ResName IN ByteSet(flag)) THEN
		PutString('NOT ');
	    PutString('Resident');
	    Flush;
	    
	    StartDataLine;
	    IF Ordinal IN ByteSet(flag) THEN BEGIN
		w := GetWord();
		PutString(' Ordinal number=');
		PutWord(w);
	    END;
	END;
    END;
    $A1:
    BEGIN
	PutString('Microsoft OMF extensions');
	MicrosoftExtensions := TRUE;
    END;
    $A2:
	PutString('Linker Pass 2 start');
    $A3:
	PutComentName('LIBMOD ');
    $AD:
	PutComentName('Imported Module ');
    $DE:
        (* Stony Brook Pascal+ only *)
	PutString('SLVM record');
    $E0..$EE,
    $F5..$FA:
	DoBorlandComents(class);
    END;
    IF Length(BuildLine) <> save THEN
	Flush;
    BuildLine := '';
    
    IF Detail THEN BEGIN
	RecCursor := 0;
	DumpRecordAsHex;
    END;
END;

PROCEDURE HandleOBJNAM;
BEGIN
    PutRecAddr;
    PutString('OBJNAM');
    Flush;
END;

PROCEDURE HandleLOCSYM;
BEGIN
    PutRecAddr;
    PutString('LOCSYM');
    Flush;
END;

PROCEDURE HandleBAKPAT;
BEGIN
    PutRecAddr;
    PutString('BAKPAT');
    Flush;
END;


FUNCTION GetRecordHeader() : BOOLEAN;
VAR
    total : WORD;
BEGIN
    RecAddr := DiskAddr;

    Nibble(RecordType, 1);
    total := Count;
    Nibble(RecordLength, 2);
    total := total + Count;
    
    IF total <> 3 THEN BEGIN
	ObjectError('Unexpected end of file');
	GetRecordHeader := FALSE;
    END ELSE BEGIN
	GetRecordHeader := TRUE;
    END;
END;

FUNCTION FillRecordData() : BOOLEAN;
VAR
    total	: WORD;
    chk		: WORD;
    i		: WORD;
BEGIN
    FillRecordData := FALSE;
    RecCursor := 0;
    
    IF (RecordLength = 0) OR (RecordLength >= MaxRecSize) THEN BEGIN
	ObjectError('Record too large');
	EXIT;
    END;
    
    DEC(RecordLength);
    
    IF RecordLength > InBufSize THEN BEGIN
	Seek(InFile, Pos());
	BlockRead(InFile, RecData, RecordLength, Count);
	Position(FilePos(InFile));
    END ELSE
	Nibble(RecData, RecordLength);
    total := Count;
    Nibble(CheckSum, 1);
    total := total + Count;
    
    
    chk := RecordType;
    chk := chk + ORD(Bytes(RecordLength)[0]+1);
    chk := chk + ORD(Bytes(RecordLength)[1]);
    FOR i := 0 TO RecordLength-1 DO
	chk := chk + ORD(RecData[i]);
    chk := 256 - (chk MOD 256);
    IF (NOT Terse) AND (BYTE(chk) <> CheckSum) THEN BEGIN
	PutString('*** Checksum does not match data for following record ***');
	Flush;
    END;
    
    IF total <> RecordLength+1 THEN BEGIN
	ObjectError('Error reading object file');
	FillRecordData := FALSE;
    END ELSE BEGIN
	FillRecordData := TRUE;
    END;
END;

FUNCTION ProcessRecord() : BOOLEAN;
BEGIN
    ProcessRecord := FALSE;
    
    IF (NOT GetRecordHeader()) OR (NOT FillRecordData()) THEN
	EXIT;

    ProcessRecord := TRUE;

    RecCursor := 0;
    CASE RecordType OF
	THEADR:
	    HandleTHEADR;
	LNAMES:
	    HandleLNAMES;
	SEGDEF, SEGD32:
	    HandleSEGDEF;
	GRPDEF:
	    HandleGRPDEF;
	PUBDEF,PUBD32:
	    HandlePUBDEF;
	LPUBDEF,LPUBD32:
	    HandleLPUBDEF;
	COMDEF:
	    HandleCOMDEF;
	EXTDEF:
	    HandleEXTDEF;
	LEXTDEF:
	    HandleLEXTDEF;
	LINNUM,LINN32:
	    HandleLINNUM;
	LEDATA,LEDA32:
	    HandleLEDATA;
	LIDATA,LIDA32:
	    HandleLIDATA;
	FIXUPP,FIXU32:
	    HandleFIXUPP;
	MODEND,MODE32:
	BEGIN
	    HandleMODEND;
	    ProcessRecord := FALSE;
	END;
	COMENT:
	    HandleCOMENT;
	OBJNAM:
	    HandleOBJNAM;
	LOCSYM:
	    HandleLOCSYM;
	BAKPAT1,BAKPAT2:
	    HandleBAKPAT;
    ELSE
	ObjectError('Bad record type ');
	ProcessRecord := FALSE;
    END;
    
    (*
    IF Detail AND (RecordType <> LEDATA) THEN BEGIN
	RecCursor := 0;
	DumpRecordAsHex;
    END;
    *)
END;

FUNCTION EatRecord() : BOOLEAN;
BEGIN
    EatRecord := FALSE;
    
    IF (NOT GetRecordHeader()) OR (NOT FillRecordData()) THEN
	EXIT;

    EatRecord := TRUE;

    CASE RecordType OF
	THEADR:;
	LNAMES:;
	SEGDEF:;
	GRPDEF:;
	PUBDEF:;
	LPUBDEF:;
	COMDEF:;
	EXTDEF:;
	LEXTDEF:;
	LINNUM:;
	LEDATA:;
	LIDATA:;
	FIXUPP:;
	MODEND: EatRecord := FALSE;
	COMENT:;
	OBJNAM, LOCSYM:;
    ELSE
	ObjectError('Bad record type ');
	EatRecord := FALSE;
    END;
END;

PROCEDURE ProcessObjectModule;
VAR
    name : NamePointer;
    next : NamePointer;
BEGIN
    name := FirstName;
    WHILE name <> NIL DO BEGIN
	next := name^.next;
	FreeMem(name, 5+Length(name^.name));
	name := next;
    END;

    name := FirstExtName;
    WHILE name <> NIL DO BEGIN
	next := name^.next;
	FreeMem(name, 5+Length(name^.name));
	name := next;
    END;

    name := FirstGroupName;
    WHILE name <> NIL DO BEGIN
	next := name^.next;
	FreeMem(name, 5+Length(name^.name));
	name := next;
    END;

    name := FirstSegName;
    WHILE name <> NIL DO BEGIN
	next := name^.next;
	FreeMem(name, 5+Length(name^.name));
	name := next;
    END;

    FirstName := NIL;
    FirstExtName := NIL;
    FirstGroupName := NIL;
    FirstSegName := NIL;
    MaxNames := 0;
    MaxExtNames := 0;
    MaxGroups := 0;
    MaxSegments := 0;
    MicrosoftExtensions := FALSE;
    FixupNumber := 0;
    
    IF NOT FillRecordData() THEN
	EXIT;
    
    HandleTHEADR;
    IF Terse THEN
	WHILE EatRecord() DO
    ELSE
	WHILE ProcessRecord() DO;
END;

PROCEDURE FormattedOBJ;
BEGIN
    ModuleAddr := 0;
    
    IF (NOT GetRecordHeader()) OR (RecordType <> THEADR) THEN BEGIN
	WriteLn('Not an Object file');
	EXIT;
    END;
    
    ProcessObjectModule;
END;

FUNCTION StartModule() : LONGINT;
BEGIN
    Padding := 0;
    IF (DiskAddr MOD Modulus) <> 0 THEN BEGIN
	Padding := Modulus-(DiskAddr MOD Modulus);
	Nibble(RecData, Padding);
    END;
    StartModule := DiskAddr;
END;

PROCEDURE PutSeparator;
BEGIN
    PutString('; +');
    Flush;
    PutString('; --------------- ');
    PutWord(Padding);
    Flush;
    PutString('; -');
    Flush;
END;

PROCEDURE FormattedLIB;
VAR
    b : BYTE;
    w : WORD;
    l : LONGINT;
BEGIN
    Nibble(b, 1);
    IF b <> LIBHDR THEN BEGIN
	WriteLn('Not a object library file');
	EXIT;
    END;
    
    Nibble(w, 2);
    Modulus := w + 3;
    
    Nibble(DictionaryAddr, 4);
    Nibble(DictionarySize, 2);
    Nibble(LibFlags, 1);
    
    PutString('Dictionary address = ');
    PutLongHex(DictionaryAddr);
    Flush;
    PutString('Dictionary size    = ');
    PutWord(DictionarySize);
    Flush;
    PutString('Library modulus    = ');
    PutWord(Modulus);
    Flush;
    
    IF (1 AND LibFlags) = 1 THEN
	PutString('Library case       = sensitive')
    ELSE
	PutString('Library case       = insensitive');
    Flush;
    BlankLine(2);
    
    REPEAT
	ModuleAddr := StartModule();
	IF NOT GetRecordHeader() THEN
	    EXIT;
	
	IF RecordType = THEADR THEN BEGIN
	    IF (NOT Terse) AND (ModuleAddr <> Modulus) THEN
		PutSeparator;
	    ProcessObjectModule;
	END ELSE IF RecordType <> LIBEND THEN BEGIN
	    ObjectError('Bad library file');
	    EXIT;
	END;
    UNTIL RecordType = LIBEND;
END;

BEGIN
    Detail := FALSE;
    Terse := FALSE;
    FirstName := NIL;
    FirstExtName := NIL;
    FirstGroupName := NIL;
    FirstSegName := NIL;
END.
