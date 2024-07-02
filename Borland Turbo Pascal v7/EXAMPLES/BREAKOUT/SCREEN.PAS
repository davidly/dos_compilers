{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Screen;

{
  See BREAKOUT.PAS.
  This unit provides several objects for dealing with the screen.
}

interface

uses Crt, Dos;

type
  Location = object
    X, Y : Integer;
    Visible : Boolean;
    constructor Init(InitX, InitY : Integer);
    procedure Relocate(NewX, NewY : Integer);
    procedure MoveTo(NewX, NewY : Integer); virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    function GetX : Integer;
    function GetY : Integer;
    function IsVisible : Boolean;
  end;

  Cursor = object(Location)
    OldCursor : Integer;
    TempCursor : Integer;
    constructor Init;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure SetCursor(NewCursor : Integer);
    function GetCursor : Integer;
    procedure MoveTo(NewX, NewY : Integer); virtual;
    procedure Save;
    procedure Restore;
    procedure Speedup;
    procedure Slowdown;
  end;

  SaveScreen = object(Cursor)
    OldAttr   : Byte;
    constructor Init;
    procedure Save;
    procedure Restore;
  end;

implementation

procedure SetCursorSpeed(NewSpeed : Word);
begin
  Port[$60] := $F3;
  Delay(200);
  Port[$60] := NewSpeed;
end;

constructor Location.Init(InitX, InitY : Integer);
begin
  X := InitX;
  Y := InitY;
  Visible := False;
end;

procedure Location.Relocate(NewX, NewY : Integer);
begin
  X := NewX;
  Y := NewY;
end;

procedure Location.MoveTo(NewX, NewY : Integer);
var
  Vis : Boolean;
begin
  Vis := Visible;
  if Vis then Hide;
  X := NewX;
  Y := NewY;
  if Vis then Show;
end;

procedure Location.Show;
begin
  Visible := True;
end;

procedure Location.Hide;
begin
  Visible := False;
end;

function Location.GetX : Integer;
begin
  GetX := X;
end;

function Location.GetY : Integer;
begin
  GetY := Y;
end;

function Location.IsVisible;
begin
  IsVisible := Visible;
end;

constructor Cursor.Init;
begin
  Location.Init(WhereX, WhereY);
  OldCursor := GetCursor;
  Location.Show;
end;

procedure Cursor.Show;
begin
  SetCursor(TempCursor);
end;

procedure Cursor.Hide;
begin
  TempCursor := GetCursor;
  SetCursor($2000);
end;

function Cursor.GetCursor : Integer;
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 3;
    BH := 0;
    Intr($10, Reg);
    GetCursor := CX;
  end;
end;

procedure Cursor.SetCursor(NewCursor : Integer);
var
  Reg : Registers;
begin
  with Reg do
  begin
    AH := 1;
    BH := 0;
    CX := NewCursor;
    Intr($10, Reg);
  end;
end;

procedure Cursor.MoveTo(NewX, NewY : Integer);
begin
  Location.Relocate(NewX, NewY);
  GoToXY(NewX, NewY);
end;

procedure Cursor.Save;
begin
  Location.Relocate(WhereX, WhereY);
  OldCursor := GetCursor;
end;

procedure Cursor.Restore;
begin
  SetCursor(OldCursor);
  GoToXY(X, Y);
end;

procedure Cursor.Speedup;
begin
  SetCursorSpeed(0);
end;

procedure Cursor.Slowdown;
begin
  SetCursorSpeed($2C);
end;

constructor SaveScreen.Init;
begin
  Cursor.Init;
  OldAttr := TextAttr;
end;

procedure SaveScreen.Save;
begin
  Cursor.Save;
  OldAttr := TextAttr;
end;

procedure SaveScreen.Restore;
begin
  Cursor.Restore;
  TextAttr := OldAttr;
  ClrScr;
end;

end.
