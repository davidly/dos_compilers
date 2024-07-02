
{ Copyright (c) 1985, 88 by Borland International, Inc. }

unit MCPARSER;

interface

uses Crt, Dos, MCVars, MCUtil, MCDisply;

function CellValue(Col, Row : Word) : Real;
{ Finds the Value of a particular cell }

function Parse(S : String; var Att : Word) : Real;
{ Parses the string s - returns the Value of the evaluated string, and puts
   the attribute in Att: TXT = 0, CONSTANT = 1, FORMULA = 2, +4 = ERROR.
}

implementation

const
  PLUS = 0;
  MINUS = 1;
  TIMES = 2;
  DIVIDE = 3;
  EXPO = 4;
  COLON = 5;
  OPAREN = 6;
  CPAREN = 7;
  NUM = 8;
  CELLT = 9;
  FUNC = 10;
  EOL = 11;
  BAD = 12;
  MAXFUNCNAMELEN = 5;

type
  TokenRec = record
    State : Byte;
    case Byte of
      0 : (Value : Real);
      1 : (Row, Col : Word);
      2 : (FuncName : String[MAXFUNCNAMELEN]);
  end;

var
  Stack : array [1..PARSERSTACKSIZE] of TokenRec;
  CurToken : TokenRec;
  StackTop, TokenType : Word;
  MathError, TokenError, IsFormula : Boolean;
  Input : IString;

function IsFunc(S : String) : Boolean;
{ Checks to see if the start of the Input string is a legal function.
  Returns TRUE if it is, FALSE otherwise.
}
var
  Len : Word;
begin
  Len := Length(S);
  if Pos(S, Input) = 1 then
  begin
    CurToken.FuncName := Copy(Input, 1, Len);
    Delete(Input, 1, Len);
    IsFunc := True;
  end
  else
    IsFunc := False;
end; { IsFunc }

function NextToken : Word;
{ Gets the next Token from the Input stream }
var
  NumString : String[80];
  FormLen, Place, Len, NumLen, Check : Word;
  FirstChar : Char;
  Decimal : Boolean;
begin
  if Input = '' then
  begin
    NextToken := EOL;
    Exit;
  end;
  while (Input <> '') and (Input[1] = ' ') do
    Delete(Input, 1, 1);
  if Input[1] in ['0'..'9', '.'] then
  begin
    NumString := '';
    Len := 1;
    Decimal := False;
    while (Len <= Length(Input)) and
          ((Input[Len] in ['0'..'9']) or
           ((Input[Len] = '.') and (not Decimal))) do
    begin
      NumString := NumString + Input[Len];
      if Input[1] = '.' then
        Decimal := True;
      Inc(Len);
    end;
    if (Len = 2) and (Input[1] = '.') then
    begin
      NextToken := BAD;
      Exit;
    end;
    if (Len <= Length(Input)) and (Input[Len] = 'E') then
    begin
      NumString := NumString + 'E';
      Inc(Len);
      if Input[Len] in ['+', '-'] then
      begin
        NumString := NumString + Input[Len];
        Inc(Len);
      end;
      NumLen := 1;
      while (Len <= Length(Input)) and (Input[Len] in ['0'..'9']) and
            (NumLen <= MAXEXPLEN) do
      begin
        NumString := NumString + Input[Len];
        Inc(NumLen);
        Inc(Len);
      end;
    end;
    if NumString[1] = '.' then
      NumString := '0' + NumString;
    Val(NumString, CurToken.Value, Check);
    if Check <> 0 then
      MathError := True;
    NextToken := NUM;
    Delete(Input, 1, Length(NumString));
    Exit;
  end
  else if Input[1] in LETTERS then
  begin
    if IsFunc('ABS') or
       IsFunc('ATAN') or
       IsFunc('COS') or
       IsFunc('EXP') or
       IsFunc('LN') or
       IsFunc('ROUND') or
       IsFunc('SIN') or
       IsFunc('SQRT') or
       IsFunc('SQR') or
       IsFunc('TRUNC') then
    begin
      NextToken := FUNC;
      Exit;
    end;
    if FormulaStart(Input, 1, CurToken.Col, CurToken.Row, FormLen) then
    begin
      Delete(Input, 1, FormLen);
      IsFormula := True;
      NextToken := CELLT;
      Exit;
    end
    else begin
      NextToken := BAD;
      Exit;
    end;
  end
  else begin
    case Input[1] of
      '+' : NextToken := PLUS;
      '-' : NextToken := MINUS;
      '*' : NextToken := TIMES;
      '/' : NextToken := DIVIDE;
      '^' : NextToken := EXPO;
      ':' : NextToken := COLON;
      '(' : NextToken := OPAREN;
      ')' : NextToken := CPAREN;
      else
        NextToken := BAD;
    end;
    Delete(Input, 1, 1);
    Exit;
  end; { case }
end; { NextToken }

