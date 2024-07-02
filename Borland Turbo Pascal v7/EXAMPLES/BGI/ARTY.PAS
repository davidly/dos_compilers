{************************************************}
{                                                }
{   Turbo Art Demo Program                       }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Arty;

{
  This program is a demonstration of the Borland Graphics Interface (BGI)

  Runtime Commands for ARTY
  -------------------------
  <B>   - changes background color
  <C>   - changes drawcolor
  <ESC> - exits program
  Any other key pauses, then regenerates the drawing

  Note: If a /H command-line parameter is specified, the highest
        resolution mode will be used (if possible).
}

uses
  Crt, Graph;

const
   Memory  = 100;
   Windows =   4;

type
  ResolutionPreference = (Lower, Higher);
  ColorList = array [1..Windows] of integer;

var
  Xmax,
  Ymax,
  ViewXmax,
  ViewYmax : integer;

  Line:  array [1..Memory] of record
                                LX1,LY1: integer;
                                LX2,LY2: integer;
                                LColor : ColorList;
                              end;
  X1,X2,Y1,Y2,
  CurrentLine,
  ColorCount,
  IncrementCount,
  DeltaX1,DeltaY1,DeltaX2,DeltaY2: integer;
  Colors: ColorList;
  Ch: char;
  BackColor:integer;
  GraphDriver, GraphMode : integer;
  MaxColors : word;
  MaxDelta : integer;
  ChangeColors: Boolean;

procedure Frame;
begin
  SetViewPort(0, 0, Xmax, Ymax-(TextHeight('M')+4)-1,ClipOn);
  SetColor(MaxColors);
  Rectangle(0, 0, Xmax-1, (Ymax-(TextHeight('M')+4)-1)-1);
  SetViewPort(1, 1, Xmax-2, (Ymax-(TextHeight('M')+4)-1)-2,ClipOn);
end  { Frame };

procedure FullPort;
{ Set the view port to the entire screen }
begin
  SetViewPort(0, 0, Xmax, Ymax, ClipOn);
end; { FullPort }

procedure MessageFrame(Msg:string);
begin
  FullPort;
  SetColor(MaxColors);
  SetTextStyle(DefaultFont, HorizDir, 1);
  SetTextJustify(CenterText, TopText);
  SetLineStyle(SolidLn, 0, NormWidth);
  SetFillStyle(EmptyFill, 0);
  Bar(0, Ymax-(TextHeight('M')+4), Xmax, Ymax);
  Rectangle(0, Ymax-(TextHeight('M')+4), Xmax, Ymax);
  OutTextXY(Xmax div 2, Ymax-(TextHeight('M')+2), Msg);
  { Go back to the main window }
  Frame;
end  { MessageFrame };

procedure WaitToGo;
var
  Ch : char;
begin
  MessageFrame('Press any key to continue... Esc aborts');
  repeat until KeyPressed;
  Ch := ReadKey;
  if Ch = #27 then begin
      CloseGraph;
      Writeln('All done.');
      Halt(1);
    end
  else
    ClearViewPort;
  MessageFrame('Press a key to stop action, Esc quits.');
end; { WaitToGo }

procedure TestGraphError(GraphErr: integer);
begin
  if GraphErr <> grOk then begin
    Writeln('Graphics error: ', GraphErrorMsg(GraphErr));
    repeat until keypressed;
    ch := readkey;
    Halt(1);
  end;
end;

procedure Init;
var
  Err, I: integer;
  StartX, StartY: integer;
  Resolution: ResolutionPreference;
  s: string;
begin
  Resolution := Lower;
  if paramcount > 0 then begin
    s := paramstr(1);
    if s[1] = '/' then
      if upcase(s[2]) = 'H' then
        Resolution := Higher;
  end;

  CurrentLine    := 1;
  ColorCount     := 0;
  IncrementCount := 0;
  Ch := ' ';
  GraphDriver := Detect;
  DetectGraph(GraphDriver, GraphMode);
  TestGraphError(GraphResult);
  case GraphDriver of
    CGA        : begin
                   MaxDelta := 7;
                   GraphDriver := CGA;
                   GraphMode := CGAC1;
                 end;

    MCGA       : begin
                   MaxDelta := 7;
                   case GraphMode of
                     MCGAMed, MCGAHi: GraphMode := MCGAC1;
                   end;
                 end;

    EGA         : begin
                    MaxDelta := 16;
                    If Resolution = Lower then
                      GraphMode := EGALo
                    else
                      GraphMode := EGAHi;
                  end;

    EGA64       : begin
                    MaxDelta := 16;
                    If Resolution = Lower then
                      GraphMode := EGA64Lo
                    else
                      GraphMode := EGA64Hi;
                  end;

     HercMono   : MaxDelta := 16;
     EGAMono    : MaxDelta := 16;
     PC3270     : begin
                   MaxDelta := 7;
                   GraphDriver := CGA;
                   GraphMode := CGAC1;
                 end;


     ATT400     : case GraphMode of
                    ATT400C1,
                    ATT400C2,
                    ATT400Med,
                    ATT400Hi  :
                      begin
                        MaxDelta := 7;
                        GraphMode := ATT400C1;
                      end;
                  end;

     VGA         : begin
                     MaxDelta := 16;
                   end;
  end;
  InitGraph(GraphDriver, GraphMode, '');
  TestGraphError(GraphResult);
  SetTextStyle(DefaultFont, HorizDir, 1);
  SetTextJustify(CenterText, TopText);

  MaxColors := GetMaxColor;
  BackColor := 0;
  ChangeColors := TRUE;
  Xmax := GetMaxX;
  Ymax := GetMaxY;
  ViewXmax := Xmax-2;
  ViewYmax := (Ymax-(TextHeight('M')+4)-1)-2;
  StartX := Xmax div 2;
  StartY := Ymax div 2;
  for I := 1 to Memory do with Line[I] do begin
      LX1 := StartX; LX2 := StartX;
      LY1 := StartY; LY2 := StartY;
    end;

   X1 := StartX;
   X2 := StartX;
   Y1 := StartY;
   Y2 := StartY;
