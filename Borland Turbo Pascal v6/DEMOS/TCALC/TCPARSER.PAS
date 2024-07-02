
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCParser;
{ Turbo Pascal 6.0 object-oriented example parser.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$N+,S-}

interface

uses Crt, Dos, TCUtil, TCScreen, TCCell, TCCellSp, TCLStr;

const
  ParserStackSize = 10;
  MaxFuncNameLen = 5;
  ExpLimit = 11356;
  SqrLimit = 1E2466;
  MaxExpLen = 4;
  TotalErrors = 7;
  ErrParserStack = 1;
  ErrBadRange = 2;
  ErrExpression = 3;
  ErrOperator = 4;
  ErrOpenParen = 5;
  ErrCell = 6;
  ErrOpCloseParen = 7;
  ErrorMessages : array[1..TotalErrors] of String[33] =
    ('Parser stack overflow', 'Bad cell range', 'Expected expression',
     'Expected operator', 'Expected open paren', 'Expected cell',
     'Expected operator or closed paren');

type
  ErrorRange = 0..TotalErrors;
  TokenTypes = (Plus, Minus, Times, Divide, Expo, Colon, OParen, CParen,
                Num, CellT, Func, EOL, Bad);
  TokenRec = record
    State : Byte;
    case Byte of
      0 : (Value : Extended);
      1 : (CP : CellPos);
      2 : (FuncName : String[MaxFuncNameLen]);
  end;
  ParserObj = object
    Inp : LStringPtr;
    ParserHash : CellHashTablePtr;
    PMaxCols : Word;
    PMaxRows : Word;
    Position : Word;
    CurrToken : TokenRec;
    StackTop : 0..ParserStackSize;
    TokenError : ErrorRange;
    ParseError : Boolean;
    CType : CellTypes;
    ParseValue : Extended;
    Stack : array[1..ParserStackSize] of TokenRec;
    TokenType : TokenTypes;
    TokenLen : Word;
    MathError, IsFormula : Boolean;
    constructor Init(InitHash : CellHashTablePtr; InitInp : LStringPtr;
                     InitPMaxCols, InitPMaxRows : Word);
    function IsFunc(S : String) : Boolean;
    procedure Push(Token : TokenRec);
    procedure Pop(var Token : TokenRec);
    function GotoState(Production : Word) : Word;
    procedure Shift(State : Word);
    procedure Reduce(Reduction : Word);
    function NextToken : TokenTypes;
    procedure Parse;
    function CellValue(P : CellPos) : Extended;
  end;

var
  Parser : ParserObj;

implementation

constructor ParserObj.Init(InitHash : CellHashTablePtr;
                           InitInp : LStringPtr;
                           InitPMaxCols, InitPMaxRows : Word);
{ Initializes the parser }
begin
  ParserHash := InitHash;
  Inp := InitInp;
  PMaxCols := InitPMaxCols;
  PMaxRows := InitPMaxRows;
  Position := 1;
  StackTop := 0;
  TokenError := 0;
  MathError := False;
  IsFormula := False;
  ParseError := False;
end; { ParserObj.Init }

function ParserObj.IsFunc(S : String) : Boolean;
{ Checks to see if the parser is about to read a function }
var
  Counter, SLen : Word;
begin
  with Inp^ do
  begin
    SLen := System.Length(S);
    for Counter := 1 to System.Length(S) do
    begin
      if UpCase(Data^[Pred(Position + Counter)]) <> S[Counter] then
      begin
        IsFunc := False;
        Exit;
      end;
    end;
    CurrToken.FuncName := UpperCase(Copy(Position, SLen));
    Inc(Position, SLen);
    IsFunc := True;
  end; { with }
end; { IsFunc }

function ParserObj.NextToken : TokenTypes;
{ Gets the next Token from the Input stream }
var
  NumString : String[80];
  FormLen, Place, TLen, NumLen, Check : Word;
  Ch, FirstChar : Char;
  Decimal : Boolean;
