
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

unit MCDISPLY;

interface

uses Crt, Dos, MCVars, MCUtil;

var
  InsCursor, ULCursor, NoCursor, OldCursor : Word;

procedure MoveToScreen(var Source, Dest; Len : Word);
{ Moves memory to screen memory }

procedure MoveFromScreen(var Source, Dest; Len : Word);
{ Moves memory from screen memory }

procedure WriteXY(S : String; Col, Row : Word);
{ Writes text in a particular location }

procedure MoveText(OldX1, OldY1, OldX2, OldY2, NewX1, NewY1 : Word);
{ Moves text from one location to another }

procedure Scroll(Direction, Lines, X1, Y1, X2, Y2, Attrib : Word);
{ Scrolls an area of the screen }

function GetCursor : Word;
{ Returns the current cursor }

procedure SetCursor(NewCursor : Word);
{ Sets a new cursor }

function GetSetCursor(NewCursor : Word) : Word;
{ Sets a new cursor and returns the current one }

procedure SetColor(Color : Word);
{ Sets the foreground and background color based on a single color }

procedure PrintCol;
{ Prints the column headings }

procedure PrintRow;
{ Prints the row headings }

procedure ClearInput;
{ Clears the input line }

procedure ChangeCursor(InsMode : Boolean);
{ Changes the cursor shape based on the current insert mode }

procedure ShowCellType;
{ Prints the type of cell and what is in it }

procedure PrintFreeMem;
{ Prints the amount of free memory }

procedure ErrorMsg(S : String);
{ Prints an error message at the bottom of the screen }

procedure WritePrompt(Prompt : String);
{ Prints a prompt on the screen }

function EGAInstalled : Boolean;
{ Tests for the presence of an EGA }

implementation

const
  MaxLines = 43;

type
  ScreenType = array[1..MaxLines, 1..80] of Word;
  ScreenPtr = ^ScreenType;

var
  DisplayPtr : ScreenPtr;

procedure MoveToScreen; external;

procedure MoveFromScreen; external;

{$L MCMVSMEM.OBJ}

procedure WriteXY;
begin
  GotoXY(Col, Row);
  Write(S);
end; { WriteXY }

procedure MoveText;
var
  Counter, Len : Word;
begin
  Len := Succ(OldX2 - OldX1) shl 1;
  if NewY1 < OldY1 then
  begin
    for Counter := 0 to OldY2 - OldY1 do
      MoveFromScreen(DisplayPtr^[OldY1 + Counter, OldX1],
                     DisplayPtr^[NewY1 + Counter, NewX1], Len)
  end
  else begin
    for Counter := OldY2 - OldY1 downto 0 do
      MoveFromScreen(DisplayPtr^[OldY1 + Counter, OldX1],
                     DisplayPtr^[NewY1 + Counter, NewX1], Len)
  end;
end; { MoveText }

procedure Scroll;
begin
  if Lines = 0 then
    Window(X1, Y1, X2, Y2)
  else begin
    case Direction of
      UP : begin
        MoveText(X1, Y1 + Lines, X2, Y2, X1, Y1);
        Window(X1, Succ(Y2 - Lines), X2, Y2);
      end;
      DOWN : begin
        MoveText(X1, Y1, X2, Y2 - Lines, X1, Y1 + Lines);
        Window(X1, Y1, X2, Pred(Y1 + Lines));
      end;
      LEFT : begin
        MoveText(X1 + Lines, Y1, X2, Y2, X1, Y1);
        Window(Succ(X2 - Lines), Y1, X2, Y2);
      end;
      RIGHT : begin
        MoveText(X1, Y1, X2 - Lines, Y2, X1 + Lines, Y1);
        Window(X1, Y1, Pred(X1 + Lines), Y2);
      end;
    end; { case }
  end;
  SetColor(Attrib);
  ClrScr;
  Window(1, 1, 80, ScreenRows + 5);
end; { Scroll }

function GetCursor;
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 3;
    BH := 0;
    Intr($10, Reg);
    GetCursor := CX;
  end; { Reg }
end; { GetCursor }

procedure SetCursor;
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 1;
    BH := 0;
    CX := NewCursor;
    Intr($10, Reg);
  end; { with }
end; { SetCursor }

function GetSetCursor;
begin
  GetSetCursor := GetCursor;
  SetCursor(NewCursor);
end; { GetSetCursor }

procedure SetColor;
begin
  TextAttr := ColorTable[Color];
end; { SetColor }

procedure InitColorTable(BlackWhite : Boolean);
{ Sets up the color table }
var
  Color, FG, BG, FColor, BColor : Word;
