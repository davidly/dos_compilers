{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit Puzzle;

{$F+,O+,S-,D-}

{ Simple puzzle object. See TVDEMO.PAS for an example
  program that uses this unit.
}


interface

uses views, Drivers, Objects, Crt;

const
  CPuzzleView = #6#7;

type

 TBoard = array[0..5,0..5] of Char;
 PPuzzleView = ^TPuzzleView;
 TPuzzleView = object(TView)
   Board: TBoard;
   Moves: Word;
   Solved: Boolean;
   constructor Init(Bounds: TRect);
   constructor Load(var S: TStream);
   procedure HandleEvent(var Event: TEvent); Virtual;
   procedure Draw; Virtual;
   function  GetPalette: PPalette; virtual;
   procedure MoveKey(Key: Word);
   procedure MoveTile(Point: TPoint);
   procedure Scramble;
   procedure Store(var S: TStream);
   procedure WinCheck;
 end;

 PPuzzleWindow = ^TPuzzleWindow;
 TPuzzleWindow = object(TWindow)
   constructor Init;
 end;

const
  RPuzzleView: TStreamRec = (
     ObjType: 10010;
     VmtLink: Ofs(TypeOf(TPuzzleView)^);
     Load:    @TPuzzleView.Load;
     Store:   @TPuzzleView.Store
  );

const
  RPuzzleWindow: TStreamRec = (
     ObjType: 10011;
     VmtLink: Ofs(TypeOf(TPuzzleWindow)^);
     Load:    @TPuzzleWindow.Load;
     Store:   @TPuzzleWindow.Store
  );

procedure RegisterPuzzle;

implementation

{ TPuzzleWindow }

constructor TPuzzleWindow.Init;
var
  R: TRect;
begin
  R.Assign(1, 1, 21, 7);
  inherited Init(R, 'Puzzle', 0);
  Flags := Flags and not (wfZoom + wfGrow);
  GrowMode := 0;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PPuzzleView, Init(R)));
end;

{ TPuzzleView }

constructor TPuzzleView.Init(Bounds: TRect);
type
  TBoardValue = array[1..16] of Char;
const
  SBoardValue: TBoardValue =
    ('A','B','C','D',
     'E','F','G','H',
     'I','J','K','L',
     'M','N','O',' ');
var
  I, J: Integer;
begin
  inherited Init(Bounds);
  Randomize;
  Options := Options or ofSelectable;
  FillChar(Board, SizeOf(Board), '?');
  for I := 0 to 3 do
    for J := 0 to 3 do
      Board[I+1, J+1] := SBoardValue[I*4 + J+1];
  Scramble;
end;

constructor TPuzzleView.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Board, SizeOf(Board) + Sizeof(Moves) + SizeOf(Solved));
end;

Procedure TPuzzleView.Draw;
var
  I, J, K: Integer;
  B: array[0..17] of word;
  S1: String[3];
  Color: array[0..1] of byte;
  ColorBack: Byte;
const
  Map: array['A'..'O'] of Byte =
    (0, 1, 0, 1,
     1, 0, 1, 0,
     0, 1, 0, 1,
     1, 0, 1);
begin
  Color[0] := GetColor(1);
  Color[1] := GetColor(2);
  ColorBack := GetColor(1);
  if Solved then Color[1] := Color[0]
  else Color[1] := GetColor(2);
  for I := 1 to 4 do
  begin
    MoveChar(B, ' ', ColorBack, 18);
    if I = 2 then MoveStr(B[13], 'Move', ColorBack);
    if I = 3 Then
    begin
      Str(Moves: 3, S1);
      MoveStr(B[14], S1, ColorBack);
    end;
    for J := 1 to 4 do
    begin
      S1 := ' ' + Board[I, J] + ' ';
      K := (Byte(Board[I, J]) mod 2) +1;
      if Board[I, J] = ' ' then MoveStr(B[(J - 1) * 3], S1, Color[0])
      else
        MoveStr(B[(J - 1) * 3], S1, Color[Map[Board[I, J]]]);
    end;
    WriteLine(0, I - 1, 18, 1, B);
  end;