begin
  with Inp^ do
  begin
    while (Position <= Length) and (Data^[Position] = ' ') do
      Inc(Position);
    TokenLen := Position;
    if Position > Length then
    begin
      NextToken := EOL;
      TokenLen := 0;
      Exit;
    end;
    Ch := UpCase(Data^[Position]);
    if Ch in ['0'..'9', '.'] then
    begin
      NumString := '';
      TLen := Position;
      Decimal := False;
      while (TLen <= Length) and
            ((Data^[TLen] in ['0'..'9']) or
             ((Data^[TLen] = '.') and (not Decimal))) do
      begin
        NumString := NumString + Data^[TLen];
        if Ch = '.' then
          Decimal := True;
        Inc(TLen);
      end;
      if (TLen = 2) and (Ch = '.') then
      begin
        NextToken := BAD;
        TokenLen := 0;
        Exit;
      end;
      if (TLen <= Length) and ((Data^[TLen] = 'E') or
                               (Data^[TLen] = 'e')) then
      begin
        NumString := NumString + 'E';
        Inc(TLen);
        if Data^[TLen] in ['+', '-'] then
        begin
          NumString := NumString + Data^[TLen];
          Inc(TLen);
        end;
        NumLen := 1;
        while (TLen <= Length) and (Data^[TLen] in ['0'..'9']) and
              (NumLen <= MaxExpLen) do
        begin
          NumString := NumString + Data^[TLen];
          Inc(NumLen);
          Inc(TLen);
        end;
      end;
      if NumString[1] = '.' then
        NumString := '0' + NumString;
      Val(NumString, CurrToken.Value, Check);
      if Check <> 0 then
        MathError := True;
      NextToken := NUM;
      Inc(Position, System.Length(NumString));
      TokenLen := Position - TokenLen;
      Exit;
    end
    else if Ch in Letters then
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
        TokenLen := Position - TokenLen;
        Exit;
      end;
      if FormulaStart(Inp, Position, PMaxCols, PMaxRows, CurrToken.CP,
                      FormLen) then
      begin
        Inc(Position, FormLen);
        IsFormula := True;
        NextToken := CELLT;
        TokenLen := Position - TokenLen;
        Exit;
      end
      else begin
        NextToken := BAD;
        TokenLen := 0;
        Exit;
      end;
    end
    else begin
      case Ch of
        '+' : NextToken := PLUS;
        '-' : NextToken := MINUS;
        '*' : NextToken := TIMES;
        '/' : NextToken := DIVIDE;
        '^' : NextToken := EXPO;
        ':' : NextToken := COLON;
        '(' : NextToken := OPAREN;
        ')' : NextToken := CPAREN;
        else begin
          NextToken := BAD;
          TokenLen := 0;
          Exit;
        end;
      end;
      Inc(Position);
      TokenLen := Position - TokenLen;
      Exit;
    end; { case }
  end; { with }
end; { ParserObj.NextToken }

procedure ParserObj.Push(Token : TokenRec);
{ Pushes a new Token onto the stack }
begin
  if StackTop = ParserStackSize then
    TokenError := ErrParserStack
  else begin
    Inc(StackTop);
    Stack[StackTop] := Token;
  end;
end; { ParserObj.Push }

procedure ParserObj.Pop(var Token : TokenRec);
{ Pops the top Token off of the stack }
begin
  Token := Stack[StackTop];
  Dec(StackTop);
end; { ParserObj.Pop }

function ParserObj.GotoState(Production : Word) : Word;
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
end; { ParserObj.GotoState }

function ParserObj.CellValue(P : CellPos) : Extended;
{ Returns the value of a cell }
var
  CPtr : CellPtr;
begin
  CPtr := ParserHash^.Search(P);
  with CPtr^ do
  begin
    if (not LegalValue) or HasError then
    begin
      MathError := True;
      CellValue := 0;
    end
    else
      CellValue := CurrValue;
  end; { with }
end; { ParserObj.CellValue }

procedure ParserObj.Shift(State : Word);
{ Shifts a Token onto the stack }
begin
  CurrToken.State := State;
  Push(CurrToken);
  TokenType := NextToken;
end; { ParserObj.Shift }

procedure ParserObj.Reduce(Reduction : Word);
{ Completes a reduction }
var
  Token1, Token2 : TokenRec;
  Counter : CellPos;
