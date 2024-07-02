program Grep2Msg;

{$I-,S-}

var
  LineNo, E: Word;
  Line: String;
  InputBuffer: array[0..4095] of Char;
  OutputBuffer: array[0..4095] of Char;

procedure WriteHeader;
begin
  Write('BI#PIP#OK'#0);
end;

procedure WriteNewFile(const FileName: String);
begin
  Write(#0, FileName, #0);
end;

procedure WriteMessage(Line, Col: Word; const Message: String);
begin
  Write(#1, Chr(Lo(Line)), Chr(Hi(Line)), Chr(Lo(Col)), Chr(Hi(Col)),
    Message, #0);
end;

procedure WriteEnd;
begin
  Write(#127);
end;

function TrimLeft(S:String): String;
var
  i: Integer;
  n: String;
begin
  i := 1;
  while (i <= Length(s)) and (s[i] = #32) do Inc(i);
  if i <= Length(s) then
  begin
    Move(s[i], n[1], Length(s) - i + 1);
    n[0] := Char(Length(s) - i + 1);
  end
  else n[0] := #0;
  TrimLeft := n;
end;

begin
  SetTextBuf(Input, InputBuffer);
  SetTextBuf(Output, OutputBuffer);
  WriteHeader;
  while not Eof do
  begin
    ReadLn(Line);
    if Line <> '' then
    begin
      if Copy(Line, 1, 5) = 'File ' then
        WriteNewFile(Copy(Line, 6, Length(Line) - 6))
      else
      begin
        Val(Copy(Line, 1, Pos(' ', Line) - 1), LineNo, E);
        if E = 0 then WriteMessage(LineNo, 1, TrimLeft(Copy(Line, 9, 132)));
      end;
    end;
  end;
  WriteEnd;
end.
