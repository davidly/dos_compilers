
UNIT Graph;

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


VAR
    GraphGetMemPtr  : POINTER;   { allows user to steal heap allocation }
    GraphFreeMemPtr : POINTER;   { allows user to steal heap de-allocation }

    { *** high-level error handling *** }

    GraphErrorMsg	: FUNCTION (ErrorCode : INTEGER) : STRING;
    GraphResult 	: FUNCTION : INTEGER;

    { *** detection, initialization and crt mode routines *** }

    DetectGraph		: PROCEDURE (VAR GraphDriver, GraphMode : INTEGER);
    GetDriverName 	: FUNCTION : STRING;

    InitGraph		: PROCEDURE (VAR GraphDriver : INTEGER;
				     VAR GraphMode   : INTEGER;
					 PathToDriver : STRING);

    RegisterBGIfont	: FUNCTION (Font : pointer) : INTEGER;
    RegisterBGIdriver	: FUNCTION (Driver : pointer) : INTEGER;
    InstallUserDriver	: FUNCTION (DriverFileName : STRING;
				    AutoDetectPtr : pointer) : INTEGER;
    InstallUserFont	: FUNCTION (FontFileName : STRING) : INTEGER;
    SetGraphBufSize	: PROCEDURE (BufSize : WORD);
    GetMaxMode 		: FUNCTION : INTEGER;
    GetModeRange	: PROCEDURE (GraphDriver : INTEGER;
				     VAR LoMode, HiMode : INTEGER);
    GetModeName		: FUNCTION (GraphMode : INTEGER) : STRING;
    SetGraphMode	: PROCEDURE (Mode : INTEGER);
    GetGraphMode 	: FUNCTION : INTEGER;
    GraphDefaults	: PROCEDURE;
    RestoreCrtMode	: PROCEDURE;
    CloseGraph		: PROCEDURE;

    GetX 		: FUNCTION  : INTEGER;
    GetY 		: FUNCTION  : INTEGER;
    GetMaxX 		: FUNCTION  : INTEGER;
    GetMaxY 		: FUNCTION  : INTEGER;

    { *** Screen, viewport, page routines *** }

    ClearDevice		: PROCEDURE;
    SetViewPort		: PROCEDURE (x1, y1, x2, y2 : INTEGER; Clip : BOOLEAN);
    GetViewSettings	: PROCEDURE (VAR ViewPort : ViewPortType);
    ClearViewPort	: PROCEDURE;
    SetVisualPage	: PROCEDURE (Page : WORD);
    SetActivePage	: PROCEDURE (Page : WORD);

    { *** point-oriented routines *** }

    PutPixel		: PROCEDURE (X, Y : INTEGER; Pixel : WORD);
    GetPixel		: FUNCTION  (X, Y : INTEGER) : WORD;

    { *** line-oriented routines *** }

    SetWriteMode	: PROCEDURE (WriteMode : INTEGER);
    LineTo		: PROCEDURE (X, Y : INTEGER);
    LineRel		: PROCEDURE (Dx, Dy : INTEGER);
    MoveTo		: PROCEDURE (X, Y : INTEGER);
    MoveRel		: PROCEDURE (Dx, Dy : INTEGER);
    Line		: PROCEDURE (x1, y1, x2, y2 : INTEGER);
    GetLineSettings	: PROCEDURE (VAR LineInfo : LineSettingsType);
    SetLineStyle	: PROCEDURE (LineStyle : WORD;
				     Pattern   : WORD;
				     Thickness : WORD);

    { *** polygon, fills and figures *** }

    Rectangle		: PROCEDURE (x1, y1, x2, y2 : INTEGER);
    Bar			: PROCEDURE (x1, y1, x2, y2 : INTEGER);
    Bar3D		: PROCEDURE (x1, y1, x2, y2 : INTEGER;
				     Depth : WORD; Top : BOOLEAN);
    DrawPoly		: PROCEDURE (NumPoints : WORD; VAR PolyPoints);
    FillPoly		: PROCEDURE (NumPoints : WORD; VAR PolyPoints);
    GetFillSettings	: PROCEDURE (VAR FillInfo : FillSettingsType);
    GetFillPattern	: PROCEDURE (VAR FillPattern : FillPatternType);
    SetFillStyle	: PROCEDURE (Pattern : WORD; Color : WORD);
    SetFillPattern	: PROCEDURE (Pattern : FillPatternType; Color : WORD);
    FloodFill		: PROCEDURE (X, Y : INTEGER; Border : WORD);

    { *** arc, circle, and other curves *** }

    Arc			: PROCEDURE (X, Y : INTEGER; StAngle, EndAngle, Radius : WORD);
    GetArcCoords	: PROCEDURE (VAR ArcCoords : ArcCoordsType);
    Circle		: PROCEDURE (X, Y : INTEGER; Radius : WORD);
    Ellipse		: PROCEDURE (X, Y : INTEGER;
				     StAngle, EndAngle : WORD;
				     XRadius, YRadius  : WORD);
    FillEllipse		: PROCEDURE (X, Y : INTEGER;
				     XRadius, YRadius  : WORD);
    GetAspectRatio	: PROCEDURE (VAR Xasp, Yasp : WORD);
    SetAspectRatio	: PROCEDURE (Xasp, Yasp : WORD);
    PieSlice		: PROCEDURE (X, Y : INTEGER; StAngle, EndAngle, Radius : WORD);
    Sector		: PROCEDURE (X, Y : INTEGER;
				     StAngle, EndAngle,
				     XRadius, YRadius : WORD);


    { *** color and palette routines *** }

    SetBkColor		: PROCEDURE (ColorNum : WORD);
    SetColor		: PROCEDURE (Color : WORD);
    GetBkColor 		: FUNCTION : WORD;
    GetColor 		: FUNCTION : WORD;
    SetAllPalette	: PROCEDURE (VAR Palette);
    SetPalette		: PROCEDURE (ColorNum : WORD; Color : SHORTINT);
    GetPalette		: PROCEDURE (VAR Palette : PaletteType);
    GetPaletteSize 	: FUNCTION : INTEGER;
    GetDefaultPalette	: PROCEDURE (VAR Palette : PaletteType);
    GetMaxColor 	: FUNCTION : WORD;
    SetRGBPalette	: PROCEDURE (ColorNum, RedValue,
				     GreenValue, BlueValue : INTEGER);

    { *** bit-image routines *** }

    ImageSize		: FUNCTION  (x1, y1, x2, y2 : INTEGER) : WORD;
    GetImage		: PROCEDURE (x1, y1, x2, y2 : INTEGER; VAR BitMap);
    PutImage		: PROCEDURE (X, Y : INTEGER; VAR BitMap; BitBlt : WORD);

    { *** text routines *** }

    GetTextSettings	: PROCEDURE (VAR TextInfo : TextSettingsType);
    OutText		: PROCEDURE (TextString : STRING);
    OutTextXY		: PROCEDURE (X, Y : INTEGER; TextString : STRING);
    SetTextJustify	: PROCEDURE (Horiz, Vert : WORD);
    SetTextStyle	: PROCEDURE (Font, Direction : WORD; CharSize : WORD);
    SetUserCharSize	: PROCEDURE (MultX, DivX, MultY, DivY : WORD);
    TextHeight		: FUNCTION  (TextString : STRING) : WORD;
    TextWidth		: FUNCTION  (TextString : STRING) : WORD;

