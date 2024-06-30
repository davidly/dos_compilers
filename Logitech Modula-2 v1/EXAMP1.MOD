MODULE Examp1;
  FROM Terminal IMPORT WriteString, WriteLn, Read;
  VAR ch: CHAR;
BEGIN
  WriteString('The program worked! (Hit a key)');
  WriteLn;
  Read(ch);
END Examp1.
