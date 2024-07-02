
{ Turbo Graphics }
{ Copyright (c) 1985, 1990 by Borland International, Inc. }

program BGIDemo;
(*
  Turbo Pascal 6.0 Borland Graphics Interface (BGI) demonstration
  program. This program shows how to use many features of
  the Graph unit.

  NOTE: to have this demo use the IBM8514 driver, specify a
  conditional define constant "Use8514" (using the {$DEFINE}
  directive or Options\Compiler\Conditional defines) and then
  re-compile.

*)

uses
  Crt, Dos, Graph;


const
  { The five fonts available }
  Fonts : array[0..4] of string[13] =
  ('DefaultFont', 'TriplexFont', 'SmallFont', 'SansSerifFont', 'GothicFont');

  { The five predefined line styles supported }
  LineStyles : array[0..4] of string[9] =
  ('SolidLn', 'DottedLn', 'CenterLn', 'DashedLn', 'UserBitLn');

  { The twelve predefined fill styles supported }
  FillStyles : array[0..11] of string[14] =
  ('EmptyFill', 'SolidFill', 'LineFill', 'LtSlashFill', 'SlashFill',
   'BkSlashFill', 'LtBkSlashFill', 'HatchFill', 'XHatchFill',
   'InterleaveFill', 'WideDotFill', 'CloseDotFill');

  { The two text directions available }
  TextDirect : array[0..1] of string[8] = ('HorizDir', 'VertDir');

  { The Horizontal text justifications available }
  HorizJust  : array[0..2] of string[10] = ('LeftText', 'CenterText', 'RightText');

  { The vertical text justifications available }
  VertJust   : array[0..2] of string[10] = ('BottomText', 'CenterText', 'TopText');

var
  GraphDriver : integer;  { The Graphics device driver }
  GraphMode   : integer;  { The Graphics mode value }
  MaxX, MaxY  : word;     { The maximum resolution of the screen }
  ErrorCode   : integer;  { Reports any graphics errors }
  MaxColor    : word;     { The maximum color value available }
  OldExitProc : Pointer;  { Saves exit procedure address }

{$F+}
procedure MyExitProc;
begin
  ExitProc := OldExitProc; { Restore exit procedure address }
  CloseGraph;              { Shut down the graphics system }
end; { MyExitProc }
{$F-}

procedure Initialize;
{ Initialize graphics and report any errors that may occur }
var
  InGraphicsMode : boolean; { Flags initialization of graphics mode }
  PathToDriver   : string;  { Stores the DOS path to *.BGI & *.CHR }