procedure Push(Token : TokenRec);
{ Pushes a new Token onto the stack }
begin
  if StackTop = PARSERSTACKSIZE then
  begin
    ErrorMsg(MSGSTACKERROR);
    TokenError := True;
  end
  else begin
    Inc(StackTop);
    Stack[StackTop] := Token;
  end;
end; { Push }

procedure Pop(var Token : TokenRec);
{ Pops the top Token off of the stack }
begin
  Token := Stack[StackTop];
  Dec(StackTop);
end; { Pop }

function GotoState(Production : Word) : Word;
{ Finds the new state based on the just-completed production and the
   top state.
}
var
  State : Word;
begin
  State := Stack[StackTop].State;
  if (Production <= 3) then
  begin
    case State of
      0 : GotoState := 1;
      9 : GotoState := 19;
      20 : GotoState := 28;
    end; { case }
  end
  else if Production <= 6 then
  begin
    case State of
      0, 9, 20 : GotoState := 2;
      12 : GotoState := 21;
      13 : GotoState := 22;
    end; { case }
  end
  else if Production <= 8 then
  begin
    case State of
      0, 9, 12, 13, 20 : GotoState := 3;
      14 : GotoState := 23;
      15 : GotoState := 24;
      16 : GotoState := 25;
    end; { case }
  end
  else if Production <= 10 then
  begin
    case State of
      0, 9, 12..16, 20 : GotoState := 4;
    end; { case }
  end
  else if Production <= 12 then
  begin
    case State of
      0, 9, 12..16, 20 : GotoState := 6;
      5 : GotoState := 17;
    end; { case }
  end
  else begin
    case State of
      0, 5, 9, 12..16, 20 : GotoState := 8;
    end; { case }
  end;
end; { GotoState }

function CellValue;
var
  CPtr : CellPtr;
begin
  CPtr := Cell[Col, Row];
  if (CPtr = nil) then
    CellValue := 0
  else begin
    if (CPtr^.Error) or (CPtr^.Attrib = TXT) then
      MathError := True;
    if CPtr^.Attrib = FORMULA then
      CellValue := CPtr^.FValue
    else
      CellValue := CPtr^.Value;
  end;
end; { CellValue }

procedure Shift(State : Word);
{ Shifts a Token onto the stack }
begin
  CurToken.State := State;
  Push(CurToken);
  TokenType := NextToken;
end; { Shift }

procedure Reduce(Reduction : Word);
{ Completes a reduction }
var
  Token1, Token2 : TokenRec;
  Counter : Word;
begin
  case Reduction of
    1 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurToken.Value := Token1.Value + Token2.Value;
    end;
    2 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurToken.Value := Token2.Value - Token1.Value;
    end;
    4 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurToken.Value := Token1.Value * Token2.Value;
    end;
    5 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      if Token1.Value = 0 then
        MathError := True
      else
        CurToken.Value := Token2.Value / Token1.Value;
    end;
    7 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      if Token2.Value <= 0 then
        MathError := True
      else if (Token1.Value * Ln(Token2.Value) < -EXPLIMIT) or
              (Token1.Value * Ln(Token2.Value) > EXPLIMIT) then
        MathError := True
      else
        CurToken.Value := Exp(Token1.Value * Ln(Token2.Value));
    end;
    9 : begin
      Pop(Token1);
      Pop(Token2);
      CurToken.Value := -Token1.Value;
    end;
    11 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurToken.Value := 0;
      if Token1.Row = Token2.Row then
      begin
        if Token1.Col < Token2.Col then
          TokenError := True
        else begin
          for Counter := Token2.Col to Token1.Col do
            CurToken.Value := CurToken.Value + CellValue(Counter, Token1.Row);
        end;
      end
      else if Token1.Col = Token2.Col then
      begin
        if Token1.Row < Token2.Row then
          TokenError := True
        else begin
          for Counter := Token2.Row to Token1.Row do
            CurToken.Value := CurToken.Value + CellValue(Token1.Col, Counter);
        end;
      end
      else
        TokenError := True;
    end;
    13 : begin
      Pop(CurToken);
      CurToken.Value := CellValue(CurToken.Col, CurToken.Row);
    end;
    14 : begin
      Pop(Token1);
      Pop(CurToken);
      Pop(Token1);
    end;
    16 : begin
      Pop(Token1);
      Pop(CurToken);
      Pop(Token1);
      Pop(Token1);
      if Token1.FuncName = 'ABS' then
        CurToken.Value := Abs(CurToken.Value)
      else if Token1.FuncName = 'ATAN' then
        CurToken.Value := ArcTan(CurToken.Value)
      else if Token1.FuncName = 'COS' then
        CurToken.Value := Cos(CurToken.Value)
      else if Token1.FuncName = 'EXP' then
      begin
        if (CurToken.Value < -EXPLIMIT) or (CurToken.Value > EXPLIMIT) then
          MathError := True
        else
          CurToken.Value := Exp(CurToken.Value);
      end
      else if Token1.FuncName = 'LN' then
      begin
        if CurToken.Value <= 0 then
          MathError := True
        else
          CurToken.Value := Ln(CurToken.Value);
      end
      else if Token1.FuncName = 'ROUND' then
      begin
        if (CurToken.Value < -1E9) or (CurToken.Value > 1E9) then
          MathError := True
        else
          CurToken.Value := Round(CurToken.Value);
      end
      else if Token1.FuncName = 'SIN' then
        CurToken.Value := Sin(CurToken.Value)
      else if Token1.FuncName = 'SQRT' then
      begin
        if CurToken.Value < 0 then
          MathError := True
        else
          CurToken.Value := Sqrt(CurToken.Value);
      end
      else if Token1.FuncName = 'SQR' then
      begin
        if (CurToken.Value < -SQRLIMIT) or (CurToken.Value > SQRLIMIT) then
          MathError := True
        else
          CurToken.Value := Sqr(CurToken.Value);
      end
      else if Token1.FuncName = 'TRUNC' then
      begin
        if (CurToken.Value < -1E9) or (CurToken.Value > 1E9) then
          MathError := True
        else
          CurToken.Value := Trunc(CurToken.Value);
      end;
    end;
    3, 6, 8, 10, 12, 15 : Pop(CurToken);
  end; { case }
  CurToken.State := GotoState(Reduction);
  Push(CurToken);
