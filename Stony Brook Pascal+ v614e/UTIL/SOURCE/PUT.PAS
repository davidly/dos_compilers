UNIT Put;

INTERFACE

CONST
    Printable	: SET OF CHAR = [#32..#126, #128..#156, #160..#167];
    HexDig	: ARRAY [0..15] OF CHAR = '0123456789ABCDEF';
TYPE
    HexString	= STRING[8];
VAR
    OutBuf	: ARRAY [0..4095] OF CHAR;
    IsConsole	: BOOLEAN;
    Pause	: BOOLEAN;
    ScreenLines	: WORD;
    CurrentLine	: WORD;
    BuildLine	: STRING;
    
    Detail	: BOOLEAN;
    
PROCEDURE Wait;

PROCEDURE Flush;

PROCEDURE BlankLine(num : WORD);

PROCEDURE PutChar(ch : CHAR);

PROCEDURE PutString(s : STRING);

PROCEDURE PutQuote(s : STRING);

PROCEDURE ConvertHex(li : LONGINT; size : WORD; VAR s : HexString);

PROCEDURE PutHex(num, size : WORD);

PROCEDURE PutLongHex(num : LONGINT);

PROCEDURE PutAddress(num : LONGINT);

PROCEDURE PutWord(num : WORD);

PROCEDURE PutLong(num : LONGINT);

PROCEDURE TabTo(tabPos : WORD);

IMPLEMENTATION

USES Dos;

TYPE
    Words	= ARRAY [0..1] OF WORD;

PROCEDURE Wait;
VAR
    R : REGISTERS;
BEGIN
    INC(CurrentLine);
    IF Pause AND IsConsole AND (CurrentLine = ScreenLines) THEN BEGIN
	CurrentLine := 0;
	Write('-- Press any key --');
	R.AH := 8;
	INTR($21, R);
	Write(#13'                   '#13);
    END;
END;

PROCEDURE Flush;
BEGIN
    WriteLn(BuildLine);
    BuildLine := '';
    Wait;
END;

PROCEDURE BlankLine(num : WORD);
VAR
    i : WORD;
BEGIN
    FOR i := 1 TO num DO BEGIN
	WriteLn;
	Wait;
    END;
END;

PROCEDURE PutChar(ch : CHAR);
BEGIN
    INC(BuildLine[0]);
    BuildLine[ ORD(BuildLine[0]) ] := ch;
END;

PROCEDURE PutString(s : STRING);
BEGIN
    BuildLine := BuildLine +  s;
END;

PROCEDURE PutQuote(s : STRING);
BEGIN
    PutChar('"');
    PutString(s);
    PutChar('"');
END;

PROCEDURE ConvertHex(li : LONGINT; size : WORD; VAR s : HexString);
VAR
    i	: WORD;
BEGIN
    BYTE(s[0]) := size;
    FOR i := size DOWNTO 1 DO BEGIN
	s[i] := HexDig[WORD(li) MOD 16];
	li := li SHR 4;
    END;
END;

PROCEDURE PutHex(num, size : WORD);
VAR
    s	: HexString;
BEGIN
    ConvertHex(num, size, s);
    PutString(s);
END;

PROCEDURE PutLongHex(num : LONGINT);
VAR
    s	: HexString;
BEGIN
    ConvertHex(num, 8, s);
    PutString(s);
END;

PROCEDURE PutAddress(num : LONGINT);
BEGIN
    PutHex(Words(num)[1], 4);
    PutChar(':');
    PutHex(Words(num)[0], 4);
END;

PROCEDURE PutWord(num : WORD);
VAR
    s	: STRING[5];
BEGIN
    Str(num, s);
    PutString(s);
END;

PROCEDURE PutLong(num : LONGINT);
VAR
    s	: STRING[10];
BEGIN
    Str(num, s);
    PutString(s);
END;

PROCEDURE TabTo(tabPos : WORD);
VAR
    i		: WORD;
    start	: WORD;
BEGIN
    IF Length(BuildLine) < tabPos THEN BEGIN
	start := Length(BuildLine)+1;
	BYTE(BuildLine[0]) := tabPos;
	FOR i := start TO tabPos DO
	    BuildLine[i] := ' ';
    END;
END;

BEGIN
    BuildLine := '';
    CurrentLine := 0;
    Pause := FALSE;
END.