begin
  if not BlackWhite then
  begin
    for Color := 0 to 255 do
      ColorTable[Color] := Color;
  end
  else begin
    for FG := Black to White do
    begin
      case FG of
        Black : FColor := Black;
        Blue..LightGray : FColor := LightGray;
        DarkGray..White : FColor := White;
      end; { case }
      for BG := Black to LightGray do
      begin
        if BG = Black then
          BColor := Black
        else begin
          if FColor = White then
            FColor := Black;
          BColor := LightGray;
        end;
        ColorTable[FG + (BG shl 4)] := FColor + (BColor shl 4);
      end;
    end;
    for FG := 128 to 255 do
      ColorTable[FG] := ColorTable[FG - 128] or $80;
  end;
end; { InitColorTable }

procedure PrintCol;
var
  Col : Word;
begin
  Scroll(UP, 0, 1, 2, 80, 2, HEADERCOLOR);
  for Col := LeftCol to RightCol do
    WriteXY(CenterColString(Col), ColStart[Succ(Col - LeftCol)], 2);
end; { PrintCol }

procedure PrintRow;
var
  Row : Word;
begin
  SetColor(HEADERCOLOR);
  for Row := 0 to Pred(ScreenRows) do
    WriteXY(Pad(WordToString(Row + TopRow, 1), LEFTMARGIN), 1, Row + 3);
end; { PrintRow }

procedure ClearInput;
begin
  SetColor(TXTCOLOR);
  GotoXY(1, ScreenRows + 5);
  ClrEol;
end; { ClearInput }

procedure ChangeCursor;
begin
  if InsMode then
    SetCursor(InsCursor)
  else
    SetCursor(ULCursor);
end; { ChangeCursor }

procedure ShowCellType;
var
  ColStr : String[2];
  S : IString;
  Color : Word;
begin
  FormDisplay := not FormDisplay;
  S := CellString(CurCol, CurRow, Color, NOFORMAT);
  ColStr := ColString(CurCol);
  SetColor(CELLTYPECOLOR);
  GotoXY(1, ScreenRows + 3);
  if CurCell = Nil then
    Write(ColStr, CurRow, ' ', MSGEMPTY, ' ':10)
  else begin
    case CurCell^.Attrib of
    TXT :
      Write(ColStr, CurRow, ' ', MSGTEXT, ' ':10);
    VALUE :
      Write(ColStr, CurRow, ' ', MSGVALUE, ' ':10);
    FORMULA :
      Write(ColStr, CurRow, ' ', MSGFORMULA, ' ':10);
    end; { case }
  end;
  SetColor(CELLCONTENTSCOLOR);
  WriteXY(Pad(S, 80), 1, ScreenRows + 4);
  FormDisplay := not FormDisplay;
end; { ShowCellType }

procedure PrintFreeMem;
begin
  SetColor(MEMORYCOLOR);
  GotoXY(Length(MSGMEMORY) + 2, 1);
  Write(MemAvail:6);
end; { PrintFreeMem }

procedure ErrorMsg;
var
  Ch : Char;
begin
  Sound(1000);    { Beeps the speaker }
  Delay(500);
  NoSound;
  SetColor(ERRORCOLOR);
  WriteXY(S + '  ' + MSGKEYPRESS, 1, ScreenRows + 5);
  GotoXY(Length(S) + Length(MSGKEYPRESS) + 3, ScreenRows + 5);
  Ch := ReadKey;
  ClearInput;
end; { ErrorMsg }

procedure WritePrompt;
begin
  SetColor(PROMPTCOLOR);
  GotoXY(1, ScreenRows + 4);
  ClrEol;
  Write(Prompt);
end; { WritePrompt }

procedure InitDisplay;
{ Initializes various global variables - must be called before using the
  above procedures and functions.
}
var
  Reg : Registers;
begin
  Reg.AH := 15;
  Intr($10, Reg);
  ColorCard := Reg.AL <> 7;
  if ColorCard then
    DisplayPtr := Ptr($B800, 0)
  else
    DisplayPtr := Ptr($B000, 0);
  InitColorTable((not ColorCard) or (Reg.AL = 0) or (Reg.AL = 2));
end; { InitDisplay }

function EGAInstalled;
var
  Reg : Registers;
begin
  Reg.AX := $1200;
  Reg.BX := $0010;
  Reg.CX := $FFFF;
  Intr($10, Reg);
  EGAInstalled := Reg.CX <> $FFFF;
end; { EGAInstalled }

begin
  InitDisplay;
  NoCursor := $2000;
  OldCursor := GetSetCursor(NoCursor);
  OldMode := LastMode;
  if (LastMode and Font8x8) <> 0 then
    ScreenRows := 38
  else
    ScreenRows := 20;
  Window(1, 1, 80, ScreenRows + 5);
  if ColorCard then
  begin
    ULCursor := $0607;
    InsCursor := $0507;
  end
  else begin
    ULCursor := $0B0C;
    InsCursor := $090C;
  end;
  if EGAInstalled then
  begin
    UCommandString := UCOMMAND;
    UMenuString := UMNU;
  end
  else begin
    UCommandString := Copy(UCOMMAND, 1, 2);
    UMenuString := Copy(UMNU, 1, 23);
  end;
end.