end; { Reduce }

function Parse;
var
  FirstToken : TokenRec;
  Accepted : Boolean;
  Counter : Word;
begin
  Accepted := False;
  TokenError := False;
  MathError := False;
  IsFormula := False;
  Input := UpperCase(S);
  StackTop := 0;
  FirstToken.State := 0;
  FirstToken.Value := 0;
  Push(FirstToken);
  TokenType := NextToken;
  repeat
    case Stack[StackTop].State of
      0, 9, 12..16, 20 : begin
        if TokenType = NUM then
          Shift(10)
        else if TokenType = CELLT then
          Shift(7)
        else if TokenType = FUNC then
          Shift(11)
        else if TokenType = MINUS then
          Shift(5)
        else if TokenType = OPAREN then
          Shift(9)
        else
          TokenError := True;
      end;
      1 : begin
        if TokenType = EOL then
          Accepted := True
        else if TokenType = PLUS then
          Shift(12)
        else if TokenType = MINUS then
          Shift(13)
        else
          TokenError := True;
      end;
      2 : begin
        if TokenType = TIMES then
          Shift(14)
        else if TokenType = DIVIDE then
          Shift(15)
        else
          Reduce(3);
      end;
      3 : Reduce(6);
      4 : begin
       if TokenType = EXPO then
         Shift(16)
       else
         Reduce(8);
      end;
      5 : begin
        if TokenType = NUM then
          Shift(10)
        else if TokenType = CELLT then
          Shift(7)
        else if TokenType = FUNC then
          Shift(11)
        else if TokenType = OPAREN then
          Shift(9)
        else
          TokenError := True;
      end;
      6 : Reduce(10);
      7 : begin
        if TokenType = COLON then
          Shift(18)
        else
          Reduce(13);
      end;
      8 : Reduce(12);
      10 : Reduce(15);
      11 : begin
        if TokenType = OPAREN then
          Shift(20)
        else
          TokenError := True;
      end;
      17 : Reduce(9);
      18 : begin
        if TokenType = CELLT then
          Shift(26)
        else
          TokenError := True;
      end;
      19 : begin
        if TokenType = PLUS then
          Shift(12)
        else if TokenType = MINUS then
          Shift(13)
        else if TokenType = CPAREN then
          Shift(27)
        else
          TokenError := True;
      end;
      21 : begin
        if TokenType = TIMES then
          Shift(14)
        else if TokenType = DIVIDE then
          Shift(15)
        else
          Reduce(1);
      end;
      22 : begin
        if TokenType = TIMES then
          Shift(14)
        else if TokenType = DIVIDE then
          Shift(15)
        else
          Reduce(2);
      end;
      23 : Reduce(4);
      24 : Reduce(5);
      25 : Reduce(7);
      26 : Reduce(11);
      27 : Reduce(14);
      28 : begin
        if TokenType = PLUS then
          Shift(12)
        else if TokenType = MINUS then
          Shift(13)
        else if TokenType = CPAREN then
          Shift(29)
        else
          TokenError := True;
      end;
      29 : Reduce(16);
    end; { case }
  until Accepted or TokenError;
  if TokenError then
  begin
    Att := TXT;
    Parse := 0;
    Exit;
  end;
  if IsFormula then
    Att := FORMULA
  else
    Att := VALUE;
  if MathError then
  begin
    Inc(Att, 4);
    Parse := 0;
    Exit;
  end;
  Parse := Stack[StackTop].Value;
end; { Parse }

end.