end; {init}

procedure AdjustX(var X,DeltaX: integer);
var
  TestX: integer;
begin
  TestX := X+DeltaX;
  if (TestX<1) or (TestX>ViewXmax) then begin
    TestX := X;
    DeltaX := -DeltaX;
  end;
  X := TestX;
end;

procedure AdjustY(var Y,DeltaY: integer);
var
  TestY: integer;
begin
  TestY := Y+DeltaY;
  if (TestY<1) or (TestY>ViewYmax) then begin
    TestY := Y;
    DeltaY := -DeltaY;
  end;
  Y := TestY;
end;

procedure SelectNewColors;
begin
  if not ChangeColors then exit;
  Colors[1] := Random(MaxColors)+1;
  Colors[2] := Random(MaxColors)+1;
  Colors[3] := Random(MaxColors)+1;
  Colors[4] := Random(MaxColors)+1;
  ColorCount := 3*(1+Random(5));
end;

procedure SelectNewDeltaValues;
begin
  DeltaX1 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaX2 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaY1 := Random(MaxDelta)-(MaxDelta Div 2);
  DeltaY2 := Random(MaxDelta)-(MaxDelta Div 2);
  IncrementCount := 2*(1+Random(4));
end;


procedure SaveCurrentLine(CurrentColors: ColorList);
begin
  with Line[CurrentLine] do
  begin
    LX1 := X1;
    LY1 := Y1;
    LX2 := X2;
    LY2 := Y2;
    LColor := CurrentColors;
  end;
end;

procedure Draw(x1,y1,x2,y2,color:word);
begin
  SetColor(color);
  Graph.Line(x1,y1,x2,y2);
end;

procedure Regenerate;
var
  I: integer;
begin
  Frame;
  for I := 1 to Memory do with Line[I] do begin
    Draw(LX1,LY1,LX2,LY2,LColor[1]);
    Draw(ViewXmax-LX1,LY1,ViewXmax-LX2,LY2,LColor[2]);
    Draw(LX1,ViewYmax-LY1,LX2,ViewYmax-LY2,LColor[3]);
    Draw(ViewXmax-LX1,ViewYmax-LY1,ViewXmax-LX2,ViewYmax-LY2,LColor[4]);
  end;
  WaitToGo;
  Frame;
end;

procedure Updateline;
begin
  Inc(CurrentLine);
  if CurrentLine > Memory then CurrentLine := 1;
  Dec(ColorCount);
  Dec(IncrementCount);
end;

procedure CheckForUserInput;
begin
  if KeyPressed then begin
    Ch := ReadKey;
    if Upcase(Ch) = 'B' then begin
      if BackColor > MaxColors then BackColor := 0 else Inc(BackColor);
      SetBkColor(BackColor);
    end
    else
    if Upcase(Ch) = 'C' then begin
      if ChangeColors then ChangeColors := FALSE else ChangeColors := TRUE;
      ColorCount := 0;
    end
    else if Ch<>#27 then Regenerate;
  end;
end;

procedure DrawCurrentLine;
var c1,c2,c3,c4: integer;
begin
  c1 := Colors[1];
  c2 := Colors[2];
  c3 := Colors[3];
  c4 := Colors[4];
  if MaxColors = 1 then begin
    c2 := c1; c3 := c1; c4 := c1;
  end;

  Draw(X1,Y1,X2,Y2,c1);
  Draw(ViewXmax-X1,Y1,ViewXmax-X2,Y2,c2);
  Draw(X1,ViewYmax-Y1,X2,ViewYmax-Y2,c3);
  if MaxColors = 3 then c4 := Random(3)+1; { alternate colors }
  Draw(ViewXmax-X1,ViewYmax-Y1,ViewXmax-X2,ViewYmax-Y2,c4);
  SaveCurrentLine(Colors);
end;

procedure EraseCurrentLine;
begin
  with Line[CurrentLine] do begin
    Draw(LX1,LY1,LX2,LY2,0);
    Draw(ViewXmax-LX1,LY1,ViewXmax-LX2,LY2,0);
    Draw(LX1,ViewYmax-LY1,LX2,ViewYmax-LY2,0);
    Draw(ViewXmax-LX1,ViewYmax-LY1,ViewXmax-LX2,ViewYmax-LY2,0);
  end;
end;


procedure DoArt;
begin
  SelectNewColors;
  repeat
    EraseCurrentLine;
    if ColorCount = 0 then SelectNewColors;

    if IncrementCount=0 then SelectNewDeltaValues;

    AdjustX(X1,DeltaX1); AdjustX(X2,DeltaX2);
    AdjustY(Y1,DeltaY1); AdjustY(Y2,DeltaY2);

    if Random(5)=3 then begin
      x1 := (x1+x2) div 2; { shorten the lines }
      y2 := (y1+y2) div 2;
    end;

    DrawCurrentLine;
    Updateline;
    CheckForUserInput;
  until Ch=#27;
end;

begin
   Init;
   Frame;
   MessageFrame('Press a key to stop action, Esc quits.');
   DoArt;
   CloseGraph;
   RestoreCrtMode;
   Writeln('The End.');
end.
