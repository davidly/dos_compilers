
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCScreen;
{ Turbo Pascal 6.0 object-oriented example screen routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses Crt, Dos, TCUtil;

const
  ScreenCols = 80;
  ScreenRows = 50;
  MinScreenRows = 25;
  ESCPress = 'Press ESC.';    { Printed in error messages }

type
  Direction = (Up, Down, Left, Right);
  ScreenColRange = 1..ScreenCols;
  ScreenRowRange = 1..ScreenRows;
  VideoTypes = (MDA, CGA, MCGA, EGA, VGA);
  ScreenChar = record
    Data : Char;
    Attrib : Byte;
  end;
  ScreenArray = array[ScreenRowRange, ScreenColRange] of ScreenChar;
  ScreenRow = array[ScreenColRange] of ScreenChar;
  ScreenPointer = ^ScreenArray;
  ScreenPos = record
    Col : ScreenColRange;
    Row : ScreenRowRange;
  end;
  Screen = object
    CurrRows : ScreenRowRange;
    CurrCols : ScreenColRange;
    VideoType : VideoTypes;
    OldCursor : Word;
    InsCursor : Word;
    OldMode : Word;
    constructor Init;
    destructor Done;
    procedure ToggleMaxLinesMode;
    procedure PrintError(Error : String);
    procedure PrintMessage(Message : String);
    procedure ClearMessage;
    procedure PrintHelpLine(CommandString : String);
  end;
  ScreenArea = object
    UpperLeft, LowerRight : ScreenPos;
    Attrib : Byte;
    constructor Init(InitX1 : ScreenColRange; InitY1 : ScreenRowRange;
                     InitX2 : ScreenColRange; InitY2 : ScreenRowRange;
                     InitAttrib : Byte);
    procedure Scroll(Dir : Direction; Amt : Word);
    procedure Clear;
    procedure Erase;
  end;
  ColorTableType = (ColorMono, ColorBW, ColorColor);
  ColorTablePtr = ^ColorTable;
  ColorTable = object
    TableType : ColorTableType;
    BlankColor : Byte;
    ValueCellColor : Byte;
    TextCellColor : Byte;
    FormulaCellColor : Byte;
    RepeatCellColor : Byte;
    ColColor : Byte;
    RowColor : Byte;
    InfoColor : Byte;
    HighlightColor : Byte;
    BlockColor : Byte;
    InputColor : Byte;
    InputArrowColor : Byte;
    ErrorColor : Byte;
    CellErrorColor : Byte;
    MemoryColor : Byte;
    CellDataColor : Byte;
    PromptColor : Byte;
    FileNameColor : Byte;
    ChangedColor : Byte;
    TitleColor : Byte;
    ContentsColor : Byte;
    KeyNameColor : Byte;
    KeyDescColor : Byte;
    MenuHiColor : Byte;
    MenuLoColor : Byte;
    MessageColor : Byte;
    constructor Init;
    procedure FillColorTable;
  end;

const
  NoCursor = $2000;

var
  Colors : ColorTable;
  Scr : Screen;
  ScreenPtr : ScreenPointer;

procedure MoveToScreen(var Source, Dest; Len : Word);

procedure MoveFromScreen(var Source, Dest; Len : Word);

procedure ClrEOLXY(Col : ScreenColRange; Row : ScreenRowRange;
                   Color : Byte);

procedure WriteColor(S : String; Color : Byte);

procedure WriteXY(S : String; Col : ScreenColRange; Row : ScreenRowRange;
                      Color : Byte);

procedure WriteXYClr(S : String; Col : ScreenColRange; Row : ScreenRowRange;
                         Color : Byte);

procedure SetCursor(NewCursor : Word);

function GetCursor : Word;

implementation

const
  TotalColors = 26;
  WhiteOnRed = White + (Red shl 4);
  WhiteOnBlue = White + (Blue shl 4);
  WhiteOnCyan = White + (Cyan shl 4);
  BlackOnGray = LightGray shl 4;
  WhiteOnGray = White + (LightGray shl 4);
  BlinkingLightRed = LightRed + Blink;
  BlinkingWhite = White + Blink;
  LightCyanOnBlue = LightCyan + (Blue shl 4);
  YellowOnBlue = Yellow + (Blue shl 4);

type
  ColorArray = array[1..TotalColors] of Byte;

const
  ColorColors : ColorArray = (White, LightCyan, White, LightMagenta, White,
                              WhiteOnRed, WhiteOnRed, WhiteOnCyan,
                              WhiteOnBlue, WhiteOnCyan, White, LightCyan,
                              WhiteOnRed, BlinkingLightRed, LightRed,
                              LightGreen, Yellow, LightCyan, Yellow,
                              LightMagenta, Yellow, LightCyanOnBlue,
                              YellowOnBlue, LightCyan, White,
                              BlinkingLightRed);
  BWColors : ColorArray = (White, White, White, White, White, BlackOnGray,
                           BlackOnGray, WhiteOnGray, WhiteOnGray, BlackOnGray,
                           White, White, White, BlinkingWhite, White, White,
                           White, White, White, White, White, BlackOnGray,
                           White, White, LightGray, BlinkingWhite);
  MonoColors : ColorArray = (White, White, White, White, White, BlackOnGray,
                             BlackOnGray, BlackOnGray, BlackOnGray,
                             BlackOnGray, White, White, White, BlinkingWhite,
                             White, White, White, White, White, White, White,
                             BlackOnGray, White, White, LightGray,
                             BlinkingWhite);

const
  InsCursorSmall = $0007;
  InsCursorLarge = $000D;

var
  SavedExitProc : Pointer;

procedure ClearScreen(X1, Y1, X2, Y2, Attrib : Word);
{ Clears an area of the screen }
var
  Reg : Registers;
begin
  if (X1 > X2) or (Y1 > Y2) then   { Illegal values }
    Exit;
  with Reg do
  begin
    AX := $0600;              { Clear screen through the BIOS }
    BH := Attrib;
    CH := Pred(Y1);
    CL := Pred(X1);
    DH := Pred(Y2);
    DL := Pred(X2);
    Intr($10, Reg);
  end; { with }
end; { ClearScreen }

{$L TCMVSMEM}

procedure MoveToScreen(var Source, Dest; Len : Word); external;
{ Moves screen memory from normal RAM to screen memory - see TCMVSMEM.ASM
  for source }

procedure MoveFromScreen(var Source, Dest; Len : Word); external;
{ Moves screen memory to normal RAM from screen memory - see TCMVSMEM.ASM
  for source }

procedure MoveText(OldX1, OldY1, OldX2, OldY2, NewX1, NewY1 : Word);
{ Moves an area of text to a new position on the screen }
var
  Counter, Len : Word;
begin
  if (OldX2 < OldX1) or (OldY2 < OldY1) then
    Exit;
  Len := Succ(OldX2 - OldX1) shl 1;
  if NewY1 < OldY1 then
  begin                    { Move it row by row, going forwards }
    for Counter := 0 to OldY2 - OldY1 do
      MoveFromScreen(ScreenPtr^[OldY1 + Counter, OldX1],
                     ScreenPtr^[NewY1 + Counter, NewX1], Len)
  end
  else begin               { Move it row by row, going backwards }
    for Counter := OldY2 - OldY1 downto 0 do
      MoveFromScreen(ScreenPtr^[OldY1 + Counter, OldX1],
                     ScreenPtr^[NewY1 + Counter, NewX1], Len)
  end;
end; { MoveText }

procedure ScrollText(Dir : Direction; X1, Y1, X2, Y2, Amt, Attrib : Word);
{ Scrolls the screen by an amount in a direction - it does this by moving
  the text to be scrolled and then clearing the area that wasn't scrolled }
begin
  case Dir of
    Up : begin
      MoveText(X1, Y1 + Amt, X2, Y2, X1, Y1);
      ClearScreen(X1, Succ(Y2 - Amt), X2, Y2, Attrib);
    end;
    Down : begin
      MoveText(X1, Y1, X2, Y2 - Amt, X1, Succ(Y1));
      ClearScreen(X1, Y1, X2, Pred(Y1 + Amt), Attrib);
    end;
    Left : begin
      MoveText(X1 + Amt, Y1, X2, Y2, X1, Y1);
      ClearScreen(Succ(X2 - Amt), Y1, X2, Y2, Attrib);
    end;
    Right : begin
      MoveText(X1, Y1, X2 - Amt, Y2, X1 + Amt, Y1);
      ClearScreen(X1, Y1, Pred(X1 + Amt), Y2, Attrib);
    end;
  end; { case }
end; { ScrollText }

function EGAInstalled : Boolean;
{ Tests for the presence of an EGA }
var
  Reg : Registers;
begin
  Reg.AX := $1200;
  Reg.BX := $0010;
  Reg.CX := $FFFF;
  Intr($10, Reg);
  EGAInstalled := Reg.CX <> $FFFF;
end; { EGAInstalled }

function PS2 : Boolean;
{ This function returns True if we are running on a PS/2 type video adapter }
var
  Regs : Registers;
begin
  Regs.AX := $1A00;
  Intr($10, Regs);
  PS2 := ((Regs.AL and $FF) = $1A) and
         ((Regs.BL and $FF) in [$07, $08, $0B, $0C]);
end; { PS2 }

procedure ClrEOLXY(Col : ScreenColRange; Row : ScreenRowRange; Color : Byte);
{ Clears to the end-of-line in a color at a specified position }
begin
  GotoXY(Col, Row);
  TextAttr := Color;
  ClrEOL;
end; { ClrEOLXY }

procedure WriteColor(S : String; Color : Byte);
{ Writes a string in a color }
begin
  TextAttr := Color;
  Write(S);
end; { WriteColor }

procedure WriteXY(S : String; Col : ScreenColRange; Row : ScreenRowRange;
                  Color : Byte);
{ Writes a string in a color at a specified position }
begin
  GotoXY(Col, Row);
  WriteColor(S, Color);
end; { WriteXY }

procedure WriteXYClr(S : String; Col : ScreenColRange; Row : ScreenRowRange;
                     Color : Byte);
{ Clears to the end-of-line in a color at a specified position and then
  writes a string }
begin
  ClrEOLXY(Col, Row, Color);
  Write(S);
end; { WriteXYClr }

procedure SetCursor(NewCursor : Word);
{ Sets the value of the scan lines of the cursor }
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

function GetCursor : Word;
{ Returns the value of the scan lines of the cursor }
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

constructor Screen.Init;
{ Finds what type of video adapter is being run on, and initializes various
  variables based on this information }
var
  Reg : Registers;
begin
  OldMode := LastMode;
  Reg.AH := $0F;
  Intr($10, Reg);                    { Check for the current video mode }
  if Reg.AL <> 7 then
  begin
    if EGAInstalled then
    begin
      if PS2 then
        VideoType := VGA
      else
        VideoType := EGA;
    end
    else begin
      if PS2 then
        VideoType := MCGA
      else
        VideoType := CGA;
    end;
    ScreenPtr := Ptr($B800, 0);
    if Reg.AL < 2 then
      CurrCols := 40
    else
      CurrCols := 80;
  end
  else begin
    VideoType := MDA;
    ScreenPtr := Ptr($B000, 0);
    CurrCols := 80;
  end;
  CurrRows := Succ(Hi(WindMax));
  OldCursor := GetCursor;
  if (CurrRows = MinScreenRows) and (VideoType <> CGA) then
    InsCursor := InsCursorLarge
  else
    InsCursor := InsCursorSmall;
end; { Screen.Init }

destructor Screen.Done;
{ Restores the screen mode and cursor that existed at the start of the 
  program }
begin
  TextMode(OldMode);
  SetCursor(OldCursor);
  ExitProc := SavedExitProc;
end; { Screen.Done }

procedure Screen.ToggleMaxLinesMode;
{ Toggles the display in and out of 43/50-line mode }
begin
  if CurrRows = MinScreenRows then
  begin
    TextMode(Lo(LastMode) + Font8x8);
    InsCursor := InsCursorSmall;
  end
  else begin
    TextMode(Lo(LastMode));
    InsCursor := InsCursorLarge;
  end;
  CurrRows := Succ(Hi(WindMax));
end; { Screen.ToggleMaxLinesMode }

procedure Screen.PrintError(Error : String);
{ Prints an error message at the bottom of the screen }
var
  Ch : Word;
  Buffer : ScreenRow;
begin
  MoveFromScreen(ScreenPtr^[CurrRows, 1], Buffer,
                 SizeOf(ScreenChar) * CurrCols);  { Save bottom line }
  WriteXYClr(CenterStr(Error + '. ' + ESCPress, Pred(CurrCols)), 1, CurrRows,
             Colors.ErrorColor);
  Beep;
  repeat
    Ch := GetKey;
  until Ch = ESC;
  MoveToScreen(Buffer, ScreenPtr^[CurrRows, 1],  { Restore bottom line }
               SizeOf(ScreenChar) * CurrCols);
end; { Screen.PrintError }

procedure Screen.PrintMessage(Message : String);
{ Prints a message }
begin
  WriteXYClr(Message + '...', 1, Pred(CurrRows), Colors.MessageColor);
end; { Screen.PrintMessage }

procedure Screen.ClearMessage;
{ Clears the last printed message }
begin
  ClrEOLXY(1, Pred(CurrRows), Colors.MessageColor);
end; { Screen.ClearMessage }

procedure Screen.PrintHelpLine(CommandString : String);
{ Prints a help line at the bottom of the screen. The command string is
  made up of a series of keys and descriptions separated by backslashes.
  Example: 'F1\Help\F2\Save\F3\Load\Alt-X\Exit'}
var
  P : Integer;
  S : String[ScreenCols];
begin
  CommandString := CommandString + '\';
  ClrEOLXY(1, CurrRows, Colors.KeyDescColor);
  while CommandString <> '' do
  begin
    Write(' ');
    P := Pos('\', CommandString);
    WriteColor(Copy(CommandString, 1, Pred(P)), Colors.KeyNameColor);
    Delete(CommandString, 1, P);
    P := Pos('\', CommandString);
    if CommandString[1] = '\' then
      S := '-'
    else
      S := '-' + Copy(CommandString, 1, Pred(P));
    WriteColor(S, Colors.KeyDescColor);
    Delete(CommandString, 1, P);
  end;
end; { Screen.PrintHelpLine }

constructor ScreenArea.Init(InitX1 : ScreenColRange; InitY1 : ScreenRowRange;
                            InitX2 : ScreenColRange; InitY2 : ScreenRowRange;
                            InitAttrib : Byte);
{ Sets up a screen area }
begin
  UpperLeft.Col := InitX1;
  UpperLeft.Row := InitY1;
  LowerRight.Col := InitX2;
  LowerRight.Row := InitY2;
  Attrib := InitAttrib;
end; { ScreenArea.Init }

procedure ScreenArea.Scroll(Dir : Direction; Amt : Word);
{ Scrolls a screen area an certain amount in a direction }
begin
  ScrollText(Dir, UpperLeft.Col, UpperLeft.Row, LowerRight.Col,
             LowerRight.Row, Amt, Attrib);
end; { ScreenArea.Scroll }

procedure ScreenArea.Clear;
{ Clears a screen area }
begin
  ClearScreen(UpperLeft.Col, UpperLeft.Row, LowerRight.Col, LowerRight.Row,
              Attrib);
end; { ScreenArea.Clear }

procedure ScreenArea.Erase;
{ Erases a screen area by writing over it in black }
begin
  ClearScreen(UpperLeft.Col, UpperLeft.Row, LowerRight.Col, LowerRight.Row,
              Black);
end; { ScreenArea.Erase }

constructor ColorTable.Init;
{ Initializes the color table by finding the video mode that is being used }
begin
  case Lo(LastMode) of
    BW40, BW80 : TableType := ColorBW;
    CO40, CO80 : TableType := ColorColor;
    Mono : TableType := ColorMono;
  end; { case }
  FillColorTable;
end; { ColorTable.Init }

procedure ColorTable.FillColorTable;
{ Moves the correct built-in color table to the program's color table }
var
  P : Pointer;
begin
  case TableType of
    ColorColor : P := @ColorColors;
    ColorBW : P := @BWColors;
    ColorMono : P := @MonoColors;
  end; { case }
  Move(P^, BlankColor, TotalColors);
end; { ColorTable.FillColorTable }

{$F+}

procedure ScreenExit;
{ Clears the screen at exit }
begin
  Scr.Done;
end; { ScreenExit }

{$F-}

begin
  SavedExitProc := ExitProc;
  ExitProc := @ScreenExit;
  TextMode(LastMode);
  Scr.Init;
  Colors.Init;
end.
