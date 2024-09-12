PROGRAM rendir;
{$M 4096, 0, 0}

USES Dos;

VAR
    FromDir, ToDir : PathStr;

PROCEDURE ParseCommandLine;
BEGIN
    IF ParamCount() <> 2 THEN BEGIN
	WriteLn('USAGE: rendir fromName toName');
	HALT;
    END;
    
    FromDir := ParamStr(1);
    ToDir := ParamStr(2);
END;

PROCEDURE Rename(fromFile, toFile : STRING);
VAR
    lstr1, lstr2 : STRING[80];
    r : REGISTERS;
BEGIN
    lstr1 := fromFile;
    lstr1[Length(lstr1)+1] := #0;
    lstr2 := toFile;
    lstr2[Length(lstr2)+1] := #0;
    r.AX := $5600;
    r.DS := Seg(lstr1[1]);
    r.DX := Ofs(lstr1[1]);
    r.ES := Seg(lstr2[1]);
    r.DI := Ofs(lstr2[1]);
    MsDos(r);
END;

BEGIN
    ParseCommandLine;
    
    IF (FromDir[2] = ':') OR (ToDir[2] = ':') THEN
	WriteLn('...cannot specify a drive...')
    ELSE BEGIN
	Rename(FromDir, ToDir);
	WriteLn('Renaming ', FromDir, ' >> ', ToDir);
    END;
END.

