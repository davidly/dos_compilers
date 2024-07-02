{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit FViewer;

{$F+,O+,X+,S-,D-}

{ FileViewer object for scrolling through text files. See
  TVDEMO.PAS for an example program that uses this unit.
}

interface

uses Objects, Views, Dos;

type

  { TLineCollection }

  PLineCollection = ^TLineCollection;
  TLineCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  { TFileViewer }

  PFileViewer = ^TFileViewer;
  TFileViewer = object(TScroller)
    FileName: PString;
    FileLines: PCollection;
    IsValid: Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      var AFileName: PathStr);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure ReadFile(var FName: PathStr);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

  { TFileWindow }

  PFileWindow = ^TFileWindow;
  TFileWindow = object(TWindow)
    constructor Init(var FileName: PathStr);
  end;

const

  RFileViewer: TStreamRec = (
     ObjType: 10080;
     VmtLink: Ofs(TypeOf(TFileViewer)^);
     Load:    @TFileViewer.Load;
     Store:   @TFileViewer.Store
  );
  RFileWindow: TStreamRec = (
     ObjType: 10081;
     VmtLink: Ofs(TypeOf(TFileWindow)^);
     Load:    @TFileWindow.Load;
     Store:   @TFileWindow.Store
  );

procedure RegisterFViewer;

implementation

uses Drivers, Memory, MsgBox, App;

{ TLineCollection }
procedure TLineCollection.FreeItem(P: Pointer);
begin
  DisposeStr(P);
end;

{ TFileViewer }
constructor TFileViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; var AFileName: PathStr);
begin
  TScroller.Init(Bounds, AHScrollbar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  FileName := nil;
  ReadFile(AFileName);
end;

constructor TFileViewer.Load(var S: TStream);
var
  FName: PathStr;
begin
  TScroller.Load(S);
  FileName := S.ReadStr;
  FName := FileName^;
  ReadFile(FName);
end;

destructor TFileViewer.Done;
begin
  Dispose(FileLines, Done);
  TScroller.Done;
end;

procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  C := GetColor(1);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < FileLines^.Count then
    begin
      P := FileLines^.At(Delta.Y + I);
      if P <> nil then S := Copy(P^, Delta.X + 1, Size.X)
      else S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TFileViewer.ReadFile(var FName: PathStr);
var
  FileToView: Text;
  Line: String;
  MaxWidth: Integer;
  E: TEvent;
begin
  IsValid := True;
  if FileName <> nil then DisposeStr(FileName);
  FileName := NewStr(FName);
  FileLines := New(PLineCollection, Init(5,5));
  {$I-}
  Assign(FileToView, FName);
  Reset(FileToView);
  if IOResult <> 0 then
  begin
    MessageBox('Cannot open file '+FName+'.', nil, mfError + mfOkButton);
    IsValid := False;
  end
  else
  begin
    MaxWidth := 0;
    while not Eof(FileToView) and not LowMemory do
    begin
      Readln(FileToView, Line);
      if Length(Line) > MaxWidth then MaxWidth := Length(Line);
      FileLines^.Insert(NewStr(Line));
    end;
    Close(FileToView);
  end;
  {$I+}
  Limit.X := MaxWidth;
  Limit.Y := FileLines^.Count;
end;

procedure TFileViewer.SetState(AState: Word; Enable: Boolean);
begin
  TScroller.SetState(AState, Enable);
  if Enable and (AState and sfExposed <> 0) then
     SetLimit(Limit.X, Limit.Y);
end;

procedure TFileViewer.Store(var S: TStream);
begin
  TScroller.Store(S);
  S.WriteStr(FileName);
end;

function TFileViewer.Valid(Command: Word): Boolean;
begin
  Valid := IsValid;
end;

{ TFileWindow }
constructor TFileWindow.Init(var FileName: PathStr);
const
  WinNumber: Integer = 1;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  TWindow.Init(R, Filename, WinNumber);
  Options := Options or ofTileable;
  Inc(WinNumber);
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), Filename)));
end;

procedure RegisterFViewer;
begin
  RegisterType(RFileViewer);
  RegisterType(RFileWindow);
end;

end.
