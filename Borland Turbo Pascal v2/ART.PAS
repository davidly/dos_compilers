
const
  Memory = 150;

var
  Line:  array [1..Memory] of record
                                LX1,LY1: integer;
                                LX2,LY2: integer;
                                LColor:  integer;
                              end;
  X1,X2,Y1,Y2,
  CurrentLine,
  ColorCount,
  IncrementCount,
  DeltaX1,DeltaY1,DeltaX2,DeltaY2,
  I,Color:            integer;
  Ch: char;


procedure Check;
var
  Ch: char;
begin
  writeln('This program will only work if you have the color graphics adapter installed');
  write('Continue Y/N ');
  repeat read (Kbd,Ch)  until Upcase(Ch) in ['Y','N'];
  if Upcase(Ch)='N' then Halt;
end;



procedure Init;
begin
  for I:=1 to Memory do
  with Line[I] do
  begin
    LX1:=0; LX2:=0;
    LY1:=0; LY2:=0;
  end;
  X1:=0; Y1:=0; X2:=0; Y2:=0;
  CurrentLine:=1;
  ColorCount:=0;
  IncrementCount:=0;
  Ch:=' ';
end;

procedure AdjustX(var X,DeltaX: integer);
var
  TestX: integer;
begin
  TestX:=X+DeltaX;
  if (TestX<1) or (TestX>320) then
  begin
    TestX:=X;
    DeltaX:=-DeltaX;
  end;
  X:=TestX;
end;

procedure AdjustY(var Y,DeltaY: integer);
var
  TestY: integer;
begin
  TestY:=Y+DeltaY;
  if (TestY<1) or (TestY>190) then
  begin
    TestY:=Y;
    DeltaY:=-DeltaY;
  end;
  Y:=TestY;
end;

procedure SelectNewColor;
begin
  Color:=Random(3)+1;
  ColorCount:=5*(1+Random(10));
end;

procedure SelectNewDeltaValues;
begin
  DeltaX1:=Random(7)-3;
  DeltaX2:=Random(7)-3;
  DeltaY1:=Random(7)-3;
  DeltaY2:=Random(7)-3;
  IncrementCount:=4*(1+Random(9));
end;


procedure SaveCurrentLine;
begin
  with Line[CurrentLine] do
  begin
    LX1:=X1;
    LY1:=Y1;
    LX2:=X2;
    LY2:=Y2;
    LColor:=Color;
  end;
end;


procedure Regenerate;
var
  I: integer;
begin
  NoSound;
  GraphColorMode; Palette(2);
  for I:=1 to Memory do with Line[I] do Draw(LX1,LY1,LX2,LY2,LColor);
  gotoxy(1,25);
  write('Press any key to continue, ESC to stop');
  read(Kbd,Ch);
end;

begin
  Check;
  Init;
  GraphColorMode;
  Palette(2);
  Color:=2;
  gotoxy(1,25);
  write('Press any key to regenerate, ESC to stop');
  repeat
    with Line[CurrentLine] do Draw(LX1,LY1,LX2,LY2,0);

    if ColorCount=0 then SelectNewColor;
    if IncrementCount=0 then SelectNewDeltaValues;

    AdjustX(X1,DeltaX1); AdjustX(X2,DeltaX2);
    AdjustY(Y1,DeltaY1); AdjustY(Y2,DeltaY2);

    Draw(X1,Y1,X2,Y2,Color);

    SaveCurrentLine;

    CurrentLine:=Succ(CurrentLine);
    if CurrentLine>Memory then CurrentLine:=1;
    ColorCount:=Pred(ColorCount); IncrementCount:=Pred(IncrementCount);

    if KeyPressed then
    begin
      read(Kbd,Ch);
      if Ch<>#27 then
      begin
        Regenerate;
        gotoxy(1,25);
        write('Press any key to regenerate, ESC to stop');
      end;
    end;
  until Ch=#27;
  TextMode;
end.

