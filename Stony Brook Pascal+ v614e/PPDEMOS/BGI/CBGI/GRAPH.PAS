UNIT Graph;
(*$//NOMODINIT*)

INTERFACE

CONST
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
    ClipOn  = TRUE;
    ClipOff = FALSE;

    { Bar3D constants: }
    TopOn  = TRUE;
    TopOff = FALSE;

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

CONST
    MaxColors	= 15;
TYPE
    PaletteType =
    RECORD
	Size	: BYTE;
	Colors	: ARRAY [0..MaxColors] of SHORTINT;
    END;

    LineSettingsType =
    RECORD
	LineStyle : WORD;
	Pattern   : WORD;
	Thickness : WORD;
    END;

    TextSettingsType =
    RECORD
	Font	  : WORD;
	Direction : WORD;
	CharSize  : WORD;
	Horiz	  : WORD;
	Vert	  : WORD;
    END;

    FillSettingsType =
    RECORD               { Pre-defined fill style }
	Pattern	: WORD;
	Color	: WORD;
    END;

  FillPatternType = ARRAY [1..8] OF BYTE;  { User defined fill style }

    PointType =
    RECORD
	X	: INTEGER;
	Y	: INTEGER;
    END;

    ViewPortType =
    RECORD
	x1	: INTEGER;
	y1	: INTEGER;
	x2	: INTEGER;
	y2	: INTEGER;
	Clip	: BOOLEAN;
	Dummy   : BOOLEAN;
    END;

    ArcCoordsType =
    RECORD
	X	: INTEGER;
	Y	: INTEGER;
	Xstart	: INTEGER;
	Ystart	: INTEGER;
	Xend	: INTEGER;
	Yend	: INTEGER;
    END;

{ Default memory allocators, they just call GetMem and FreeMem }

PROCEDURE MyGetMem(VAR p : POINTER; size : word);

PROCEDURE MyFreeMem(VAR p : POINTER; size : word);

CONST
    GraphGetMemPtr : POINTER = @MyGetMem;
    GraphFreeMemPtr : POINTER = @MyFreeMem;

{ these two procs are called from the C BGI code }

FUNCTION CGetMem(size : WORD) : POINTER [C]; FAR; EXTERNAL '__graphgetmem';

PROCEDURE CFreeMem(p : POINTER; size : WORD)
		    [C]; FAR; EXTERNAL '__graphfreemem';

{ BGI procedure declarations }
{ they call the C BGI directly where possible }
{ indirectly when necessary for such things as string conversions }

PROCEDURE arc (x, y : INTEGER; stangle, endangle, radius : WORD)
	[C]; FAR; EXTERNAL '_arc';

PROCEDURE bar (left, top, right, bottom : INTEGER)
	[C]; FAR; EXTERNAL '_bar';

PROCEDURE bar3d (left, top, right, bottom : INTEGER; depth : WORD; topflag : BOOLEAN);

PROCEDURE circle (x, y : INTEGER; radius : WORD)
	[C]; FAR; EXTERNAL '_circle';

PROCEDURE cleardevice()
	[C]; FAR; EXTERNAL '_cleardevice';

PROCEDURE clearviewport()
	[C]; FAR; EXTERNAL '_clearviewport';

PROCEDURE closegraph()
	[C]; FAR; EXTERNAL '_closegraph';

PROCEDURE detectgraph (VAR graphdriver, graphmode : INTEGER)
	[C]; FAR; EXTERNAL '_detectgraph';

PROCEDURE drawpoly (numpoints : WORD; VAR polypoints)
	[C]; FAR; EXTERNAL '_drawpoly';

PROCEDURE ellipse (x, y : INTEGER; stangle, endangle, xradius, yradius : WORD)
	[C]; FAR; EXTERNAL '_ellipse';

PROCEDURE fillellipse (x, y : INTEGER; xradius, yradius : WORD)
	[C]; FAR; EXTERNAL '_fillellipse';

PROCEDURE fillpoly (numpoints : WORD; VAR polypoints)
	[C]; FAR; EXTERNAL '_fillpoly';

PROCEDURE floodfill (x, y : INTEGER; border : WORD)
	[C]; FAR; EXTERNAL '_floodfill';

PROCEDURE getarccoords (VAR arccords : arccoordstype)
	[C]; FAR; EXTERNAL '_getarccoords';

PROCEDURE getaspectratio (VAR xasp, yasp : WORD)
	[C]; FAR; EXTERNAL '_getaspectratio';

FUNCTION getbkcolor : WORD
	[C]; FAR; EXTERNAL '_getbkcolor';

FUNCTION getcolor : WORD
	[C]; FAR; EXTERNAL '_getcolor';

PROCEDURE getdefaultpalette (VAR palette : PaletteType);

FUNCTION getdrivername : STRING;

PROCEDURE getfillpattern (VAR pattern : FillPatternType)
	[C]; FAR; EXTERNAL '_getfillpattern';

PROCEDURE getfillsettings (VAR fillinfo : FillSettingsType)
	[C]; FAR; EXTERNAL '_getfillsettings';

FUNCTION getgraphmode : INTEGER
	[C]; FAR; EXTERNAL '_getgraphmode';

PROCEDURE getimage (left, top, right, bottom : INTEGER; VAR bitmap)
	[C]; FAR; EXTERNAL '_getimage';

PROCEDURE getlinesettings (VAR lineinfo : LineSettingsType)
	[C]; FAR; EXTERNAL '_getlinesettings';

FUNCTION getmaxcolor : WORD
	[C]; FAR; EXTERNAL '_getmaxcolor';

FUNCTION getmaxmode : WORD
	[C]; FAR; EXTERNAL '_getmaxmode';

FUNCTION getmaxx : INTEGER
	[C]; FAR; EXTERNAL '_getmaxx';

FUNCTION getmaxy : INTEGER
	[C]; FAR; EXTERNAL '_getmaxy';

FUNCTION getmodename (mode_number : INTEGER) : STRING;

PROCEDURE getmoderange (graphdriver : INTEGER; VAR lomode, himode : INTEGER)
	[C]; FAR; EXTERNAL '_getmoderange';

PROCEDURE getpalette (VAR palette : PaletteType)
	[C]; FAR; EXTERNAL '_getpalette';

FUNCTION getpalettesize : INTEGER
	[C]; FAR; EXTERNAL '_getpalettesize';

FUNCTION getpixel  (x, y : INTEGER) : WORD
	[C]; FAR; EXTERNAL '_getpixel';

PROCEDURE gettextsettings (VAR texttypeinfo : TextSettingsType)
	[C]; FAR; EXTERNAL '_gettextsettings';

PROCEDURE getviewsettings (VAR viewport : ViewPortType)
	[C]; FAR; EXTERNAL '_getviewsettings';

FUNCTION getx : INTEGER
	[C]; FAR; EXTERNAL '_getx';

FUNCTION gety : INTEGER
	[C]; FAR; EXTERNAL '_gety';

PROCEDURE graphdefaults()
	[C]; FAR; EXTERNAL '_graphdefaults';

FUNCTION grapherrormsg (errorcode : INTEGER) : STRING;

FUNCTION graphresult : INTEGER
	[C]; FAR; EXTERNAL '_graphresult';

FUNCTION imagesize (left, top, right, bottom : INTEGER) : WORD
	[C]; FAR; EXTERNAL '_imagesize';

PROCEDURE initgraph (VAR graphdriver, graphmode : INTEGER; pathtodriver : STRING);

FUNCTION installuserdriver (name : STRING; autodetectptr : POINTER) : INTEGER;

FUNCTION installuserfont (name : STRING) : INTEGER;

PROCEDURE line (x1, y1, x2, y2 : INTEGER)
	[C]; FAR; EXTERNAL '_line';

PROCEDURE linerel (dx, dy : INTEGER)
	[C]; FAR; EXTERNAL '_linerel';

PROCEDURE lineto (x, y : INTEGER)
	[C]; FAR; EXTERNAL '_lineto';

PROCEDURE moverel (dx, dy : INTEGER)
	[C]; FAR; EXTERNAL '_moverel';

PROCEDURE moveto (x, y : INTEGER)
	[C]; FAR; EXTERNAL '_moveto';

PROCEDURE outtext (textstring : STRING);

PROCEDURE outtextxy (x, y : INTEGER; textstring : STRING);

PROCEDURE pieslice (x, y : INTEGER; stangle, endangle, radius : WORD)
	[C]; FAR; EXTERNAL '_pieslice';

PROCEDURE putimage (left, top : INTEGER; VAR bitmap; op : WORD)
	[C]; FAR; EXTERNAL '_putimage';

PROCEDURE putpixel (x, y : INTEGER; color : WORD)
	[C]; FAR; EXTERNAL '_putpixel';

PROCEDURE rectangle (left, top, right, bottom : INTEGER)
	[C]; FAR; EXTERNAL '_rectangle';

FUNCTION registerbgidriver (driver : POINTER) : INTEGER;

FUNCTION registerbgifont (font : POINTER) : INTEGER;

PROCEDURE restorecrtmode()
	[C]; FAR; EXTERNAL '_restorecrtmode';

PROCEDURE sector (X, Y : INTEGER; StAngle, EndAngle, XRadius, YRadius : WORD)
	[C]; FAR; EXTERNAL '_sector';

PROCEDURE setactivepage (page : WORD)
	[C]; FAR; EXTERNAL '_setactivepage';

PROCEDURE setallpalette (VAR palette)
	[C]; FAR; EXTERNAL '_setallpalette';

PROCEDURE setaspectratio (xasp, yasp : WORD)
	[C]; FAR; EXTERNAL '_setaspectratio';

PROCEDURE setbkcolor (color : WORD)
	[C]; FAR; EXTERNAL '_setbkcolor';

PROCEDURE setcolor (color : WORD)
	[C]; FAR; EXTERNAL '_setcolor';

PROCEDURE setfillpattern (upattern : FillPatternType; Color : WORD);

PROCEDURE setfillstyle (pattern, color : WORD)
	[C]; FAR; EXTERNAL '_setfillstyle';

PROCEDURE setgraphbufsize (bufsize : WORD)
	[C]; FAR; EXTERNAL '_setgraphbufsize';

PROCEDURE setgraphmode (mode : INTEGER)
	[C]; FAR; EXTERNAL '_setgraphmode';

PROCEDURE setlinestyle (linestyle, upattern, thickness : WORD)
	[C]; FAR; EXTERNAL '_setlinestyle';

PROCEDURE setpalette (colornum : WORD; color : SHORTINT)
	[C]; FAR; EXTERNAL '_setpalette';

PROCEDURE setrbgpalette (colornum, red, green, blue : INTEGER)
	[C]; FAR; EXTERNAL '_setrbgpalette';

PROCEDURE settextjustify (horiz, vert : WORD)
	[C]; FAR; EXTERNAL '_settextjustify';

PROCEDURE settextstyle (font, direction, charsize : WORD)
	[C]; FAR; EXTERNAL '_settextstyle';

PROCEDURE setusercharsize (multx, divx, multy, divy : WORD)
	[C]; FAR; EXTERNAL '_setusercharsize';

PROCEDURE setviewport (left, top, right, bottom : INTEGER; clip : BOOLEAN);

PROCEDURE setvisualpage (page : WORD)
	[C]; FAR; EXTERNAL '_setvisualpage';

PROCEDURE setwritemode (mode : INTEGER)
	[C]; FAR; EXTERNAL '_setwritemode';

FUNCTION textheight (textstring : STRING) : WORD;

FUNCTION textwidth (textstring : STRING) : WORD;

IMPLEMENTATION

TYPE
  PalettePointer = ^PaletteType;

PROCEDURE _bar3d (left, top, right, bottom : INTEGER; depth : WORD; topflag : word)
	[C]; FAR; EXTERNAL '_bar3d';

FUNCTION _getdefaultpalette() : PalettePointer
	[C]; FAR; EXTERNAL '_getdefaultpalette';

FUNCTION _getdrivername() : POINTER
	[C]; FAR; EXTERNAL '_getdrivername';

FUNCTION _getmodename(mode_number : INTEGER) : POINTER
	[C]; FAR; EXTERNAL '_getmodename';

FUNCTION _grapherrormsg(errorcode : INTEGER) : POINTER
	[C]; FAR; EXTERNAL '_grapherrormsg';

PROCEDURE _initgraph(VAR graphdriver, graphmode : INTEGER; pathtodriver : POINTER)
	[C]; FAR; EXTERNAL '_initgraph';

FUNCTION _installuserdriver(name : POINTER; autodetectptr : POINTER) : INTEGER
	[C]; FAR; EXTERNAL '_installuserdriver';

FUNCTION _installuserfont(name : POINTER) : INTEGER
	[C]; FAR; EXTERNAL '_installuserfont';

PROCEDURE _outtext(textstring : POINTER)
	[C]; FAR; EXTERNAL '_outtext';

PROCEDURE _outtextxy(x, y : INTEGER; textstring : POINTER)
	[C]; FAR; EXTERNAL '_outtextxy';

PROCEDURE _setfillpattern(VAR upattern : FillPatternType; color : INTEGER)
	[C]; FAR; EXTERNAL '_setfillpattern';

PROCEDURE _setviewport (left, top, right, bottom : INTEGER; clip : WORD)
	[C]; FAR; EXTERNAL '_setviewport';

FUNCTION _textheight(textstring : POINTER) : INTEGER
	[C]; FAR; EXTERNAL '_textheight';

FUNCTION _textwidth(textstring : POINTER) : INTEGER
	[C]; FAR; EXTERNAL '_textwidth';

TYPE
    DriverPROC = PROCEDURE();

FUNCTION _registerfarbgidriver(driver : DriverPROC) : INTEGER
	[C]; FAR; EXTERNAL '_registerfarbgidriver';

TYPE
    FontPROC = PROCEDURE();

FUNCTION _registerfarbgifont(font : FontPROC) : INTEGER
	[C]; FAR; EXTERNAL '_registerfarbgifont';

TYPE
    StrArr = STRING;

    StrPtr = ^StrArr;

    PtrRec =
	RECORD
	    CASE INTEGER OF
		1 : (adr : POINTER);
		2 : (str : StrPtr);
	END;

PROCEDURE ConvertString(asciizStr : StrArr; VAR pascalStr : STRING);
VAR
    i : INTEGER;
BEGIN
    FOR i := 1 TO 255 DO
    BEGIN
	pascalStr[i] := asciizStr[i-1];
	pascalStr[0] := CHAR(i);
	IF asciizStr[i] = #0 THEN
	    EXIT;
    END;
END;

PROCEDURE bar3d (left, top, right, bottom : INTEGER; depth : WORD; topflag : BOOLEAN);
BEGIN
    _bar3d(left, top, right, bottom, depth, word(topflag));
END;

PROCEDURE getdefaultpalette (VAR palette : PaletteType);
BEGIN
    palette := _getdefaultpalette^;
END;

FUNCTION getdrivername : STRING;
VAR
    ptr : PtrRec;
    str : STRING;
BEGIN
    ptr.adr := _getdrivername;
    ConvertString(ptr.str^, str);
    getdrivername := str;
END;

FUNCTION getmodename (mode_number : INTEGER) : STRING;
VAR
    ptr : PtrRec;
    str : STRING;
BEGIN
    ptr.adr := _getmodename(mode_number);
    ConvertString(ptr.str^, str);
    getmodename := str;
END;

FUNCTION grapherrormsg (errorcode : INTEGER) : STRING;
VAR
    ptr : PtrRec;
    str : STRING;
BEGIN
    ptr.adr := _grapherrormsg(errorcode);
    ConvertString(ptr.str^, str);
    grapherrormsg := str;
END;

PROCEDURE initgraph (VAR graphdriver, graphmode : INTEGER; pathtodriver : STRING);
VAR
    lname : STRING;
BEGIN
    lname := pathtodriver;
    lname[Length(lname)+1] := #0;
    _initgraph(graphdriver, graphmode, ADDR(lname[1]));
END;

FUNCTION installuserdriver (name : STRING; autodetectptr : POINTER) : INTEGER;
VAR
    lname : STRING;
BEGIN
    lname := name;
    lname[Length(lname)+1] := #0;
    installuserdriver := _installuserdriver(ADDR(lname[1]), autodetectptr);
END;

FUNCTION installuserfont (name : STRING) : INTEGER;
VAR
    lname : STRING;
BEGIN
    lname := name;
    lname[Length(lname)+1] := #0;
    installuserfont := _installuserfont(ADDR(lname[1]));
END;

PROCEDURE outtext (textstring : STRING);
VAR
    ltextstring : STRING;
BEGIN
    ltextstring := textstring;
    ltextstring[Length(ltextstring)+1] := #0;
    _outtext(ADDR(ltextstring[1]));
END;

PROCEDURE outtextxy (x, y : INTEGER; textstring : STRING);
VAR
    ltextstring : STRING;
BEGIN
    ltextstring := textstring;
    ltextstring[Length(ltextstring)+1] := #0;
    _outtextxy(x, y, ADDR(ltextstring[1]));
END;

PROCEDURE setfillpattern (upattern : FillPatternType; color : WORD);
BEGIN
    _setfillpattern(upattern, color);
END;

PROCEDURE setviewport (left, top, right, bottom : INTEGER; clip : BOOLEAN);
BEGIN
    _setviewport(left, top, right, bottom, WORD(clip));
END;

FUNCTION textheight (textstring : STRING) : WORD;
VAR
    ltextstring : STRING;
BEGIN
    ltextstring := textstring;
    ltextstring[Length(ltextstring)+1] := #0;
    textheight := _textheight(ADDR(ltextstring[1]));
END;

FUNCTION textwidth (textstring : STRING) : WORD;
VAR
    ltextstring : STRING;
BEGIN
    ltextstring := textstring;
    ltextstring[Length(ltextstring)+1] := #0;
    textwidth := _textwidth(ADDR(ltextstring[1]));
END;

FUNCTION registerbgidriver (driver : POINTER) : INTEGER;
BEGIN
    registerbgidriver := _registerfarbgidriver(DriverPROC(driver));
END;

FUNCTION registerbgifont (font : POINTER) : INTEGER;
BEGIN
    registerbgifont := _registerfarbgifont(FontPROC(font));
END;

PROCEDURE MyGetMem(VAR p : POINTER; size : word);
BEGIN
    GetMem(p, size);
END;

PROCEDURE MyFreeMem(VAR p : POINTER; size : word);
BEGIN
    FreeMem(p, size);
END;

{ the C code calls these for memory, then I just call the proc variables }

TYPE
    MemProc = PROCEDURE (VAR p : POINTER; size : word);

(*$//NOOPT:X*)
FUNCTION CGetMem(size : WORD) : POINTER
	[C]; FAR;
VAR
    p : POINTER;
BEGIN
    p := NIL;
    MemProc(GraphGetMemPtr)(p, size);
    CGetMem := p;
END;

PROCEDURE CFreeMem(p : POINTER; size : WORD)
	[C]; FAR;
BEGIN
    MemProc(GraphFreeMemPtr)(p, size);
END;

END.
