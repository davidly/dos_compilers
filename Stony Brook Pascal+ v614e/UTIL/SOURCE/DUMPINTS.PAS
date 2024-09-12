UNIT DumpIntSym;

INTERFACE

PROCEDURE FormattedIntSym;

IMPLEMENTATION


USES Disk, Put;

TYPE
    header =
	RECORD
	lang	: ARRAY [0..2] OF CHAR;
	version	: BYTE;
	TkInvalid	: BYTE; (* language dependent *)
	dt	: ARRAY [0..1] OF WORD;
	regPos	: LONGINT;	(* reg param pass info *)
	impNames: LONGINT;	(* Modula-2 Implementation inports *)
	hasFPP	: BOOLEAN;
	init	: BOOLEAN;
	check	: BOOLEAN;
	dataM	: BYTE;
	stackSS	: BOOLEAN;
	codeM	: BYTE;
	constM	: BYTE;
	END;

CONST
    Model : ARRAY [0..2] OF STRING[8] = 
	(
	 'SMALL',
	 'MEDIUM',
	 'LARGE'
	);
VAR
    h	: header;

PROCEDURE WriteDT;
VAR
    name	: STRING;
    
    PROCEDURE AppendChar(ch : CHAR);
    BEGIN
	INC(BYTE(name[0]));
	name[ORD(name[0])] := ch;
    END;
    
    PROCEDURE AppendNum(n : WORD);
    VAR
	d	: WORD;
    BEGIN
	d := 10000;
	WHILE (d > n) AND (d > 1) DO
	    d := d DIV 10;
	REPEAT
	    AppendChar(CHR(n DIV d MOD 10 + ORD('0')));
	    d := d DIV 10;
	UNTIL d = 0;
    END;
    
BEGIN
    name := '';
    
    AppendNum(h.dt[1] DIV 32 MOD 16);
    AppendChar('_');
    AppendNum(h.dt[1] MOD 32);
    AppendChar('_');
    AppendNum(h.dt[1] DIV 512 + 1980);
    AppendChar('_');
    AppendNum(h.dt[0] DIV 2048);
    AppendChar('_');
    AppendNum(h.dt[0] DIV 32 MOD 64);
    AppendChar('_');
    AppendNum(h.dt[0] MOD 32 * 2);
    
    PutString('Date/Time = ');
    PutString(name);
    Flush;
END;

PROCEDURE FormattedIntSym;
TYPE
    Register = (AX, CX, DX, BX, SP, BP, SI, DI, 
		ES, CS, SS, DS, NoReg);
TYPE
    RegisterSet = SET OF Register;
CONST
    RegNames : ARRAY [Register] OF STRING[2] =
	('AX','CX','DX','BX','SP','BP','SI','DI','ES','CS','SS','DS','');
VAR
    s	: STRING;
    b	: CHAR;
    w	: WORD;
    i	: WORD;
    l	: WORD;
    reg	: Register;
    reg1: Register;
    alt	: RegisterSet;
    name: STRING;
BEGIN
    BlockRead(InFile, h, SizeOf(h));
    
    IF (h.lang[0] = 'I') AND (h.lang[1] = 'N') AND (h.lang[2] = 'T') THEN
	PutString('Pascal interface file')
    ELSE IF (h.lang[0] = 'S') AND (h.lang[1] = 'Y') AND (h.lang[2] = 'M') THEN
	PutString('Modula-2 symbol file')
    ELSE BEGIN
	PutString('Not a Stony Brook symbol file');
	Flush;
	EXIT;
    END;
    Flush;
    
    PutString('Version = ');
    PutWord(h.version);
    Flush;
    
    WriteDT;
    
    PutString('Reg param pos = ');
    PutLong(h.regPos);
    Flush;

    PutString('IMP names pos = ');
    PutLong(h.impNames);
    Flush;
    
    IF h.hasFPP THEN
	PutString('Has FPP code')
    ELSE
	PutString('No FPP code');
    Flush;
    
    IF h.init THEN
	PutString('Has init code')
    ELSE
	PutString('No init code');
    Flush;

    IF h.check THEN
	PutString('Allow Module checking')
    ELSE
	PutString('Disallow module checking');
    Flush;

    PutString('Code = ');
    PutString(Model[h.codeM]);
    Flush;
    PutString('Data = ');
    PutString(Model[h.dataM]);
    Flush;
    PutString('Const = ');
    PutString(Model[h.constM]);
    Flush;
    
    IF h.stackSS THEN
	PutString('SS <> DS')
    ELSE
	PutString('SS = DS');
    Flush;
    
    IF Detail THEN BEGIN
	IF h.impNames <> 0 THEN BEGIN
	    PutString('IMPLEMENTATION IMPORTS');
	    Flush;
	    
	    Position(h.impNames);
	    REPEAT
		Nibble(b, 1);
		IF b <> #0 THEN BEGIN
		    i := 1;
		    REPEAT
			IF i <= 255 THEN BEGIN
			    BYTE(s[0]) := i;
			    s[i] := b;
			    INC(i);
			END;
			Nibble(b, 1);
		    UNTIL b = #0;
		    PutString('    ');
		    PutString(s);
		    Flush;
		    b := #1;
		END;
	    UNTIL b = #0;
	END;
	
	IF h.regPos <> 0 THEN BEGIN
	    PutString('Register Param Pass info');
	    Flush;
	    
	    Position(h.regPos);
	    Nibble(b, 1);
	    IF b = #2 THEN BEGIN
		Nibble(b, 1);
		REPEAT
		    l := ORD(b);
		    
		    FOR i := 1 TO l DO BEGIN
			Nibble(b, 1);
			name[i] := b;
		    END;
		    BYTE(name[0]) := l;
		    PutString(name);
		    Flush;
		    PutString('  (');
		    
		    Nibble(b, 1);
		    
		    Nibble(b, 1);
		    l := ORD(b);
		    FOR i := 1 TO l DO BEGIN
			Nibble(reg, 1);
			Nibble(reg1, 1);
			IF reg <> NoReg THEN BEGIN
			    IF reg1 <> NoReg THEN BEGIN
				PutString(RegNames[reg1]);
				PutChar(':');
			    END;
			    PutString(RegNames[reg]);
			END;
			IF i <> l THEN
			    PutChar(',');
		    END;
		    PutChar(')');
		    Flush;
		    
		    Nibble(w, 2);
		    PutString('   ProcLabel ');
		    PutWord(w);
		    Flush;
		    
		    PutString('   Altered regs ');
		    Nibble(alt, 2);
		    FOR reg := AX TO NoReg DO BEGIN
			IF reg IN alt THEN BEGIN
			    PutString(RegNames[reg]);
			    PutChar(' ');
			END;
		    END;
		    Flush;
		    
		    Nibble(b, 1);
		UNTIL EndOfFile;
	    END;
	END;
    END;
END;

END.
