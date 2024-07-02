IMPLEMENTATION MODULE Mod;

  FROM Terminal IMPORT WriteLn, WriteString;
  FROM InOut    IMPORT WriteInt;

PROCEDURE IntegerProcedure(x : INTEGER);
VAR local : INTEGER;
BEGIN
  local := x;
  WriteString("IntegerProcedure, param : ");
  WriteInt(x,5);
  WriteLn;
  WriteString("                  local : ");
  WriteInt(local,5);
  WriteLn;
END IntegerProcedure;

PROCEDURE StringProcedure1(s : ARRAY OF CHAR);
BEGIN
  WriteString("StringProcedure1, param : ");
  WriteString(s);
  WriteLn;
END StringProcedure1;


MODULE LocalModule[1];

IMPORT WriteString, WriteLn, StringPointer;
EXPORT StringProcedure2, localdata;

VAR localdata : INTEGER;

PROCEDURE LocalProcedure(s : ARRAY OF CHAR) : INTEGER;
VAR localvar : INTEGER;
BEGIN
  WriteString("LocalProcedure, param : ");
  WriteString(s);
  WriteLn;
  localvar := 12;
  RETURN localvar;
END LocalProcedure;

PROCEDURE StringProcedure2(p : StringPointer);
BEGIN
  WriteString("StringProcedure2, param : ");
  WriteString(p^);
  WriteLn;
END StringProcedure2;

BEGIN
  localdata := LocalProcedure("Init of local module");
END LocalModule;

BEGIN
  extInt := 10;
  WriteString("Init of Mod,  extInt    : ");
  WriteInt(extInt,5); WriteLn;
  WriteString("              localdata : ");
  WriteInt(localdata,5); WriteLn;
END Mod.
