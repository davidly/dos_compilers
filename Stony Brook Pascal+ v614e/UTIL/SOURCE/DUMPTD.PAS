UNIT DumpTD;
(*$//NOMODINIT*)

INTERFACE

FUNCTION TdPresent() : BOOLEAN;

IMPLEMENTATION

USES Dos, Disk, DumpEXE;

FUNCTION TdPresent() : BOOLEAN;
VAR
    header	: ExeHeader;
    fileEnd	: LONGINT;
    tdSig	: WORD;
BEGIN
    TdPresent := FALSE;
    
    Seek(InFile, 0);
    BlockRead(InFile, header, SizeOf(header), Count);
    IF (Count <> SizeOf(header)) OR (header.sig <> ExeSig) THEN
	EXIT;
    
    DEC(header.length);
    fileEnd := LONGINT(header.length)*512 + LONGINT(header.modlength);
    
    IF FileSize(InFile) > fileEnd THEN BEGIN
	Seek(InFile, fileEnd);
	BlockRead(InFile, tdSig, 2);
	IF tdSig <> $52FB THEN
	    EXIT;
	TdPresent := TRUE;
    END;
END;

END.
