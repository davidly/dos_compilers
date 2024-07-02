MODULE PtDemo;

FROM Terminal IMPORT WriteString, WriteLn;

PROCEDURE Hello (str : ARRAY OF CHAR);
VAR i : CARDINAL;
BEGIN
  FOR i := 1 TO 10 DO
    WriteString(str);
    WriteLn;
  END
END Hello

BEGIN
  Hello("Hello Everybody"," !!!")
END PtDemo.
  
