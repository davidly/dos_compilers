UNIT DumpExe;

INTERFACE

CONST
    ExeSig	=  ORD('Z')*256 + ORD('M');
TYPE
    ExeHeader =
	RECORD
	sig		: WORD;
	modlength	: WORD;
	length		: WORD;
	fixups		: WORD;
	headersize	: WORD;
	minalloc	: WORD;
	maxalloc	: WORD;
	ss		: WORD;
	sp		: WORD;
	checksum	: WORD;
	ip		: WORD;
	cs		: WORD;
	reloc		: WORD;
	overlay		: WORD;
	fill		: WORD;
	END;

PROCEDURE FormattedEXE;

IMPLEMENTATION

Uses Disk, Put, DumpOMF, DumpCV, DumpTd;

PROCEDURE StartDataLine;
BEGIN
    TabTo(4);
END;

PROCEDURE FormattedEXE;
TYPE
    tableEntry	=
	RECORD
	offset	: WORD;
	segment	: WORD;
	END;
    vovlHeader	=
	RECORD
	ovlSig		: ARRAY [0..1] OF CHAR; (* SB *)
	ovlSize		: LONGINT;
	ovlCount	: WORD;
	firstThunkSeg	: WORD;
	ovlGlobalOpts	: WORD;
	reserved1	: WORD;
	reserved2	: WORD;
	END;
    thunkHeader	=
	RECORD
	attr		: BYTE;			(* 0 *)
	farCall		: BYTE;			(* 1 *)
	ovlMgrEntry	: POINTER;		(* 2 *)
	status		: BYTE;			(* 6 *)
	nearCall	: BYTE;			(* 7 *)
	thunkCount	: WORD;			(* 8 *)
	retIP		: WORD;			(* 10 *)
	filePos		: LONGINT;		(* 12 *)
	codeSize	: WORD;			(* 16 *)
	fixupSize	: WORD;			(* 18 *)
	nextThunkSeg	: WORD;			(* 20 *)
	ovlRunSeg	: WORD;			(* 22 *)
	emsPageOffs	: WORD;			(* 24 *)
	emsPageRecSeg	: WORD;			(* 26 *)
	reserved1	: WORD;			(* 28 *)
	reserved2	: WORD;			(* 30 *)
	END;

VAR
    i		: WORD;
    j		: WORD;
    remaining	: WORD;
    exeImage	: LONGINT;
    loadSize	: LONGINT;
    extraSize	: LONGINT;
    headerSize	: LONGINT;
    fileLength	: LONGINT;
    header	: ExeHeader;
    vHeader	: vovlHeader;
    thunk	: thunkHeader;
    table	: ARRAY [1..5] OF tableEntry;
BEGIN
    Nibble(header, SizeOf(header));
    
    IF (Count <> SizeOf(header)) OR (header.sig <> ExeSig) THEN BEGIN
	WriteLn('Not a DOS EXE file');
	EXIT;
    END;
    
    fileLength := FileSize(InFile);
    
    DEC(header.length);

    exeImage := LONGINT(header.length)*512 + LONGINT(header.modlength);
    headerSize := LONGINT(header.headerSize)*16;
    loadSize := exeImage - headerSize;
    extraSize := LONGINT(header.minalloc)*16;
    
    PutString('load size      = ');
    PutLong(loadSize);
    Flush;

    PutString('image size     = ');
    PutLong(loadSize+extraSize);
    Flush;

    PutString('header size    = ');
    PutLong(headerSize);
    Flush;

    PutString('segment fixups = ');
    PutWord(header.fixups);
    Flush;

    PutString('MINALLOC       = ');
    PutLong(extraSize);
    Flush;

    PutString('MAXALLOC       = ');
    PutLong(LONGINT(header.maxalloc)*16);
    Flush;

    PutString('SS:SP          = ');
    PutHex(header.ss, 4);
    PutChar(':');
    PutHex(header.sp, 4);
    Flush;

    PutString('CS:IP          = ');
    PutHex(header.cs, 4);
    PutChar(':');
    PutHex(header.ip, 4);
    Flush;
    
    IF Detail THEN BEGIN
	BlankLine(2);
	
	Position(header.reloc);
	i := 0;
	WHILE i < header.fixups DO BEGIN
	    remaining := header.fixups - i;
	    IF remaining > 5 THEN
		remaining := 5;
	    Nibble(table, 4*remaining);
	    StartDataLine;
	    FOR j := 1 TO remaining DO BEGIN
		PutHex(table[j].segment, 4);
		PutChar(':');
		PutHex(table[j].offset, 4);
		PutString('    ');
	    END;
	    Flush;
	    i := i + 4;
	END;
    END;
    
    (* look for virtual overlays and debug information *)
    
    IF fileLength > exeImage THEN BEGIN

	(* first look for debug info *)
	
	IF GetCvVersion() THEN BEGIN
	    BlankLine(2);
	    PutString('*** CodeView debug information present ***');
	    Flush;
	END ELSE IF TdPresent() THEN BEGIN
	    BlankLine(2);
	    PutString('*** Turbo debugger information present ***');
	    Flush;
	END;
	
	(* now look for virtual overlays *)
	
	exeImage := exeImage + ((16 - exeImage MOD 16) MOD 16);
	Position(exeImage);
	
	Nibble(vHeader, SizeOf(vHeader));
	IF Count <> SizeOf(vHeader) THEN
	    EXIT;
	
	IF (vHeader.ovlSig[0] = 'S') AND (vHeader.ovlSig[1] = 'B') THEN BEGIN
	    BlankLine(2);
	    PutString('*** Virtual overlays present ***');
	    Flush;
	    BlankLine(1);
	    PutString('Number of overlays = ');
	    PutWord(vHeader.ovlCount);
	    Flush;
	    PutString('  Size of overlays = ');
	    PutLong(vHeader.ovlSize);
	    Flush;
	    
	    PutString('         EMS usage = ');
	    IF (3 AND vHeader.ovlGlobalOpts) = 3 THEN
		PutString('NOEMS')
	    ELSE IF (1 AND vHeader.ovlGlobalOpts) = 1 THEN
		PutString('NOEMSRUN')
	    ELSE
		PutString('RUN IN EMS');
	    Flush;
	    
	    i := 0;
	    thunk.nextThunkSeg := vHeader.firstThunkSeg;
	    REPEAT
		INC(i);
		Position(headerSize+(thunk.nextThunkSeg*16));
		Nibble(thunk, SizeOf(thunk));
		
		BlankLine(1);
		PutString('Overlay number = ');
		PutWord(i);
		Flush;
		
		PutString('     EMS usage = ');
		IF (3 AND thunk.attr) = 3 THEN
		    PutString('NOEMS')
		ELSE IF (1 AND thunk.attr) = 1 THEN
		    PutString('NOEMSRUN')
		ELSE
		    PutString('RUN IN EMS');
		Flush;
    
		PutString('Vectored calls = ');
		PutWord(thunk.thunkCount);
		Flush;
		
		PutString('     Code size = ');
		PutWord(thunk.codeSize);
		Flush;

		PutString('   Fixups size = ');
		PutWord(thunk.fixupSize);
		Flush;

		PutString(' File position = ');
		PutLongHex(thunk.filePos);
		PutChar('H');
		Flush;
	    UNTIL thunk.nextThunkSeg = 0;
	END;
    END;
END;

END.
