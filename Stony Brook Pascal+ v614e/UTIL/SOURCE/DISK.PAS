UNIT Disk;

INTERFACE

USES Dos;

CONST
    InBufSize	= 2048;
VAR
    InFile	: File;
    InFileName	: PathStr;
    InBuf	: ARRAY [0..InBufSize-1] OF BYTE;
    DiskAddr	: LONGINT;
    Bp		: WORD;
    Be		: WORD;
    Valid	: BOOLEAN;
    BufStart	: LONGINT;
    BufferSize	: WORD;

    Count	: WORD;
    EndOfFile	: BOOLEAN;

PROCEDURE Position(pos : LONGINT);

FUNCTION Pos() : LONGINT;

PROCEDURE Nibble(VAR it; size : WORD);


IMPLEMENTATION

PROCEDURE Position(pos : LONGINT);
BEGIN
    EndOfFile := FALSE;
    IF Valid AND (pos >= BufStart) AND (pos <= BufStart+Be) THEN
	Bp := pos-BufStart
    ELSE BEGIN
	BufStart := pos;
	Bp := 0;
	Be := 0;
	Valid := FALSE;
    END;
    DiskAddr := BufStart+Bp;
END;

FUNCTION Pos() : LONGINT;
BEGIN
    Pos := BufStart+Bp;
END;

PROCEDURE Gulp;
VAR
    res	: WORD;
BEGIN
    EndOfFile := FALSE;
    
    BufStart := BufStart + Be;
    Seek(InFile, BufStart);
    BlockRead(InFile, InBuf, BufferSize, Be);
    
    res := IOResult();
    IF (res <> 0) AND (res <> 100) THEN BEGIN
	WriteLn('!!! Disk read error !!!');
	HALT;
    END;
    
    IF Be = 0 THEN
	EndOfFile := TRUE;
    Bp := 0;
    Valid := NOT EndOfFile;
END;

PROCEDURE Nibble(VAR it; size : WORD);
VAR
    lbp	: WORD;
    i	: WORD;
    out	: ARRAY [0..InBufSize-1] OF BYTE ABSOLUTE it;
BEGIN
    Count := 0;

    IF Bp+size <= Be THEN BEGIN
	Move(InBuf[Bp], it, size);
	Bp := Bp + size;
	Count := size;
	DiskAddr := DiskAddr + LONGINT(size);
    END ELSE BEGIN
	lbp := Bp;
	i := 0;
	REPEAT
	    IF lbp = Be THEN BEGIN
		Gulp;
		lbp := 0;
	    END;
	    IF NOT EndOfFile THEN BEGIN
		out[i] := InBuf[lbp];
		INC(i);
		INC(lbp);
	    END;
	UNTIL (i = size) OR EndOfFile;
	Bp := lbp;
	Count := i;
	DiskAddr := DiskAddr + LONGINT(i);
    END;
END;

BEGIN
    Valid := FALSE;
    EndOfFile := FALSE;
    Bp := 0;
    Be := 0;
    DiskAddr := 0;
    BufStart := 0;
    BufferSize := SizeOf(InBuf);
END.
