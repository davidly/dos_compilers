{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+}

unit ViewHex;

interface

uses Drivers, Objects, Memory, Views;

type

  PHexViewer = ^THexViewer;
  THexViewer = object(TScroller)
    FileBuf: Pointer;
    BufSize: Word;
    MaxLines: Integer;
    constructor Init(var Bounds:TRect; AVScrollBar: PScrollBar;
      const Name: FNameStr);
    destructor Done; virtual;
    procedure Draw; virtual;
  end;

  PHexWindow = ^THexWindow;
  THexWindow = object(TWindow)
    Interior: PHexViewer;
    constructor Init(var Bounds: TRect; Filename: FNameStr);
    destructor Done; virtual;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    function GetPalette: PPalette; virtual;
  end;

implementation

uses MsgBox;

type
  String2 = String[2];

  PByteBuffer = ^TByteBuffer;
  TByteBuffer = array[0..$FFFE] of Byte;


{ Store hex characters directly into the string location pointed to by P }
{ No bounds checking done! }
procedure AddHexByte(B: Byte; P: Pointer);
const
  HexChars : array[0..15] of char = '0123456789ABCDEF';
type
  P2Char = ^T2Char;
  T2Char = array[0..1] of Char;
begin
  P2Char(P)^[0] := HexChars[ (B and $F0) shr 4 ];
  P2Char(P)^[1] := HexChars[ B and $0F ];
end;


{ THexViewer }

constructor THexViewer.Init(var Bounds:TRect; AVScrollBar: PScrollBar;
  const Name: FNameStr);
var
  F: File;
  Result: Word;
  FSize : Longint;
  Msg: String;
  SaveMode : Byte;
begin
  inherited Init(Bounds, nil, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofTileable;
  FileBuf := nil;
  BufSize := 0;
  Msg := '';     { no errors encountered   }

  { open the file }

  SaveMode := FileMode;
  FileMode := 0;        { make sure we open as Read-Only }
  Assign(F, Name);
  {$I-}
  Reset(F,1);
  {$I+}
  FileMode := SaveMode;
  Result := IOResult;
  if Result = 0 then
  begin
    FSize := FileSize(F);

    if FSize > $FFFE then
    begin
      FSize := $FFFE;
      Msg := 'File is larger than 64k.  Display will be truncated';
    end;

    if FSize > MaxAvail - LowMemSize then  { use standard safety size }
    begin
      FSize := MaxAvail - LowMemSize;
      if FSize > 0 then
        Msg := 'File too large for available memory.  Display will be truncated.'
      else Msg := 'Not enough memory for safety pool!';
    end;

    if FSize > 0 then
    begin
      GetMem(FileBuf, FSize);
      BlockRead(F, FileBuf^, FSize, Result);
      BufSize := FSize;
    end;

    Close(F);
  end
  else Msg := 'Unable to open this file!';

  { Display any message that was generated }
  if Msg <> '' then
    MessageBox(Msg, nil, mfInformation+mfOKButton);

  MaxLines := BufSize div 16;
  if BufSize mod 16 > 0 then Inc(MaxLines);
  SetLimit(0, MaxLines);
end;

destructor THexViewer.Done;
begin
  if (BufSize > 0) and (FileBuf <> nil) then FreeMem(FileBuf, BufSize);
  inherited Done;
end;

procedure THexViewer.Draw;
const
  VWidth = 69;      { total width of view }
  HStart = 7;       { starting column of hex dump }
  CStart = 56;      { starting column of character dump }
  LineChar = #179;  { vertical line character }
var
  B: TDrawBuffer;
  S: String;
  C: Word;
  Offset: Word;
  x,y : Byte;
  i,byt: Byte;
  L: Longint;
begin
  C := GetColor(1);
  for y := 0 to Size.Y-1 do
  begin
    FillChar(S[1], VWidth, 32);
    S[0] := Char(VWidth);
    MoveChar(B, #32, C, Size.X);
    Offset := (Delta.Y + Y) * 16;
    if (Delta.Y + Y) < MaxLines then
    begin
      L := (Delta.Y + Y) * 16;
      FormatStr(S, '%04x:', L);
      S[0] := Char(VWidth);
      i := HStart;
      for x := 0 to 15 do
      begin
        if Offset + x < BufSize then
        begin
          byt := PByteBuffer(FileBuf)^[Offset+x];
          AddHexByte(byt, @S[i]);
          S[CStart + x] := Char(byt);
          Inc(i,3);
        end;
      end;
    end;
    S[CStart - 1] := LineChar;
    MoveStr(B, S, C);
    WriteLine(0,Y,Size.X,1,B);
  end;
end;


{ THexWindow }
constructor THexWindow.Init(var Bounds: TRect; Filename: FNameStr);
var
  R: TRect;
  SB: PScrollBar;
begin
  inherited Init(Bounds, Filename, wnNoNumber);
  GetExtent(R);
  SB := StandardScrollBar(sbVertical + sbHandleKeyboard);
  Insert(SB);
  R.Grow(-1,-1);
  Interior := New(PHexViewer, Init(R, SB, Filename));
  Insert(Interior);
end;

destructor THexWindow.Done;
begin
  if Interior <> nil then Dispose(Interior, Done);
  inherited Done;
end;

procedure THexWindow.SizeLimits(var Min, Max: TPoint);
begin
  inherited SizeLimits(Min, Max);
  Max.X := 72;
end;

function THexWindow.GetPalette: PPalette;
const
  MyPal : String[Length(CGrayWindow)] = CCyanWindow;
begin
  GetPalette := @MyPal;
end;

end. { unit }