end;

function TPuzzleView.GetPalette: PPalette;
const
  P: String[Length(CPuzzleView)] = CPuzzleView;
begin
  GetPalette := @P;
end;

procedure TPuzzleView.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Solved and (Event.What and (evKeyDown + evMouseDown) <> 0) then
  begin
    Scramble;
    ClearEvent(Event);
  end;
  case Event.What of
    evMouseDown: MoveTile(Event.Where);
    evKeyDown: MoveKey(Event.KeyCode);
  else
    Exit;
  end;
  ClearEvent(Event);
  WinCheck;
end;

procedure TPuzzleView.MoveKey(Key: Word);
var
  X, Y, I, J: Integer;
begin
  for I:=1 To 4 do
    for J:=1 To 4 do
      if Board[i,j] = ' ' then
      begin
        Y:=I;
        X:=J;
      end;

  case Key of
    kbDown:
      if Y > 1 then
      begin
        Board[Y, X] := Board[Y-1, X];
        Board[Y-1, X] := ' ';
        Inc(moves, Byte(moves<1000));
      end;
    kbUp:
      if Y < 4 then
      begin
        Board[Y, X] := Board[Y+1, X];
        Board[Y+1, X] := ' ';
        Inc(moves, Byte(moves<1000));
      end;
    kbRight:
      if X > 1 then
      begin
        Board[Y, X] := Board[Y, X-1];
        Board[Y, X-1] := ' ';
        Inc(moves, Byte(moves<1000));
      end;
    kbLeft:
      if X < 4 then
      begin
        Board[Y, X] := Board[Y, X+1];
        Board[Y, X+1] := ' ';
        Inc(moves,Byte(moves<1000));
      end;
  end;
  DrawView;
end;

procedure TPuzzleView.MoveTile(Point: TPoint);
var
  P: TPoint;
  X, Y: Word;
begin
  MakeLocal(Point, P);
  X := ((P.X + 3) div 3);
  Y := P.Y + 1;
  if (X > 0) and (X < 5) and (Y > 0) and (Y < 5) Then
  begin
    if Board[Y, X-1] = ' ' then
    begin
      Board[Y, X-1] := Board[Y, X];
      Board[Y, X] := ' ';
      Inc(moves, Byte(moves<1000));
    end;
    if Board[Y-1, X] = ' ' then
    begin
      Board[Y-1, X] := Board[Y, X];
      Board[Y, X] := ' ';
      Inc(moves, Byte(moves<1000));
    end;
    if Board[Y, X+1] = ' ' then
    begin
      Board[Y, X+1] := Board[Y, X];
      Board[Y, X] := ' ';
      Inc(moves, Byte(moves<1000));
    end;
    if Board[Y+1, X] = ' ' then
    begin
      Board[Y+1, X] := Board[Y, X];
      Board[Y, X] := ' ';
      Inc(moves, Byte(moves<1000));
    end;
    DrawView;
  end;
end;

procedure TPuzzleView.Scramble;
begin
  Moves := 0;
  Solved := False;
  repeat
    case Random(4) of
      0: MoveKey(kbUp);
      1: MoveKey(kbDown);
      2: MoveKey(kbRight);
      3: MoveKey(kbLeft);
    end;
  until Moves=500;
  Moves := 0;
  DrawView;
end;

procedure TPuzzleView.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Board, SizeOf(Board) + Sizeof(Moves) + SizeOf(Solved));
end;

procedure TPuzzleView.WinCheck;
type
  BoardStr = array [0..35] of Char;
const
  FBoard: BoardStr = '???????ABCD??EFGH??IJKL??MNO ???????';
var
  I: Integer;
begin
  Solved := BoardStr(Board) = FBoard;
  DrawView;
end;

procedure RegisterPuzzle;
begin
  RegisterType(RPuzzleView);
  RegisterType(RPuzzleWindow);
end;

end.