begin
  { when using Crt and graphics, turn off Crt's memory-mapped writes }
  DirectVideo := False;
  OldExitProc := ExitProc;                { save previous exit proc }
  ExitProc := @MyExitProc;                { insert our exit proc in chain }
  PathToDriver := '';
  repeat

{$IFDEF Use8514}                          { check for Use8514 $DEFINE }
    GraphDriver := IBM8514;
    GraphMode := IBM8514Hi;
{$ELSE}
    GraphDriver := Detect;                { use autodetection }
{$ENDIF}

    InitGraph(GraphDriver, GraphMode, PathToDriver);
    ErrorCode := GraphResult;             { preserve error return }
    if ErrorCode <> grOK then             { error? }
    begin
      Writeln('Graphics error: ', GraphErrorMsg(ErrorCode));
      if ErrorCode = grFileNotFound then  { Can't find driver file }
      begin
        Writeln('Enter full path to BGI driver or type <Ctrl-Break> to quit:');
        Readln(PathToDriver);
        Writeln;
      end
      else
        Halt(1);                          { Some other error: terminate }
    end;
  until ErrorCode = grOK;
  Randomize;                { init random number generator }
  MaxColor := GetMaxColor;  { Get the maximum allowable drawing color }
  MaxX := GetMaxX;          { Get screen resolution values }
  MaxY := GetMaxY;
end; { Initialize }

function Int2Str(L : LongInt) : string;
{ Converts an integer to a string for use with OutText, OutTextXY }
var
  S : string;
begin
  Str(L, S);
  Int2Str := S;
end; { Int2Str }

function RandColor : word;
{ Returns a Random non-zero color value that is within the legal
  color range for the selected device driver and graphics mode.
  MaxColor is set to GetMaxColor by Initialize }
begin
  RandColor := Random(MaxColor)+1;
end; { RandColor }

procedure DefaultColors;
{ Select the maximum color in the Palette for the drawing color }
begin
  SetColor(MaxColor);
end; { DefaultColors }

procedure DrawBorder;
{ Draw a border around the current view port }
var
  ViewPort : ViewPortType;
begin
  DefaultColors;
  SetLineStyle(SolidLn, 0, NormWidth);
  GetViewSettings(ViewPort);
  with ViewPort do
    Rectangle(0, 0, x2-x1, y2-y1);
end; { DrawBorder }

procedure FullPort;
{ Set the view port to the entire screen }
begin
  SetViewPort(0, 0, MaxX, MaxY, ClipOn);
end; { FullPort }

procedure MainWindow(Header : string);
{ Make a default window and view port for demos }
begin
  DefaultColors;                           { Reset the colors }
  ClearDevice;                             { Clear the screen }
  SetTextStyle(DefaultFont, HorizDir, 1);  { Default text font }
  SetTextJustify(CenterText, TopText);     { Left justify text }
  FullPort;                                { Full screen view port }
  OutTextXY(MaxX div 2, 2, Header);        { Draw the header }
  { Draw main window }
  SetViewPort(0, TextHeight('M')+4, MaxX, MaxY-(TextHeight('M')+4), ClipOn);
  DrawBorder;                              { Put a border around it }
  { Move the edges in 1 pixel on all sides so border isn't in the view port }
  SetViewPort(1, TextHeight('M')+5, MaxX-1, MaxY-(TextHeight('M')+5), ClipOn);
end; { MainWindow }

procedure StatusLine(Msg : string);
{ Display a status line at the bottom of the screen }
begin
  FullPort;
  DefaultColors;
  SetTextStyle(DefaultFont, HorizDir, 1);
  SetTextJustify(CenterText, TopText);
  SetLineStyle(SolidLn, 0, NormWidth);
  SetFillStyle(EmptyFill, 0);
  Bar(0, MaxY-(TextHeight('M')+4), MaxX, MaxY);      { Erase old status line }
  Rectangle(0, MaxY-(TextHeight('M')+4), MaxX, MaxY);
  OutTextXY(MaxX div 2, MaxY-(TextHeight('M')+2), Msg);
  { Go back to the main window }
  SetViewPort(1, TextHeight('M')+5, MaxX-1, MaxY-(TextHeight('M')+5), ClipOn);
end; { StatusLine }

procedure WaitToGo;
{ Wait for the user to abort the program or continue }
const
  Esc = #27;
var
  Ch : char;
begin
  StatusLine('Esc aborts or press a key...');
  repeat until KeyPressed;
  Ch := ReadKey;
  if ch = #0 then ch := readkey;      { trap function keys }
  if Ch = Esc then
    Halt(0)                           { terminate program }
  else
    ClearDevice;                      { clear screen, go on with demo }
end; { WaitToGo }

procedure GetDriverAndMode(var DriveStr, ModeStr : string);
{ Return strings describing the current device driver and graphics mode
  for display of status report }
begin
  DriveStr := GetDriverName;
  ModeStr := GetModeName(GetGraphMode);
end; { GetDriverAndMode }

procedure ReportStatus;
{ Display the status of all query functions after InitGraph }
const
  X = 10;
var
  ViewInfo   : ViewPortType;     { Parameters for inquiry procedures }
  LineInfo   : LineSettingsType;
  FillInfo   : FillSettingsType;
  TextInfo   : TextSettingsType;
  Palette    : PaletteType;
  DriverStr  : string;           { Driver and mode strings }
  ModeStr    : string;
  Y          : word;

procedure WriteOut(S : string);
{ Write out a string and increment to next line }
begin
  OutTextXY(X, Y, S);
  Inc(Y, TextHeight('M')+2);
end; { WriteOut }

begin { ReportStatus }
  GetDriverAndMode(DriverStr, ModeStr);   { Get current settings }
  GetViewSettings(ViewInfo);
  GetLineSettings(LineInfo);
  GetFillSettings(FillInfo);
  GetTextSettings(TextInfo);
  GetPalette(Palette);

  Y := 4;
  MainWindow('Status report after InitGraph');
  SetTextJustify(LeftText, TopText);
  WriteOut('Graphics device    : '+DriverStr);
  WriteOut('Graphics mode      : '+ModeStr);
  WriteOut('Screen resolution  : (0, 0, '+Int2Str(GetMaxX)+', '+Int2Str(GetMaxY)+')');
  with ViewInfo do
  begin
    WriteOut('Current view port  : ('+Int2Str(x1)+', '+Int2Str(y1)+', '+Int2Str(x2)+', '+Int2Str(y2)+')');
    if ClipOn then
      WriteOut('Clipping           : ON')
    else
      WriteOut('Clipping           : OFF');
  end;
  WriteOut('Current position   : ('+Int2Str(GetX)+', '+Int2Str(GetY)+')');
  WriteOut('Palette entries    : '+Int2Str(Palette.Size));
  WriteOut('GetMaxColor        : '+Int2Str(GetMaxColor));
  WriteOut('Current color      : '+Int2Str(GetColor));
  with LineInfo do
  begin
    WriteOut('Line style         : '+LineStyles[LineStyle]);
    WriteOut('Line thickness     : '+Int2Str(Thickness));
  end;
  with FillInfo do
  begin
    WriteOut('Current fill style : '+FillStyles[Pattern]);
    WriteOut('Current fill color : '+Int2Str(Color));
  end;
  with TextInfo do
  begin
    WriteOut('Current font       : '+Fonts[Font]);
    WriteOut('Text direction     : '+TextDirect[Direction]);
    WriteOut('Character size     : '+Int2Str(CharSize));
    WriteOut('Horizontal justify : '+HorizJust[Horiz]);
    WriteOut('Vertical justify   : '+VertJust[Vert]);
  end;
  WaitToGo;
end; { ReportStatus }

procedure FillEllipsePlay;
{ Random filled ellipse demonstration }
const
  MaxFillStyles = 12; { patterns 0..11 }
var
  MaxRadius : word;
  FillColor : integer;
begin
  MainWindow('FillEllipse demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius := MaxY div 10;
  SetLineStyle(SolidLn, 0, NormWidth);
  repeat
    FillColor := RandColor;
    SetColor(FillColor);
    SetFillStyle(Random(MaxFillStyles), FillColor);
    FillEllipse(Random(MaxX), Random(MaxY),
                Random(MaxRadius), Random(MaxRadius));
  until KeyPressed;
  WaitToGo;
end; { FillEllipsePlay }

procedure SectorPlay;
{ Draw random sectors on the screen }
const
  MaxFillStyles = 12; { patterns 0..11 }
var
  MaxRadius : word;
  FillColor : integer;
  EndAngle  : integer;
begin
  MainWindow('Sector demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius := MaxY div 10;
  SetLineStyle(SolidLn, 0, NormWidth);
  repeat
    FillColor := RandColor;
    SetColor(FillColor);
    SetFillStyle(Random(MaxFillStyles), FillColor);
    EndAngle := Random(360);
    Sector(Random(MaxX), Random(MaxY), Random(EndAngle), EndAngle,
           Random(MaxRadius), Random(MaxRadius));
  until KeyPressed;
  WaitToGo;
end; { SectorPlay }

procedure WriteModePlay;
{ Demonstrate the SetWriteMode procedure for XOR lines }
const
  DelayValue = 50;  { milliseconds to delay }
var
  ViewInfo      : ViewPortType;
  Color         : word;
  Left, Top     : integer;
  Right, Bottom : integer;
  Step          : integer; { step for rectangle shrinking }
begin
  MainWindow('SetWriteMode demonstration');
  StatusLine('Esc aborts or press a key');
  GetViewSettings(ViewInfo);
  Left := 0;
  Top := 0;
  with ViewInfo do
  begin
    Right := x2-x1;
    Bottom := y2-y1;
  end;
  Step := Bottom div 50;
  SetColor(GetMaxColor);
  Line(Left, Top, Right, Bottom);
  Line(Left, Bottom, Right, Top);
  SetWriteMode(XORPut);                    { Set XOR write mode }
  repeat
    Line(Left, Top, Right, Bottom);        { Draw XOR lines }
    Line(Left, Bottom, Right, Top);
    Rectangle(Left, Top, Right, Bottom);   { Draw XOR rectangle }
    Delay(DelayValue);                     { Wait }
    Line(Left, Top, Right, Bottom);        { Erase lines }
    Line(Left, Bottom, Right, Top);
    Rectangle(Left, Top, Right, Bottom);   { Erase rectangle }
    if (Left+Step < Right) and (Top+Step < Bottom) then
      begin
        Inc(Left, Step);                  { Shrink rectangle }
        Inc(Top, Step);
        Dec(Right, Step);
        Dec(Bottom, Step);
      end
    else
      begin
        Color := RandColor;                { New color }
        SetColor(Color);
        Left := 0;                         { Original large rectangle }
        Top := 0;
        with ViewInfo do
        begin
          Right := x2-x1;
          Bottom := y2-y1;
        end;
      end;
  until KeyPressed;
  SetWriteMode(CopyPut);                   { back to overwrite mode }
  WaitToGo;
end; { WriteModePlay }

procedure AspectRatioPlay;
{ Demonstrate  SetAspectRatio command }
var
  ViewInfo   : ViewPortType;
  CenterX    : integer;
  CenterY    : integer;
  Radius     : word;
  Xasp, Yasp : word;
  i          : integer;
  RadiusStep : word;
begin
  MainWindow('SetAspectRatio demonstration');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    CenterX := (x2-x1) div 2;
    CenterY := (y2-y1) div 2;
    Radius := 3*((y2-y1) div 5);
  end;
  RadiusStep := (Radius div 30);
  Circle(CenterX, CenterY, Radius);
  GetAspectRatio(Xasp, Yasp);
  for i := 1 to 30 do
  begin
    SetAspectRatio(Xasp, Yasp+(I*GetMaxX));    { Increase Y aspect factor }
    Circle(CenterX, CenterY, Radius);
    Dec(Radius, RadiusStep);                   { Shrink radius }
  end;
  Inc(Radius, RadiusStep*30);
  for i := 1 to 30 do
  begin
    SetAspectRatio(Xasp+(I*GetMaxX), Yasp);    { Increase X aspect factor }
    if Radius > RadiusStep then
      Dec(Radius, RadiusStep);                 { Shrink radius }
    Circle(CenterX, CenterY, Radius);
  end;
  SetAspectRatio(Xasp, Yasp);                  { back to original aspect }
  WaitToGo;
end; { AspectRatioPlay }

procedure TextPlay;
{ Demonstrate text justifications and text sizing }
var
  Size : word;
  W, H, X, Y : word;
  ViewInfo : ViewPortType;
begin
  MainWindow('SetTextJustify / SetUserCharSize demo');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    SetTextStyle(TriplexFont, VertDir, 4);
    Y := (y2-y1) - 2;
    SetTextJustify(CenterText, BottomText);
    OutTextXY(2*TextWidth('M'), Y, 'Vertical');
    SetTextStyle(TriplexFont, HorizDir, 4);
    SetTextJustify(LeftText, TopText);
    OutTextXY(2*TextWidth('M'), 2, 'Horizontal');
    SetTextJustify(CenterText, CenterText);
    X := (x2-x1) div 2;
    Y := TextHeight('H');
    for Size := 1 to 4 do
    begin
      SetTextStyle(TriplexFont, HorizDir, Size);
      H := TextHeight('M');
      W := TextWidth('M');
      Inc(Y, H);
      OutTextXY(X, Y, 'Size '+Int2Str(Size));
    end;
    Inc(Y, H div 2);
    SetTextJustify(CenterText, TopText);
    SetUserCharSize(5, 6, 3, 2);
    SetTextStyle(TriplexFont, HorizDir, UserCharSize);
    OutTextXY((x2-x1) div 2, Y, 'User defined size!');
  end;
  WaitToGo;
end; { TextPlay }

procedure TextDump;
{ Dump the complete character sets to the screen }
const
  CGASizes  : array[0..4] of word = (1, 3, 7, 3, 3);
  NormSizes : array[0..4] of word = (1, 4, 7, 4, 4);
var
  Font : word;
  ViewInfo : ViewPortType;
  Ch : char;
begin
  for Font := 0 to 4 do
  begin
    MainWindow(Fonts[Font]+' character set');
    GetViewSettings(ViewInfo);
    with ViewInfo do
    begin
      SetTextJustify(LeftText, TopText);
      MoveTo(2, 3);
      if Font = DefaultFont then
        begin
          SetTextStyle(Font, HorizDir, 1);
          Ch := #0;
          repeat
            OutText(Ch);
            if (GetX + TextWidth('M')) > (x2-x1) then
              MoveTo(2, GetY + TextHeight('M')+3);
            Ch := Succ(Ch);
          until (Ch >= #255);
        end
      else
        begin
          if MaxY < 200 then
            SetTextStyle(Font, HorizDir, CGASizes[Font])
          else
            SetTextStyle(Font, HorizDir, NormSizes[Font]);
          Ch := '!';
          repeat
            OutText(Ch);
            if (GetX + TextWidth('M')) > (x2-x1) then
              MoveTo(2, GetY + TextHeight('M')+3);
            Ch := Succ(Ch);
          until (Ch >= #255);
        end;
    end; { with }
    WaitToGo;
  end; { for loop }
end; { TextDump }

procedure LineToPlay;
{ Demonstrate MoveTo and LineTo commands }
const
  MaxPoints = 15;
var
  Points     : array[0..MaxPoints] of PointType;
  ViewInfo   : ViewPortType;
  I, J       : integer;
  CenterX    : integer;   { The center point of the circle }
  CenterY    : integer;
  Radius     : word;
  StepAngle  : word;
  Xasp, Yasp : word;
  Radians    : real;

function AdjAsp(Value : integer) : integer;
{ Adjust a value for the aspect ratio of the device }
begin
  AdjAsp := (LongInt(Value) * Xasp) div Yasp;
end; { AdjAsp }

begin
  MainWindow('MoveTo, LineTo demonstration');
  GetAspectRatio(Xasp, Yasp);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    CenterX := (x2-x1) div 2;
    CenterY := (y2-y1) div 2;
    Radius := CenterY;
    while (CenterY+AdjAsp(Radius)) < (y2-y1)-20 do
      Inc(Radius);
  end;
  StepAngle := 360 div MaxPoints;
  for I := 0 to MaxPoints - 1 do
  begin
    Radians := (StepAngle * I) * Pi / 180;
    Points[I].X := CenterX + round(Cos(Radians) * Radius);
    Points[I].Y := CenterY - AdjAsp(round(Sin(Radians) * Radius));
  end;
  Circle(CenterX, CenterY, Radius);
  for I := 0 to MaxPoints - 1 do
  begin
    for J := I to MaxPoints - 1 do
    begin
      MoveTo(Points[I].X, Points[I].Y);
      LineTo(Points[J].X, Points[J].Y);
    end;
  end;
  WaitToGo;
end; { LineToPlay }

procedure LineRelPlay;
{ Demonstrate MoveRel and LineRel commands }
const
  MaxPoints = 12;
var
  Poly     : array[1..MaxPoints] of PointType; { Stores a polygon for filling }
  CurrPort : ViewPortType;

procedure DrawTesseract;
{ Draw a Tesseract on the screen with relative move and
  line drawing commands, also create a polygon for filling }
const
  CheckerBoard : FillPatternType = (0, $10, $28, $44, $28, $10, 0, 0);
var
  X, Y, W, H   : integer;

begin
  GetViewSettings(CurrPort);
  with CurrPort do
  begin
    W := (x2-x1) div 9;
    H := (y2-y1) div 8;
    X := ((x2-x1) div 2) - round(2.5 * W);
    Y := ((y2-y1) div 2) - (3 * H);

    { Border around viewport is outer part of polygon }
    Poly[1].X := 0;     Poly[1].Y := 0;
    Poly[2].X := x2-x1; Poly[2].Y := 0;
    Poly[3].X := x2-x1; Poly[3].Y := y2-y1;
    Poly[4].X := 0;     Poly[4].Y := y2-y1;
    Poly[5].X := 0;     Poly[5].Y := 0;
    MoveTo(X, Y);

    { Grab the whole in the polygon as we draw }
    MoveRel(0, H);      Poly[6].X := GetX;  Poly[6].Y := GetY;
    MoveRel(W, -H);     Poly[7].X := GetX;  Poly[7].Y := GetY;
    MoveRel(4*W, 0);    Poly[8].X := GetX;  Poly[8].Y := GetY;
    MoveRel(0, 5*H);    Poly[9].X := GetX;  Poly[9].Y := GetY;
    MoveRel(-W, H);     Poly[10].X := GetX; Poly[10].Y := GetY;
    MoveRel(-4*W, 0);   Poly[11].X := GetX; Poly[11].Y := GetY;
    MoveRel(0, -5*H);   Poly[12].X := GetX; Poly[12].Y := GetY;

    { Fill the polygon with a user defined fill pattern }
    SetFillPattern(CheckerBoard, MaxColor);
    FillPoly(12, Poly);

    MoveRel(W, -H);
    LineRel(0, 5*H);   LineRel(2*W, 0);    LineRel(0, -3*H);
    LineRel(W, -H);    LineRel(0, 5*H);    MoveRel(0, -5*H);
    LineRel(-2*W, 0);  LineRel(0, 3*H);    LineRel(-W, H);
    MoveRel(W, -H);    LineRel(W, 0);      MoveRel(0, -2*H);
    LineRel(-W, 0);

    { Flood fill the center }
    FloodFill((x2-x1) div 2, (y2-y1) div 2, MaxColor);
  end;
end; { DrawTesseract }

begin
  MainWindow('LineRel / MoveRel demonstration');
  GetViewSettings(CurrPort);
  with CurrPort do
    { Move the viewport out 1 pixel from each end }
    SetViewPort(x1-1, y1-1, x2+1, y2+1, ClipOn);
  DrawTesseract;
  WaitToGo;
end; { LineRelPlay }

procedure PiePlay;
{ Demonstrate  PieSlice and GetAspectRatio commands }
var
  ViewInfo   : ViewPortType;
  CenterX    : integer;
  CenterY    : integer;
  Radius     : word;
  Xasp, Yasp : word;
  X, Y       : integer;

function AdjAsp(Value : integer) : integer;
{ Adjust a value for the aspect ratio of the device }
begin
  AdjAsp := (LongInt(Value) * Xasp) div Yasp;
end; { AdjAsp }

procedure GetTextCoords(AngleInDegrees, Radius : word; var X, Y : integer);
{ Get the coordinates of text for pie slice labels }
var
  Radians : real;
begin
  Radians := AngleInDegrees * Pi / 180;
  X := round(Cos(Radians) * Radius);
  Y := round(Sin(Radians) * Radius);
end; { GetTextCoords }

begin
  MainWindow('PieSlice / GetAspectRatio demonstration');
  GetAspectRatio(Xasp, Yasp);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    CenterX := (x2-x1) div 2;
    CenterY := ((y2-y1) div 2) + 20;
    Radius := (y2-y1) div 3;
    while AdjAsp(Radius) < round((y2-y1) / 3.6) do
      Inc(Radius);
  end;
  SetTextStyle(TriplexFont, HorizDir, 4);
  SetTextJustify(CenterText, TopText);
  OutTextXY(CenterX, 0, 'This is a pie chart!');

  SetTextStyle(TriplexFont, HorizDir, 3);

  SetFillStyle(SolidFill, RandColor);
  PieSlice(CenterX+10, CenterY-AdjAsp(10), 0, 90, Radius);
  GetTextCoords(45, Radius, X, Y);
  SetTextJustify(LeftText, BottomText);
  OutTextXY(CenterX+10+X+TextWidth('H'), CenterY-AdjAsp(10+Y), '25 %');

  SetFillStyle(HatchFill, RandColor);
  PieSlice(CenterX, CenterY, 225, 360, Radius);
  GetTextCoords(293, Radius, X, Y);
  SetTextJustify(LeftText, TopText);
  OutTextXY(CenterX+X+TextWidth('H'), CenterY-AdjAsp(Y), '37.5 %');

  SetFillStyle(InterleaveFill, RandColor);
  PieSlice(CenterX-10, CenterY, 135, 225, Radius);
  GetTextCoords(180, Radius, X, Y);
  SetTextJustify(RightText, CenterText);
  OutTextXY(CenterX-10+X-TextWidth('H'), CenterY-AdjAsp(Y), '25 %');

  SetFillStyle(WideDotFill, RandColor);
  PieSlice(CenterX, CenterY, 90, 135, Radius);
  GetTextCoords(112, Radius, X, Y);
  SetTextJustify(RightText, BottomText);
  OutTextXY(CenterX+X-TextWidth('H'), CenterY-AdjAsp(Y), '12.5 %');

  WaitToGo;
end; { PiePlay }

procedure Bar3DPlay;
{ Demonstrate Bar3D command }
const
  NumBars   = 7;  { The number of bars drawn }
  BarHeight : array[1..NumBars] of byte = (1, 3, 2, 5, 4, 2, 1);
  YTicks    = 5;  { The number of tick marks on the Y axis }
var
  ViewInfo : ViewPortType;
  H        : word;
  XStep    : real;
  YStep    : real;
  I, J     : integer;
  Depth    : word;
  Color    : word;
begin
  MainWindow('Bar3D / Rectangle demonstration');
  H := 3*TextHeight('M');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText, TopText);
  SetTextStyle(TriplexFont, HorizDir, 4);
  OutTextXY(MaxX div 2, 6, 'These are 3D bars !');
  SetTextStyle(DefaultFont, HorizDir, 1);
  with ViewInfo do
    SetViewPort(x1+50, y1+40, x2-50, y2-10, ClipOn);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Line(H, H, H, (y2-y1)-H);
    Line(H, (y2-y1)-H, (x2-x1)-H, (y2-y1)-H);
    YStep := ((y2-y1)-(2*H)) / YTicks;
    XStep := ((x2-x1)-(2*H)) / NumBars;
    J := (y2-y1)-H;
    SetTextJustify(CenterText, CenterText);

    { Draw the Y axis and ticks marks }
    for I := 0 to Yticks do
    begin
      Line(H div 2, J, H, J);
      OutTextXY(0, J, Int2Str(I));
      J := Round(J-Ystep);
    end;


    Depth := trunc(0.25 * XStep);    { Calculate depth of bar }

    { Draw X axis, bars, and tick marks }
    SetTextJustify(CenterText, TopText);
    J := H;
    for I := 1 to Succ(NumBars) do
    begin
      SetColor(MaxColor);
      Line(J, (y2-y1)-H, J, (y2-y1-3)-(H div 2));
      OutTextXY(J, (y2-y1)-(H div 2), Int2Str(I-1));
      if I <> Succ(NumBars) then
      begin
        Color := RandColor;
        SetFillStyle(I, Color);
        SetColor(Color);
        Bar3D(J, round((y2-y1-H)-(BarHeight[I] * Ystep)),
                 round(J+Xstep-Depth), round((y2-y1)-H-1), Depth, TopOn);
        J := Round(J+Xstep);
      end;
    end;

  end;
  WaitToGo;
end; { Bar3DPlay }

procedure BarPlay;
{ Demonstrate Bar command }
const
  NumBars   = 5;
  BarHeight : array[1..NumBars] of byte = (1, 3, 5, 2, 4);
  Styles    : array[1..NumBars] of byte = (1, 3, 10, 5, 9);
var
  ViewInfo  : ViewPortType;
  BarNum    : word;
  H         : word;
  XStep     : real;
  YStep     : real;
  I, J      : integer;
  Color     : word;
begin
  MainWindow('Bar / Rectangle demonstration');
  H := 3*TextHeight('M');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText, TopText);
  SetTextStyle(TriplexFont, HorizDir, 4);
  OutTextXY(MaxX div 2, 6, 'These are 2D bars !');
  SetTextStyle(DefaultFont, HorizDir, 1);
  with ViewInfo do
    SetViewPort(x1+50, y1+30, x2-50, y2-10, ClipOn);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Line(H, H, H, (y2-y1)-H);
    Line(H, (y2-y1)-H, (x2-x1)-H, (y2-y1)-H);
    YStep := ((y2-y1)-(2*H)) / NumBars;
    XStep := ((x2-x1)-(2*H)) / NumBars;
    J := (y2-y1)-H;
    SetTextJustify(CenterText, CenterText);

    { Draw Y axis with tick marks }
    for I := 0 to NumBars do
    begin
      Line(H div 2, J, H, J);
      OutTextXY(0, J, Int2Str(i));
      J := Round(J-Ystep);
    end;

    { Draw X axis, bars, and tick marks }
    J := H;
    SetTextJustify(CenterText, TopText);
    for I := 1 to Succ(NumBars) do
    begin
      SetColor(MaxColor);
      Line(J, (y2-y1)-H, J, (y2-y1-3)-(H div 2));
      OutTextXY(J, (y2-y1)-(H div 2), Int2Str(I));
      if I <> Succ(NumBars) then
      begin
        Color := RandColor;
        SetFillStyle(Styles[I], Color);
        SetColor(Color);
        Bar(J, round((y2-y1-H)-(BarHeight[I] * Ystep)), round(J+Xstep), (y2-y1)-H-1);
        Rectangle(J, round((y2-y1-H)-(BarHeight[I] * Ystep)), round(J+Xstep), (y2-y1)-H-1);
      end;
      J := Round(J+Xstep);
    end;

  end;
  WaitToGo;
end; { BarPlay }

procedure CirclePlay;
{ Draw random circles on the screen }
var
  MaxRadius : word;
begin
  MainWindow('Circle demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius := MaxY div 10;
  SetLineStyle(SolidLn, 0, NormWidth);
  repeat
    SetColor(RandColor);
    Circle(Random(MaxX), Random(MaxY), Random(MaxRadius));
  until KeyPressed;
  WaitToGo;
end; { CirclePlay }


procedure RandBarPlay;
{ Draw random bars on the screen }
var
  MaxWidth  : integer;
  MaxHeight : integer;
  ViewInfo  : ViewPortType;
  Color     : word;
begin
  MainWindow('Random Bars');
  StatusLine('Esc aborts or press a key');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    MaxWidth := x2-x1;
    MaxHeight := y2-y1;
  end;
  repeat
    Color := RandColor;
    SetColor(Color);
    SetFillStyle(Random(CloseDotFill)+1, Color);
    Bar3D(Random(MaxWidth), Random(MaxHeight),
          Random(MaxWidth), Random(MaxHeight), 0, TopOff);
  until KeyPressed;
  WaitToGo;
end; { RandBarPlay }

procedure ArcPlay;
{ Draw random arcs on the screen }
var
  MaxRadius : word;
  EndAngle : word;
  ArcInfo : ArcCoordsType;
begin
  MainWindow('Arc / GetArcCoords demonstration');
  StatusLine('Esc aborts or press a key');
  MaxRadius := MaxY div 10;
  repeat
    SetColor(RandColor);
    EndAngle := Random(360);
    SetLineStyle(SolidLn, 0, NormWidth);
    Arc(Random(MaxX), Random(MaxY), Random(EndAngle), EndAngle, Random(MaxRadius));
    GetArcCoords(ArcInfo);
    with ArcInfo do
    begin
      Line(X, Y, XStart, YStart);
      Line(X, Y, Xend, Yend);
    end;
  until KeyPressed;
  WaitToGo;
end; { ArcPlay }

procedure PutPixelPlay;
{ Demonstrate the PutPixel and GetPixel commands }
const
  Seed   = 1962; { A seed for the random number generator }
  NumPts = 2000; { The number of pixels plotted }
  Esc    = #27;
var
  I : word;
  X, Y, Color : word;
  XMax, YMax  : integer;
  ViewInfo    : ViewPortType;
begin
  MainWindow('PutPixel / GetPixel demonstration');
  StatusLine('Esc aborts or press a key...');

  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    XMax := (x2-x1-1);
    YMax := (y2-y1-1);
  end;

  while not KeyPressed do
  begin
    { Plot random pixels }
    RandSeed := Seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      PutPixel(Random(XMax)+1, Random(YMax)+1, RandColor);
    end;

    { Erase pixels }
    RandSeed := Seed;
    I := 0;
    while (not KeyPressed) and (I < NumPts) do
    begin
      Inc(I);
      X := Random(XMax)+1;
      Y := Random(YMax)+1;
      Color := GetPixel(X, Y);
      if Color = RandColor then
        PutPixel(X, Y, 0);
    end;
  end;
  WaitToGo;
end; { PutPixelPlay }

procedure PutImagePlay;
{ Demonstrate the GetImage and PutImage commands }

const
  r  = 20;
  StartX = 100;
  StartY = 50;

var
  CurPort : ViewPortType;

procedure MoveSaucer(var X, Y : integer; Width, Height : integer);
var
  Step : integer;
begin
  Step := Random(2*r);
  if Odd(Step) then
    Step := -Step;
  X := X + Step;
  Step := Random(r);
  if Odd(Step) then
    Step := -Step;
  Y := Y + Step;

  { Make saucer bounce off viewport walls }
  with CurPort do
  begin
    if (x1 + X + Width - 1 > x2) then
      X := x2-x1 - Width + 1
    else
      if (X < 0) then
        X := 0;
    if (y1 + Y + Height - 1 > y2) then
      Y := y2-y1 - Height + 1
    else
      if (Y < 0) then
        Y := 0;
  end;
end; { MoveSaucer }

var
  Pausetime : word;
  Saucer    : pointer;
  X, Y      : integer;
  ulx, uly  : word;
  lrx, lry  : word;
  Size      : word;
  I         : word;
begin
  ClearDevice;
  FullPort;

  { PaintScreen }
  ClearDevice;
  MainWindow('GetImage / PutImage Demonstration');
  StatusLine('Esc aborts or press a key...');
  GetViewSettings(CurPort);

  { DrawSaucer }
  Ellipse(StartX, StartY, 0, 360, r, (r div 3)+2);
  Ellipse(StartX, StartY-4, 190, 357, r, r div 3);
  Line(StartX+7, StartY-6, StartX+10, StartY-12);
  Circle(StartX+10, StartY-12, 2);
  Line(StartX-7, StartY-6, StartX-10, StartY-12);
  Circle(StartX-10, StartY-12, 2);
  SetFillStyle(SolidFill, MaxColor);
  FloodFill(StartX+1, StartY+4, GetColor);

  { ReadSaucerImage }
  ulx := StartX-(r+1);
  uly := StartY-14;
  lrx := StartX+(r+1);
  lry := StartY+(r div 3)+3;

  Size := ImageSize(ulx, uly, lrx, lry);
  GetMem(Saucer, Size);
  GetImage(ulx, uly, lrx, lry, Saucer^);
  PutImage(ulx, uly, Saucer^, XORput);               { erase image }

  { Plot some "stars" }
  for I := 1 to 1000 do
    PutPixel(Random(MaxX), Random(MaxY), RandColor);
  X := MaxX div 2;
  Y := MaxY div 2;
  PauseTime := 70;

  { Move the saucer around }
  repeat
    PutImage(X, Y, Saucer^, XORput);                 { draw image }
    Delay(PauseTime);
    PutImage(X, Y, Saucer^, XORput);                 { erase image }
    MoveSaucer(X, Y, lrx - ulx + 1, lry - uly + 1);  { width/height }
  until KeyPressed;
  FreeMem(Saucer, size);
  WaitToGo;
end; { PutImagePlay }

procedure PolyPlay;
{ Draw random polygons with random fill styles on the screen }
const
  MaxPts = 5;
type
  PolygonType = array[1..MaxPts] of PointType;
var
  Poly : PolygonType;
  I, Color : word;
begin
  MainWindow('FillPoly demonstration');
  StatusLine('Esc aborts or press a key...');
  repeat
    Color := RandColor;
    SetFillStyle(Random(11)+1, Color);
    SetColor(Color);
    for I := 1 to MaxPts do
      with Poly[I] do
      begin
        X := Random(MaxX);
        Y := Random(MaxY);
      end;
    FillPoly(MaxPts, Poly);
  until KeyPressed;
  WaitToGo;
end; { PolyPlay }

procedure FillStylePlay;
{ Display all of the predefined fill styles available }
var
  Style    : word;
  Width    : word;
  Height   : word;
  X, Y     : word;
  I, J     : word;
  ViewInfo : ViewPortType;

procedure DrawBox(X, Y : word);
begin
  SetFillStyle(Style, MaxColor);
  with ViewInfo do
    Bar(X, Y, X+Width, Y+Height);
  Rectangle(X, Y, X+Width, Y+Height);
  OutTextXY(X+(Width div 2), Y+Height+4, Int2Str(Style));
  Inc(Style);
end; { DrawBox }

begin
  MainWindow('Pre-defined fill styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Width := 2 * ((x2+1) div 13);
    Height := 2 * ((y2-10) div 10);
  end;
  X := Width div 2;
  Y := Height div 2;
  Style := 0;
  for J := 1 to 3 do
  begin
    for I := 1 to 4 do
    begin
      DrawBox(X, Y);
      Inc(X, (Width div 2) * 3);
    end;
    X := Width div 2;
    Inc(Y, (Height div 2) * 3);
  end;
  SetTextJustify(LeftText, TopText);
  WaitToGo;
end; { FillStylePlay }

procedure FillPatternPlay;
{ Display some user defined fill patterns }
const
  Patterns : array[0..11] of FillPatternType = (
  ($AA, $55, $AA, $55, $AA, $55, $AA, $55),
  ($33, $33, $CC, $CC, $33, $33, $CC, $CC),
  ($F0, $F0, $F0, $F0, $F, $F, $F, $F),
  (0, $10, $28, $44, $28, $10, 0, 0),
  (0, $70, $20, $27, $25, $27, $4, $4),
  (0, 0, 0, $18, $18, 0, 0, 0),
  (0, 0, $3C, $3C, $3C, $3C, 0, 0),
  (0, $7E, $7E, $7E, $7E, $7E, $7E, 0),
  (0, 0, $22, $8, 0, $22, $1C, 0),
  ($FF, $7E, $3C, $18, $18, $3C, $7E, $FF),
  (0, $10, $10, $7C, $10, $10, 0, 0),
  (0, $42, $24, $18, $18, $24, $42, 0));
var
  Style    : word;
  Width    : word;
  Height   : word;
  X, Y     : word;
  I, J     : word;
  ViewInfo : ViewPortType;

procedure DrawBox(X, Y : word);
begin
  SetFillPattern(Patterns[Style], MaxColor);
  with ViewInfo do
    Bar(X, Y, X+Width, Y+Height);
  Rectangle(X, Y, X+Width, Y+Height);
  Inc(Style);
end; { DrawBox }

begin
  MainWindow('User defined fill styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Width := 2 * ((x2+1) div 13);
    Height := 2 * ((y2-10) div 10);
  end;
  X := Width div 2;
  Y := Height div 2;
  Style := 0;
  for J := 1 to 3 do
  begin
    for I := 1 to 4 do
    begin
      DrawBox(X, Y);
      Inc(X, (Width div 2) * 3);
    end;
    X := Width div 2;
    Inc(Y, (Height div 2) * 3);
  end;
  SetTextJustify(LeftText, TopText);
  WaitToGo;
end; { FillPatternPlay }

procedure ColorPlay;
{ Display all of the colors available for the current driver and mode }
var
  Color    : word;
  Width    : word;
  Height   : word;
  X, Y     : word;
  I, J     : word;
  ViewInfo : ViewPortType;

procedure DrawBox(X, Y : word);
begin
  SetFillStyle(SolidFill, Color);
  SetColor(Color);
  with ViewInfo do
    Bar(X, Y, X+Width, Y+Height);
  Rectangle(X, Y, X+Width, Y+Height);
  Color := GetColor;
  if Color = 0 then
  begin
    SetColor(MaxColor);
    Rectangle(X, Y, X+Width, Y+Height);
  end;
  OutTextXY(X+(Width div 2), Y+Height+4, Int2Str(Color));
  Color := Succ(Color) mod (MaxColor + 1);
end; { DrawBox }

begin
  MainWindow('Color demonstration');
  Color := 1;
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Width := 2 * ((x2+1) div 16);
    Height := 2 * ((y2-10) div 10);
  end;
  X := Width div 2;
  Y := Height div 2;
  for J := 1 to 3 do
  begin
    for I := 1 to 5 do
    begin
      DrawBox(X, Y);
      Inc(X, (Width div 2) * 3);
    end;
    X := Width div 2;
    Inc(Y, (Height div 2) * 3);
  end;
  WaitToGo;
end; { ColorPlay }

procedure PalettePlay;
{ Demonstrate the use of the SetPalette command }
const
  XBars = 15;
  YBars = 10;
var
  I, J     : word;
  X, Y     : word;
  Color    : word;
  ViewInfo : ViewPortType;
  Width    : word;
  Height   : word;
  OldPal   : PaletteType;
begin
  GetPalette(OldPal);
  MainWindow('Palette demonstration');
  StatusLine('Press any key...');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Width := (x2-x1) div XBars;
    Height := (y2-y1) div YBars;
  end;
  X := 0; Y := 0;
  Color := 0;
  for J := 1 to YBars do
  begin
    for I := 1 to XBars do
    begin
      SetFillStyle(SolidFill, Color);
      Bar(X, Y, X+Width, Y+Height);
      Inc(X, Width+1);
      Inc(Color);
      Color := Color mod (MaxColor+1);
    end;
    X := 0;
    Inc(Y, Height+1);
  end;
  repeat
    SetPalette(Random(GetMaxColor + 1), Random(65));
  until KeyPressed;
  SetAllPalette(OldPal);
  WaitToGo;
end; { PalettePlay }

procedure CrtModePlay;
{ Demonstrate the use of RestoreCrtMode and SetGraphMode }
var
  ViewInfo : ViewPortType;
  Ch       : char;
begin
  MainWindow('SetGraphMode / RestoreCrtMode demo');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText, CenterText);
  with ViewInfo do
  begin
    OutTextXY((x2-x1) div 2, (y2-y1) div 2, 'Now you are in graphics mode');
    StatusLine('Press any key for text mode...');
    repeat until KeyPressed;
    Ch := ReadKey;
    if ch = #0 then ch := readkey;    { trap function keys }
    RestoreCrtmode;
    Writeln('Now you are in text mode.');
    Write('Press any key to go back to graphics...');
    repeat until KeyPressed;
    Ch := ReadKey;
    if ch = #0 then ch := readkey;    { trap function keys }
    SetGraphMode(GetGraphMode);
    MainWindow('SetGraphMode / RestoreCrtMode demo');
    SetTextJustify(CenterText, CenterText);
    OutTextXY((x2-x1) div 2, (y2-y1) div 2, 'Back in graphics mode...');
  end;
  WaitToGo;
end; { CrtModePlay }

procedure LineStylePlay;
{ Demonstrate the predefined line styles available }
var
  Style    : word;
  Step     : word;
  X, Y     : word;
  ViewInfo : ViewPortType;

begin
  ClearDevice;
  DefaultColors;
  MainWindow('Pre-defined line styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    X := 35;
    Y := 10;
    Step := (x2-x1) div 11;
    SetTextJustify(LeftText, TopText);
    OutTextXY(X, Y, 'NormWidth');
    SetTextJustify(CenterText, TopText);
    for Style := 0 to 3 do
    begin
      SetLineStyle(Style, 0, NormWidth);
      Line(X, Y+20, X, Y2-40);
      OutTextXY(X, Y2-30, Int2Str(Style));
      Inc(X, Step);
    end;
    Inc(X, 2*Step);
    SetTextJustify(LeftText, TopText);
    OutTextXY(X, Y, 'ThickWidth');
    SetTextJustify(CenterText, TopText);
    for Style := 0 to 3 do
    begin
      SetLineStyle(Style, 0, ThickWidth);
      Line(X, Y+20, X, Y2-40);
      OutTextXY(X, Y2-30, Int2Str(Style));
      Inc(X, Step);
    end;
  end;
  SetTextJustify(LeftText, TopText);
  WaitToGo;
end; { LineStylePlay }

procedure UserLineStylePlay;
{ Demonstrate user defined line styles }
var
  Style    : word;
  X, Y, I  : word;
  ViewInfo : ViewPortType;
begin
  MainWindow('User defined line styles');
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    X := 4;
    Y := 10;
    Style := 0;
    I := 0;
    while X < X2-4 do
    begin
      {$B+}
      Style := Style or (1 shl (I mod 16));
      {$B-}
      SetLineStyle(UserBitLn, Style, NormWidth);
      Line(X, Y, X, (y2-y1)-Y);
      Inc(X, 5);
      Inc(I);
      if Style = 65535 then
      begin
        I := 0;
        Style := 0;
      end;
    end;
  end;
  WaitToGo;
end; { UserLineStylePlay }


procedure SayGoodbye;
{ Say goodbye and then exit the program }
var
  ViewInfo : ViewPortType;
begin
  MainWindow('');
  GetViewSettings(ViewInfo);
  SetTextStyle(TriplexFont, HorizDir, 4);
  SetTextJustify(CenterText, CenterText);
  with ViewInfo do
    OutTextXY((x2-x1) div 2, (y2-y1) div 2, 'That''s all folks!');
  StatusLine('Press any key to quit...');
  repeat until KeyPressed;
end; { SayGoodbye }

begin { program body }
  Initialize;
  ReportStatus;

  AspectRatioPlay;
  FillEllipsePlay;
  SectorPlay;
  WriteModePlay;

  ColorPlay;
  { PalettePlay only intended to work on these drivers: }
  if (GraphDriver = EGA) or
     (GraphDriver = EGA64) or
     (GraphDriver = VGA) then
    PalettePlay;
  PutPixelPlay;
  PutImagePlay;
  RandBarPlay;
  BarPlay;
  Bar3DPlay;
  ArcPlay;
  CirclePlay;
  PiePlay;
  LineToPlay;
  LineRelPlay;
  LineStylePlay;
  UserLineStylePlay;
  TextDump;
  TextPlay;
  CrtModePlay;
  FillStylePlay;
  FillPatternPlay;
  PolyPlay;
  SayGoodbye;
  CloseGraph;
end.