IMPLEMENTATION

USES DOS, GraphAsm;

TYPE ExeHeader =
    RECORD
    magic	: ARRAY [1..2] OF CHAR;
    modlength	: WORD;
    length	: WORD;
    fixups	: WORD;
    headersize	: WORD;
    minalloc	: WORD;
    maxalloc	: WORD;
    ss		: WORD;
    sp		: WORD;
    checksum	: WORD;
    ip		: WORD;
    cs		: WORD;
    reloc	: WORD;
    overlay	: WORD;
    fill1	: WORD;
    fill2	: WORD;
    END;

CONST
    OverlayName = 'BGI.EXE';
TYPE
    InitSystemProc = PROCEDURE(a, b, c, d : POINTER);
    split =
	RECORD
	    offs, seg : WORD;
	END;
VAR
    ProgEntryPoint      : POINTER;
    Loader 		: InitSystemProc;
    Alloc		: WORD;

PROCEDURE Scan(VAR addr :  POINTER; VAR i : WORD; data : BYTE);
VAR
    ptc : ^BYTE;
BEGIN
    ptc := addr;
    REPEAT
	i := i - 1;
	WORD(ptc) := WORD(ptc) + 1;
    UNTIL (ptc^ = data) OR (i = 0);
    addr := ptc;
END;

(* what we do here is do a string search in the .EXE file *)
(* yea, that is ugly but the code is small and fast *)
(* other methods are more "elegant", but are not really any better *)
(* we must get the address at run-time, no patches of EXEs will work *)
(* reading debug information to get the addr would be an interesting *)
(* alternative! *)

PROCEDURE FindEntryPoint( VAR adr : POINTER );
CONST
    signature = 'Stony Brook Software';
VAR
    pts : ^STRING;
    i : WORD;
BEGIN
    i := Alloc;
    WHILE TRUE DO
    BEGIN
	Scan(adr, i, Length(signature));
	IF i = 0 THEN
	BEGIN
	    adr := NIL;
	    EXIT;
	END;
	pts := adr;
	IF pts^ = signature THEN
	BEGIN
	    WORD(pts)  := WORD(pts) + Length(signature) + 1;
	    adr := pts;
	    EXIT;
	END;
    END;
END;

(* we search for the "overlay" in the current dir first, then in the *)
(* directory that the main EXE was run from *)
(* the latter only works on DOS 3.x and later *)

PROCEDURE GetProgramName(VAR name : PathStr);
(* riped off from the Modula-2 RTL and converted *)
TYPE
    DummyType = ARRAY [0..254] OF CHAR;
