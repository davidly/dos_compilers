
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Graph Interface Unit                            }
{                                                       }
{       Copyright (C) 1987,92 Borland International     }
{                                                       }
{*******************************************************}

unit Graph;

interface

const
  { GraphResult error return codes: }
  grOk               =   0;
  grNoInitGraph      =  -1;
  grNotDetected      =  -2;
  grFileNotFound     =  -3;
  grInvalidDriver    =  -4;
  grNoLoadMem        =  -5;
  grNoScanMem        =  -6;
  grNoFloodMem       =  -7;
  grFontNotFound     =  -8;
  grNoFontMem        =  -9;
  grInvalidMode      = -10;
  grError            = -11;   { generic error }
  grIOerror          = -12;
  grInvalidFont      = -13;
  grInvalidFontNum   = -14;
  grInvalidVersion   = -18;

  { define graphics drivers }
  CurrentDriver = -128; { passed to GetModeRange }
  Detect        = 0;    { requests autodetection }
  CGA           = 1;
  MCGA          = 2;
  EGA           = 3;
  EGA64         = 4;
  EGAMono       = 5;
  IBM8514       = 6;
  HercMono      = 7;
  ATT400        = 8;
  VGA           = 9;
  PC3270        = 10;

  { graphics modes for each driver }
  CGAC0      = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
  CGAC1      = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
  CGAC2      = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
  CGAC3      = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
  CGAHi      = 4;  { 640x200 1 page }
  MCGAC0     = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
  MCGAC1     = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
  MCGAC2     = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
  MCGAC3     = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
  MCGAMed    = 4;  { 640x200 1 page }
  MCGAHi     = 5;  { 640x480 1 page }
  EGALo      = 0;  { 640x200 16 color 4 page }
  EGAHi      = 1;  { 640x350 16 color 2 page }
  EGA64Lo    = 0;  { 640x200 16 color 1 page }
  EGA64Hi    = 1;  { 640x350 4 color  1 page }
  EGAMonoHi  = 3;  { 640x350 64K on card, 1 page; 256K on card, 2 page }
  HercMonoHi = 0;  { 720x348 2 page }
  ATT400C0   = 0;  { 320x200 palette 0: LightGreen, LightRed, Yellow; 1 page }
  ATT400C1   = 1;  { 320x200 palette 1: LightCyan, LightMagenta, White; 1 page }
  ATT400C2   = 2;  { 320x200 palette 2: Green, Red, Brown; 1 page }
  ATT400C3   = 3;  { 320x200 palette 3: Cyan, Magenta, LightGray; 1 page }
  ATT400Med  = 4;  { 640x200 1 page }
  ATT400Hi   = 5;  { 640x400 1 page }
  VGALo      = 0;  { 640x200 16 color 4 page }
  VGAMed     = 1;  { 640x350 16 color 2 page }
  VGAHi      = 2;  { 640x480 16 color 1 page }
  PC3270Hi   = 0;  { 720x350 1 page }
  IBM8514LO  = 0;  { 640x480 256 colors }
  IBM8514HI  = 1;  { 1024x768 256 colors }

  { Colors for SetPalette and SetAllPalette: }
  Black        = 0;
  Blue         = 1;
  Green        = 2;
  Cyan         = 3;
  Red          = 4;
  Magenta      = 5;
  Brown        = 6;
  LightGray    = 7;
  DarkGray     = 8;
  LightBlue    = 9;
  LightGreen   = 10;
  LightCyan    = 11;
  LightRed     = 12;
  LightMagenta = 13;
  Yellow       = 14;
  White        = 15;

  { colors for 8514 to set standard EGA colors w/o knowing their values }
  EGABlack             = 0;       { dark colors }
  EGABlue              = 1;
  EGAGreen             = 2;
  EGACyan              = 3;
  EGARed               = 4;
  EGAMagenta           = 5;
  EGABrown             = 20;
  EGALightgray         = 7;
  EGADarkgray          = 56;      { light colors }
  EGALightblue         = 57;
  EGALightgreen        = 58;
  EGALightcyan         = 59;
  EGALightred          = 60;
  EGALightmagenta      = 61;
  EGAYellow            = 62;
  EGAWhite             = 63;

  { Line styles and widths for Get/SetLineStyle: }
  SolidLn    = 0;
  DottedLn   = 1;
  CenterLn   = 2;
  DashedLn   = 3;
  UserBitLn  = 4;       { User-defined line style }

  NormWidth  = 1;
  ThickWidth = 3;

  { Set/GetTextStyle constants: }
  DefaultFont   = 0;    { 8x8 bit mapped font }
  TriplexFont   = 1;    { "Stroked" fonts }
  SmallFont     = 2;
  SansSerifFont = 3;
  GothicFont    = 4;

  HorizDir   = 0;       { left to right }
  VertDir    = 1;       { bottom to top }

  UserCharSize = 0;     { user-defined char size }

  { Clipping constants: }
  ClipOn  = true;
  ClipOff = false;

  { Bar3D constants: }
  TopOn  = true;
  TopOff = false;

  { Fill patterns for Get/SetFillStyle: }
  EmptyFill       = 0;  { fills area in background color }
  SolidFill       = 1;  { fills area in solid fill color }
  LineFill        = 2;  { --- fill }
  LtSlashFill     = 3;  { /// fill }
  SlashFill       = 4;  { /// fill with thick lines }
  BkSlashFill     = 5;  { \\\ fill with thick lines }
  LtBkSlashFill   = 6;  { \\\ fill }
  HatchFill       = 7;  { light hatch fill }
  XHatchFill      = 8;  { heavy cross hatch fill }
  InterleaveFill  = 9;  { interleaving line fill }
  WideDotFill     = 10; { Widely spaced dot fill }
  CloseDotFill    = 11; { Closely spaced dot fill }
  UserFill        = 12; { user defined fill }

  { BitBlt operators for PutImage: }
  NormalPut     = 0;    { MOV }       { left for 1.0 compatibility }
  CopyPut       = 0;    { MOV }
  XORPut        = 1;    { XOR }
  OrPut         = 2;    { OR  }
  AndPut        = 3;    { AND }
  NotPut        = 4;    { NOT }

  { Horizontal and vertical justification for SetTextJustify: }
  LeftText   = 0;
  CenterText = 1;
  RightText  = 2;

  BottomText = 0;
{ CenterText = 1; already defined above }
  TopText    = 2;


const
  MaxColors = 15;
type
  PaletteType = record
      Size   : byte;
      Colors : array[0..MaxColors] of shortint;
    end;

  LineSettingsType = record
      LineStyle : word;
      Pattern   : word;
      Thickness : word;
    end;

  TextSettingsType = record
      Font      : word;
      Direction : word;
      CharSize  : word;
      Horiz     : word;
      Vert      : word;
    end;

  FillSettingsType = record               { Pre-defined fill style }
      Pattern : word;
      Color   : word;
    end;

  FillPatternType = array[1..8] of byte;  { User defined fill style }

  PointType = record
      X, Y : integer;
    end;

  ViewPortType = record
      x1, y1, x2, y2 : integer;
      Clip           : boolean;
    end;

  ArcCoordsType = record
      X, Y           : integer;
      Xstart, Ystart : integer;
      Xend, Yend     : integer;
    end;


var
  GraphGetMemPtr  : Pointer;   { allows user to steal heap allocation }
  GraphFreeMemPtr : Pointer;   { allows user to steal heap de-allocation }

{ *** high-level error handling *** }
function GraphErrorMsg(ErrorCode : integer) : String;
function GraphResult : integer;

{ *** detection, initialization and crt mode routines *** }
procedure DetectGraph(var GraphDriver, GraphMode : integer);
function GetDriverName : string;

procedure InitGraph(var GraphDriver : integer;
		    var GraphMode   : integer;
			PathToDriver : String);

function RegisterBGIfont(Font : pointer) : integer;
function RegisterBGIdriver(Driver : pointer) : integer;
function InstallUserDriver(DriverFileName : string;
			    AutoDetectPtr : pointer) : integer;
function InstallUserFont(FontFileName : string) : integer;
procedure SetGraphBufSize(BufSize : word);
function GetMaxMode : integer;
procedure GetModeRange(GraphDriver : integer; var LoMode, HiMode : integer);
function GetModeName(GraphMode : integer) : string;
procedure SetGraphMode(Mode : integer);
function GetGraphMode : integer;
procedure GraphDefaults;
procedure RestoreCrtMode;
procedure CloseGraph;

function  GetX : integer;
function  GetY : integer;
function  GetMaxX : integer;
function  GetMaxY : integer;

{ *** Screen, viewport, page routines *** }
procedure ClearDevice;
procedure SetViewPort(x1, y1, x2, y2 : integer; Clip : boolean);
procedure GetViewSettings(var ViewPort : ViewPortType);
procedure ClearViewPort;
procedure SetVisualPage(Page : word);
procedure SetActivePage(Page : word);

{ *** point-oriented routines *** }
procedure PutPixel(X, Y : integer; Pixel : word);
function  GetPixel(X, Y : integer) : word;

{ *** line-oriented routines *** }
procedure SetWriteMode(WriteMode : integer);
procedure LineTo(X, Y : integer);
procedure LineRel(Dx, Dy : integer);
procedure MoveTo(X, Y : integer);
procedure MoveRel(Dx, Dy : integer);
procedure Line(x1, y1, x2, y2 : integer);
procedure GetLineSettings(var LineInfo : LineSettingsType);
procedure SetLineStyle(LineStyle : word;
		       Pattern   : word;
		       Thickness : word);

{ *** polygon, fills and figures *** }
procedure Rectangle(x1, y1, x2, y2 : integer);
procedure Bar(x1, y1, x2, y2 : integer);
procedure Bar3D(x1, y1, x2, y2 : integer; Depth : word; Top : boolean);
procedure DrawPoly(NumPoints : word; var PolyPoints);
procedure FillPoly(NumPoints : word; var PolyPoints);
procedure GetFillSettings(var FillInfo : FillSettingsType);
procedure GetFillPattern(var FillPattern : FillPatternType);
procedure SetFillStyle(Pattern : word; Color : word);
procedure SetFillPattern(Pattern : FillPatternType; Color : word);
procedure FloodFill(X, Y : integer; Border : word);

{ *** arc, circle, and other curves *** }
procedure Arc(X, Y : integer; StAngle, EndAngle, Radius : word);
procedure GetArcCoords(var ArcCoords : ArcCoordsType);
procedure Circle(X, Y : integer; Radius : word);
procedure Ellipse(X, Y : integer;
		  StAngle, EndAngle : word;
		  XRadius, YRadius  : word);
procedure FillEllipse(X, Y : integer;
		      XRadius, YRadius  : word);
procedure GetAspectRatio(var Xasp, Yasp : word);
procedure SetAspectRatio(Xasp, Yasp : word);
procedure PieSlice(X, Y : integer; StAngle, EndAngle, Radius : word);
procedure Sector(X, Y : Integer;
		 StAngle, EndAngle,
		 XRadius, YRadius : word);


{ *** color and palette routines *** }
procedure SetBkColor(ColorNum : word);
procedure SetColor(Color : word);
function GetBkColor : word;
function GetColor : word;
procedure SetAllPalette(var Palette);
procedure SetPalette(ColorNum : word; Color : shortint);
procedure GetPalette(var Palette : PaletteType);
function GetPaletteSize : integer;
procedure GetDefaultPalette(var Palette : PaletteType);
function GetMaxColor : word;
procedure SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue : integer);

{ *** bit-image routines *** }
function  ImageSize(x1, y1, x2, y2 : integer) : word;
procedure GetImage(x1, y1, x2, y2 : integer; var BitMap);
procedure PutImage(X, Y : integer; var BitMap; BitBlt : word);

{ *** text routines *** }
procedure GetTextSettings(var TextInfo : TextSettingsType);
procedure OutText(TextString : string);
procedure OutTextXY(X, Y : integer; TextString : string);
procedure SetTextJustify(Horiz, Vert : word);
procedure SetTextStyle(Font, Direction : word; CharSize : word);
procedure SetUserCharSize(MultX, DivX, MultY, DivY : word);
function  TextHeight(TextString : string) : word;
function  TextWidth(TextString : string) : word;


