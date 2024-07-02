MODULE main;

FROM Terminal IMPORT WriteString, WriteLn;
FROM SYSTEM   IMPORT ADR;

FROM c IMPORT
   IntegerProcedure, 
   StringProcedure1, 
   StringProcedure2, 
   extInt;

VAR
 local : INTEGER;
 modulastring : ARRAY [0..50] OF CHAR;
 
BEGIN
  local := 10;
  modulastring := "String declared in Modula-2, length 39";

  WriteString("Start in Modula-2");WriteLn;
  IntegerProcedure(extInt);
  IntegerProcedure(local);
  
  StringProcedure1(modulastring);
  StringProcedure2(ADR(modulastring));
  
  WriteString("End in Modula-2");WriteLn;
END main.