VAR
    envSeg : ^WORD;
    R : REGISTERS;
    P : ^DummyType;
    i : WORD;
BEGIN
    name := '';

    (* Check to make sure we are at least dos 3 *)

    R.AX := $3000;
    MSDOS(R);
    IF R.AL < 3 THEN
	EXIT;

    (* Now, address the environment.  The program name immediately *)
    (* follows the list of environment definitions *)

    envSeg := Ptr(PrefixSeg, $2C);
    envSeg := Ptr(envSeg^, 0);
    P := POINTER(envSeg);

    (* Skip all the environment symbols, i.e. loop until we hit a *)
    (* double zero sorry, roulette players *)

    WHILE P^[0] <> #0 DO
    BEGIN
	REPEAT
	    WORD(P) := WORD(P) + 1;
	UNTIL P^[0] = #0;
	WORD(P) := WORD(P) + 1;
    END;
    WORD(P) := WORD(P) + 3;

    (* find the end of it *)

    i := 0;
    WHILE P^[i] <> #0 DO
       i := i + 1;

    name := Copy(P^, 0, i);
END;

PROCEDURE LoadBGI(VAR entry : POINTER) [LOADDS];
TYPE
    ProcType = PROCEDURE;
VAR
    runExe	: ProcType;
    header	: ExeHeader;
    mem		: LONGINT;
    loadOverParams	: ARRAY [0..1] OF WORD;
    f		: File;
    R		: REGISTERS;
    A		: POINTER;

    path	: PathStr;
    dir		: DirStr;
    name	: NameStr;
    ext		: ExtStr;
BEGIN

    (* open the exe file and read the header *)

    {$I-}
    path := OverlayName;
    Assign(f, path);
    Reset(f, SIZEOF(header));
    IF IOResult <> 0 THEN
    BEGIN
	GetProgramName(path);
	IF path = '' THEN
	BEGIN
	    WriteLn('Could not find ', OverlayName);
	    HALT;
	END;
	FSplit(path, dir, name, ext);
	path := dir + OverlayName;
	Assign(f, path);
	Reset(f, SIZEOF(header));
	IF IOResult <> 0 THEN
	BEGIN
	    WriteLn('Could not find ', OverlayName);
	    HALT;
	END;
    END;
    BlockRead(f, header, 1);
    Close(f);

    (* calculate the memory needed by the BGI.EXE *)

    mem := LONGINT(header.length) * 512 + LONGINT(header.modlength) +
	LONGINT(header.minalloc) * 16 - LONGINT(header.sp);

    (* try to get memory *)

    GetMem(A, mem);
    Alloc := mem;

    (* use the load overlay call to load it *)

    POINTER(loadOverParams) := A;
    loadOverParams[0] := loadOverParams[1];
    R.AX := $4B03;
    R.BX := OFS(loadOverParams);
    R.ES := SEG(loadOverParams);
    path[Length(path)+1] := #0;
    R.DX := OFS(path[1]);
    R.DS := SEG(path[1]);
    MSDOS(R);

    (* Check for a good load *)

    IF (FCarry AND R.FLAGS) <> 0 THEN
    BEGIN
	WriteLn('Could not load ', OverlayName);
	HALT;
    END;

    (* Set the entry address *)

    entry := Ptr(header.cs + split(A).seg, header.ip);

    runExe := ProcType(entry);

    (* exectue the "program"  BGI.EXE *)

    runExe;
END;

(* the default memory allocation routines *)

PROCEDURE MyGetMem(VAR p : POINTER; size : WORD); far;
BEGIN
    GetMem(p, size);
END;

PROCEDURE MyFreeMem(VAR p : POINTER; size : WORD); far;
BEGIN
    FreeMem(p,  size);
END;

(* BGI.EXE will call these guys, they will then redirect the call to *)
(* GraphGetMemPtr and GraphFreeMemPtr respectively *)
(* in this way the user, that means you, can assign to the proc variable *)
(* and the BGI.EXE dosen't need know about it *)

PROCEDURE RedGetMem(VAR p : POINTER; size : WORD); far; external 'GRAPH_REDGETMEM';

PROCEDURE RedFreeMem(VAR p : POINTER; size : WORD); far; external 'GRAPH_REDFREEMEM';

BEGIN
    SaveVects;
    
    (* load the BGI exe "overlay" *)

    LoadBGI(ProgEntryPoint);

    (* find initialization procedure *)

    FindEntryPoint(ProgEntryPoint);

    IF ProgEntryPoint = NIL THEN
    BEGIN
	WriteLn('load could not find signature');
	HALT;
    END;

    (* need to redirect the memory allocation routines to ours *)

    GraphGetMemPtr := @MyGetMem;
    GraphFreeMemPtr := @MyFreeMem;

    loader := InitSystemProc(ProgEntryPoint);

    (* pass addr of HeapError & address of memory allocators *)
    (* & address of first proc variable *)

    Loader(@HeapError, @RedGetMem, @RedFreeMem, @@GraphErrorMsg);

    (* bebe bebe bebe that all folks *)
END.