begin
  case Reduction of
    1 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurrToken.Value := Token1.Value + Token2.Value;
    end;
    2 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurrToken.Value := Token2.Value - Token1.Value;
    end;
    4 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurrToken.Value := Token1.Value * Token2.Value;
    end;
    5 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      if Token1.Value = 0 then
        MathError := True
      else
        CurrToken.Value := Token2.Value / Token1.Value;
    end;
    7 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      if Token2.Value <= 0 then
        MathError := True
      else if (Token1.Value * Ln(Token2.Value) < -ExpLimit) or
              (Token1.Value * Ln(Token2.Value) > ExpLimit) then
        MathError := True
      else
        CurrToken.Value := Exp(Token1.Value * Ln(Token2.Value));
    end;
    9 : begin
      Pop(Token1);
      Pop(Token2);
      CurrToken.Value := -Token1.Value;
    end;
    11 : begin
      Pop(Token1);
      Pop(Token2);
      Pop(Token2);
      CurrToken.Value := 0;
      if Token1.CP.Row = Token2.CP.Row then
      begin
        if Token1.CP.Col < Token2.CP.Col then
          TokenError := ErrBadRange
        else begin
          Counter.Row := Token1.CP.Row;
          for Counter.Col := Token2.CP.Col to Token1.CP.Col do
            CurrToken.Value := CurrToken.Value + CellValue(Counter);
        end;
      end
      else if Token1.CP.Col = Token2.CP.Col then
      begin
        if Token1.CP.Row < Token2.CP.Row then
          TokenError := ErrBadRange
        else begin
          Counter.Col := Token1.CP.Col;
          for Counter.Row := Token2.CP.Row to Token1.CP.Row do
            CurrToken.Value := CurrToken.Value + CellValue(Counter);
        end;
      end
      else if (Token1.CP.Col >= Token2.CP.Col) and
              (Token1.CP.Row >= Token2.CP.Row) then
      begin
        for Counter.Row := Token2.CP.Row to Token1.CP.Row do
        begin
          for Counter.Col := Token2.CP.Col to Token1.CP.Col do
            CurrToken.Value := CurrToken.Value + CellValue(Counter);
        end;
      end
      else
        TokenError := ErrBadRange;
    end;
    13 : begin
      Pop(CurrToken);
      CurrToken.Value := CellValue(CurrToken.CP);
    end;
    14 : begin
      Pop(Token1);
      Pop(CurrToken);
      Pop(Token1);
    end;
    16 : begin
      Pop(Token1);
      Pop(CurrToken);
      Pop(Token1);
      Pop(Token1);
      if Token1.FuncName = 'ABS' then
        CurrToken.Value := Abs(CurrToken.Value)
      else if Token1.FuncName = 'ATAN' then
        CurrToken.Value := ArcTan(CurrToken.Value)
      else if Token1.FuncName = 'COS' then
        CurrToken.Value := Cos(CurrToken.Value)
      else if Token1.FuncName = 'EXP' then
      begin
        if (CurrToken.Value < -ExpLimit) or (CurrToken.Value > ExpLimit) then
          MathError := True
        else
          CurrToken.Value := Exp(CurrToken.Value);
      end
      else if Token1.FuncName = 'LN' then
      begin
        if CurrToken.Value <= 0 then
          MathError := True
        else
          CurrToken.Value := Ln(CurrToken.Value);
      end
      else if Token1.FuncName = 'ROUND' then
      begin
        if (CurrToken.Value < -1E9) or (CurrToken.Value > 1E9) then
          MathError := True
        else
          CurrToken.Value := Round(CurrToken.Value);
      end
      else if Token1.FuncName = 'SIN' then
        CurrToken.Value := Sin(CurrToken.Value)
      else if Token1.FuncName = 'SQRT' then
      begin
        if CurrToken.Value < 0 then
          MathError := True
        else
          CurrToken.Value := Sqrt(CurrToken.Value);
      end
      else if Token1.FuncName = 'SQR' then
      begin
        if (CurrToken.Value < -SQRLIMIT) or (CurrToken.Value > SQRLIMIT) then
          MathError := True
        else
          CurrToken.Value := Sqr(CurrToken.Value);
      end
      else if Token1.FuncName = 'TRUNC' then
      begin
        if (CurrToken.Value < -1E9) or (CurrToken.Value > 1E9) then
          MathError := True
        else
          CurrToken.Value := Trunc(CurrToken.Value);
      end;
    end;
    3, 6, 8, 10, 12, 15 : Pop(CurrToken);
  end; { case }
  CurrToken.State := GotoState(Reduction);
  Push(CurrToken);
end; { ParserObj.Reduce }

procedure ParserObj.Parse;
{ Parses an input stream }
var
  FirstToken : TokenRec;
  Accepted : Boolean;
begin
  Position := 1;
  StackTop := 0;
  TokenError := 0;
  MathError := False;
  IsFormula := False;
  ParseError := False;
  with Inp^ do
  begin
    if (Length = 2) and (Data^[1] = RepeatFirstChar) then
    begin
      CType := ClRepeat;
      Exit;
    end;
    if Data^[1] = TextFirstChar then
    begin
      CType := ClText;
      Exit;
    end;
  end; { with }
  Accepted := False;
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
        else begin
          TokenError := ErrExpression;
          Dec(Position, TokenLen);
        end;
      end;
      1 : begin
        if TokenType = EOL then
          Accepted := True
        else if TokenType = PLUS then
          Shift(12)
        else if TokenType = MINUS then
          Shift(13)
        else begin
          TokenError := ErrOperator;
          Dec(Position, TokenLen);
        end;
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
          TokenError := ErrExpression;
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
          TokenError := ErrOpenParen;
      end;
      17 : Reduce(9);
      18 : begin
        if TokenType = CELLT then
          Shift(26)
        else
          TokenError := ErrCell;
      end;
      19 : begin
        if TokenType = PLUS then
          Shift(12)
        else if TokenType = MINUS then
          Shift(13)
        else if TokenType = CPAREN then
          Shift(27)
        else
          TokenError := ErrOpCloseParen;
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
          TokenError := ErrOpCloseParen;
      end;
      29 : Reduce(16);
    end; { case }
  until Accepted or (TokenError <> 0);
  if TokenError <> 0 then
  begin
    with Scr do
    begin
      if TokenError = ErrBadRange then
        Dec(Position, TokenLen);
      PrintError(ErrorMessages[TokenError]);
      Exit;
    end; { with }
  end;
  if IsFormula then
    CType := ClFormula
  else
    CType := ClValue;
  if MathError then
  begin
    ParseError := True;
    ParseValue := 0;
    Exit;
  end;
  ParseError := False;
  ParseValue := Stack[StackTop].Value;
end; { ParserObj.Parse }

end.
