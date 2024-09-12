UNIT Windows;

(*$//NOMODINIT//CODE:L//DATA:M//WINDOWS*)

INTERFACE

TYPE
    ATOM		= WORD;
    BOOL		= INTEGER;
    DWORD		= LONGINT;
    FARPROC		= POINTER {PROCEDURE () [WINDOWS]};
    HANDLE		= WORD;
    HBITMAP		= HANDLE;
    HBRUSH		= HANDLE;
    HCURSOR		= HANDLE;
    HDC			= HANDLE;
    HFONT		= HANDLE;
    HICON		= HANDLE;
    HMENU		= HANDLE;
    HWND		= HANDLE;
    HPEN		= HANDLE;
    HRGN		= HANDLE;
    HPALETTE		= HANDLE;
    tGLOBALHANDLE	= HANDLE;   {Name conflict because Pascal is}
    LPDWORD		= ^DWORD;   {not case sensitive}
    LPINT		= ^INTEGER;
    LPSTR		= POINTER;
    LPVOID		= POINTER;
    PSTR		= WORD;
    COLORREF		= DWORD;

(* Constants of basic types *)

CONST
    wTRUE 		= 1;	{Name conflicts because Pascal is}
    wFALSE		= 0;	{not case sensitive}
    NULL		= 0;

(*----------------------------------------------------------------------------
|       DDEACK structure
|
|	Structure of wStatus (LOWORD(lParam)) in WM_DDE_ACK message
|       sent in response to a WM_DDE_DATA, WM_DDE_REQUEST, WM_DDE_POKE,
|       WM_DDE_ADVISE, or WM_DDE_UNADVISE message.
|
----------------------------------------------------------------------------*)

TYPE
    DDEACK = WORD;
    (*
        bAppReturnCode:8,
              reserved:6,
                 fBusy:1,
		  fAck:1;
     *)

(*----------------------------------------------------------------------------
|       DDEADVISE structure
|
|	WM_DDE_ADVISE parameter structure for hOptions (LOWORD(lParam))
|
----------------------------------------------------------------------------*)
TYPE
    DDEADVISE =
	RECORD
	   w1 : WORD; (* reserved:14, fDeferUpd:1, fAckReq:1 *)
	   cfFormat : INTEGER;
       END;

(*----------------------------------------------------------------------------
|       DDEDATA structure
|
|       WM_DDE_DATA parameter structure for hData (LOWORD(lParam)).
|       The actual size of this structure depends on the size of
|       the Value array.
|
----------------------------------------------------------------------------*)

TYPE
    DDEDATA =
	RECORD
	    w1 : WORD;
		 (*
	         unused:12,
                 fResponse:1,
                 fRelease:1,
                 reserved:1,
                 fAckReq:1;
		 *)
	     cfFormat : INTEGER;
	     Value : ARRAY [0..1] OF BYTE;
	 END;

(*----------------------------------------------------------------------------
|	DDEPOKE structure
|
|	WM_DDE_POKE parameter structure for hData (LOWORD(lParam)).
|       The actual size of this structure depends on the size of
|       the Value array.
|
----------------------------------------------------------------------------*)

TYPE
    DDEPOKE =
	RECORD
	    w1 : WORD;
		(*
		unused:13,
		fRelease:1,
		fReserved:2;
		*)
	    cfFormat : INTEGER;
	    Value : ARRAY [0..1] OF BYTE;
	END;

(* types used in other type structures *)

TYPE

    (* Point data structure *)

    POINT =
	RECORD
	x,
	y		: INTEGER;
	END;

    (* Pointer to point *)

    LPPOINT = ^POINT;

    (* Rectangle data structure *)

    RECT =
        RECORD
	left,
	top,
	right,
	bottom		: INTEGER;
      END;


   (* The windows procedure type *)

    WndProc = POINTER;
(*
   WndProc = FUNCTION (a:HANDLE; b:WORD; c:WORD; d:LONGINT) : LONGINT [WINDOWS];
*)

   (* The dialog box procedure type *)

    DlgProc = POINTER;
(*
   DlgProc = FUNCTION (a:HANDLE; b:WORD; c:WORD; d:LONGINT) : BOOL [WINDOWS];
*)

CONST
    LF_FACESIZE		= 32;

(* Data structures used by windows *)

TYPE

    (* Bitmap data struture *)

    BITMAP =
        RECORD
	bmType           : INTEGER;
	bmWidth          : INTEGER;
	bmHeight         : INTEGER;
	bmWidthBytes     : INTEGER;
	bmPlanes         : BYTE;
	bmBitsPixel      : BYTE;
	bmBits           : LPSTR;
        END;

    BITMAPCOREHEADER =
	RECORD
	bcSize		: DWORD;
	bcWidth		: WORD;
	bcHeight	: WORD;
	bcPlanes	: WORD;
	bcBitCount	: WORD;
	END;

    BITMAPINFOHEADER =
	RECORD
	biSize		: DWORD;
	biWidth		: DWORD;
	biHeigth	: DWORD;
	biPlanes	: WORD;
	biBitCount	: WORD;
	biCompression	: DWORD;
	biSizeImage	: DWORD;
	biXPelsPerMeter	: DWORD;
	biYPelsPerMeter	: DWORD;
	biClrUsed	: DWORD;
	biClrImportant	: DWORD;
	END;
	
    RGBTRIPLE =
	RECORD
	rgbtBlue  : CHAR;
	rgbtGreen : CHAR;
	rgbtRed   : CHAR;
	END;

    RGBQUAD =
	RECORD
	rgbBlue  : CHAR;
	rgbGreen : CHAR;
	rgbRed   : CHAR;
	rgbReserved   : CHAR;
	END;
	
    BITMAPINFO =
	RECORD
	bmiHeader : BITMAPINFOHEADER;
	bmiColors : ARRAY [0..0] OF RGBQUAD;
	END;
	
    BITMAPCOREINFO =
	RECORD
	bcmiHeader : BITMAPCOREHEADER;
	bcmiColors : ARRAY [0..0] OF RGBTRIPLE;
	END;

    BITMAPFILEHEADER =
	RECORD
	bfType		: WORD;
	bfSize		: DWORD;
	bfReserved1	: WORD;
	bfReserved2	: WORD;
	bfOffBits	: DWORD;
	END;
	
CONST
    BI_RBG	= 0;
    BI_RLE8	= 1;
    BI_RLE4	= 2;
    
TYPE

    (* the buffer for throw and catch functions *)
    
    CATCHBUF = ARRAY [0..8] OF INTEGER;

    (* Commuication events *)
        
    CommEventFlag =
	(
	    EV_RXCHAR,
	    EV_RXFLAG,
	    EV_TXEMPTY,
	    EV_CTS,
	    EV_DSR,
	    EV_RLSD,
	    EV_BREAK,
	    EV_ERR,
	    EV_RING,
	    EV_PERR
	);
		
    CommEventMask = SET OF CommEventFlag;
    
    LPCommEventMask = ^CommEventMask;
    
    (* Communication device status bits *)
    
    CommStatusFlags =
        (
	    fCtsHold,
	    fDstHold,
	    fRlsHold,
	    fXoffHold,
	    fXoffSent,
	    fEof,
	    fTxim
	);
CONST
    SETXOFF	= 1;
    SETXON	= 2;
    SETRTS	= 3;
    CLRCTS	= 4;
    SETDTR	= 5;
    CLRDTR	= 6;
    RESETDEV	= 7;
    
    LPTx	= $80;

TYPE
    CommStatusFlagSet = SET OF CommStatusFlags;

    (* communication device status structure *)
    
    COMSTAT =
        RECORD
	bits		: CommStatusFlagSet;
	cbInQue		: WORD;
	cbOutQue	: WORD;
	END;
	
    MDICREATESTRUCT =
	RECORD
	szClass		: LPSTR;
	szTitle		: LPSTR;
	hOwner		: HANDLE;
	x, y,
	cx, cy		: INTEGER;
	style,
	lparam		: LONGINT;
	END;
	
    CLIENTCREATESTRUCT =
	RECORD
	hWindowMenu	: HANDLE;
	idFirstChild	: WORD;
	END;
CONST
    HELP_CONTEXT		= 1;
    HELP_QUIT			= 2;
    HELP_INDEX			= 3;
    HELP_HELPONHELP		= 4;
    HELP_SETINDEX		= 5;
    HELP_KEY			= $101;
    HELP_MULTIKEY		= $201;
TYPE
    MULTIKEYHELP =
	RECORD
	mkSize		: WORD;
	mkKeylist	: CHAR;
	szKeyphrase	: ARRAY [0..0] OF CHAR;
	END;

    (* Window creation structure *)
            
    CREATESTRUCT =
	RECORD
	lpCreateParams   : LPSTR;
	hInstance        : HANDLE;
	hMenu            : HANDLE;
	hwndParent       : HWND;
	cy               : INTEGER;
	cx               : INTEGER;
	y                : INTEGER;
	x                : INTEGER;
	style            : LONGINT;
	lpszName         : LPSTR;
	lpszClass        : LPSTR;
	dwExStyle	: DWORD;
        END;
	
CONST
    ODT_MENU		= 1;
    ODT_LISTBOX		= 2;
    ODT_COMBOBOX	= 3;
    ODT_BUTTON		= 4;
    
    ODA_DRAWENTIRE	= 1;
    ODA_SELECT		= 2;
    ODA_FOCUS		= 4;
    
    ODS_SELECTED	= 1;
    ODS_GRAYED		= 2;
    ODS_DISABLED	= 4;
    ODS_CHECKED		= 8;
    ODS_FOCUS		= 16;

TYPE
    MEASUREITEMSTRUCT =
	RECORD
	CtlType,
	CtlID,
	itemID,
	itemWidth,
	itemHeight,
	itemData	: WORD;
	END;
	
    DRAWITEMSTRUCT =
	RECORD
	CtlType,
	CtlID,
	itemID,
	itemAction,
	itemState	: WORD;
	hwndItem	: HWND;
	hDC		: HDC;
	rcItem		: RECT;
	itemData	: DWORD;
	END;
    
    DELETEITEMSTRUCT =
	RECORD
	CtlType,
	CtlID,
	itemID		: WORD;
	hwndItem	: HWND;
	itemData	: DWORD;
	END;
	
    COMPAREITEMSTRUCT =
	RECORD
	CtlType,
	CtlID		: WORD;
	hwndItem	: HWND;
	itemID1		: WORD;
	itemData1	: DWORD;
	itemID2		: WORD;
	itemData2	: DWORD;
	END;
	
    (* Communcation device control block *)
    
    CommFlags =
        (
	    fBinary,		
	    fRtsDisable,
	    fParity,
	    fOutxCtsFlow,
	    fOutxDsrFlow,
	    fDummy1,
	    fDummy2,
	    fDtrDisable,
	    
	    fOutX,
	    fInX,
	    fPeChar,
	    fNull,
	    fChEvt,
	    fDtrFlow,
	    fRtsFlow,
	    fDummy3
	);
    
    CommFlagSet = SET OF CommFlags;
    
    (* Communications device control block *)
    
    DCB = 
	RECORD
	id		: BYTE;
	BaudRate	: WORD;
	ByteSize	: BYTE;
	Parity		: BYTE;
	StopBits	: BYTE;
	RlsTimeout	: WORD;
	CtsTimeout	: WORD;
	DsrTimeout	: WORD;
	flags		: CommFlagSet;
	XonChar		: CHAR;
	XoffChar	: CHAR;
	XonLim		: WORD;
	XoffLim		: WORD;
	PeChar		: CHAR;
	EofChar		: CHAR;
	EvtChar		: CHAR;
	TxDelay		: WORD;
	END;

    (* Fixed portion of the dialog box template *)
    (* The data field contains variable length data describing the *)
    (* dialog box *)
    
    DLGTEMPLATE =
	RECORD
	dtStyle		: LONGINT;
	dtItemCount	: BYTE;
	dtX, dtY	: INTEGER;
	dtCX, dtCY	: INTEGER;
	data		: ARRAY [0..32767] OF CHAR;
	END;

    (* Buffer for GetKeyboardStat *)
    
    KEYBUFFER = ARRAY [0..255] OF CHAR;

    (* Logical Brush *)
    
    LOGBRUSH =
	RECORD
	lbStyle            : WORD;
	lbColor            : DWORD;
	lbHatch            : INTEGER;
        END;
    
    (* Logical font record *)
    
    LOGFONT =
        RECORD
	lfHeight           : INTEGER;
	lfWidth            : INTEGER;
	lfEscapement       : INTEGER;
	lfOrientation      : INTEGER;
	lfWeight           : INTEGER;
	lfItalic           : BYTE;
	lfUnderline        : BYTE;
	lfStrikeOut        : BYTE;
	lfCharSet          : BYTE;
	lfOutPrecision     : BYTE;
	lfClipPrecision    : BYTE;
	lfQuality          : BYTE;
	lfPitchAndFamily   : BYTE;
	lfFaceName         : ARRAY [0..LF_FACESIZE-1] OF BYTE;
        END;

    (* Logical Pen *)
	
    LOGPEN =
	RECORD
	lopnStyle          : WORD;
	lopnWidth          : POINT;
	lopnColor          : DWORD;
	END;
	
    PALETTEENTRY =
	RECORD
	peRed,
	peGreen,
	peBlue,
	peFlags	: CHAR;
	END;
	
    LOGPALETTE =
	RECORD
	palVersion,
	palNumEntries	: WORD;
	palPalEntry	: ARRAY [0..0] OF PALETTEENTRY;
	END;
	

    (* Message structure *)

    MSG =
	RECORD
	hwnd		: HWND;
	message		: WORD;
	wParam		: WORD;
	lParam		: LONGINT;
	time		: DWORD;
	pt		: POINT;
	END;

    (* Open file structure *)
    
    OFSTRUCT =
	RECORD
	cBytes                  : BYTE;
	fFixedDisk              : BYTE;
	nErrCode                : WORD;
	reserved                : ARRAY [0..3] OF BYTE;
	szPathName              : ARRAY [0..127] OF BYTE;
        END;

    (* Windows paint information *)
    
    PAINTSTRUCT =
        RECORD
	hdc              : HDC;
	fErase           : BOOL;
	rcPaint          : RECT;
	fRestore         : BOOL;
	fIncUpdate       : BOOL;
	rgbReserved      : ARRAY [0..15] OF BYTE;
	END;
	
(* TextMetric structure *)
   
    TEXTMETRIC =
	RECORD
	tmHeight,
	tmAscent,
	tmDescent,
	tmInternalLeading,
	tmExternalLeading,
	tmAveCharWidth,
	tmMaxCharWidth,
	tmWeight		: INTEGER;
	tmItalic,
	tmUnderlined,
	tmStruckOut,
	tmFirstChar,
	tmLastChar,
	tmDefaultChar,
	tmBreakChar,
	tmPitchAndFamily,
	tmCharSet		: BYTE;
	tmOverhang,
	tmDigitizedAspectX,
	tmDigitizedAspectY	: INTEGER;
	END;
	
    PELARRAY =
	RECORD
	paXCount,
	paYCount,
	paXExt,
	paYExt		: INTEGER;
	paRGBs		: CHAR;
	END;

    (* Window class structure *)
    
    WNDCLASS =
	RECORD
	style            : WORD;
	lpfnWndProc      : WndProc;
	cbClsExtra       : INTEGER;
	cbWndExtra       : INTEGER;
	hInstance        : HANDLE;
	hIcon            : HICON;
	hCursor          : HCURSOR;
	hbrBackground    : HBRUSH;
	lpszMenuName     : LPSTR;
	lpszClassName    : LPSTR;
	END;

    EVENTMSG =
	RECORD
	message		: WORD;
	paramL		: WORD;
	paramH		: WORD;
	time		: DWORD;
	END;
	
(* These variables can be passed to procedures that take structures *)
(* when a NULL value is allowed in the c interface *)

VAR
    NULLRECT		: RECT ABSOLUTE 0:0;
    
(* Trick to make a constant look like the address of a string *)

TYPE
	MAKEINTRESOURCE = LPSTR;
	MAKEPOINT	= POINT;

(*
 *
 *  Header file for printer driver initialization using ExtDeviceMode()
 *  and DeviceCapabilities().
 *
 *)

(* size of a device name string *)
CONST
    CCHDEVICENAME  = 32;

(* current version of specification *)
    DM_SPECVERSION  = $300;

(* field selection bits *)
    DM_ORIENTATION	= $0000001;
    DM_PAPERSIZE	= $0000002;
    DM_PAPERLENGTH	= $0000004;
    DM_PAPERWIDTH	= $0000008;
    DM_SCALE	    	= $0000010;
    DM_COPIES	    	= $0000100;
    DM_DEFAULTSOURCE    = $0000200;
    DM_PRINTQUALITY     = $0000400;
    DM_COLOR	        = $0000800;
    DM_DUPLEX	        = $0001000;

(* orientation selections *)
    DMORIENT_PORTRAIT   = 1;
    DMORIENT_LANDSCAPE  = 2;

(* paper selections *)
    DMPAPER_LETTER	    = 1; (* Letter 8 1/2 x 11 in  *)
    DMPAPER_FIRST	    = DMPAPER_LETTER;
    DMPAPER_LETTERSMALL	    = 2; (* Letter Small 8 1/2 x 11 in *)
    DMPAPER_TABLOID         = 3; (* Tabloid 11 x 17 in *)
    DMPAPER_LEDGER	    = 4; (* Ledger 17 x 11 in *)
    DMPAPER_LEGAL	    = 5; (* Legal 8 1/2 x 14 in *)
    DMPAPER_STATEMENT       = 6; (* Statement 5 1/2 x 8 1/2 in *)
    DMPAPER_EXECUTIVE	    = 7; (* Executive"7 1/2 x 10 in *)
    DMPAPER_A3	    	    = 8; (* A3 297 x 420 mm *)
    DMPAPER_A4	    	    = 9; (* A4 210 x 297 mm *)
    DMPAPER_A4SMALL         = 10; (* A4 Small 210 x 297 mm *)
    DMPAPER_A5	    	    = 11; (* A5 148 x 210 mm *)
    DMPAPER_B4	    	    = 12; (* B4 250 x 354 *)
    DMPAPER_B5	    	    = 13; (* B5 182 x 257 mm *)
    DMPAPER_FOLIO	    = 14; (* Folio 8 1/2 x 13 in *)
    DMPAPER_QUARTO	    = 15; (* Quarto 215 x 275 mm *)
    DMPAPER_10X14	    = 16; (* 10x14 in *)
    DMPAPER_11X17	    = 17; (* 11x17 in *)
    DMPAPER_NOTE	    = 18; (* Note 8 1/2 x 11 in *)
    DMPAPER_ENV_9	    = 19; (* Envelope #9 3 7/8 x 8 7/8 *)
    DMPAPER_ENV_10	    = 20; (* Envelope #10 4 1/8 x 9 1/2 *)
    DMPAPER_ENV_11	    = 21; (* Envelope #11 4 1/2 x 10 3/8 *)
    DMPAPER_ENV_12	    = 22; (* Envelope #12 4 \276 x 11 *)
    DMPAPER_ENV_14	    = 23; (* Envelope #14 5 x 11 1/2 *)
    DMPAPER_CSHEET	    = 24; (* C size sheet *)
    DMPAPER_DSHEET	    = 25; (* D size sheet *)
    DMPAPER_ESHEET	    = 26; (* E size sheet *)
    DMPAPER_LAST	    = DMPAPER_ESHEET;
    
    DMPAPER_USER	    = 256;

(* bin selections *)
CONST
    DMBIN_UPPER	    = 1;
    DMBIN_FIRST	    = DMBIN_UPPER;
    DMBIN_ONLYONE   = 1;
    DMBIN_LOWER	    = 2;
    DMBIN_MIDDLE    = 3;
    DMBIN_MANUAL    = 4;
    DMBIN_ENVELOPE  = 5;
    DMBIN_ENVMANUAL = 6;
    DMBIN_AUTO	    = 7;
    DMBIN_TRACTOR   = 8;
    DMBIN_SMALLFMT  = 9;
    DMBIN_LARGEFMT  = 10;
    DMBIN_LARGECAPACITY = 11;
    DMBIN_CASSETTE      = 14;
    DMBIN_LAST	    	= DMBIN_CASSETTE;
    
    DMBIN_USER	    = 256;     (* device specific bins start here *) 

(* print qualities *)
CONST
    DMRES_DRAFT	    = (-1);
    DMRES_LOW	    = (-2);
    DMRES_MEDIUM    = (-3);
    DMRES_HIGH	    = (-4);

(* color enable/disable for color printers *)
CONST
    DMCOLOR_MONOCHROME  = 1;
    DMCOLOR_COLOR	= 2;

(* duplex enable *)
    DMDUP_SIMPLEX	 = 1;
    DMDUP_VERTICAL	 = 2;
    DMDUP_HORIZONTAL 	 = 3;

TYPE
    LPDEVMODE =  ^DEVMODE;
    NPDEVMODE =  ^DEVMODE;
    PDEVMODE = ^DEVMODE;
    DEVMODE =
	RECORD
	dmDeviceName : ARRAY [0..CCHDEVICENAME] OF CHAR;
	dmSpecVersion : WORD;
	dmDriverVersion :  WORD;
	dmSize : WORD;
	dmDriverExtra : WORD;
	dmFields : DWORD;
	dmOrientation : INTEGER;
	dmPaperSize : INTEGER;
	dmPaperLength : INTEGER;
	dmPaperWidth : INTEGER;
	dmScale : INTEGER;
	dmCopies : INTEGER;
	dmDefaultSource : INTEGER;
	dmPrintQuality : INTEGER;
	dmColor : INTEGER;
	dmDuplex : INTEGER;
	END;

(* mode selections for the device mode function *)
CONST
    DM_UPDATE	    = 1;
    DM_COPY 	    = 2;
    DM_PROMPT	    = 4;
    DM_MODIFY	    = 8;
    
    DM_IN_BUFFER	    = DM_MODIFY;
    DM_IN_PROMPT	    = DM_PROMPT;
    DM_OUT_BUFFER	    = DM_COPY;
    DM_OUT_DEFAULT	    = DM_UPDATE;

(* device capabilities indices *)
CONST
    DC_FIELDS	    = 1;
    DC_PAPERS	    = 2;
    DC_PAPERSIZE    = 3;
    DC_MINEXTENT    = 4;
    DC_MAXEXTENT    = 5;
    DC_BINS 	    = 6;
    DC_DUPLEX	    = 7;
    DC_SIZE 	    = 8;
    DC_EXTRA	    = 9;
    DC_VERSION	    = 10;
    DC_DRIVER	    = 11;
    
(* export ordinal definitions *)
CONST
    PROC_EXTDEVICEMODE	    = MAKEINTRESOURCE(90);
    PROC_DEVICECAPABILITIES = MAKEINTRESOURCE(91);
    PROC_OLDDEVICEMODE	    = MAKEINTRESOURCE(13);

(* define types of pointers to ExtDeviceMode() and DeviceCapabilities()
 * functions
 *)

TYPE
    FNDEVMODE = FUNCTION (a:HWND; b:HANDLE; c:LPDEVMODE; d:LPSTR; e:LPSTR; f:LPDEVMODE; g:LPSTR; h:WORD) : WORD;

    LPFNDEVMODE =  ^FNDEVMODE;

    FNDEVCAPS = FUNCTION (a:LPSTR; b:LPSTR; c:WORD; d:LPSTR; e:LPDEVMODE) : DWORD;

    LPFNDEVCAPS =  ^FNDEVCAPS;
    
(* general size definitions *)
CONST
    CTLTYPES		= 12;	(* number of control types *)
    CTLDESCR		= 22;	(* size of control menu name *)
    CTLCLASS	  	= 20;  	(* max size of class name *)
    CTLTITLE	  	= 94;  	(* max size of control text *)

(*
 * CONTROL STYLE DATA STRUCTURE
 *
 * This data structure is used by the class style dialog function
 * to set and/or reset various control attributes.
 *
 *)

TYPE
    PCTLSTYLE = ^CTLSTYLE;
    LPCTLSTYLE =  ^CTLSTYLE;
    CTLSTYLE =
	RECORD
	wX : WORD; (* x origin of control *)
	wY : WORD; (* y origin of control *)
	wCx : WORD; (* width of control *)
	wCy : WORD; (* height of control *)
	wId : WORD; (* control child id *)
	dwStyle : DWORD; (* control style *)
	szClass : ARRAY [0..CTLCLASS] OF CHAR; (* name of control class *)
	szTitle : ARRAY [0..CTLTITLE] OF CHAR; (* control text *)
	END;

(*
 * CONTROL DATA STRUCTURE
 *
 * This data structure is returned by the control options function
 * when enquiring about the capabilities of a particular control.
 * Each control may contain various types (with predefined style
 * bits) under one general class.
 *
 * The width and height fields are used to provide the host
 * application with a suggested size.  The values in these fields
 * could be either in pixels or in rc coordinates.  If it is in pixel,
 * the most sigificant bit(MSB) is on.  If the MSB is off, it is in rc
 * coordinates.
 *
 * The cursor and bitmap handles reference objects which can be
 * used by the dialog editor in the placement and definition of
 * new, user-defined control classes.  However, dialog editor in win30
 * does not use these fields.
 *
 *)

    CTLTYPE =
	RECORD
	wType : WORD; (* type style *)
	wWidth : WORD; (* suggested width *)
	wHeight : WORD; (* suggested height *)
	dwStyle : DWORD; (* default style *)
	szDescr : ARRAY [0..CTLDESCR]  OF CHAR; (* menu name *)
	END;

    CTLINFO =
	RECORD
	wVersion : WORD; (* control version *)
	wCtlTypes : WORD; (* control types *)
	szClass : ARRAY [0..CTLCLASS] OF CHAR; (* control class name *)
	szTitle : ARRAY [0..CTLTITLE] OF CHAR; (* control title *)
	szReserved : ARRAY [0..10] OF CHAR; (* reserved for future use *)
	Typ : ARRAY [0..CTLTYPES] OF CTLTYPE; (* control type list *)
	END;

    PCTLINFO = ^CTLINFO;
    LPCTLINFO =  ^CTLINFO;

(* These two function prototypes are used by dialog editor *)
    LPFNSTRTOID = FUNCTION (a:LPSTR) : DWORD;
    LPFNIDTOSTR = FUNCTION (a:WORD; b:LPSTR; c:WORD) : WORD;

(* Windowing system constants *)

CONST

    (* color indices for GetSysColor and SetSysColor *)
    
    COLOR_SCROLLBAR		= 0;
    COLOR_BACKGROUND		= 1;
    COLOR_ACTIVECAPTION		= 2;
    COLOR_INACTIVECAPTION	= 3;
    COLOR_MENU			= 4;
    COLOR_WINDOW		= 5;
    COLOR_WINDOWFRAME		= 6;
    COLOR_MENUTEXT		= 7;
    COLOR_WINDOWTEXT		= 8;
    COLOR_CAPTIONTEXT		= 9;
    COLOR_ACTIVEBORDER		= 10;
    COLOR_INACTIVEBORDER	= 11;
    COLOR_APPWORKSPACE		= 12;
    COLOR_HIGHLIGHT		= 13;
    COLOR_HIGHLIGHTTEXT		= 14;
    COLOR_BTNFACE		= 15;
    COLOR_BTNSHADOW		= 16;
    COLOR_GRAYTEXT		= 17;
    COLOR_BTNTEXT		= 18;
    COLOR_ENDCOLORS		= COLOR_BTNTEXT;

    (* color type_indices for the WM_CTLCOLOR message *)

    CTLCOLOR_MSGBOX		= 0;
    CTLCOLOR_EDIT		= 1;
    CTLCOLOR_LISTBOX		= 2;
    CTLCOLOR_BTN		= 3;
    CTLCOLOR_DLG		= 4;
    CTLCOLOR_SCROLLBAR		= 5;
    CTLCOLOR_STATIC		= 6;
    CTLCOLOR_MAX		= 8;
    
    (* Window class styles *)

    CS_VREDRAW		= $00001;
    CS_HREDRAW		= $00002;
    CS_KEYCVTWINDOW	= $00004;
    CS_DBLCLKS		= $00008;
(*    CS_OEMCHARS		= 00010H;*)
    CS_OWNDC		= $00020;
    CS_CLASSDC		= $00040;
    CS_PARENTDC		= $00080;
    CS_MENUPOPUP	= $00080;
    CS_NOKEYCVT		= $00100;
    CS_SAVEBITS		= $00800;
    CS_NOCLOSE		= $00200;
    CS_BYTEALIGNCLIENT	= $01000;
    CS_BYTEALIGNWINDOW	= $02000;
    
    CS_GLOBALCLASS	= $04000;

    (* Create window special parameter value *)
    
    CW_USEDEFAULT 	= INTEGER($08000);

    (* Class field offsets for GetClassLong & GetClassWord *)
    
    GCL_MENUNAME	= -8;
    GCW_HBRBACKGROUND	= -10;
    GCW_HCURSOR		= -12;
    GCW_HICON		= -14;
    GCW_HMODULE		= -16;
    GCW_CBWNDEXTRA	= -18;
    GCW_CBCLSEXTRA	= -20;
    GCL_WNDPROC		= -24;
    GCW_STYLE		= -26;
    
    (* Window field offsets for GetWindowLong & GetWindowWord *)

    GW_HWNDFIRST	= 0;
    GW_HWNDLAST		= 1;
    GW_HWNDNEXT		= 2;
    GW_HWNDPREV		= 3;
    GW_OWNER		= 4;
    GW_CHILD		= 5;
    
    GWL_WNDPROC		= -4;
    GWW_HINSTANCE	= -6;
    GWW_HWNDPARENT	= -8;
    GWW_HWNDTEXT	= -10;
    GWW_ID		= -12;
    GWL_STYLE		= -16;
    GWL_EXSTYLE		= -20;
    
    (* WINWhere area codes *)

    HTERROR		= -2;
    HTTRANSPARENT	= -1;
    HTNOWHERE		= 0;
    HTCLIENT		= 1;
    HTCAPTION		= 2;
    HTSYSMENU		= 3;
    HTGROWBOX		= 4;
    HTSIZE		= HTGROWBOX;
    HTMENU		= 5;
    HTHSCROLL		= 6;
    HTVSCROLL		= 7;
    HTREDUCE		= 8;
    HTZOOM		= 9;
    HTLEFT		= 10;
    HTRIGHT		= 11;
    HTTOP		= 12;
    HTTOPLEFT		= 13;
    HTTOPRIGHT		= 14;
    HTBOTTOM		= 15;
    HTBOTTOMLEFT	= 16;
    HTBOTTOMRIGHT	= 17;
    HTSIZEFIRST		= HTLEFT;
    HTSIZELAST		= HTBOTTOMRIGHT;
    
    MA_ACTIVATE		= 1;
    MA_ACTIVATEANDEAT	= 2;
    MA_NOACTIVATE	= 3;

    (* MessageBox type_flags *)
    
    MB_OK		= $00000;
    MB_OKCANCEL		= $00001;
    MB_ABORTRETRYIGNORE	= $00002;
    MB_YESNOCANCEL	= $00003;
    MB_YESNO		= $00004;
    MB_RETRYCANCEL	= $00005;
    
    MB_ICONHAND		= $00010;
    MB_ICONQUESTION	= $00020;
    MB_ICONEXCLAMATION	= $00030;
    MB_ICONASTERISK	= $00040;
    
    MB_ICONINFORMATION	= MB_ICONASTERISK;
    MB_ICONSTOP		= MB_ICONHAND;

    MB_DEFBUTTON1	= $00000;
    MB_DEFBUTTON2	= $00100;
    MB_DEFBUTTON3	= $00200;

    MB_APPLMODAL	= $00000;
    MB_SYSTEMMODAL	= $01000;
    MB_TASKMODAL	= $02000;
    MB_NOFOCUS		= $08000;
    MB_TYPEMASK		= $0000f;
    MB_ICONMASK		= $000f0;
    MB_DEFMASK		= $00f00;
    MB_MODEMASK		= $03000;
    MB_MISCMASK		= $0c000;

    (* Menu flags for Add/Check/EnableMenuItem *)

    MF_CHANGE		= $00080;
    MF_INSERT		= $00000;
    MF_APPEND		= $00100;
    MF_DELETE		= $00200;
    MF_REMOVE		= $01000;
    MF_BYPOSITION	= $00400;
    MF_SEPARATOR	= $00800;
    MF_BYCOMMAND	= $00000;
    MF_GRAYED		= $00001;
    MF_DISABLED		= $00002;
    MF_ENABLED		= $00000;
    MF_CHECKED		= $00008;
    MF_UNCHECKED	= $00000;
    MF_USECHECKBITMAPS	= $00200;
    MF_BITMAP		= $00004;
    MF_STRING		= $00000;
    MF_OWNERDRAW	= $00100;
    MF_POPUP		= $00010;
    MF_MENUBARBREAK	= $00020;
    MF_MENUBREAK	= $00040;
    MF_HILITE		= $00080;
    MF_UNHILITE		= $00000;
    
    MF_SYSMENU		= $02000;
    MF_HELP		= $04000;
    MF_MOUSESELECT	= $08000;
    
    MF_END		= $00080;

    (* Key state masks for mouse messages *)

    MK_LBUTTON           = $00001;
    MK_RBUTTON           = $00002;
    MK_SHIFT             = $00004;
    MK_CONTROL           = $00008;
    MK_MBUTTON           = $00010;

TYPE
    MENUITEMTEMPLATEHEADER =
	RECORD
	versionNumber	: WORD;
	offset		: WORD;
	END;
	
    MENUITEMTEMPLATE =
	RECORD
	mtOption	: WORD;
	mtID		: WORD;
	mtString	: ARRAY [0..0] OF CHAR;
	END;

CONST

    (* WH_MSGFILTER filter proc codes *)

    MSGF_DIALOGBOX	= 0;
    MSGF_MESSAGEBOX	= 1;
    MSGF_MENU		= 2;
    MSGF_MOVE		= 3;
    MSGF_SIZE		= 4;
    MSGF_SCROLLBAR	= 5;
    MSGF_NEXTWINDOW	= 6;
    
    WC_INIT		= 1;
    WC_SWP		= 2;
    WC_DEFWINDOWPROC	= 3;
    WC_MINMAX		= 4;
    WC_MOVE		= 5;
    WC_SIZE		= 6;
    WC_DRAWCAPTION	= 7;

    (* PeekMessage commands *)
    
    PM_NOREMOVE		= 0;
    PM_REMOVE		= 1;
    PM_NOYIELD		= 2;

    (* flags for regions *)

    ERROR		= 0;
    NULLREGION		= 1;
    SIMPLEREGION	= 2;
    COMPLEXREGION	= 3;

    (* styles for CombineRgn *)

    RGN_AND		= 1;
    RGN_OR		= 2;
    RGN_XOR		= 3;
    RGN_DIFF		= 4;
    RGN_COPY		= 5;

    (*  Scroll bar constants *)

    SB_HORZ            = 0;
    SB_VERT            = 1;
    SB_CTL             = 2;
    SB_BOTH		= 3;

    (*  Scroll Commands *)

    SB_LINEUP		= 0;
    SB_LINEDOWN		= 1;
    SB_PAGEUP		= 2;
    SB_PAGEDOWN		= 3;
    SB_THUMBPOSITION	= 4;
    SB_THUMBTRACK	= 5;
    SB_TOP		= 6;
    SB_BOTTOM		= 7;
    SB_ENDSCROLL	= 8;

    (* System Menu Command Values *)
    
    SC_SIZE		= $0F000;
    SC_MOVE		= $0F010;
    SC_MINIMIZE		= $0F020;
    SC_MAXIMIZE		= $0F030;
    SC_NEXTWINDOW	= $0F040;
    SC_PREVWINDOW	= $0F050;
    SC_CLOSE		= $0F060;
    SC_VSCROLL		= $0F070;
    SC_HSCROLL		= $0F080;
    SC_MOUSEMENU	= $0F090;
    SC_KEYMENU		= $0F100;
    SC_ARRANGE		= $0F110;
    SC_RESTORE		= $0F120;
    SC_TASKLIST		= $0F130;
    
    SC_ICON		= SC_MINIMIZE;
    SC_ZOOM		= SC_MAXIMIZE;
    
    (* ShowWindow commands *)

    HIDE_WINDOW		= 0;
    SHOW_OPENWINDOW	= 1;
    SHOW_ICONWINDOW	= 2;
    SHOW_FULLSCREEN	= 3;
    SHOW_OPENNOACTIVATE	= 4;

    (* Size message commands *)

    SIZENORMAL		= 0;
    SIZEICONIC		= 1;
    SIZEFULLSCREEN	= 2;
    SIZEZOOMSHOW	= 3;
    SIZEZOOMHIDE	= 4;

    (* GetSystemMetrics codes *)

    SM_CXSCREEN		= 0;
    SM_CYSCREEN		= 1;
    SM_CXVSCROLL	= 2;
    SM_CYHSCROLL	= 3;
    SM_CYCAPTION	= 4;
    SM_CXBORDER		= 5;
    SM_CYBORDER		= 6;
    SM_CXDLGFRAME	= 7;
    SM_CYDLGFRAME	= 8;
    SM_CYVTHUMB		= 9;
    SM_CXHTHUMB		= 10;
    SM_CXICON		= 11;
    SM_CYICON		= 12;
    SM_CXCURSOR		= 13;
    SM_CYCURSOR		= 14;
    SM_CYMENU		= 15;
    SM_CXFULLSCREEN	= 16;
    SM_CYFULLSCREEN	= 17;
    SM_CYKANJIWINDOW	= 18;
    SM_MOUSEPRESENT	= 19;
    SM_CYVSCROLL	= 20;
    SM_CXHSCROLL	= 21;
    SM_DEBUG		= 22;
    SM_SWAPBUTTON	= 23;
    SM_RESERVED1	= 24;
    SM_RESERVED2	= 25;
    SM_RESERVED3	= 26;
    SM_RESERVED4	= 27;
    SM_CXMIN		= 28;
    SM_CYMIN		= 29;
    SM_CXSIZE		= 30;
    SM_CYSIZE		= 31;
    SM_CXFRAME		= 32;
    SM_CYFRAME		= 33;
    SM_CXMINTRACK	= 34;
    SM_CYMINTRACK	= 35;
    SM_CMETRICS		= 36;
    
    
    ST_BEGINSWP		= 0;
    ST_ENDSWP		= 1;

    SWP_NOSIZE		= $0001;
    SWP_NOMOVE		= $0002;
    SWP_NOZORDER	= $0004;
    SWP_NOREDRAW	= $0008;
    SWP_NOACTIVATE	= $0010;
    SWP_DRAWFRAME	= $0020;
    SWP_SHOWWINDOW	= $0040;
    SWP_HIDEWINDOW	= $0080;
    SWP_NOCOPYBITS	= $0100;
    SWP_NOREPOSITION	= $0200;
    
    (* identifiers for the WM_SHOWWINDOW message *)

    SW_HIDE		= 0;
    SW_PARENTCLOSING	= 1;
    SW_OTHERZOOM	= 2;
    SW_PARENTOPENING	= 3;
    SW_OTHERUNZOOM	= 4;
    SW_SHOW		= 5;
    
    SW_SHOWNORMAL	= 1;
    SW_NORMAL		= 1;
    SW_SHOWMINIMIZED	= 2;
    SW_SHOWMAXIMIZED	= 3;
    SW_MAXIMIZE		= 3;
    SW_SHOWNOACTIVATE	= 4;
    SW_MINIMIZE		= 6;
    SW_SHOWMINNOACTIVE	= 7;
    SW_SHOWNA		= 8;
    SW_RESTORE		= 9;

    (* Virtual Keys, Standard Set *)

    VK_LBUTTON		= $001;
    VK_RBUTTON		= $002;
    VK_CANCEL		= $003;
    VK_MBUTTON		= $004;
    VK_BACK		= $008;
    VK_TAB		= $009;
    VK_CLEAR		= $00c;
    VK_RETURN		= $00d;
    VK_SHIFT		= $010;
    VK_CONTROL		= $011;
    VK_MENU		= $012;
    VK_PAUSE		= $013;
    VK_CAPITAL		= $014;
    VK_ESCAPE		= $01b;
    VK_SPACE		= $020;

    VK_PRIOR		= $021;
    VK_NEXT		= $022;
    VK_END		= $023;
    VK_HOME		= $024;
    VK_LEFT		= $025;
    VK_UP		= $026;
    VK_RIGHT		= $027;
    VK_DOWN		= $028;
    
    (* VK_A thru VK_Z are the same as their ASCII equivalents: 'A' thru 'Z' *)
    (* VK_0 thru VK_9 are the same as their ASCII equivalents: '0' thru '0' *)
    
    VK_SELECT		= $029;
    VK_PRINT		= $02a;
    VK_EXECUTE		= $02b;
    VK_SNAPSHOT		= $02C;
    VK_INSERT		= $02d;
    VK_DELETE		= $02e;
    VK_HELP		= $02f;

    VK_NUMPAD0		= $060;
    VK_NUMPAD1		= $061;
    VK_NUMPAD2		= $062;
    VK_NUMPAD3		= $063;
    VK_NUMPAD4		= $064;
    VK_NUMPAD5		= $065;
    VK_NUMPAD6		= $066;
    VK_NUMPAD7		= $067;
    VK_NUMPAD8		= $068;
    VK_NUMPAD9		= $069;
    VK_MULTIPLY		= $06A;
    VK_ADD		= $06B;
    VK_SEPARATOR	= $06C;
    VK_SUBTRACT		= $06D;
    VK_DECIMAL		= $06E;
    VK_DIVIDE		= $06F;

    VK_F1		= $070;
    VK_F2		= $071;
    VK_F3		= $072;
    VK_F4		= $073;
    VK_F5		= $074;
    VK_F6		= $075;
    VK_F7		= $076;
    VK_F8		= $077;
    VK_F9		= $078;
    VK_F10		= $079;
    VK_F11		= $07a;
    VK_F12		= $07b;
    VK_F13		= $07c;
    VK_F14		= $07d;
    VK_F15		= $07e;
    VK_F16		= $07f;
    
    VK_NUMLOCK		= $090;

    (* SetWindowsHook codes *)

    WH_MSGFILTER	= -1;
    WH_JOURNALRECORD	= 0;
    WH_JOURNALPLAYBACK	= 1;
    WH_KEYBOARD		= 2;
    WH_GETMESSAGE	= 3;
    WH_CALLWNDPROC	= 4;
    WH_CBT		= 5;
    WH_SYSMSGFILTER	= 6;
    WH_WINDOWMGR	= 7;
    
    HC_LPLPFNNEXT	= -2;
    HC_LPFNNEXT		= -1;
    HC_ACTION		= 0;
    HC_GETNEXT		= 1;
    HC_SKIP		= 2;
    HC_NOREM		= 3;
    HC_NOREMOVE		= 3;
    HC_SYSMODALON	= 4;
    HC_SYSMODALOFF	= 5;
    
    HCBT_MOVESIZE	= 0;
    HCBT_MINMAX		= 1;
    HCBT_QS		= 2;
    

    (* Window Procedure Messages *)

    WM_NULL		= $00000;
    WM_CREATE		= $00001;
    WM_DESTROY		= $00002;
    WM_MOVE		= $00003;
    WM_SIZEWAIT		= $00004;
    WM_SIZE		= $00005;
    WM_ACTIVATE		= $00006;
    WM_SETFOCUS		= $00007;
    WM_KILLFOCUS	= $00008;
    WM_SETVISIBLE	= $00009;
    WM_ENABLE		= $0000a;
    WM_SETREDRAW	= $0000b;
    WM_SETTEXT		= $0000c;
    WM_GETTEXT		= $0000d;
    WM_GETTEXTLENGTH	= $0000e;
    WM_PAINT		= $0000f;
    WM_CLOSE		= $00010;
    WM_QUERYENDSESSION	= $00011;
    WM_QUIT		= $00012;
    WM_QUERYOPEN	= $00013;
    WM_ERASEBKGND	= $00014;
    WM_SYSCOLORCHANGE	= $00015;
    WM_ENDSESSION	= $00016;
    WM_SYSTEMERROR	= $00017;
    WM_SHOWWINDOW	= $00018;
    WM_CTLCOLOR		= $00019;
    WM_WININICHANGE	= $0001a;
    WM_DEVMODECHANGE	= $0001b;
    WM_ACTIVATEAPP	= $0001c;
    WM_FONTCHANGE	= $0001d;
    WM_TIMECHANGE	= $0001e;
    WM_CANCELMODE	= $0001f;
    
    WM_SETCURSOR	= $00020;
    WM_MOUSEACTIVATE	= $00021;
    WM_CHILDACTIVATE	= $00022;
    WM_QUEUESYNC	= $00023;
    WM_GETMINMAXINFO	= $00024;
    WM_PAINTICON	= $00026;
    WM_ICONERASEBKGND	= $00027;
    WM_NEXTDLGCTL	= $00028;
    WM_SPOOLERSTATUS	= $0002A;
    WM_DRAWITEM		= $0002B;
    WM_MEASUREITEM	= $0002C;
    WM_DELETEITEM	= $0002D;
    WM_VKEYTOITEM	= $0002E;
    WM_CHARTOITEM	= $0002F;
    WM_SETFONT		= $00030;
    WM_GETFONT		= $00031;
    
    WM_QUERYDRAGICON	= $00037;
    
    WM_COMPAREITEM	= $00039;
    WM_COMPACTING	= $00041;
    
    WM_NCCREATE		= $00081;
    WM_NCDESTROY	= $00082;
    WM_NCCALCSIZE	= $00083;
    WM_NCHITTEST	= $00084;
    WM_NCPAINT		= $00085;
    WM_NCACTIVATE	= $00086;
    WM_GETDLGCODE	= $00087;
    WM_NCMOUSEMOVE	= $000a0;
    WM_NCLBUTTONDOWN	= $000a1;
    WM_NCLBUTTONUP	= $000a2;
    WM_NCLBUTTONDBLCLK	= $000a3;
    WM_NCRBUTTONDOWN	= $000a4;
    WM_NCRBUTTONUP	= $000a5;
    WM_NCRBUTTONDBLCLK	= $000a6;
    WM_NCMBUTTONDOWN	= $000a7;
    WM_NCMBUTTONUP	= $000a8;
    WM_NCMBUTTONDBLCLK	= $000a9;

    (* keyboard messages *)

    WM_KEYFIRST		= $00100;
		
    WM_KEYDOWN		= $00100;
    WM_KEYUP		= $00101;
    WM_CHAR		= $00102;
    WM_DEADCHAR		= $00103;
    WM_SYSKEYDOWN	= $00104;
    WM_SYSKEYUP		= $00105;
    WM_SYSCHAR		= $00106;
    WM_SYSDEADCHAR	= $00107;
    WM_KEYLAST		= $00108;
    WM_MOVECONVERTWINDOW= $00109;
    WM_CONVERTREQUEST	= $0010A;
    WM_CONVERTRESULT	= $0010B;

    (* random event messages *)

    WM_INITDIALOG	= $00110;
    WM_COMMAND		= $00111;
    WM_SYSCOMMAND	= $00112;
    WM_TIMER		= $00113;
    WM_HSCROLL		= $00114;
    WM_VSCROLL		= $00115;
    WM_INITMENU		= $00116;
    WM_INITMENUPOPUP	= $00117;
    WM_SYSTIMER		= $00118;

    (* mouse messages *)

    WM_MOUSEFIRST	= $00200;
    WM_MOUSELAST	= $00209;

    WM_MOUSEMOVE	= $00200;
    WM_LBUTTONDOWN	= $00201;
    WM_LBUTTONUP	= $00202;
    WM_LBUTTONDBLCLK	= $00203;
    WM_RBUTTONDOWN	= $00204;
    WM_RBUTTONUP	= $00205;
    WM_RBUTTONDBLCLK	= $00206;
    WM_MBUTTONDOWN	= $00207;
    WM_MBUTTONUP	= $00208;
    WM_MBUTTONDBLCLK	= $00209;

    (* clipboard messages *)

    WM_CUT		= $00300;
    WM_COPY		= $00301;
    WM_PASTE		= $00302;
    WM_CLEAR		= $00303;
    WM_UNDO		= $00304;
    WM_RENDERFORMAT	= $00305;
    WM_RENDERALLFORMATS	= $00306;
    WM_DESTROYCLIPBOARD	= $00307;
    WM_DRAWCLIPBOARD	= $00308;
    WM_PAINTCLIPBOARD	= $00309;
    WM_VSCROLLCLIPBOARD	= $0030a;
    WM_SIZECLIPBOARD	= $0030b;
    WM_ASKCBFORMATNAME	= $0030c;
    WM_CHANGECBCHAIN	= $0030d;
    WM_HSCROLLCLIPBOARD	= $0030e;
    
    WM_PARENTNOTIFY	= $0210;
    WM_MDICREATE	= $0220;
    WM_MDIDESTROY	= $0221;
    WM_MDIACTIVATE	= $0222;
    WM_MDIRESTORE	= $0223;
    WM_MDINEXT		= $0224;
    WM_MDIMAXIMIZE	= $0225;
    WM_MDITITLE		= $0226;
    WM_MDICASCADE	= $0227;
    WM_MDIICONARRANGE	= $0228;
    WM_MDIGETACTIVATE	= $0229;
    WM_MDISETMENU	= $0230;
    
(* DDE window messages *)

    WM_DDE_FIRST	    = $03E0;
    WM_DDE_INITIATE         = WM_DDE_FIRST;
    WM_DDE_TERMINATE        = WM_DDE_FIRST+1;
    WM_DDE_ADVISE	    = WM_DDE_FIRST+2;
    WM_DDE_UNADVISE         = WM_DDE_FIRST+3;
    WM_DDE_ACK	    	    = WM_DDE_FIRST+4;
    WM_DDE_DATA	    	    = WM_DDE_FIRST+5;
    WM_DDE_REQUEST	    = WM_DDE_FIRST+6;
    WM_DDE_POKE	    	    = WM_DDE_FIRST+7;
    WM_DDE_EXECUTE	    = WM_DDE_FIRST+8;
    WM_DDE_LAST	    	    = WM_DDE_FIRST+8;

    (* private window messages start here *)
    
    WM_USER		= $00400;

    (* Window styles *)

    WS_TILED		= $000000000;
    WS_OVERLAPPED	= WS_TILED;
    WS_ICONICPOPUP	= $0C0000000;
    WS_POPUP		= $080000000;
    WS_CHILD		= $040000000;
    WS_MINIMIZE		= $020000000;
    WS_VISIBLE		= $010000000;
    WS_DISABLED		= $008000000;
    WS_CLIPSIBLINGS	= $004000000;
    WS_CLIPCHILDREN	= $002000000;
    WS_MAXIMIZE		= $001000000;
    WS_BORDER		= $000800000;
    WS_CAPTION		= $000C00000;
    WS_DLGFRAME		= $000400000;
    WS_VSCROLL		= $000200000;
    WS_HSCROLL		= $000100000;
    WS_SYSMENU		= $000080000;
    WS_THICKFRAME	= $000040000;
    WS_SIZEBOX		= WS_THICKFRAME;
    WS_GROUP		= $000020000;
    WS_TABSTOP		= $000010000;
    WS_MINIMIZEBOX	= $000020000;
    WS_MAXIMIZEBOX	= $000010000;
    WS_ICONIC		= WS_MINIMIZE;

    (* Shorthand for the common cases *)

    WS_TILEDWINDOW	= WS_TILED + WS_CAPTION + WS_SYSMENU + 
			  WS_THICKFRAME + WS_MINIMIZEBOX + WS_MAXIMIZEBOX;
    WS_OVERLAPPEDWINDOW	= WS_TILEDWINDOW;
    WS_POPUPWINDOW	= WS_POPUP + WS_BORDER + WS_SYSMENU;
    WS_CHILDWINDOW	= (WS_CHILD);

    WS_EX_DLGMODALFRAME	= 1;
    WS_EX_NOPARENTNOTIFY= 4;
    
(* Standard resource constants *)

CONST

    (* Standard cursor types *)

    IDC_ARROW		= MAKEINTRESOURCE (32512);
    IDC_IBEAM		= MAKEINTRESOURCE (32513);
    IDC_WAIT		= MAKEINTRESOURCE (32514);
    IDC_CROSS		= MAKEINTRESOURCE (32515);
    IDC_UPARROW		= MAKEINTRESOURCE (32516);
    IDC_SIZE		= MAKEINTRESOURCE (32640);
    IDC_ICON		= MAKEINTRESOURCE (32641);

    IDC_SIZEWSE		= MAKEINTRESOURCE (32642);
    IDC_SIZEESW		= MAKEINTRESOURCE (32643);
    IDC_SIZEWE		= MAKEINTRESOURCE (32644);
    IDC_SIZENS		= MAKEINTRESOURCE (32645);
    
    ORD_LANGDRIVER	= 1;

    (* Standard icon IDs *)
    
    IDI_APPLICATION	= MAKEINTRESOURCE (32512);
    IDI_HAND		= MAKEINTRESOURCE (32513);
    IDI_QUESTION	= MAKEINTRESOURCE (32514);
    IDI_EXCLAMATION	= MAKEINTRESOURCE (32515);
    IDI_ASTERISK	= MAKEINTRESOURCE (32516);

    (* Standard bitmap resources *)
    OBM_CLOSE		= 32754;
    OBM_UPARROW		= 32753;
    OBM_DNARROW		= 32752;
    OBM_RGARROW		= 32751;
    OBM_LFARROW		= 32750;
    OBM_REDUCE		= 32749;
    OBM_ZOOM		= 32748;
    OBM_RESTORE		= 32747;
    OBM_REDUCED		= 32746;
    OBM_ZOOMD		= 32745;
    OBM_RESTORED	= 32744;
    OBM_UPARROWD	= 32743;
    OBM_DNARROWD	= 32742;
    OBM_RGARROWD	= 32741;
    OBM_LFARROWD	= 32740;
    OBM_MNARROW		= 32739;
    OBM_COMBO		= 32738;

    OBM_OLD_CLOSE          = 32767;
    OBM_SIZE           = 32766;
    OBM_OLD_UPARROW        = 32765;
    OBM_OLD_DNARROW        = 32764;
    OBM_OLD_RGARROW        = 32763;
    OBM_OLD_LFARROW        = 32762;
    OBM_BTSIZE         = 32761;
    OBM_CHECK          = 32760;
    OBM_CHECKBOXES     = 32759;
    OBM_BTNCORNERS     = 32758;
    OBM_OLD_REDUCE	= 32757;
    OBM_OLD_ZOOM	= 32756;
    OBM_OLD_RESTORE	= 32755;

    OCR_NORMAL         = 32512;
    OCR_IBEAM          = 32513;
    OCR_WAIT           = 32514;
    OCR_CROSS          = 32515;
    OCR_UP             = 32516;
    OCR_SIZE           = 32640;
    OCR_ICON           = 32641;
    OCR_SIZENWSE	= 32642;
    OCR_SIZENESW	= 32643;
    OCR_SIZEWE		= 32644;
    OCR_SIZENS		= 32645;
    OCR_SIZEALL		= 32646;
    OCR_ICOCUR		= 32647;

    OIC_SAMPLE         = 32512;
    OIC_HAND           = 32513;
    OIC_QUES           = 32514;
    OIC_BANG           = 32515;
    OIC_NOTE           = 32516;

    (* Predefined resource types *)

    RT_CURSOR             = MAKEINTRESOURCE (1);
    RT_BITMAP             = MAKEINTRESOURCE (2);
    RT_ICON               = MAKEINTRESOURCE (3);
    RT_MENU               = MAKEINTRESOURCE (4);
    RT_DIALOG             = MAKEINTRESOURCE (5);
    RT_STRING             = MAKEINTRESOURCE (6);
    RT_FONTDIR            = MAKEINTRESOURCE (7);
    RT_FONT               = MAKEINTRESOURCE (8);
    RT_ACCELERATOR        = MAKEINTRESOURCE (9);
    RT_RCDATA		  = MAKEINTRESOURCE (10);

(* Logical font constants *)

CONST
    
    (* output precision constants *)
     
    OUT_DEFAULT_PRECIS	= 0;
    OUT_STRING_PRECIS    = 1;
    OUT_CHARACTER_PRECIS = 2;
    OUT_STROKE_PRECIS    = 3;
    
    (* clipping precision constants *)
    
    CLIP_DEFAULT_PRECIS	= 0;
    CLIP_CHARACTER_PRECIS= 1;
    CLIP_STROKE_PRECIS	= 2;

    (* quality constants *)
    
    DEFAULT_QUALITY	= 0;
    DRAFT_QUALITY	= 1;
    PROOF_QUALITY	= 2;

    (* pitch constants *)
    
    DEFAULT_PITCH	= 0;
    FIXED_PITCH		= 1;
    VARIABLE_PITCH	= 2;

    (* character set constants *)
    
    ANSI_CHARSET	= 0;
    SYMBOL_CHARSET	= 2;
    SHIFTJIS_CHARSET	= 128;
    OEM_CHARSET		= 255;

    (* EnumFonts masks. *)

    RASTER_FONTTYPE	= $00001;
    DEVICE_FONTTYPE	= $00002;

    (* Logical font styles *)

    FF_DONTCARE		= 0;	(* Don't care or don't know. *)
    FF_ROMAN		= 16;	(* Variable stroke width, serifed. *)
				(* Times Roman, Century Schoolbook, etc. *)
    FF_SWISS		= 32;	(* Variable stroke width, sans-serifed. *)
				(* Helvetica, Swiss, etc. *)
    FF_MODERN		= 48;	(* Constant stroke width, serifed or sans-serifed. *)
				(* Pica, Elite, Courier, etc. *)
    FF_SCRIPT		= 64;	(* Cursive, etc. *)
    FF_DECORATIVE	= 80;	(* Old English, etc. *)

    (* Font weights lightest to darkest. *)
    
    FW_DONTCARE		= 0;
    FW_THIN		= 100;
    FW_EXTRALIGHT	= 200;
    FW_LIGHT		= 300;
    FW_NORMAL		= 400;
    FW_MEDIUM		= 500;
    FW_SEMIBOLD		= 600;
    FW_BOLD		= 700;
    FW_EXTRABOLD	= 800;
    FW_HEAVY		= 900;
    
    FW_ULTRALIGHT	= (FW_EXTRALIGHT);
    FW_REGULAR		= (FW_NORMAL);
    FW_DEMIBOLD		= (FW_SEMIBOLD);
    FW_ULTRABOLD	= (FW_EXTRABOLD);
    FW_BLACK		= (FW_HEAVY);


(* Clipboard constants *)

CONST

    (* predefined clipboard formats *)

    CF_TEXT		= 1;
    CF_BITMAP		= 2;
    CF_METAFILEPICT	= 3;
    CF_SYLK		= 4;
    CF_DIF		= 5;
    CF_TIFF		= 6;
    CF_OEMTEXT		= 7;
    CF_DIB		= 8;
    CF_PALETTE		= 9;

    CF_OWNERDISPLAY	= $080;
    CF_DSPTEXT		= $081;
    CF_DSPBITMAP	= $082;
    CF_DSPMETAFILEPICT	= $083;

    (* Private clipboard format range *)

    CF_PRIVATEFIRST	= $0200;   (* Anything in this range doesn't *)
    CF_PRIVATELAST	= $02ff;   (* get GlobalFree'd *)
    CF_GDIOBJFIRST	= $0300;   (* Anything in this range gets *)
    CF_GDIOBJLAST	= $03ff;   (* DeleteObject'ed *)


(* Dialog and message box controls constants *)

CONST

    (* button control messages *)
    
    BM_GETCHECK		= WM_USER+0;
    BM_SETCHECK		= WM_USER+1;
    BM_GETSTATE		= WM_USER+2;
    BM_SETSTATE		= WM_USER+3;
    BM_SETSTYLE		= WM_USER+4;
    
    (* user button notification codes *)
    
    BN_CLICKED		= 0;
    BN_PAINT		= 1;
    BN_HILITE		= 2;
    BN_UNHILITE		= 3;
    BN_DISABLE		= 4;
    BN_DOUBLECLICKED	= 5;
    
    (* button control styles *)
    
    BS_PUSHBUTTON	= 0;
    BS_DEFPUSHBUTTON	= 1;
    BS_CHECKBOX		= 2;
    BS_AUTOCHECKBOX	= 3;
    BS_RADIOBUTTON	= 4;
    BS_3STATE		= 5;
    BS_AUTO3STATE	= 6;
    BS_GROUPBOX		= 7;
    BS_USERBUTTON	= 8;
    BS_AUTORADIOBUTTON	= 9;
    BS_PUSHBOX		= 10;
    BS_OWNERDRAW	= 11;
    BS_LEFTTEXT		= 32;
    
    (* Dialog style bits *)
    
    DS_ABSALIGN		= $1;
    DS_SYSMODAL		= $2;
    
    DS_LOCALEDIT	= $20;   (* Edit items get Local storage. *)
    DS_SETFONT		= $40;   (* User specified font for Dlg controls *)
    DS_MODALFRAME	= $80;   (* Can be combined with WS_CAPTION  *)
    DS_NOIDLEMSG	= $100;  (* WM_ENTERIDLE message will not be sent *)

    (*  Dialog codes (returned by WM_GETDLGCODE message) *)
    
    DLGC_WANTARROWS	= $00001; (* control wants arrow keys *)
    DLGC_WANTTAB	= $00002; (* control wants tab keys *)
    DLGC_WANTALLKEYS	= $00004; (* control wants all keys *)
    DLGC_HASSETSEL	= $00008; (* understands EM_SETSEL message *)
        
    (* control messages *)
    
    EM_GETSEL		= WM_USER+0;
    EM_SETSEL		= WM_USER+1;
    EM_GETRECT		= WM_USER+2;
    EM_SETRECT		= WM_USER+3;
    EM_SETRECTNP	= WM_USER+4;
    EM_SCROLL		= WM_USER+5;
    EM_LINESCROLL	= WM_USER+6;
    EM_GETMODIFY	= WM_USER+8;
    EM_SETMODIFY	= WM_USER+9;
    EM_GETLINECOUNT	= WM_USER+10;
    EM_LINEINDEX	= WM_USER+11;
    EM_SETHANDLE	= WM_USER+12;
    EM_GETHANDLE	= WM_USER+13;
    EM_GETTHUMB		= WM_USER+14;
    EM_LINELENGTH	= WM_USER+17;
    EM_REPLACESEL	= WM_USER+18;
    EM_SETFONT		= WM_USER+19;
    EM_GETLINE		= WM_USER+20;
    EM_LIMITTEXT	= WM_USER+21;
    EM_CANUNDO		= WM_USER+22;
    EM_UNDO		= WM_USER+23;
    EM_FMTLINES		= WM_USER+24;
    
    EM_LINEFROMCHAR	= WM_USER+25;
    EM_SETWORDBREAK	= WM_USER+26;
    EM_SETABSSTOPS	= WM_USER+27;
    EM_SETPASSWORDCHAR	= WM_USER+28;
    EM_EMPTYUNDOBUFFER	= WM_USER+29;
    EM_MSGMAX		= WM_USER+30;
    
    (* edit control notification codes *)
    
    EN_SETFOCUS		= $00100;
    EN_KILLFOCUS	= $00200;
    EN_CHANGE		= $00300;
    EN_UPDATE		= $00400;
    EN_ERRSPACE		= $00500;
    EN_MAXTEXT		= $00501;
    EN_HSCROLL		= $00601;
    EN_VSCROLL		= $00602;
    
    (* Edit control styles *)
    
    ES_LEFT		= 0;
    ES_CENTER		= 1;
    ES_RIGHT		= 2;
    ES_MULTILINE	= 4;
    ES_UPPERCASE	= 8;
    ES_LOWERCASE	= 16;
    ES_PASSWORD		= $20;
    ES_AUTOVSCROLL	= 64;
    ES_AUTOHSCROLL	= 128;
    ES_NOHIDESEL	= 256;
    ES_OEMCONVERT	= $400;
    
    (* Conventional dialog box and message box command IDs *)
    
    IDOK		= 1;
    IDCANCEL		= 2;
    IDABORT		= 3;
    IDRETRY		= 4;
    IDIGNORE		= 5;
    IDYES		= 6;
    IDNO		= 7;

    (* Listbox control return values *)

    LB_OKAY		= 0;
    LB_ERR		= -1;
    LB_ERRSPACE		= -2;
    LB_CTLCODE		= 0;
    
    (* listbox messages *)

    LB_ADDSTRING	= 1+WM_USER;
    LB_INSERTSTRING	= 2+WM_USER;
    LB_DELETESTRING	= 3+WM_USER;
    LB_REPLACESTRING	= 4+WM_USER;
    LB_RESETCONTENT	= 5+WM_USER;
    LB_SETSEL		= 6+WM_USER;
    LB_SETCURSEL	= 7+WM_USER;
    LB_GETSEL		= 8+WM_USER;
    LB_GETCURSEL	= 9+WM_USER;
    LB_GETTEXT		= 10+WM_USER;
    LB_GETTEXTLEN	= 11+WM_USER;
    LB_GETCOUNT		= 12+WM_USER;
    LB_SELECTSTRING	= 13+WM_USER;
    LB_DIR		= 14+WM_USER;
    LB_GETTOPINDEX	= 15+WM_USER;
    LB_FINDSTRING	= 16+WM_USER;
    LB_GETSELCOUNT	= 17+WM_USER;
    LB_GETSELITEMS	= 18+WM_USER;
    LB_SETABSSTOPS	= 19+WM_USER;
    LB_GETHORIZONTALEXTENT = 20+WM_USER;
    LB_SETHORIZONTALEXTENT = 21+WM_USER;
    LB_SETCOLUMNWIDTH	= 22+WM_USER;
    LB_SETTOPINDEX	= 24+WM_USER;
    LB_GETITEMRECT	= 25+WM_USER;
    LB_GETITEMDATA	= 26+WM_USER;
    LB_SETITEMDATA	= 27+WM_USER;
    LB_SELITEMRANGE	= 28+WM_USER;
    LB_MSGMAX		= 33+WM_USER;
    
    (* listbox notification codes *)

    LBN_ERRSPACE	= -2;
    LBN_SELCHANGE	= 1;
    LBN_DBLCLK		= 2;
    LBN_SELCANCEL	= 3;
    LBN_SETFOCUS	= 4;
    LBN_KILLFOCUS	= 5;
    
    (* listbox style bits *)

    LBS_NOTIFY		= $000000001;
    LBS_SORT		= $000000002;
    LBS_NOREDRAW	= $000000004;
    LBS_MULTIPLESEL 	= $000000008;
    LBS_STANDARD 	= $000A00003; (*LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER *)
    LBS_OWNERDRAWFIXED	= $10;
    LBS_OWNERDRAWVARIABLE	= $20;
    LBS_HASSTRINGS	= $40;
    LBS_USETABSTOPS	= $80;
    LBS_NOINTEGRALHEIGHT= $100;
    LBS_MULTICOLUMN	= $200;
    LBS_WANTKEYBOARDINPUT	= $400;
    LBS_EXTENDEDSEL	= $800;
    
    CB_OKAY	= 0;
    CB_ERR	= -1;
    CB_ERRSPACE	= -2;
    
    CBN_ERRSPACE	= -1;
    CBN_SELCHANGE	= 1;
    CBN_DBLCLK		= 2;
    CBN_SETFOCUS	= 3;
    CBN_KILLFOCUS	= 4;
    CBN_EDITCHANGE	= 5;
    CBN_EDITUPDATE	= 6;
    CBN_DROPDOWN	= 7;
    
    CBS_SIMPLE		= 1;
    CBS_DROPDOWN	= 2;
    CBS_DROPDOWNLIST	= 3;
    CBS_OWNERDRAWFIXED	= $10;
    CBS_OWNERDRAWVARIABLE	= $20;
    CBS_AUTOHSCROLL	= $40;
    CBS_OEMCONVERT	= $80;
    CBS_SORT		= $100;
    CBS_HASSTRINGS	= $200;
    CBS_NOINTEGERALHEIGHT	= $400;
    
    CB_GETEDITSEL	= WM_USER+0;
    CB_LIMITTEXT	= WM_USER+1;
    CB_SETEDITSEL	= WM_USER+2;
    CB_ADDSTRING	= WM_USER+3;
    CB_DELETESTRING	= WM_USER+4;
    CB_DIR		= WM_USER+5;
    CB_GETCOUNT		= WM_USER+6;
    CB_GETCURSEL	= WM_USER+7;
    CB_GETLBTEXT	= WM_USER+8;
    CB_GETLBTEXTLEN	= WM_USER+9;
    CB_INSERTSTRING	= WM_USER+10;
    CB_RESETCONTENT	= WM_USER+11;
    CB_FINDSTRING	= WM_USER+12;
    CB_SELECTSTRING	= WM_USER+13;
    CB_SETCURSEL	= WM_USER+14;
    CB_SHOWDROPDOWN	= WM_USER+15;
    CB_GETITEMDATA	= WM_USER+16;
    CB_SETITEMDATA	= WM_USER+17;
    CB_GETDROPPEDCONTROLRECT	= WM_USER+18;
    CB_MSGMAX		= WM_USER+19;
    
    (* scroll bar styles *)
    
    SBS_HORZ			= $000000000;
    SBS_VERT			= $000000001;
    SBS_TOPALIGN		= $000000002;
    SBS_LEFTALIGN		= $000000002;
    SBS_BOTTOMALIGN		= $000000004;
    SBS_RIGHTALIGN		= $000000004;
    SBS_SIZEBOXTOPLEFTALIGN	= $000000002;
    SBS_SIZEBOXBOTTOMRIGHTALIGN	= $000000004;
    SBS_SIZEBOX			= $000000008;
    
    (* Static control constants *)
    
    SS_LEFT		= 0;
    SS_CENTER		= 1;
    SS_RIGHT		= 2;
    SS_ICON		= 3;
    SS_BLACKRECT	= 4;
    SS_GRAYRECT		= 5;
    SS_WHITERECT	= 6;
    SS_BLACKFRAME	= 7;
    SS_GRAYFRAME	= 8;
    SS_WHITEFRAME	= 9;
    SS_USERITEM		= 10;
    SS_SIMPLE		= 11;
    SS_LEFTWORDWRAP	= 12;
    SS_NOPREFIX		= $80;

(* GDI Constants *)

CONST

    (* Background modes *)
    
    TRANSPARENT		= 1;
    OPAQUE		= 2;
    
    (* StretchBlt() modes *)

    BLACKONWHITE	= 1;
    WHITEONBLACK	= 2;
    COLORONCOLOR	= 3;

    (* PolyFill modes *)

    ALTERNATE		= 1;
    WINDING		= 2;

    (* GDI escapes *)

    NEWFRAME		= 1;
    ABORTDOC		= 2;
    NEXTBAND		= 3;
    SETCOLORTABLE	= 4;
    GETCOLORTABLE	= 5;
    FLUSHOUTPUT		= 6;
    DRAFTMODE		= 7;
    QUERYESCSUPPORT	= 8;
    SETABORTPROC	= 9;
    STARTDOC		= 10;
    ENDDOC		= 11;
    GETPHYSPAGESIZE	= 12;
    GETPRINTINGOFFSET	= 13;
    GETSCALINGFACTOR	= 14;
    
    MFCOMMENT		= 15;
    GETPENWIDTH		= 16;
    SETCOPYCOUNT	= 17;
    SELECTPAPERSOURCE	= 18;
    DEVICEDATA		= 19;
    PASSTHROUGH		= 19;
    GETTECHNOLGY	= 20;
    GETTECHNOLOGY	= 20;
    SETENDCAP		= 21;
    SETLINEJOIN		= 22;
    SETMITERLIMIT	= 23;
    BANDINFO		= 24;
    DRAWPATTERNRECT	= 25;
    GETVECTORPENSIZE	= 26;
    GETVECTORBRUSHSIZE	= 27;
    ENABLEDUPLEX	= 28;
    GETSETPAPERBINS	= 29;
    GETSETPRINTORIENT	= 30;
    ENUMPAPERBINS	= 31;
    SETDIBSCALING	= 32;
    EPSPRINTING		= 33;
    ENUMPAPERMETRICS	= 34;
    GETSETPAPERMETRICS	= 35;
    POSTSCRIPT_DATA	= 37;
    POSTSCRIPT_IGNORE	= 38;
    GETEXTENDEDTEXTMETRICS	= 256;
    GETEXTENTTABLE	= 257;
    GETPAIRKERNTABLE	= 258;
    GETTRACKKERNTABLE	= 259;
    cEXTTEXTOUT		= 512;	{Name conflict because Pascal is}
    ENABLERELATIVEWIDTHS= 768;  {not case sensitive}
    ENABLEPAIRKERNING	= 769;
    SETKERNTRACK	= 770;
    SETALLJUSTVALUES	= 771;
    SETCHARSET		= 772;
    
    cSTRETCHBLT		= 2048;  {Name conflict because Pascal is}
    BEGIN_PATH		= 4096;  {not case sensitive}
    CLIP_TO_PATH	= 4097;
    END_PATH		= 4098;
    EXT_DEVICE_CAPS	= 4099;
    RESTORE_CTM		= 4100;
    SAVE_CTM		= 4101;
    SET_ARC_DIRECTION	= 4102;
    SET_BACKGROUND_COLOR= 4103;
    SET_POLY_MODE	= 4104;
    SET_SCREEN_ANGLE	= 4105;
    SET_SPREAD		= 4106;
    TRANSFORM_CTM	= 4107;
    SET_CLIP_BOX	= 4108;
    SET_BOUNDS		= 4109;
    SET_MIRROR_MODE	= 4110;

    (* GDI coordinate modes *)
    
    ABSOLUTE		= 1;
    RELATIVE		= 2;
    
    (* Stock Logical Objects *)
    
    WHITE_BRUSH		= 0;
    LTGRAY_BRUSH	= 1;
    GRAY_BRUSH		= 2;
    DKGRAY_BRUSH	= 3;
    BLACK_BRUSH		= 4;
    NULL_BRUSH		= 5;
    HOLLOW_BRUSH 	= (NULL_BRUSH);
    WHITE_PEN		= 6;
    BLACK_PEN		= 7;
    NULL_PEN		= 8;
    OEM_FIXED_FONT	= 10;
    ANSI_FIXED_FONT	= 11;
    ANSI_VAR_FONT	= 12;
    SYSTEM_FONT		= 13;
    DEVICE_DEFAULT_FONT	= 14;
    DEFAULT_PALETTE	= 15;
    SYSTEM_FIXED_FONT	= 16;
    
    (* GDI Brush Style definitions. *)
    
    BS_SOLID		= 0;
    BS_NULL		= 1;
    BS_HOLLOW		= (BS_NULL);
    BS_HATCHED		= 2;
    BS_PATTERN		= 3;
    BS_INDEXED		= 4;
    BS_DIBPATTERN	= 5;
    
    (* DrawText format flags *)

    DT_LEFT		= $000;
    DT_CENTER		= $001;
    DT_RIGHT		= $002;
    DT_TOP		= $000;
    DT_VCENTER		= $004;
    DT_BOTTOM		= $008;
    DT_WORDBREAK	= $010;
    DT_SINGLELINE	= $020;
    DT_EXPANDTABS	= $040;
    DT_TABSTOP		= $080;
    DT_NOCLIP		= $0100;
    DT_EXTERNALLEADING	= $0200;
    DT_CALCRECT		= $0400;
    DT_NOPREFIX		= $0800;
    DT_INTERNAL		= $01000;
    
    FLOODFILLBORDER	= 0;
    FLOODFILLSURFACE	= 1;

    (* commands for use by ExtTextOut *)
    
    ETO_GRAYED			= 1;
    ETO_OPAQUE			= 2;
    ETO_CLIPPED			= 4;

    (* GDI Hatch Style definitions. *)

    HS_HORIZONTAL	= 0       (* ----- *);
    HS_VERTICAL		= 1       (* ||||| *);
    HS_FDIAGONAL	= 2       (* ///// *);
    HS_BDIAGONAL	= 3       (* \\\\\ *);
    HS_CROSS		= 4       (* +++++ *);
    HS_DIAGCROSS	= 5       (* xxxxx *);
       
    (* Mapping modes *)
    
    MM_TEXT		= 1;
    MM_LOMETRIC		= 2;
    MM_HIMETRIC		= 3;
    MM_LOENGLISH	= 4;
    MM_HIENGLISH	= 5;
    MM_TWIPS		= 6;
    MM_ISOTROPIC	= 7;
    MM_ANISOTROPIC	= 8;
    
    (* Object definitions for GDI EnumObjects. *)

    OBJ_PEN		= 1;
    OBJ_BRUSH		= 2;

    (* GDI Pen Style definitions *)
    
    PS_SOLID		= 0       (* solid pen *);
    PS_DASH		= 1       (* -------  *);
    PS_DOT		= 2       (* .......  *);
    PS_DASHDOT		= 3       (* _._._._  *);
    PS_DASHDOTDOT	= 4       (* _.._.._  *);
    PS_NULL		= 5       (*          *);
    PS_INSIDEFRAME	= 6;
    
    (*  Binary raster ops *)

    R2_BLACK		= 1	(*  0       *);
    R2_NOTMERGEPEN	= 2	(* DPon     *);
    R2_MASKNOTPEN	= 3	(* DPna     *);
    R2_NOTCOPYPEN	= 4	(* PN       *);
    R2_MASKPENNOT	= 5	(* PDna     *);
    R2_NOT		= 6	(* Dn       *);
    R2_XORPEN		= 7	(* DPx      *);
    R2_NOTMASKPEN	= 8	(* DPan     *);
    R2_MASKPEN		= 9	(* DPa      *);
    R2_NOTXORPEN	= 10	(* DPxn     *);
    R2_NOP		= 11	(* D        *);
    R2_MERGENOTPEN	= 12	(* DPno     *);
    R2_COPYPEN		= 13	(* P        *);
    R2_MERGEPENNOT	= 14	(* PDno     *);
    R2_MERGEPEN		= 15	(* DPo      *);
    R2_WHITE		= 16	(*  1       *);

    (*  Ternary raster operations *)

    SRCCOPY		= LONGINT ($000CC0020);  (* dest=source                        *)
    SRCPAINT		= LONGINT ($000EE0086);  (* dest=source OR dest                *)
    SRCAND		= LONGINT ($0008800C6);  (* dest = source AND dest             *)
    SRCINVERT		= LONGINT ($000660046);  (* dest = source XOR      dest        *)
    SRCERASE		= LONGINT ($000440328);  (* dest = source AND (not dest )      *)
    NOTSRCCOPY		= LONGINT ($000330008);  (* dest = (not source)                *)
    NOTSRCERASE		= LONGINT ($0001100A6);  (* dest = (not source) AND (not dest) *)
    MERGECOPY		= LONGINT ($000C000CA);  (* dest = (source AND pattern)        *)
    MERGEPAINT		= LONGINT ($000BB0226);  (* dest = (NOT source) OR dest        *)
    PATCOPY		= LONGINT ($000F00021);  (* dest = pattern                     *)
    PATPAINT		= LONGINT ($000FB0A09);  (* dest = DPSnoo                      *)
    PATINVERT		= LONGINT ($0005A0049);  (* dest = pattern XOR     dest        *)
    DSTINVERT		= LONGINT ($000550009);  (* dest = (not dest)                  *)
    BLACKNESS		= LONGINT ($000000042);  (* dest = BLACK                       *)
    WHITENESS		= LONGINT ($000FF0062);  (* dest = WHITE                       *)

    (* Text alignment parameter constants *)
    
	TA_UPDATECP		= 1;
	TA_NOUPDATECP		= 0;
	TA_LEFT			= 0;
	TA_RIGHT		= 2;
	TA_CENTER		= 6;
	TA_TOP			= 0;
	TA_BOTTOM		= 8;
	TA_BASELINE		= 24;

    (* Device Parameters for GetDeviceCaps() *)
    
    DRIVERVERSION	= 0     (*  Device driver version                 *);
    TECHNOLOGY		= 2     (*  Device classification                 *);
    HORZSIZE		= 4     (*  Horizontal size in millimeters        *);
    VERTSIZE		= 6     (*  Vertical   size in millimeters        *);
    HORZRES		= 8     (*  Horizontal width in pixels            *);
    VERTRES		= 10    (*  Vertical   width in pixels            *);
    BITSPIXEL		= 12    (*  Number of bits per pixel              *);
    PLANES		= 14    (*  Number of planes                      *);
    NUMBRUSHES		= 16    (*  Number of brushes the device has      *);
    NUMPENS		= 18    (*  Number of pens the device has         *);
    NUMMARKERS		= 20    (*  Number of markers the device has      *);
    NUMFONTS		= 22    (*  Number of fonts the device has        *);
    NUMCOLORS		= 24;
    PDEVICESIZE		= 26    (*  Size required for device descriptor   *);
    CURVECAPS		= 28    (*  Curves    capabilities                *);
    LINECAPS		= 30    (*  Line      capabilities                *);
    POLYGONALCAPS	= 32    (*  Polygonal capabilities                *);
    TEXTCAPS		= 34    (*  Text      capabilities                *);
    CLIPCAPS		= 36    (*  Clipping  capabilities                *);
    RASTERCAPS		= 38    (*  Bitblt    capabilities                *);
    ASPECTX		= 40    (*  Length of the X leg                   *);
    ASPECTY		= 42    (*  Length of the Y leg                   *);
    ASPECTXY		= 44    (*  Length of the hypotenuse              *);
    
    LOGPIXELSX		= 88    (*  Logical pixels/inch in X              *);
    LOGPIXELSY		= 90    (*  Logical pixels/inch in Y              *);
    
    SIZEPALETTE		= 104;
    NUMRESERVED		= 106;
    COLORRES		= 108;
    
    (* Device capability masks *)
    
    (* Device Technologies *)
    
    DT_PLOTTER		= 0	(* Vector plotter          *);
    DT_RASDISPLAY	= 1	(* Raster display          *);
    DT_RASPRINTER	= 2	(* Raster printer          *);
    DT_RASCAMERA	= 3	(* Raster camera           *);
    DT_CHARSTREAM	= 4	(* Character-stream, PLP   *);
    DT_METAFILE		= 5	(* Metafile, VDM           *);
    DT_DISPFILE		= 6	(* Display-file            *);
    
    (* Curve Capabilities *)
    
    CC_NONE		= 0	(* Curves not supported    *);
    CC_CIRCLES		= 1	(* Can do circles          *);
    CC_PIE		= 2	(* Can do pie wedges       *);
    CC_CHORD		= 4	(* Can do chord arcs       *);
    CC_ELLIPSES		= 8	(* Can do ellipese         *);
    CC_WIDE		= 16	(* Can do wide lines       *);
    CC_STYLED		= 32	(* Can do styled lines     *);
    CC_WIDESTYLED	= 64	(* Can do wide styled lines*);
    CC_INTERIORS	= 128	(* Can do interiors        *);
    
    (* Line Capabilities  *)
    
    LC_NONE		= 0	(* Lines not supported     *);
    LC_POLYLINE		= 2	(* Can do polylines        *);
    LC_MARKER		= 4	(* Can do markers          *);
    LC_POLYMARKER	= 8	(* Can do polymarkers      *);
    LC_WIDE		= 16	(* Can do wide lines       *);
    LC_STYLED		= 32	(* Can do styled lines     *);
    LC_WIDESTYLED	= 64	(* Can do wide styled lines*);
    LC_INTERIORS	= 128	(* Can do interiors        *);
    
    (* Polygonal Capabilities *)
    
    PC_NONE		= 0	(* Polygonals not supported*);
    PC_POLYGON		= 1	(* Can do polygons         *);
    PC_RECTANGLE	= 2	(* Can do rectangles       *);
    PC_TRAPEZOID	= 4	(* Can do trapezoids       *);
    PC_SCANLINE		= 8	(* Can do scanlines        *);
    PC_WIDE		= 16	(* Can do wide borders     *);
    PC_STYLED		= 32	(* Can do styled borders   *);
    PC_WIDESTYLED	= 64	(* Can do wide styled borders*);
    PC_INTERIORS	= 128	(* Can do interiors        *);
    
    (* Clipping Capabilities *)
    
    CP_NONE		= 0	(* no clipping of Output   *);
    CP_RECTANGLE	= 1	(* Output clipped to Rects *);
    
    (* Text Capabilities *)
    
    TC_OP_CHARACTER	= $00001;   (* Can do OutputPrecision   CHARACTER      *)
    TC_OP_STROKE	= $00002;   (* Can do OutputPrecision   STROKE         *)
    TC_CP_STROKE	= $00004;   (* Can do ClipPrecision     STROKE         *)
    TC_CR_90		= $00008;   (* Can do CharRotAbility    90             *)
    TC_CR_ANY		= $00010;   (* Can do CharRotAbility    ANY            *)
    TC_SF_X_YINDEP	= $00020;   (* Can do ScaleFreedom      X_YINDEPENDENT *)
    TC_SA_DOUBLE	= $00040;   (* Can do ScaleAbility      DOUBLE         *)
    TC_SA_INTEGER	= $00080;   (* Can do ScaleAbility      INTEGER        *)
    TC_SA_CONTIN	= $00100;   (* Can do ScaleAbility      CONTINUOUS     *)
    TC_EA_DOUBLE	= $00200;   (* Can do EmboldenAbility   DOUBLE         *)
    TC_IA_ABLE		= $00400;   (* Can do ItalisizeAbility  ABLE           *)
    TC_UA_ABLE		= $00800;   (* Can do UnderlineAbility  ABLE           *)
    TC_SO_ABLE		= $01000;   (* Can do StrikeOutAbility  ABLE           *)
    TC_RA_ABLE		= $02000;   (* Can do RasterFontAble    ABLE           *)
    TC_VA_ABLE		= $04000;   (* Can do VectorFontAble    ABLE           *)
    TC_RESERVED		= $08000;   (* Reserved.                               *)

    (* Raster Capabilities *)
    
    RC_BITBLT		= 1     (* Can do standard non-stretching, non-inverting BLT. *);
    RC_BANDING		= 2     (* Device requires banding support                    *);
    RC_SCALING		= 4     (* Device requires scaling support *);
    RC_BITMAP64		= 8;
    
    RC_GDI20_OUTPUT	= $10;
    RC_DI_BITMAP	= $80;
    RC_PALETTE		= $100;
    RC_DIBTODEV		= $200;
    RC_BIGFONT		= $400;
    RC_STRETCHBLT	= $800;
    RC_FLOODFILL	= $1000;
    RC_STRETCHDIB	= $2000;
    
    PC_RESERVED		= 1;
    PC_EXPLICIT		= 2;
    PC_NOCOLLAPSE	= 3;
    
    DIB_RGB_COLORS	= 0;
    DIB_PAL_COLORS	= 1;
    
    SYSPAL_STATIC	= 1;
    SYSPAL_NOSTATIC	= 2;
    
    CBM_INIT		= 4;
    	
    (* spooler error code *)

    SP_NOTREPORTED	=  $04000; (* set if GDI did not report error *)
    SP_ERROR		= (-1);    (* general errors who know what went wrong *)
    SP_APPABORT		= (-2);    (* app aborted the job - callback function returned false *)
    SP_USERABORT	= (-3);    (* user aborted the job through spooler's front end *)
    SP_OUTOFDISK	= (-4);    (* not enough disk space to spool *)
    SP_OUTOFMEMORY	= (-5);

    PR_JOBSTATUS	= 0;
    
(* Constants for file handling procedures *)

CONST

    (* Flags for GetTempFileName *)
    
    TF_FORCEDRIVE	= $080;   (* Forces use of current dir of passed *)
				  (* drive *)
    (* Flags for OpenFile *)
    
    OF_REOPEN		= $08000;
    OF_EXIST		= $04000;
    OF_PROMPT		= $02000;
    OF_CREATE		= $01000;
    OF_CANCEL		= $00800;
    OF_VERIFY		= $00400;
    OF_DELETE		= $00200;
    OF_PARSE		= $00100;
    
    OF_READ		= 0;
    OF_WRITE		= 1;
    OF_READWRITE	= 2;

    OF_SHARE_COMPAT	= 0;
    OF_SHARE_EXCLUSIVE	= $10;
    OF_SHARE_DENY_WRITE	= $20;
    OF_SHARE_DENY_READ	= $30;
    OF_SHARE_DENY_NONE	= $40;


(* Memory manager constants *)

CONST

    (* Global memory flags *)
    
    GMEM_FIXED		= $00000;
    GMEM_MOVEABLE	= $00002;
    GMEM_NOCOMPACT	= $00010;
    GMEM_NODISCARD	= $00020;
    GMEM_ZEROINIT	= $00040;
    GMEM_MODIFY		= $00080;
    GMEM_DISCARDABLE	= $00F00;
    GMEM_NOT_BANKED	= $01000;
    GMEM_SHARE		= $02000;
    GMEM_DDESHARE	= $02000;
    GMEM_NOTIFY		= $04000;
    GMEM_LOWER		= GMEM_NOT_BANKED;
    GHND		= (GMEM_MOVEABLE + GMEM_ZEROINIT);
    GPTR		= (GMEM_FIXED    + GMEM_ZEROINIT);

    (* Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE) *)
    
    GMEM_DISCARDED	= $04000;
    GMEM_SWAPPED	= $08000;(*!!!*)
    GMEM_LOCKCOUNT	= $000FF;

    (* local memory manager flags *)

    LMEM_FIXED		= $00000;
    LMEM_MOVEABLE	= $00002;
    LMEM_NOCOMPACT	= $00010;
    LMEM_NODISCARD	= $00020;
    LMEM_ZEROINIT	= $00040;
    LMEM_MODIFY		= $00080;
    LMEM_DISCARDABLE	= $00F00;
    LHND		= (LMEM_MOVEABLE + LMEM_ZEROINIT);
    LPTR		= (LMEM_FIXED    + LMEM_ZEROINIT);
    NONZEROLHND		= (LMEM_MOVEABLE);
    NONZEROLPTR		= (LMEM_FIXED);
    
    (* Flags returned by LocalFlags (in addition to LMEM_DISCARDABLE) *)
    
    LMEM_DISCARDED	= $04000;
    LMEM_LOCKCOUNT	= $000FF;

    LNOTIFY_OUTOFMEM	= 0;
    LNOTIFY_MOVE	= 1;
    LNOTIFY_DISCARD	= 2;

(* communcations procedure error return constants *)

CONST
    CE_RXOVER		= $0001;
    CE_OVERRUN		= $0002;
    CE_RXPARITY		= $0004;
    CE_FRAME		= $0008;
    CE_BREAK		= $0010;
    CE_CTSTO		= $0020;
    CE_DSRTO		= $0040;
    CE_RLSDTO		= $0080;
    CE_TXFULL		= $0100;
    CE_PTO		= $0200;
    CE_IOE		= $0400;
    CE_DNS		= $0800;
    CE_OOP		= $1000;
    CE_MODE		= $8000;

    IE_BADID		= -1;
    IE_OPEN		= -2;
    IE_NOPEN		= -3;
    IE_MEMORY		= -4;
    IE_DEFAULT		= -5;
    IE_HARDWARE		= -10;
    IE_BYTESIZE		= -11;
    IE_BAUDRATE		= -12;

(* Sound procedure constants *)

CONST
    S_QUEUEEMPTY	= 0;
    S_THRESHOLD		= 1;
    S_ALLTHRESHOLD	= 2;
    
    S_NORMAL		= 0;
    S_LEGATO		= 1;
    S_STACCATO		= 2;
    
    S_PERIOD512		= 0;
    S_PERIOD1024	= 1;
    S_PERIOD2048	= 2;
    S_PERIODVOICE	= 3;
    S_WHITE512		= 4;
    S_WHITE1024		= 5;
    S_WHITE2048		= 6;
    S_WHITEVOICE	= 7;
    
    S_SERDVNA		= -1;
    S_SEROFM		= -2;
    S_SERMACT		= -3;
    S_SERQFUL		= -4;
    S_SERBDNT		= -5;
    S_SERDLN		= -6;
    S_SERDCC		= -7;
    S_SERDTP		= -8;
    S_SERDVL		= -9;
    S_SERDMD		= -10;
    S_SERDSH		= -11;
    S_SERDPT		= -12;
    S_SERDFQ		= -13;
    S_SERDSR		= -15;
    S_SERDST		= -16;
    
    NOPARITY		= 0;
    ODDPARITY		= 1;
    EVENPARITY		= 2;
    MARKPARITY		= 3;
    SPACEPARITY		= 4;
    
    ONESTOPBIT		= 0;
    ONE5STOPBITS	= 1;
    TWOSTOPBITS		= 2;
    
    IGNORE		= 0;
    INFINITE		= $0FFFF;
    
CONST
    META_SETBKCOLOR		= $0201;
    META_SETBKMODE		= $0102;
    META_SETMAPMODE		= $0103;
    META_SETROP2		= $0104;
    META_SETREALBS		= $0105;
    META_SETPOLYFILLMODE	= $0106;
    META_SETSTRETCHBLTMODE	= $0107;
    META_SETTEXTCHAREXTRA	= $0108;
    META_SETTEXTCOLOR		= $0209;
    META_SETTEXTJUSTIFICATION	= $020A;
    META_SETWINDOWORG		= $020B;
    META_SETWINDOWEXT		= $020C;
    META_SETVIEWPORTORG		= $020D;
    META_SETVIEWPORTEXT		= $020E;
    META_OFFSETWINDOWORG	= $020F;
    META_SCALEWINDOWEXT		= $0400;
    META_OFFSETVIEWPORTORG	= $0211;
    META_SCALEVIEWPORTEXT	= $0412;
    META_LINETO			= $0213;
    META_MOVETO			= $0214;
    META_EXCLUDECLIPRECT	= $0415;
    META_INTERSECTCLIPRECT	= $0416;
    META_ARC			= $0817;
    META_ELLIPSE		= $0418;
    META_FLOODFILL		= $0419;
    META_PIE			= $081A;
    META_RECTANGLE		= $041B;
    META_ROUNDRECT		= $061C;
    META_PATBLT			= $061D;
    META_SAVEDC			= $001E;
    META_SETPIXEL		= $041F;
    META_OFFSETCLIPRGN		= $0220;
    META_TEXTOUT		= $0521;
    META_BITBLT			= $0922;
    META_STRETCHBLT		= $0B23;
    META_POLYGON		= $0324;
    META_POLYLINE		= $0325;
    META_ESCAPE			= $0626;
    META_RESTOREDC		= $0127;
    META_FILLREGION		= $0228;
    META_FRAMEREGION		= $0429;
    META_INVERTREGION		= $012A;
    META_PAINTREGION		= $012B;
    META_SELECTCLIPREGION	= $012C;
    META_SELECTOBJECT		= $012D;
    META_SETTEXTALIGN		= $012E;
    META_DRAWTEXT		= $062F;

    META_CHORD			= $0830;
    META_SETMAPPERFLAGS		= $0231;
    META_EXTEXTOUT		= $0A32;
    META_SETDIBTODEV		= $0D33;
    META_SELECTPALETTE		= $0234;
    META_REALIZEPALETTE		= $0035;
    META_ANIMATEPALETTE		= $0436;
    META_SETPALENTRIES		= $0037;
    META_POLYPOLYGON		= $0538;
    META_RESIZEPALETTE		= $0139;
    
    META_DIBBITBLT		= $0940;
    META_DIBSTRETCHBLT		= $0B41;
    META_DIBCREATEPATTERNBRUSH	= $0142;
    META_STRETCHDIB		= $0F43;
    
    META_CREATEPALETTE		= $00F7;
    META_CREATEBRUSH		= $00F8;
    META_CREATEPATTERNBRUSH	= $01F9;
    META_CREATEPENINDIRECT	= $02FA;
    META_CREATEFONTINDIRECT	= $02FB;
    META_CREATEBRUSHINDIRECT	= $02FC;
    META_CREATEBITMAPINDIRECT	= $02FD;
    META_CREATEBITMAP		= $06FE;
    META_CREATEREGION		= $06FF;


(* c macros translated into procedures or types here *)

FUNCTION MAKELONG (
	LowWord, HiWord : WORD
	) : LONGINT;

FUNCTION LOWORD (
	l : LONGINT
	) : WORD;

FUNCTION HIWORD (
	l : LONGINT
	) : WORD;

FUNCTION LOBYTE (
	w : WORD
	) : BYTE;

FUNCTION HIBYTE (
	w : WORD
	) : BYTE;

FUNCTION GlobalDiscard (
	h : HANDLE
	) : HANDLE;

FUNCTION LocalDiscard (
	h : HANDLE
	) : HANDLE;

FUNCTION LockData (
	dummy : INTEGER
	) : HANDLE;

PROCEDURE UnlockData (
	dummy : INTEGER
	);

PROCEDURE LocalFreeze (
	dummy : INTEGER
	);

PROCEDURE LocalMelt (
	dummy : INTEGER
	);

FUNCTION MAKEINTATOM (
	a : INTEGER
	) : LPSTR;

FUNCTION max (
	value1, value2 : INTEGER
	) : INTEGER;

FUNCTION min (
	value1, value2 : INTEGER
	) : INTEGER;

FUNCTION GetRValue (
	rgb : DWORD
	) : BYTE;

FUNCTION GetGValue (
	rgb : DWORD
	) : BYTE;

FUNCTION GetBValue (
	rgb : DWORD
	) : BYTE;

FUNCTION RGB (
	r, g, b : BYTE
	) : DWORD;

(* And the Windows API procedures *)

(****************************** AccessResource ******************************)

FUNCTION AccessResource (
	a : HANDLE;
	b : HANDLE
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AccessResource';


(********************************* AddAtom **********************************)

FUNCTION AddAtom (
	a : LPSTR
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AddAtom';


(***************************** AddFontResource ******************************)

FUNCTION AddFontResource (
	a : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AddFontResource';


(***************************** AdjustWindowRect *****************************)

PROCEDURE AdjustWindowRect (
	a : RECT;
	b : LONGINT;
	c : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AdjustWindowRect';


(****************************** AllocResource *******************************)

FUNCTION AllocResource (
	a : HANDLE;
	b : HANDLE;
	c : DWORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AllocResource';


(******************************** AnsiLower *********************************)

FUNCTION AnsiLower (
	a : LPSTR
	) : BYTE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiLower';


(********************************* AnsiNext *********************************)

FUNCTION AnsiNext (
	a : LPSTR
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiNext';


(********************************* AnsiPrev *********************************)

FUNCTION AnsiPrev (
	a : LPSTR;
	b : LPSTR
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiPrev';


(******************************** AnsiToOem *********************************)

FUNCTION AnsiToOem (
	a : LPSTR;
	b : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiToOem';


(******************************** AnsiUpper *********************************)

FUNCTION AnsiUpper (
	a : LPSTR
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiUpper';


(********************************* AnyPopup *********************************)

FUNCTION AnyPopup (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnyPopup';


(*********************************** Arc ************************************)

FUNCTION Arc (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : INTEGER;
	i : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Arc';


(******************************** BeginPaint ********************************)

FUNCTION BeginPaint (
	    a : HANDLE;
	VAR b : PAINTSTRUCT
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'BeginPaint';


(********************************** BitBlt **********************************)

FUNCTION BitBlt (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : HDC;
	g : INTEGER;
	h : INTEGER;
	i : DWORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'BitBlt';


(***************************** BringWindowToTop *****************************)

PROCEDURE BringWindowToTop (
	a : HWND
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'BringWindowToTop';

(****************************** BuildCommDCB ********************************)

FUNCTION BuildCommDCB (
	    a : LPSTR;
	VAR b : DCB
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'BuildCommDCB';


(****************************** CallMsgFilter *******************************)

FUNCTION CallMsgFilter (
	VAR a : MSG;
	    b : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CallMsgFilter';


(****************************** CallWindowProc ******************************)

FUNCTION CallWindowProc (
	a : WndProc;
	b : HWND;
	c : WORD;
	d : WORD;
	e : LONGINT
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CallWindowProc';


(********************************** Catch ***********************************)

FUNCTION Catch (
	VAR a : CATCHBUF
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Catch';


(*************************** ChangeClipboardChain ***************************)

FUNCTION ChangeClipboardChain (
	a : HWND;
	b : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ChangeClipboardChain';


(******************************** ChangeMenu ********************************)

FUNCTION ChangeMenu (
	a : HMENU;
	b : WORD;
	c : LPSTR;
	d : WORD;
	e : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ChangeMenu';


(****************************** CheckDlgButton ******************************)

PROCEDURE CheckDlgButton (
	a : HWND;
	b : INTEGER;
	c : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CheckDlgButton';


(****************************** CheckMenuItem *******************************)

FUNCTION CheckMenuItem (
	a : HMENU;
	b : WORD;
	c : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CheckMenuItem';


(***************************** CheckRadioButton *****************************)

PROCEDURE CheckRadioButton (
	a : HWND;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CheckRadioButton';


(*************************** ChildWindowFromPoint ***************************)

FUNCTION ChildWindowFromPoint (
	a : HWND;
	b : POINT
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ChildWindowFromPoint';


(****************************** ClientToScreen ******************************)

PROCEDURE ClientToScreen (
	    a : HWND;
	VAR b : POINT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ClientToScreen';


(********************************** Chord ***********************************)

FUNCTION Chord (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : INTEGER;
	i : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Chord';


(****************************** ClearCommBreak ******************************)

FUNCTION ClearCommBreak (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ClearCommBreak';


(******************************** ClipCursor ********************************)

PROCEDURE ClipCursor (
	a : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ClipCursor';


(****************************** CloseClipboard ******************************)

FUNCTION CloseClipboard (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CloseClipboard';


(******************************** CloseComm *********************************)

FUNCTION CloseComm (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CloseComm';


(****************************** CloseMetaFile *******************************)

FUNCTION CloseMetaFile (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CloseMetaFile';


(******************************* CloseSound *********************************)

PROCEDURE CloseSound (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CloseSound';


(******************************* CloseWindow ********************************)

PROCEDURE CloseWindow (
	a : HWND
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CloseWindow';


(******************************** CombineRgn ********************************)

FUNCTION CombineRgn (
	a : HRGN;
	b : HRGN;
	c : HRGN;
	d : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CombineRgn';


(******************************* CopyMetaFile *******************************)

FUNCTION CopyMetaFile (
	a : HANDLE;
	b : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CopyMetaFile';


(********************************* CopyRect *********************************)

FUNCTION CopyRect (
	VAR a : RECT;
	    b : RECT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CopyRect';


(************************** CountClipboardFormats ***************************)

FUNCTION CountClipboardFormats (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CountClipboardFormats';


(***************************** CountVoiceNotes ******************************)

FUNCTION CountVoiceNotes (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CountVoiceNotes';


(******************************* CreateBitmap *******************************)

FUNCTION CreateBitmap (
	a : INTEGER;
	b : INTEGER;
	c : BYTE;
	d : BYTE;
	e : LPSTR
	) : HBITMAP
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateBitmap';


(*************************** CreateBitmapIndirect ***************************)

FUNCTION CreateBitmapIndirect (
	a : BITMAP
	) : HBITMAP
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateBitmapIndirect';


(*************************** CreateBrushIndirect ****************************)

FUNCTION CreateBrushIndirect (
	a : LOGBRUSH
	) : HBRUSH
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateBrushIndirect';


(******************************* CreateCaret ********************************)

PROCEDURE CreateCaret (
	a : HWND;
	b : HBITMAP;
	c : INTEGER;
	d : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateCaret';


(************************** CreateCompatibleBitmap **************************)

FUNCTION CreateCompatibleBitmap (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : HBITMAP
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateCompatibleBitmap';


(**************************** CreateCompatibleDC ****************************)

FUNCTION CreateCompatibleDC (
	a : HDC
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateCompatibleDC';


(********************************* CreateDC *********************************)

FUNCTION CreateDC (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR;
	d : LPSTR
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDC';


(******************************* CreateDialog *******************************)

FUNCTION CreateDialog (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : DlgProc
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDialog';


(************************** CreateDialogIndirect ****************************)

FUNCTION CreateDialogIndirect (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : DlgProc
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDialogIndirect';


(************************* CreateDiscardableBitmap **************************)

FUNCTION CreateDiscardableBitmap (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : HBITMAP
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDiscardableBitmap';


(**************************** CreateEllipticRgn *****************************)

FUNCTION CreateEllipticRgn (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateEllipticRgn';


(************************ CreateEllipticRgnIndirect *************************)

FUNCTION CreateEllipticRgnIndirect (
	a : RECT
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateEllipticRgnIndirect';


(******************************** CreateFont ********************************)

FUNCTION CreateFont (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : BYTE;
	g : BYTE;
	h : BYTE;
	i : BYTE;
	j : BYTE;
	k : BYTE;
	l : BYTE;
	m : BYTE;
	n : LPSTR
	) : HFONT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateFont';


(**************************** CreateFontIndirect ****************************)

FUNCTION CreateFontIndirect (
	a : LOGFONT
	) : HFONT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateFontIndirect';


(***************************** CreateHatchBrush *****************************)

FUNCTION CreateHatchBrush (
	a : INTEGER;
	b : DWORD
	) : HBRUSH
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateHatchBrush';


(********************************* CreateIC *********************************)

FUNCTION CreateIC (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR;
	d : LPSTR
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateIC';


(******************************** CreateMenu ********************************)

FUNCTION CreateMenu (
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateMenu';


(****************************** CreateMetaFile ******************************)

FUNCTION CreateMetaFile (
	a : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateMetaFile';


(**************************** CreatePatternBrush ****************************)

FUNCTION CreatePatternBrush (
	a : HBITMAP
	) : HBRUSH
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePatternBrush';


(******************************** CreatePen *********************************)

FUNCTION CreatePen (
	a : INTEGER;
	b : INTEGER;
	c : DWORD
	) : HPEN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePen';


(**************************** CreatePenIndirect *****************************)

FUNCTION CreatePenIndirect (
	a : LOGPEN
	) : HPEN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePenIndirect';


(***************************** CreatePolygonRgn *****************************)

FUNCTION CreatePolygonRgn (
	a : LPPOINT;
	b : INTEGER;
	c : INTEGER
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePolygonRgn';


(****************************** CreateRectRgn *******************************)

FUNCTION CreateRectRgn (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateRectRgn';


(************************** CreateRectRgnIndirect ***************************)

FUNCTION CreateRectRgnIndirect (
	a : RECT
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateRectRgnIndirect';


(***************************** CreateSolidBrush *****************************)

FUNCTION CreateSolidBrush (
	a : DWORD
	) : HBRUSH
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateSolidBrush';


(******************************* CreateWindow *******************************)

FUNCTION CreateWindow (
	a : LPSTR;
	b : LPSTR;
	c : DWORD;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : HWND;
	i : HMENU;
	j : HANDLE;
	k : LPSTR
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateWindow';


(******************************* DefHookProc ********************************)

FUNCTION DefHookProc (
	    a : INTEGER;
	    b : WORD;
	    c : LONGINT;
	VAR d : FARPROC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefHookProc';


(****************************** DefWindowProc *******************************)

FUNCTION DefWindowProc (
	a : HANDLE;
	b : WORD;
	c : WORD;
	d : LONGINT
	) : LONGINT
	[WINDOWS,ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefWindowProc';


(******************************** DeleteAtom ********************************)

FUNCTION DeleteAtom (
	a : ATOM
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeleteAtom';


(********************************* DeleteDC *********************************)

FUNCTION DeleteDC (
	a : HDC
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeleteDC';


(****************************** DeleteMetaFile ******************************)

FUNCTION DeleteMetaFile (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeleteMetaFile';


(******************************* DeleteObject *******************************)

FUNCTION DeleteObject (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeleteObject';


(******************************* DestroyCaret *******************************)

PROCEDURE DestroyCaret (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DestroyCaret';


(******************************* DestroyMenu ********************************)

FUNCTION DestroyMenu (
	a : HMENU
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DestroyMenu';


(****************************** DestroyWindow *******************************)

FUNCTION DestroyWindow (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DestroyWindow';


(******************************** DialogBox *********************************)

FUNCTION DialogBox (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : DlgProc
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DialogBox';


(******************************** DialogBox *********************************)

FUNCTION DialogBoxIndirect (
	a : HANDLE;
	b : HANDLE;
	c : HWND;
	d : DlgProc
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DialogBoxIndirect';


(***************************** DispatchMessage ******************************)

FUNCTION DispatchMessage (
	a : MSG
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DispatchMessage';


(******************************** DlgDirList ********************************)

FUNCTION DlgDirList (
	a : HWND;
	b : LPSTR;
	c : INTEGER;
	d : INTEGER;
	e : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DlgDirList';


(******************************* DlgDirSelect *******************************)

FUNCTION DlgDirSelect (
	a : HWND;
	b : LPSTR;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DlgDirSelect';


(********************************** DPtoLP **********************************)

FUNCTION DPtoLP (
	a : HDC;
	b : LPPOINT;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DPtoLP';


(********************************* DrawIcon *********************************)

FUNCTION DrawIcon (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : HICON
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DrawIcon';


(******************************* DrawMenuBar ********************************)

PROCEDURE DrawMenuBar (
	a : HWND
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DrawMenuBar';


(********************************* DrawText *********************************)

FUNCTION DrawText (
	a : HDC;
	b : LPSTR;
	c : INTEGER;
	d : RECT;
	e : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DrawText';


(********************************* Ellipse **********************************)

FUNCTION Ellipse (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Ellipse';


(****************************** EmptyClipboard ******************************)

FUNCTION EmptyClipboard (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EmptyClipboard';


(*************************** EnableHardwareInput ****************************)

FUNCTION EnableHardwareInput (
	a : BOOL
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnableHardwareInput';


(****************************** EnableMenuItem ******************************)

FUNCTION EnableMenuItem (
	a : HMENU;
	b : WORD;
	c : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnableMenuItem';


(******************************* EnableWindow *******************************)

FUNCTION EnableWindow (
	a : HWND;
	b : BOOL
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnableWindow';


(******************************** EndDialog *********************************)

PROCEDURE EndDialog (
	a : HWND;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EndDialog';


(********************************* EndMenu **********************************)

PROCEDURE EndMenu (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EndMenu';


(********************************* EndPaint *********************************)

PROCEDURE EndPaint (
	a : HANDLE;
	b : PAINTSTRUCT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EndPaint';


(***************************** EnumChildWindows *****************************)

FUNCTION EnumChildWindows (
	a : HWND;
	b : FARPROC;
	c : LONGINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumChildWindows';


(*************************** EnumClipboardFormats ***************************)

FUNCTION EnumClipboardFormats (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumClipboardFormats';


(******************************** EnumFonts *********************************)

FUNCTION EnumFonts (
	a : HDC;
	b : LPSTR;
	c : FARPROC;
	d : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumFonts';


(****************************** EnumMetaFile ********************************)

FUNCTION EnumMetaFile (
	    a : HDC;
	    b : HANDLE;
	    c : FARPROC;
	VAR d : BYTE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumMetaFile';
	
(******************************* EnumObjects ********************************)

FUNCTION EnumObjects (
	a : HDC;
	b : INTEGER;
	c : FARPROC;
	d : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumObjects';


(******************************** EnumProps *********************************)

FUNCTION EnumProps (
	a : HWND;
	b : FARPROC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumProps';


(***************************** EnumTaskWindows ********************************)

FUNCTION EnumTaskWindows (
	a : HANDLE;
	b : FARPROC;
	c : LONGINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumTaskWindows';


(******************************* EnumWindows ********************************)

FUNCTION EnumWindows (
	a : FARPROC;
	b : LONGINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EnumWindows';


(********************************* EqualRect *********************************)

FUNCTION EqualRect (
	a : RECT;
	b : RECT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EqualRect';


(********************************* EqualRgn *********************************)

FUNCTION EqualRgn (
	a : HRGN;
	b : HRGN
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EqualRgn';


(********************************** Escape **********************************)

FUNCTION Escape (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : LPSTR;
	e : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Escape';


(*************************** EscapeCommFunction *****************************)

FUNCTION EscapeCommFunction (
	a : INTEGER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EscapeCommFunction';


(***************************** ExcludeClipRect ******************************)

FUNCTION ExcludeClipRect (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ExcludeClipRect';


(***************************** ExcludeUpdateRgn *****************************)

FUNCTION ExcludeUpdateRgn (
	a : HANDLE;
	b : HRGN
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ExcludeUpdateRgn';


(******************************** ExtTextOut ********************************)

FUNCTION ExtTextOut (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER;
	d : WORD;
	e : RECT;
	f : LPSTR;
	g : INTEGER;
	h : LPINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ExtTextOut';


(******************************** FatalExit *********************************)

PROCEDURE FatalExit (
	a : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FatalExit';


(********************************* FillRect *********************************)

PROCEDURE FillRect (
	a : HANDLE;
	b : RECT;
	c : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FillRect';


(********************************* FillRgn **********************************)

FUNCTION FillRgn (
	a : HDC;
	b : HRGN;
	c : HBRUSH
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FillRgn';


(********************************* FindAtom *********************************)

FUNCTION FindAtom (
	a : LPSTR
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FindAtom';


(******************************* FindResource *******************************)

FUNCTION FindResource (
	a : HANDLE;
	b : LPSTR;
	c : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FindResource';


(******************************** FindWindow ********************************)

FUNCTION FindWindow (
	a : LPSTR;
	b : LPSTR
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FindWindow';


(******************************* FlashWindow ********************************)

FUNCTION FlashWindow (
	a : HWND;
	b : BOOL
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FlashWindow';


(******************************** FloodFill *********************************)

FUNCTION FloodFill (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : DWORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FloodFill';


(******************************** FlushComm *********************************)

FUNCTION FlushComm (
	a : INTEGER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FlushComm';


(******************************** FrameRect *********************************)

FUNCTION FrameRect (
	a : HDC;
	b : RECT;
	c : HBRUSH
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FrameRect';


(********************************* FrameRgn *********************************)

FUNCTION FrameRgn (
	a : HDC;
	b : HRGN;
	c : HBRUSH;
	d : INTEGER;
	e : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FrameRgn';

(******************************* FreeLibrary ********************************)

FUNCTION FreeLibrary (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FreeLibrary';


(***************************** FreeProcInstance *****************************)

PROCEDURE FreeProcInstance (
	a : POINTER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FreeProcInstance';


(******************************* FreeResource *******************************)

FUNCTION FreeResource (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FreeResource';


(***************************** GetActiveWindow ******************************)

FUNCTION GetActiveWindow (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetActiveWindow';


(*************************** GetAspectRatioFilter ***************************)

FUNCTION GetAspectRatioFilter (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetAspectRatioFilter';


(**************************** GetAsyncKeyState ******************************)

FUNCTION GetAsyncKeyState (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetAsyncKeyState';


(****************************** GetAtomHandle *******************************)

FUNCTION GetAtomHandle (
	a : ATOM
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetAtomHandle';


(******************************* GetAtomName ********************************)

FUNCTION GetAtomName (
	a : ATOM;
	b : LPSTR;
	c : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetAtomName';


(****************************** GetBitmapBits *******************************)

FUNCTION GetBitmapBits (
	a : HBITMAP;
	b : LONGINT;
	c : LPSTR
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetBitmapBits';


(**************************** GetBitmapDimension ****************************)

FUNCTION GetBitmapDimension (
	a : HBITMAP
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetBitmapDimension';


(******************************** GetBkColor ********************************)

FUNCTION GetBkColor (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetBkColor';


(******************************** GetBkMode *********************************)

FUNCTION GetBkMode (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetBkMode';


(******************************* GetBrushOrg ********************************)

FUNCTION GetBrushOrg (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetBrushOrg';


(******************************* GetCapture *********************************)

FUNCTION GetCapture (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCapture';



(**************************** GetCaretBlinkTime *****************************)

FUNCTION GetCaretBlinkTime (
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCaretBlinkTime';


(******************************* GetCharWidth *******************************)

FUNCTION GetCharWidth (
	a : HDC;
	b : WORD;
	c : WORD;
	d : LPINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCharWidth';


(******************************* GetClassLong *******************************)

FUNCTION GetClassLong (
	a : HWND;
	b : INTEGER
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClassLong';


(******************************* GetClassName *******************************)

FUNCTION GetClassName (
	a : HWND;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClassName';


(******************************* GetClassWord *******************************)

FUNCTION GetClassWord (
	a : HWND;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClassWord';


(****************************** GetClientRect *******************************)

PROCEDURE GetClientRect (
	    a : HANDLE;
	VAR b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClientRect';


(***************************** GetClipboardData *****************************)

FUNCTION GetClipboardData (
	a : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClipboardData';


(************************** GetClipboardFormatName **************************)

FUNCTION GetClipboardFormatName (
	a : WORD;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClipboardFormatName';


(**************************** GetClipboardOwner *****************************)

FUNCTION GetClipboardOwner (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClipboardOwner';


(**************************** GetClipboardViewer ****************************)

FUNCTION GetClipboardViewer (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClipboardViewer';


(******************************** GetClipBox ********************************)

FUNCTION GetClipBox (
	    a : HDC;
	VAR b : RECT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClipBox';


(****************************** GetCodeHandle *******************************)

FUNCTION GetCodeHandle (
	a : FARPROC
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCodeHandle';


(******************************* GetCommError *******************************)

FUNCTION GetCommError (
	    a : INTEGER;
	VAR b : COMSTAT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCommError';


(***************************** GetCommEventMask *****************************)

FUNCTION GetCommEventMask (
	a : INTEGER;
	b : CommEventMask
	) : CommEventMask
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCommEventMask';


(******************************* GetCommState *******************************)

FUNCTION GetCommState (
	    a : INTEGER;
	VAR b : DCB
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCommState';


(**************************** GetCurrentPosition ****************************)

FUNCTION GetCurrentPosition (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCurrentPosition';


(****************************** GetCurrentTask ******************************)

FUNCTION GetCurrentTask (
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCurrentTask';


(****************************** GetCurrentTime ******************************)

FUNCTION GetCurrentTime (
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCurrentTime';


(******************************* GetCursorPos *******************************)

PROCEDURE GetCursorPos (
	VAR a : POINT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCursorPos';


(********************************** GetDC ***********************************)

FUNCTION GetDC (
	a : HWND
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDC';


(******************************** GetDCOrg **********************************)

FUNCTION GetDcOrg (
	a : HDC
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDCOrg';


(****************************** GetDeviceCaps *******************************)

FUNCTION GetDeviceCaps (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDeviceCaps';


(******************************** GetDlgItem ********************************)

FUNCTION GetDlgItem (
	a : HWND;
	b : INTEGER
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDlgItem';


(****************************** GetDlgItemInt *******************************)

FUNCTION GetDlgItemInt (
	    a : HWND;
	    b : INTEGER;
	VAR c : BOOL;
	    d : BOOL
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDlgItemInt';


(****************************** GetDlgItemText ******************************)

FUNCTION GetDlgItemText (
	a : HWND;
	b : INTEGER;
	c : POINTER;
	d : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDlgItemText';


(**************************** GetDoubleClickTime ****************************)

FUNCTION GetDoubleClickTime (
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDoubleClickTime';


(****************************** GetEnvironment ******************************)

FUNCTION GetEnvironment (
	a : LPSTR;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetEnvironment';


(********************************* GetFocus *********************************)

FUNCTION GetFocus (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetFocus';


(****************************** GetInputState *******************************)

FUNCTION GetInputState (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetInputState';


(***************************** GetInstanceData ******************************)

FUNCTION GetInstanceData (
	a : HANDLE;
	b : PSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetInstanceData';


(**************************** GetKeyboardState ******************************)

PROCEDURE GetKeyboardState (
	a : KEYBUFFER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetKeyboardState';


(******************************* GetKeyState ********************************)

FUNCTION GetKeyState (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetKeyState';


(******************************** GetMapMode ********************************)

FUNCTION GetMapMode (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMapMode';


(********************************* GetMenu **********************************)

FUNCTION GetMenu (
	a : HWND
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenu';


(**************************** GetMenuItemCount ******************************)

FUNCTION GetMenuItemCount (
	a : HMENU
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenuItemCount';


(****************************** GetMenuItemID *******************************)

FUNCTION GetMenuItemID (
	a : HMENU;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenuItemID';


(****************************** GetMenuState ********************************)

FUNCTION GetMenuState (
	a : HMENU;
	b : WORD;
	c : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenuState';

	
(****************************** GetMenuString *******************************)

FUNCTION GetMenuString (
	a : HMENU;
	b : WORD;
	c : LPSTR;
	d : INTEGER;
	e : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenuString';


(******************************** GetMessage ********************************)

FUNCTION GetMessage (
	VAR a : MSG;
	    b : HANDLE;
	    c : WORD;
	    d : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMessage';


(****************************** GetMessagePos *******************************)

FUNCTION GetMessagePos (
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMessagePos';


(****************************** GetMessageTime ******************************)

FUNCTION GetMessageTime (
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMessageTime';


(******************************* GetMetaFile ********************************)

FUNCTION GetMetaFile (
	a : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMetaFile';


(***************************** GetMetaFileBits ******************************)

FUNCTION GetMetaFileBits (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMetaFileBits';


(**************************** GetModuleFileName *****************************)

FUNCTION GetModuleFileName (
	a : HANDLE;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetModuleFileName';


(***************************** GetModuleHandle ******************************)

FUNCTION GetModuleHandle (
	a : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetModuleHandle';


(****************************** GetModuleUsage ******************************)

FUNCTION GetModuleUsage (
	a : HANDLE
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetModuleUsage';


(***************************** GetNearestColor ******************************)

FUNCTION GetNearestColor (
	a : HDC;
	b : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNearestColor';


(*************************** GetNextDlgGroupItem ****************************)

FUNCTION GetNextDlgGroupItem (
	a : HWND;
	b : HWND;
	c : BOOL
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNextDlgGroupItem';


(**************************** GetNextDlgTabItem *****************************)

FUNCTION GetNextDlgTabItem (
	a : HWND;
	b : HWND;
	c : BOOL
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNextDlgTabItem';


(****************************** GetNextWindow *******************************)

FUNCTION GetNextWindow (
	a : HWND;
	b : WORD
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNextWindow';


(******************************* GetNumTasks ********************************)

FUNCTION GetNumTasks (
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNumTasks';


(******************************** GetObject *********************************)

FUNCTION GetObject (
	a : HANDLE;
	b : INTEGER;
	c : POINTER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetObject';


(******************************** GetParent *********************************)

FUNCTION GetParent (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetParent';


(********************************* GetPixel *********************************)

FUNCTION GetPixel (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPixel';


(***************************** GetPolyFillMode ******************************)

FUNCTION GetPolyFillMode (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPolyFillMode';


(****************************** GetProcAddress ******************************)

FUNCTION GetProcAddress (
	a : HANDLE;
	b : LPSTR
	) : FARPROC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetProcAddress';


(****************************** GetProfileInt *******************************)

FUNCTION GetProfileInt (
	a : LPSTR;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetProfileInt';


(***************************** GetProfileString *****************************)

FUNCTION GetProfileString (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR;
	d : LPSTR;
	e : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetProfileString';


(********************************* GetProp **********************************)

FUNCTION GetProp (
	a : HWND;
	b : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetProp';


(******************************** GetRelAbs *********************************)

FUNCTION GetRelAbs (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetRelAbs';


(********************************* GetROP2 **********************************)

FUNCTION GetROP2 (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetROP2';


(******************************* GetScrollPos *******************************)

FUNCTION GetScrollPos (
	a : HWND;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetScrollPos';


(****************************** GetScrollRange ******************************)

PROCEDURE GetScrollRange (
	    a : HWND;
	    b : INTEGER;
	VAR c : INTEGER;
	VAR d : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetScrollRange';


(****************************** GetStockObject ******************************)

FUNCTION GetStockObject (
	a : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetStockObject';


(**************************** GetStretchBltMode *****************************)

FUNCTION GetStretchBltMode (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetStretchBltMode';


(******************************** GetSubMenu ********************************)

FUNCTION GetSubMenu (
	a : HMENU;
	b : INTEGER
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSubMenu';


(******************************* GetSysColor ********************************)

FUNCTION GetSysColor (
	a : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSysColor';


(**************************** GetSysModalWindow *****************************)

FUNCTION GetSysModalWindow (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSysModalWindow';


(****************************** GetSystemMenu *******************************)

FUNCTION GetSystemMenu (
	a : HWND;
	b : BOOL
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSystemMenu';


(***************************** GetSystemMetrics *****************************)

FUNCTION GetSystemMetrics (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSystemMetrics';


(******************************* GetTempDrive *******************************)

FUNCTION GetTempDrive (
	a : BYTE
	) : BYTE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTempDrive';


(***************************** GetTempFileName ******************************)

FUNCTION GetTempFileName (
	a : BYTE;
	b : LPSTR;
	c : WORD;
	d : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTempFileName';


(****************************** GetTextAlign ********************************)

FUNCTION GetTextAlign (
	a : HDC
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextAlign';


(************************** GetTextCharacterExtra ***************************)

FUNCTION GetTextCharacterExtra (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextCharacterExtra';


(******************************* GetTextColor *******************************)

FUNCTION GetTextColor (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextColor';


(****************************** GetTextExtent *******************************)

FUNCTION GetTextExtent (
	a : HDC;
	b : LPSTR;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextExtent';


(******************************* GetTextFace ********************************)

FUNCTION GetTextFace (
	a : HDC;
	b : INTEGER;
	c : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextFace';


(****************************** GetTextMetrics ******************************)

FUNCTION GetTextMetrics (
	    a : HDC;
	VAR b : TEXTMETRIC
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTextMetrics';


(**************************** GetThresholdEvent *****************************)

FUNCTION GetThresholdEvent (
	) : LPINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetThresholdEvent';


(****************************** GetTickCount ********************************)

FUNCTION GetTickCount (
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTickCount';


(****************************** GetTopWindow ********************************)

FUNCTION GetTopWindow (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTopWindow';


(****************************** GetUpdateRect *******************************)

FUNCTION GetUpdateRect (
	    a : HWND;
	VAR b : RECT;
	    c : BOOL
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetUpdateRect';


(******************************* GetUpdateRgn *******************************)

FUNCTION GetUpdateRgn (
	a : HWND;
	b : HRGN;
	c : BOOL
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetUpdateRgn';


(******************************** GetVersion ********************************)

FUNCTION GetVersion (
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetVersion';


(****************************** GetViewportExt ******************************)

FUNCTION GetViewportExt (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetViewportExt';


(****************************** GetViewportOrg ******************************)

FUNCTION GetViewportOrg (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetViewportOrg';


(******************************** GetWindow *********************************)

FUNCTION GetWindow (
	a : HWND;
	b : WORD
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindow';


(******************************* GetWindowDC ********************************)

FUNCTION GetWindowDC (
	a : HWND
	) : HDC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowDC';


(******************************* GetWindowExt *******************************)

FUNCTION GetWindowExt (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowExt';


(****************************** GetWindowLong *******************************)

FUNCTION GetWindowLong (
	a : HWND;
	b : INTEGER
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowLong';


(******************************* GetWindowOrg *******************************)

FUNCTION GetWindowOrg (
	a : HDC
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowOrg';


(****************************** GetWindowRect *******************************)

PROCEDURE GetWindowRect (
	    a : HWND;
	VAR b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowRect';


(****************************** GetWindowTask *******************************)

FUNCTION GetWindowTask (
	a : HWND
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowTask';


(****************************** GetWindowText *******************************)

FUNCTION GetWindowText (
	a : HWND;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowText';


(*************************** GetWindowTextLength ****************************)

FUNCTION GetWindowTextLength (
	a : HWND
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowTextLength';


(****************************** GetWindowWord *******************************)

FUNCTION GetWindowWord (
	a : HWND;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowWord';


(****************************** GlobalAddAtom *******************************)

FUNCTION GlobalAddAtom (
	a : LPSTR
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalAddAtom';


(******************************* GlobalAlloc ********************************)

FUNCTION GlobalAlloc (
	a : WORD;
	b : DWORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalAlloc';


(****************************** GlobalCompact *******************************)

FUNCTION GlobalCompact (
	a : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalCompact';


(**************************** GlobalDeleteAtom ******************************)

FUNCTION GlobalDeleteAtom (
	a : ATOM
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalDeleteAtom';


(***************************** GlobalFindAtom *******************************)

FUNCTION GlobalFindAtom (
	a : LPSTR
	) : ATOM
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalFindAtom';


(******************************* GlobalFlags ********************************)

FUNCTION GlobalFlags (
	a : HANDLE
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalFlags';


(******************************** GlobalFree ********************************)

FUNCTION GlobalFree (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalFree';


(**************************** GlobalGetAtomName *****************************)

FUNCTION GlobalGetAtomName (
	a : ATOM;
	b : LPSTR;
	c : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalGetAtomName';


(******************************* GlobalHandle *******************************)

FUNCTION GlobalHandle (
	a : WORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalHandle';


(******************************** GlobalLock ********************************)

FUNCTION GlobalLock (
	a : HANDLE
	) : POINTER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalLock';


(****************************** GlobalReAlloc *******************************)

FUNCTION GlobalReAlloc (
	a : HANDLE;
	b : DWORD;
	c : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalReAlloc';


(******************************** GlobalSize ********************************)

FUNCTION GlobalSize (
	a : HANDLE
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalSize';


(******************************* GlobalUnlock *******************************)

FUNCTION GlobalUnlock (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalUnlock';


(******************************* GlobalUnWire *******************************)

PROCEDURE GlobalUnWire (
	a : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalUnWire';


(******************************** GlobalWire ********************************)

FUNCTION GlobalWire (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalWire';


(******************************** GrayString ********************************)

FUNCTION GrayString (
	a : HDC;
	b : HBRUSH;
	c : FARPROC;
	d : DWORD;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : INTEGER;
	i : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GrayString';


(******************************** HideCaret *********************************)

PROCEDURE HideCaret (
	a : HWND
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'HideCaret';


(****************************** HiliteMenuItem ******************************)

FUNCTION HiliteMenuItem (
	a : HWND;
	b : HMENU;
	c : WORD;
	d : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'HiliteMenuItem';


(******************************* InflateRect ********************************)

FUNCTION InflateRect (
	VAR a : RECT;
	    b : INTEGER;
	    c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InflateRect';


(****************************** InitAtomTable *******************************)

FUNCTION InitAtomTable (
	a : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InitAtomTable';


(****************************** InSendMessage *******************************)

FUNCTION InSendMessage (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InSendMessage';


(**************************** IntersectClipRect *****************************)

FUNCTION IntersectClipRect (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IntersectClipRect';


(****************************** IntersectRect *******************************)

FUNCTION IntersectRect (
	VAR a : RECT;
	    b : RECT;
	    c : RECT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IntersectRect';


(****************************** InvalidateRect ******************************)

PROCEDURE InvalidateRect (
	a : HWND;
	b : RECT;
	c : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InvalidateRect';


(****************************** InvalidateRgn *******************************)

PROCEDURE InvalidateRgn (
	a : HWND;
	b : HRGN;
	c : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InvalidateRgn';


(******************************** InvertRect ********************************)

PROCEDURE InvertRect (
	a : HDC;
	b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InvertRect';


(******************************** InvertRgn *********************************)

FUNCTION InvertRgn (
	a : HDC;
	b : HRGN
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InvertRgn';


(********************************* IsChild **********************************)

FUNCTION IsChild (
	a : HWND;
	b : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsChild';


(************************ IsClipboardFormatAvailable ************************)

FUNCTION IsClipboardFormatAvailable (
	a : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsClipboardFormatAvailable';


(***************************** IsDialogMessage ******************************)

FUNCTION IsDialogMessage (
	    a : HWND;
	VAR b : MSG
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsDialogMessage';


(**************************** IsDlgButtonChecked ****************************)

FUNCTION IsDlgButtonChecked (
	a : HWND;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsDlgButtonChecked';


(********************************* IsIconic *********************************)

FUNCTION IsIconic (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsIconic';


(******************************* IsRectEmpty ********************************)

FUNCTION IsRectEmpty (
	a : RECT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsRectEmpty';


(*************************** IsTwoByteCharPrefix ****************************)

FUNCTION IsTwoByteCharPrefix (
	a : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsTwoByteCharPrefix';


(********************************* IsWindow *********************************)

FUNCTION IsWindow (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsWindow';


(***************************** IsWindowEnabled ******************************)

FUNCTION IsWindowEnabled (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsWindowEnabled';


(***************************** IsWindowVisible ******************************)

FUNCTION IsWindowVisible (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsWindowVisible';


(******************************** IsZoomed **********************************)

FUNCTION IsZoomed (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsZoomed';


(******************************** KillTimer *********************************)

FUNCTION KillTimer (
	a : HWND;
	b : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'KillTimer';


(********************************* LineDDA **********************************)

PROCEDURE LineDDA (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : FARPROC;
	f : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LineDDA';


(********************************** LineTo **********************************)

FUNCTION LineTo (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LineTo';


(***************************** LoadAccelerators *****************************)

FUNCTION LoadAccelerators (
	a : HANDLE;
	b : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadAccelerators';


(******************************** LoadBitmap ********************************)

FUNCTION LoadBitmap (
	a : HANDLE;
	b : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadBitmap';


(******************************** LoadCursor ********************************)

FUNCTION LoadCursor (
	a : HANDLE;
	b : LPSTR
	) : HCURSOR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadCursor';


(********************************* LoadIcon *********************************)

FUNCTION LoadIcon (
	a : HANDLE;
	b : LPSTR
	) : HICON
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadIcon';


(******************************* LoadLibrary ********************************)

FUNCTION LoadLibrary (
	a : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadLibrary';


(********************************* LoadMenu *********************************)

FUNCTION LoadMenu (
	a : HANDLE;
	b : LPSTR
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadMenu';


(***************************** LoadMenuIndirect *****************************)

FUNCTION LoadMenuIndirect (
	a : LPSTR
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadMenuIndirect';


(******************************* LoadResource *******************************)

FUNCTION LoadResource (
	a : HANDLE;
	b : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadResource';


(******************************** LoadString ********************************)

FUNCTION LoadString (
	a : HANDLE;
	b : WORD;
	c : LPSTR;
	d : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadString';


(******************************** LocalAlloc ********************************)

FUNCTION LocalAlloc (
	a : WORD;
	b : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalAlloc';


(******************************* LocalCompact *******************************)

FUNCTION LocalCompact (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalCompact';


(******************************** LocalFlags ********************************)

FUNCTION LocalFlags (
	a : HANDLE
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalFlags';


(******************************** LocalFree *********************************)

FUNCTION LocalFree (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalFree';


(******************************* LocalHandle ********************************)

FUNCTION LocalHandle (
	a : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalHandle';


(******************************** LocalInit *********************************)

FUNCTION LocalInit (
	a : WORD;
	b : WORD;
	c : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalInit';


(******************************** LocalLock *********************************)

FUNCTION LocalLock (
	a : HANDLE
	) : PSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalLock';


(******************************* LocalNotify ********************************)

FUNCTION LocalNotify (
	a : FARPROC
	) : FARPROC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalNotify';


(******************************* LocalReAlloc *******************************)

FUNCTION LocalReAlloc (
	a : HANDLE;
	b : WORD;
	c : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalReAlloc';


(******************************* LocalShrink ********************************)

FUNCTION LocalShrink (
	a : HANDLE;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalShrink';


(******************************** LocalSize *********************************)

FUNCTION LocalSize (
	a : HANDLE
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalSize';


(******************************* LocalUnlock ********************************)

FUNCTION LocalUnlock (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LocalUnlock';


(******************************* LockResource *******************************)

FUNCTION LockResource (
	a : HANDLE
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LockResource';


(******************************* LockSegment ********************************)

FUNCTION LockSegment (
	a : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LockSegment';


(********************************** LPtoDP **********************************)

FUNCTION LPtoDP (
	a : HDC;
	b : LPPOINT;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LPtoDP';


(***************************** MakeProcInstance *****************************)

FUNCTION MakeProcInstance (
	a : POINTER;
	b : HANDLE
	) : POINTER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MakeProcInstance';


(****************************** MapDialogRect *******************************)

PROCEDURE MapDialogRect (
	a : HWND;
	b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MapDialogRect';


(******************************* MessageBeep ********************************)

FUNCTION MessageBeep (
	a : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MessageBeep';


(******************************** MessageBox ********************************)

FUNCTION MessageBox (
	a : HANDLE;
	b : LPSTR;
	c : LPSTR;
	d : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MessageBox';


(********************************** MoveTo **********************************)

FUNCTION MoveTo (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MoveTo';


(******************************** MoveWindow ********************************)

PROCEDURE MoveWindow (
	a : HWND;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MoveWindow';


(******************************** OemToAnsi *********************************)

FUNCTION OemToAnsi (
	a : LPSTR;
	b : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OemToAnsi';


(****************************** OffsetClipRgn *******************************)

FUNCTION OffsetClipRgn (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OffsetClipRgn';


(******************************** OffsetRect ********************************)

PROCEDURE OffsetRect (
	VAR a : RECT;
	    b : INTEGER;
	    c : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OffsetRect';


(******************************** OffsetRgn *********************************)

FUNCTION OffsetRgn (
	a : HRGN;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OffsetRgn';


(**************************** OffsetViewportOrg *****************************)

FUNCTION OffsetViewportOrg (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OffsetViewportOrg';

	
(***************************** OffsetWindowOrg ******************************)

FUNCTION OffsetWindowOrg (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OffsetWindowOrg';

	
(****************************** OpenClipboard *******************************)

FUNCTION OpenClipboard (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OpenClipboard';


(********************************* OpenComm *********************************)

FUNCTION OpenComm (
	a : LPSTR;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OpenComm';

	
(********************************* OpenFile *********************************)

FUNCTION OpenFile (
	    a : LPSTR;
	VAR b : OFSTRUCT;
	    c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OpenFile';


(********************************* OpenIcon *********************************)

FUNCTION OpenIcon (
	a : HWND
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OpenIcon';


(******************************** OpenSound *********************************)

FUNCTION OpenSound (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OpenSound';


(********************************* PaintRgn *********************************)

FUNCTION PaintRgn (
	a : HDC;
	b : HRGN
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PaintRgn';


(********************************** PatBlt **********************************)

FUNCTION PatBlt (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : DWORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PatBlt';


(******************************* PeekMessage ********************************)

FUNCTION PeekMessage (
	VAR a : MSG;
	    b : HWND;
	    c : WORD;
	    d : WORD;
	    e : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PeekMessage';


(*********************************** Pie ************************************)

FUNCTION Pie (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : INTEGER;
	i : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Pie';


(****************************** PlayMetaFile ********************************)

FUNCTION PlayMetaFile (
	a : HDC;
	b : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PlayMetaFile';


(*************************** PlayMetaFileRecord *****************************)

PROCEDURE PlayMetaFileRecord (
	a : HDC;
	b : LPSTR;
	c : LPSTR;
	d : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PlayMetaFileRecord';


(********************************* Polygon **********************************)

FUNCTION Polygon (
	a : HANDLE;
	b : LPPOINT;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Polygon';


(********************************* Polyline *********************************)

FUNCTION Polyline (
	a : HDC;
	b : LPPOINT;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Polyline';


(****************************** PostAppMessage ******************************)

FUNCTION PostAppMessage (
	a : HANDLE;
	b : WORD;
	c : WORD;
	d : LONGINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PostAppMessage';


(******************************* PostMessage ********************************)

FUNCTION PostMessage (
	a : HWND;
	b : WORD;
	c : WORD;
	d : LONGINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PostMessage';


(***************************** PostQuitMessage ******************************)

PROCEDURE PostQuitMessage (
	a : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PostQuitMessage';


(********************************* PtInRect *********************************)

FUNCTION PtInRect (
	a : RECT;
	b : POINT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PtInRect';


(******************************** PtInRegion ********************************)

FUNCTION PtInRegion (
	a : HRGN;
	b : INTEGER;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PtInRegion';


(******************************** PtVisible *********************************)

FUNCTION PtVisible (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PtVisible';


(******************************** ReadComm **********************************)

FUNCTION ReadComm (
	a : INTEGER;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ReadComm';


(******************************** Rectangle *********************************)

FUNCTION Rectangle (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Rectangle';


(******************************* RectVisible ********************************)

FUNCTION RectVisible (
	a : HDC;
	b : RECT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RectVisible';


(****************************** RegisterClass *******************************)

FUNCTION RegisterClass (
	a : WNDCLASS
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RegisterClass';


(************************* RegisterClipboardFormat **************************)

FUNCTION RegisterClipboardFormat (
	a : LPSTR
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RegisterClipboardFormat';


(************************** RegisterWindowMessage ***************************)

FUNCTION RegisterWindowMessage (
	a : LPSTR
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RegisterWindowMessage';


(****************************** ReleaseCapture ******************************)

PROCEDURE ReleaseCapture (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ReleaseCapture';


(******************************** ReleaseDC *********************************)

FUNCTION ReleaseDC (
	a : HANDLE;
	b : HANDLE
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ReleaseDC';


(**************************** RemoveFontResource ****************************)

FUNCTION RemoveFontResource (
	a : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RemoveFontResource';


(******************************** RemoveProp ********************************)

FUNCTION RemoveProp (
	a : HWND;
	b : LPSTR
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RemoveProp';


(******************************* ReplyMessage *******************************)

PROCEDURE ReplyMessage (
	a : LONGINT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ReplyMessage';


(******************************** RestoreDC *********************************)

FUNCTION RestoreDC (
	a : HDC;
	b : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RestoreDC';


(******************************** RoundRect *********************************)

FUNCTION RoundRect (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RoundRect';


(********************************** SaveDC **********************************)

FUNCTION SaveDC (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SaveDC';


(***************************** ScaleViewportExt *****************************)

FUNCTION ScaleViewportExt (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ScaleViewportExt';

 
(***************************** ScaleWindowExt *******************************)

FUNCTION ScaleWindowExt (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ScaleWindowExt';

 
(****************************** ScreenToClient ******************************)

PROCEDURE ScreenToClient (
	    a : HWND;
	VAR b : POINT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ScreenToClient';


(********************************* ScrollDC *********************************)

FUNCTION ScrollDC (
	    a : HDC;
	    b : INTEGER;
	    c : INTEGER;
	    d : RECT;
	    e : RECT;
	    f : HRGN;
	VAR g : RECT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ScrollDC';


(******************************* ScrollWindow *******************************)

PROCEDURE ScrollWindow (
	a : HWND;
	b : INTEGER;
	c : INTEGER;
	d : RECT;
	e : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ScrollWindow';


(****************************** SelectClipRgn *******************************)

FUNCTION SelectClipRgn (
	a : HDC;
	b : HRGN
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SelectClipRgn';


(******************************* SelectObject *******************************)

FUNCTION SelectObject (
	a : HDC;
	b : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SelectObject';


(**************************** SendDlgItemMessage ****************************)

FUNCTION SendDlgItemMessage (
	a : HWND;
	b : INTEGER;
	c : WORD;
	d : WORD;
	e : LONGINT
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SendDlgItemMessage';


(******************************* SendMessage ********************************)

FUNCTION SendMessage (
	a : HWND;
	b : WORD;
	c : WORD;
	d : LONGINT
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SendMessage';


(***************************** SetActiveWindow ******************************)

FUNCTION SetActiveWindow (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetActiveWindow';


(****************************** SetBitmapBits *******************************)

FUNCTION SetBitmapBits (
	a : HBITMAP;
	b : DWORD;
	c : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetBitmapBits';


(**************************** SetBitmapDimension ****************************)

FUNCTION SetBitmapDimension (
	a : HBITMAP;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetBitmapDimension';


(******************************** SetBkColor ********************************)

FUNCTION SetBkColor (
	a : HDC;
	b : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetBkColor';


(******************************** SetBkMode *********************************)

FUNCTION SetBkMode (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetBkMode';


(******************************* SetBrushOrg ********************************)

FUNCTION SetBrushOrg (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetBrushOrg';


(******************************** SetCapture ********************************)

FUNCTION SetCapture (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCapture';


(**************************** SetCaretBlinkTime *****************************)

PROCEDURE SetCaretBlinkTime (
	a : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCaretBlinkTime';


(******************************* SetCaretPos ********************************)

PROCEDURE SetCaretPos (
	a : INTEGER;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCaretPos';


(******************************* SetClassLong *******************************)

FUNCTION SetClassLong (
	a : HWND;
	b : INTEGER;
	c : LONGINT
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetClassLong';


(******************************* SetClassWord *******************************)

FUNCTION SetClassWord (
	a : HWND;
	b : INTEGER;
	c : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetClassWord';


(***************************** SetClipboardData *****************************)

FUNCTION SetClipboardData (
	a : WORD;
	b : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetClipboardData';


(**************************** SetClipboardViewer ****************************)

FUNCTION SetClipboardViewer (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetClipboardViewer';


(******************************* SetCommBreak *******************************)

FUNCTION SetCommBreak (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCommBreak';


(***************************** SetCommEventMask *****************************)

FUNCTION SetCommEventMask (
	a : INTEGER;
	b : CommEventMask
	) : LPCommEventMask
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCommEventMask';


(******************************* SetCommState *******************************)

FUNCTION SetCommState (
	b : DCB
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCommState';


(******************************** SetCursor *********************************)

FUNCTION SetCursor (
	a : HCURSOR
	) : HCURSOR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCursor';


(******************************* SetCursorPos *******************************)

PROCEDURE SetCursorPos (
	a : INTEGER;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetCursorPos';


(****************************** SetDlgItemInt *******************************)

PROCEDURE SetDlgItemInt (
	a : HWND;
	b : INTEGER;
	c : WORD;
	d : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetDlgItemInt';


(****************************** SetDlgItemText ******************************)

PROCEDURE SetDlgItemText (
	a : HWND;
	b : INTEGER;
	c : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetDlgItemText';


(**************************** SetDoubleClickTime ****************************)

PROCEDURE SetDoubleClickTime (
	a : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetDoubleClickTime';


(****************************** SetEnvironment ******************************)

FUNCTION SetEnvironment (
	a : LPSTR;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetEnvironment';


(********************************* SetFocus *********************************)

FUNCTION SetFocus (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetFocus';


(***************************** SetKeyboardState *****************************)

PROCEDURE SetKeyboardState (
	a : KEYBUFFER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetKeyboardState';


(******************************** SetMapMode ********************************)

FUNCTION SetMapMode (
	a : HANDLE;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMapMode';


(****************************** SetMapperFlags ******************************)

FUNCTION SetMapperFlags (
	a : HDC;
	b : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMapperFlags';


(********************************* SetMenu **********************************)

FUNCTION SetMenu (
	a : HWND;
	b : HMENU
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMenu';


(***************************** SetMessageQueue ******************************)

FUNCTION SetMessageQueue (
	a : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMessageQueue';


(***************************** SetMetaFileBits ******************************)

FUNCTION SetMetaFileBits (
	a : HANDLE
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMetaFileBits';


(******************************** SetParent *********************************)

FUNCTION SetParent (
	a : HWND;
	b : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetParent';


(********************************* SetPixel *********************************)

FUNCTION SetPixel (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetPixel';


(***************************** SetPolyFillMode ******************************)

FUNCTION SetPolyFillMode (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetPolyFillMode';


(******************************* SetPriority ********************************)

FUNCTION SetPriority (
	a : HANDLE;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetPriority';


(********************************* SetProp **********************************)

FUNCTION SetProp (
	a : HWND;
	b : LPSTR;
	c : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetProp';


(********************************* SetRect **********************************)

PROCEDURE SetRect (
	VAR a : RECT;
	    b : INTEGER;
	    c : INTEGER;
	    d : INTEGER;
	    e : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetRect';


(******************************* SetRectEmpty *******************************)

PROCEDURE SetRectEmpty (
	VAR a : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetRectEmpty';


(******************************* SetRectRgn *********************************)

PROCEDURE SetRectRgn (
	a : HRGN;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetRectRgn';


(******************************** SetRelAbs *********************************)

FUNCTION SetRelAbs (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetRelAbs';


(**************************** SetResourceHandler ****************************)

FUNCTION SetResourceHandler (
	a : HANDLE;
	b : LPSTR;
	c : FARPROC
	) : FARPROC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetResourceHandler';


(********************************* SetROP2 **********************************)

FUNCTION SetROP2 (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetROP2';


(******************************* SetScrollPos *******************************)

FUNCTION SetScrollPos (
	a : HWND;
	b : INTEGER;
	c : INTEGER;
	d : BOOL
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetScrollPos';


(****************************** SetScrollRange ******************************)

PROCEDURE SetScrollRange (
	a : HWND;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetScrollRange';


(****************************** SetSoundNoise *******************************)

FUNCTION SetSoundNoise (
	a : INTEGER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetSoundNoise';


(**************************** SetStretchBltMode *****************************)

FUNCTION SetStretchBltMode (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetStretchBltMode';


(***************************** SetSwapAreaSize ******************************)

FUNCTION SetSwapAreaSize (
	a : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetSwapAreaSize';


(******************************* SetSysColor ********************************)

PROCEDURE SetSysColors (
	a : INTEGER;
	b : LPINT;
	c : LPDWORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetSysColors';


(**************************** SetSysModalWindow *****************************)

FUNCTION SetSysModalWindow (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetSysModalWindow';


(****************************** SetTextAlign ********************************)

FUNCTION SetTextAlign (
	a : HDC;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetTextAlign';


(************************** SetTextCharacterExtra ***************************)

FUNCTION SetTextCharacterExtra (
	a : HDC;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetTextCharacterExtra';


(******************************* SetTextColor *******************************)

FUNCTION SetTextColor (
	a : HDC;
	b : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetTextColor';


(*************************** SetTextJustification ***************************)

FUNCTION SetTextJustification (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetTextJustification';


(********************************* SetTimer *********************************)

FUNCTION SetTimer (
	a : HWND;
	b : INTEGER;
	c : WORD;
	d : FARPROC
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetTimer';


(****************************** SetViewportExt ******************************)

FUNCTION SetViewportExt (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetViewportExt';


(****************************** SetViewportOrg ******************************)

FUNCTION SetViewportOrg (
	a : HDC;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetViewportOrg';


(****************************** SetVoiceAccent ******************************)

FUNCTION SetVoiceAccent (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceAccent';


(***************************** SetVoiceEnvelope *****************************)

FUNCTION SetVoiceEnvelope (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceEnvelope';


(******************************* SetVoiceNote *******************************)

FUNCTION SetVoiceNote (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceNote';


(**************************** SetVoiceQueueSize *****************************)

FUNCTION SetVoice (
	a : INTEGER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceQueueSize';


(****************************** SetVoiceSound *******************************)

FUNCTION SetVoiceSound (
	a : INTEGER;
	b : LONGINT;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceSound';


(**************************** SetVoiceThreshold *****************************)

FUNCTION SetVoiceThreshold (
	a : INTEGER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetVoiceThreshold';


(******************************* SetWindowExt *******************************)

FUNCTION SetWindowExt (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowExt';


(****************************** SetWindowLong *******************************)

FUNCTION SetWindowLong (
	a : HWND;
	b : INTEGER;
	c : LONGINT
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowLong';


(******************************* SetWindowOrg *******************************)

FUNCTION SetWindowOrg (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowOrg';


(****************************** SetWindowPos ********************************)

PROCEDURE SetWindowPos (
	a : HWND;
	b : HWND;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowPos';


(***************************** SetWindowsHook *******************************)

FUNCTION SetWindowsHook (
	a : INTEGER;
	b : FARPROC
	) : FARPROC
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowsHook';


(****************************** SetWindowText *******************************)

PROCEDURE SetWindowText (
	a : HWND;
	b : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowText';


(****************************** SetWindowWord *******************************)

FUNCTION SetWindowWord (
	a : HWND;
	b : INTEGER;
	c : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetWindowWord';


(******************************** ShowCaret *********************************)

PROCEDURE ShowCaret (
	a : HWND
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ShowCaret';


(******************************** ShowCursor ********************************)

FUNCTION ShowCursor (
	a : BOOL
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ShowCursor';


(***************************** ShowOwnedPopups ******************************)

PROCEDURE ShowOwnedPopups (
	a : HWND;
	b : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ShowOwnedPopups';


(****************************** ShowScrollBar *******************************)

PROCEDURE ShowScrollBar (
	a : HANDLE;
	b : WORD;
	c : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ShowScrollBar';


(******************************** ShowWindow ********************************)

FUNCTION ShowWindow (
	a : HANDLE;
	b : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ShowWindow';


(****************************** SizeofResource ******************************)

FUNCTION SizeofResource (
	a : HANDLE;
	b : HANDLE
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SizeofResource';


(******************************** StartSound ********************************)

FUNCTION StartSound (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'StartSound';


(******************************** StopSound *********************************)

FUNCTION StopSound (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'StopSound';


(******************************** StretchBlt ********************************)

FUNCTION StretchBlt (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : HDC;
	g : INTEGER;
	h : INTEGER;
	i : INTEGER;
	j : INTEGER;
	k : DWORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'StretchBlt';


(***************************** SwapMouseButton ******************************)

PROCEDURE SwapMouseButton (
	a : BOOL
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SwapMouseButton';


(****************************** SyncAllVoices *******************************)

FUNCTION SyncAllVoices (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SyncAllVoices';


(********************************* TextOut **********************************)

FUNCTION TextOut (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : LPSTR;
	e : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TextOut';


(********************************** Throw ***********************************)

PROCEDURE Throw (
	a : CATCHBUF;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Throw';


(*************************** TranslateAccelerator ***************************)

FUNCTION TranslateAccelerator (
	    a : HWND;
	    b : HANDLE;
	VAR c : MSG
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TranslateAccelerator';


(***************************** TranslateMessage *****************************)

FUNCTION TranslateMessage (
	VAR a : MSG
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TranslateMessage';


(**************************** TransmitCommChar ******************************)

FUNCTION TransmitCommChar (
	a : INTEGER;
	c : CHAR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TransmitCommChar';


(****************************** UngetCommChar *******************************)

FUNCTION UngetCommChar (
	a : INTEGER;
	c : CHAR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UngetCommChar';


(**************************** UnhookWindowsHook	*****************************)

FUNCTION UnhookWindowsHook (
	a : INTEGER;
	b : FARPROC
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UnhookWindowsHook';


(******************************** UnionRect *********************************)

FUNCTION UnionRect (
	VAR a : RECT;
	    b : RECT;
	    c : RECT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UnionRect';


(***************************** UnlockResource *******************************)

FUNCTION UnlockResouce (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalUnlock';


(****************************** UnlockSegment *******************************)

FUNCTION UnlockSegment (
	a : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UnlockSegment';


(***************************** UnrealizeObject ******************************)

FUNCTION UnrealizeObject (
	a : HBRUSH
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UnrealizeObject';


(******************************* UpdateWindow *******************************)

PROCEDURE UpdateWindow (
	a : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UpdateWindow';


(**************************** ValidateFreeSpaces ****************************)

FUNCTION ValidateFreeSpaces (
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ValidateFreeSpaces';


(******************************* ValidateRect *******************************)

PROCEDURE ValidateRect (
	a : HWND;
	b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ValidateRect';


(******************************* ValidateRgn ********************************)

PROCEDURE ValidateRgn (
	a : HWND;
	b : HRGN
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ValidateRgn';


(******************************* WaitMessage ********************************)

PROCEDURE WaitMessage (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WaitMessage';


(***************************** WaitSoundState *******************************)

FUNCTION WaitSoundState (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WaitSoundState';


(***************************** WindowFromPoint ******************************)

FUNCTION WindowFromPoint (
	a : POINT
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WindowFromPoint';


(******************************** WriteComm *********************************)

FUNCTION WriteComm (
	a : INTEGER;
	b : LPSTR;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WriteComm';


(**************************** WriteProfileString ****************************)

FUNCTION WriteProfileString (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WriteProfileString';


(********************************** Yield ***********************************)

FUNCTION Yield (
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'Yield';



(******************************* NEW 3.0 STUFF *******************************)

PROCEDURE AdjustWindowRectEx (
	VAR a : RECT;
	    b : DWORD;
	    c : BOOL;
	    d : DWORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AdjustWindowRectEx';

FUNCTION AllocDStoCSAlias (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AllocDStoCSAlias';

FUNCTION AllocSelector (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AllocSelector';

PROCEDURE AnimatePalette (
	    a : HPALETTE;
	    b : WORD;
	    c : WORD;
	VAR d : PALETTEENTRY
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnimatePalette';

FUNCTION AnsiLowerBuff (
	a : LPSTR;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiLowerBuff';

PROCEDURE AnsiToOemBuff (
	a : LPSTR;
	b : LPSTR;
	c : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiToOemBuff';

FUNCTION AnsiUpperBuff (
	a : LPSTR;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AnsiUpperBuff';

FUNCTION AppendMenu (
	a : HMENU;
	b : WORD;
	c : WORD;
	d : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'AppendMenu';

FUNCTION ArrangeIconicWindows (
	a : HWND
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ArrangeIconicWindows';

FUNCTION BeginDeferWindowPos (
	a : INTEGER
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'BeginDeferWindowPos';

FUNCTION ChangeSelector (
	a : WORD;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ChangeSelector';

PROCEDURE CreateCursor (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : LPSTR;
	g : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateCursor';

FUNCTION CreateDialogIndirectParam (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : FARPROC;
	e : DWORD
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDialogIndirectParam';

FUNCTION CreateDialogParam (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : FARPROC;
	e : DWORD
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDialogParam';

FUNCTION CreateDIBitmap (
	    a : HDC;
	VAR b : BITMAPINFOHEADER;
	    c : DWORD;
	    d : LPSTR;
	VAR e : BITMAPINFO;
	    f : WORD
	) : HBITMAP
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDIBitmap';

FUNCTION CreateDIBPatternBrush (
	a : HANDLE;
	b : WORD
	) : HBRUSH
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateDIBPatternBrush';

FUNCTION CreateIcon (
	a : HANDLE;
	b : INTEGER;
	c : INTEGER;
	d : BYTE;
	e : BYTE;
	f : LPSTR;
	g : LPSTR
	) : HICON
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateIcon';

FUNCTION CreatePalette (
	VAR a : LOGPALETTE
	) : HPALETTE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePalette';

FUNCTION CreatePolyPolygonRgn (
	a : LPPOINT;
	b : LPINT;
	c : INTEGER;
	d : INTEGER
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePolyPolygonRgn';

FUNCTION CreatePopupMenu (
	) : HMENU
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreatePopupMenu';

FUNCTION CreateRoundRectRgn (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER
	) : HRGN
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateRoundRectRgn';

PROCEDURE CreateWindowEx (
	a : DWORD;
	b : LPSTR;
	c : LPSTR;
	d : DWORD;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : INTEGER;
	i : HWND;
	j : HMENU;
	k : HANDLE;
	l : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'CreateWindowEx';

PROCEDURE DebugBreak (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DebugBreak';

FUNCTION DefDlgProc (
	a : HWND;
	b : HWND;
	c : WORD;
	d : DWORD
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefDlgProc';

FUNCTION DeferWindowPos (
	a : HANDLE;
	b : HWND;
	c : HWND;
	d : INTEGER;
	e : INTEGER;
	f : INTEGER;
	g : INTEGER;
	h : WORD
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeferWindowPos';

FUNCTION DefFrameProc (
	a : HWND;
	b : HWND;
	c : WORD;
	d : WORD;
	e : DWORD
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefFrameProc';

TYPE
    HANDLETABLE =
	RECORD
	objectHandle : ARRAY [0..0] OF HANDLE;
	END;

    METARECORD =
	RECORD
	rdSize		: DWORD;
	rdFunction	: WORD;
	rdParam		: ARRAY [0..0] OF WORD;
	END;

    METAFILEPICT =
	RECORD
	mm	: INTEGER;
	xExt	: INTEGER;
	yExt	: INTEGER;
	hMF	: HANDLE;
	END;

    METAHEADER =
	RECORD
	mtType		: WORD;
	mtHeaderSize	: WORD;
	mtVersion	: WORD;
	mtSize		: DWORD;
	mtNoObjects	: WORD;
	mtMaxRecord	: DWORD;
	mtNoParameters	: WORD;
	END;

FUNCTION DefineHandleTable (
	a : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefineHandleTable';

FUNCTION DefMDIChildProc (
	a : HWND;
	b : WORD;
	c : WORD;
	d : DWORD
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DefMDIChildProc';

FUNCTION DeleteMenu (
	a : HMENU;
	b : WORD;
	c : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DeleteMenu';

FUNCTION DestroyCursor (
	a : HCURSOR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DestroyCursor';

FUNCTION DestroyIcon (
	a : HICON
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DestroyIcon';

(* This is the header of a procedure that is actually defined in the *)
(* printer driver.  To use this procedure, you must link to at at *)
(* runtime via LoadModule and GetProcAddress () *)

(*
TYPE DeviceCapabilities = 
    PROCEDURE(
	LPSTR,
	LPSTR,
	CARDINAL,
	LPSTR,
	VAR DEVMODE
	) : DWORD
[LARGE,LONG,ALTERS(AX,BX,CX,DX,ES)];
*)

FUNCTION DialogBoxIndirectParam (
	a : HANDLE;
	b : HANDLE;
	c : HWND;
	d : FARPROC;
	e : DWORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DialogBoxIndirectParam';

FUNCTION DialogBoxParam (
	a : HANDLE;
	b : LPSTR;
	c : HWND;
	d : FARPROC;
	e : DWORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DialogBoxParam';

FUNCTION DlgDirListComboBox (
	a : HWND;
	b : LPSTR;
	c : INTEGER;
	d : INTEGER;
	e : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DlgDirListComboBox';

PROCEDURE DlgDirSelectComboBox (
	a : HWND;
	b : LPSTR;
	c : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DlgDirSelectComboBox';

PROCEDURE DrawFocusRect (
	    a : HDC;
	VAR b : RECT
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'DrawFocusRect';

PROCEDURE EndDeferWindowPos (
	a : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'EndDeferWindowPos';

FUNCTION ExitWindows (
	a : DWORD;
	b : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ExitWindows';

(* This is the header of a procedure that is actually defined in the *)
(* printer driver.  To use this procedure, you must link to at at *)
(* runtime via LoadModule and GetProcAddress () *)

(*
TYPE ExtDeviceMode =
    PROCEDURE(
	HWND,
	HANDLE,
	VAR DEVMODE,
	LPSTR,
	LPSTR,
	DEVMODE,
	LPSTR,
	CARDINAL
	) : INTEGER
[LARGE,LONG,ALTERS(AX,BX,CX,DX,ES)];
*)

FUNCTION ExtFloodFill (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : COLORREF;
	e : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ExtFloodFill';

PROCEDURE FatalAppExit (
	a : WORD;
	b : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FatalAppExit';

PROCEDURE FreeModule (
	a : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FreeModule';

FUNCTION FreeSelector (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'FreeSelector';

FUNCTION GetClassInfo (
	    a : HANDLE;
	    b : LPSTR;
	VAR c : WNDCLASS
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetClassInfo';

PROCEDURE GetCodeInfo (
	a : FARPROC;
	b : LPVOID
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCodeInfo';

FUNCTION GetCurrentPDB (
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetCurrentPDB';

FUNCTION GetDesktopWindow (
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDesktopWindow';

FUNCTION GetDialogBaseUnits (
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDialogBaseUnits';

FUNCTION GetDIBits (
	a : HDC;
	b : HBITMAP;
	c : WORD;
	d : WORD;
	e : LPSTR;
	f : BITMAPINFO;
	g : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDIBits';

FUNCTION GetDlgCtrlID (
	a : HWND
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDlgCtrlID';

FUNCTION GetDOSEnvironment (
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDOSEnvironment';

CONST
    DRIVE_REMOVABLE	= 2;
    DRIVE_FIXED		= 3;
    DRIVE_REMOTE	= 4;

FUNCTION GetDriveType (
	a : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetDriveType';

FUNCTION GetFreeSpace (
	a : WORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetFreeSpace';

FUNCTION GetKBCodePage (
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetKBCodePage';

FUNCTION GetKeyboardType (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetKeyboardType';

FUNCTION GetKeyNameText (
	a : DWORD;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetKeyNameText';

FUNCTION GetLastActivePopup (
	a : HWND
	) : HWND
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetLastActivePopup';

FUNCTION GetMenuCheckMarkDimensions (
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetMenuCheckMarkDimensions';

FUNCTION GetNearestPaletteIndex (
	a : HPALETTE;
	b : COLORREF
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetNearestPaletteIndex';

FUNCTION GetPaletteEntries (
	    a : HPALETTE;
	    b : WORD;
	    c : WORD;
	VAR d : PALETTEENTRY
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPaletteEntries';

FUNCTION GetPriorityClipboardFormat (
	a : POINTER;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPriorityClipboardFormat';

FUNCTION GetPrivateProfileInt (
	a : LPSTR;
	b : LPSTR;
	c : INTEGER;
	d : LPSTR
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPrivateProfileInt';

FUNCTION GetPrivateProfileString (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR;
	d : LPSTR;
	e : INTEGER;
	f : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetPrivateProfileString';

FUNCTION GetRgnBox (
	    a : HRGN;
	VAR b : RECT
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetRgnBox';

FUNCTION GetSystemDirectory (
	a : LPSTR;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSystemDirectory';

FUNCTION GetSystemPaletteEntries (
	    a : HDC;
	    b : WORD;
	    c : WORD;
	VAR d : PALETTEENTRY
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSystemPaletteEntries';

FUNCTION GetSystemPaletteUse (
	a : HDC
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetSystemPaletteUse';

FUNCTION GetTabbedTextExtent (
	a : HDC;
	b : LPSTR;
	c : INTEGER;
	d : INTEGER;
	e : POINTER
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetTabbedTextExtent';

FUNCTION GetWindowsDirectory (
	a : LPSTR;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWindowsDirectory';

CONST
    WF_PMODE		= 1;
    WF_CPU286		= 2;
    WF_CPU386		= 3;
    WF_CPU486		= 4;
    WF_STANDARD		= $10;
    WF_WIN286		= $10;
    WF_ENHANCED		= $20;
    WF_WIN386		= $20;
    WF_CPU086		= $40;
    WF_CPU186		= $80;
    WF_LARGEFRAME	= $0100;
    WF_SMALLFRAME	= $0200;
    WF_80x87		= $0400;

    WEP_SYSTEM_EXIT	= 1;
    WEP_FREE_DLL	= 0;

FUNCTION GetWinFlags (
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GetWinFlags';

FUNCTION GlobalDosAlloc (
	a : DWORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalDosAlloc';

FUNCTION GlobalDosFree (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalDosFree';

PROCEDURE GlobalFix (
	a : HANDLE
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalFix';

FUNCTION GlobalPageLock (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalPageLock';

FUNCTION GlobalUnfix (
	a : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'GlobalUnfix';

FUNCTION InsertMenu (
	a : HMENU;
	b : WORD;
	c : WORD;
	d : WORD;
	e : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'InsertMenu';

FUNCTION IsCharAlpha (
	a : CHAR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsCharAlpha';

FUNCTION IsCharAlphaNumeric (
	a : CHAR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsCharAlphaNumeric';

FUNCTION IsCharLower (
	a : CHAR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsCharLower';

FUNCTION IsCharUpper (
	a : CHAR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'IsCharUpper';

FUNCTION _lclose (
	a : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_lclose';

FUNCTION _lcreat (
	a : LPSTR;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_lcreat';

FUNCTION _llseek (
	a : INTEGER;
	b : LONGINT;
	c : INTEGER
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_llseek';

TYPE
    NormRec = RECORD
		wEnvSeg : WORD;
		lpCmdLine : LPSTR;
		lpCmdShow : LPVOID;
		dwReserved : DWORD;
	      END;

FUNCTION LoadModule (
	    a : LPSTR;
	VAR b : NormRec
	) : HANDLE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'LoadModule';

CONST
    READ	= 0;
    WRITE	= 1;
    READ_WRITE	= 2;

FUNCTION _lopen (
	a : LPSTR;
	b : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_lopen';

FUNCTION _lread (
	a : INTEGER;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_lread';

FUNCTION lstrcat (
	a : LPSTR;
	b : LPSTR
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'lstrcat';

FUNCTION lstrcmp (
	a : LPSTR;
	b : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'lstrcmp';

FUNCTION lstrcmpi (
	a : LPSTR;
	b : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'lstrcmpi';

FUNCTION lstrcpy (
	a : LPSTR;
	b : LPSTR
	) : LPSTR
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'lstrcpy';

FUNCTION lstrlen (
	a : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'lstrlen';

FUNCTION _lwrite (
	a : INTEGER;
	b : LPSTR;
	c : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_lwrite';

FUNCTION MapVirtualKey (
	a : WORD;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MapVirtualKey';

FUNCTION ModifyMenu (
	a : HMENU;
	b : WORD;
	c : WORD;
	d : WORD;
	e : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ModifyMenu';


FUNCTION MulDiv (
	a : INTEGER;
	b : INTEGER;
	c : INTEGER
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'MulDiv';

FUNCTION OemKeyScan (
	a : WORD
	) : DWORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OemKeyScan';

PROCEDURE OutputDebugString (
	a : LPSTR
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'OutputDebugString';

FUNCTION PALETTEINDEX (
	a : INTEGER
	) : COLORREF;

FUNCTION PALETTERGB (
	a : BYTE;
	b : BYTE;
	c : BYTE
	) : COLORREF;

FUNCTION PolyPolygon (
	a : HDC;
	b : LPPOINT;
	c : LPINT;
	d : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'PolyPolygon';

PROCEDURE ProfClear (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfClear';

PROCEDURE ProfFinish (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfFinish';

PROCEDURE ProfFlush (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfFlush';

PROCEDURE ProfInsChk (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfInsChk';

PROCEDURE ProfSampRate (
	a : INTEGER;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfSampRate';

PROCEDURE ProfSetup (
	a : INTEGER;
	b : INTEGER
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ProfSetup';

FUNCTION RealizePalette (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RealizePalette';

FUNCTION RectInRegion (
	a : HRGN;
	b : RECT
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RectInRegion';

FUNCTION RemoveMenu (
	a : HMENU;
	b : WORD;
	c : WORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'RemoveMenu';

FUNCTION ResizePalette (
	a : HPALETTE;
	b : INTEGER
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ResizePalette';

FUNCTION SelectPalette (
	a : HDC;
	b : HPALETTE;
	c : BOOL
	) : HPALETTE
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SelectPalette';

FUNCTION SetDIBits (
	a : HDC;
	b : HBITMAP;
	c : WORD;
	d : WORD;
	e : LPSTR;
	f : BITMAPINFO;
	g : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetDIBits';

FUNCTION SetDIBitsToDevice (
	a : HDC;
	b : WORD;
	c : WORD;
	d : WORD;
	e : WORD;
	f : WORD;
	g : WORD;
	h : WORD;
	i : WORD;
	j : LPSTR;
	k : BITMAPINFO;
	l : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetDIBitsToDevice';

FUNCTION SetHandleCount (
	a : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetHandleCount';

FUNCTION SetMenuItemBitmaps (
	a : HMENU;
	b : WORD;
	c : WORD;
	d : HBITMAP;
	e : HBITMAP
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetMenuItemBitmaps';

FUNCTION SetPaletteEntries (
	    a : HPALETTE;
	    b : WORD;
	    c : WORD;
	VAR d : PALETTEENTRY
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetPaletteEntries';

FUNCTION SetSystemPaletteUse (
	a : HDC;
	b : WORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SetSystemPaletteUse';

FUNCTION StretchDIBits (
	a : HDC;
	b : WORD;
	c : WORD;
	d : WORD;
	e : WORD;
	f : WORD;
	g : WORD;
	h : WORD;
	i : WORD;
	j : BITMAPINFO;
	k : WORD;
	k : DWORD
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'StretchDIBits';

PROCEDURE SwapRecording (
	a : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SwapRecording';

PROCEDURE SwitchStackBack (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SwitchStackBack';

PROCEDURE SwitchStackTo (
	a : WORD;
	b : WORD;
	c : WORD
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'SwitchStackTo';

FUNCTION TabbedTextOut (
	a : HDC;
	b : INTEGER;
	c : INTEGER;
	d : LPSTR;
	e : INTEGER;
	f : INTEGER;
	g : LPINT;
	h : INTEGER
	) : LONGINT
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TabbedTextOut';

FUNCTION ToAscii (
	a : WORD;
	b : WORD;
	c : LPSTR;
	d : LPVOID;
	e : WORD
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ToAscii';

FUNCTION TrackPopupMenu (
	a : HMENU;
	b : WORD;
	c : INTEGER;
	d : INTEGER;
	e : INTEGER;
	f : HWND;
	g : LPVOID
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TrackPopupMenu';

FUNCTION TranslateMDISysAccel (
	a : HWND;
	b : MSG
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'TranslateMDISysAccel';

FUNCTION UnregisterClass (
	a : LPSTR;
	b : HANDLE
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UnregisterClass';

FUNCTION UpdateColors (
	a : HDC
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'UpdateColors';

PROCEDURE ValidateCodeSegments (
	)
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'ValidateCodeSegments';

FUNCTION WinExec (
	a : LPSTR;
	b : INTEGER
	) : WORD
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WinExec';

FUNCTION WinHelp (
	a : HWND;
	b : LPSTR;
	c : WORD;
	d : DWORD
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WinHelp';

FUNCTION WritePrivateProfileString (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR;
	d : LPSTR
	) : BOOL
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'WritePrivateProfileString';

FUNCTION wsprintf (
	a : LPSTR;
	b : LPSTR
	) : INTEGER
	[REVERSED,LEAVES,VARIABLE,ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL '_wsprintf';

FUNCTION wvsprintf (
	a : LPSTR;
	b : LPSTR;
	c : LPSTR
	) : INTEGER
	[ALTERS(AX,BX,CX,DX,ES)]; FAR; EXTERNAL 'wvsprintf';

(***************************************************************************)
(*									   *)
(*			     Copyright (C) 1989				   *)
(*			   by Stony Brook Software			   *)
(*									   *)
(*			     All rights reserved.			   *)
(*									   *)
(***************************************************************************)

IMPLEMENTATION
{$X+}

TYPE Wtype =
    RECORD
        CASE  INTEGER OF
            1:  (W		: WORD;
            ); 
	    2:  (B1,B2		: BYTE;
      ); END;

TYPE Ltype =
    RECORD
        CASE  INTEGER OF
            0:  (L		: LONGINT;
            );   
            1:  (W1, W2		: WORD;
            ); 
	    2:  (B1,B2,B3,B4	: BYTE;
            ); 
	    3:  (A		: POINTER;
      ); END;

FUNCTION MAKELONG (
	LowWord, HiWord : WORD
	) : LONGINT;
    VAR 
	Result: Ltype;
    BEGIN
        Result.W1 := LowWord;
        Result.W2 := HiWord;
        MAKELONG := Result.L; EXIT;
    END;

FUNCTION LOWORD (
	l : LONGINT
	) : WORD;
    BEGIN
        LOWORD := Ltype(l).W1; EXIT;
    END;

FUNCTION HIWORD (
	l : LONGINT
	) : WORD;
    BEGIN
        HIWORD := Ltype(l).W2; EXIT;
    END;

FUNCTION LOBYTE (
	w : WORD
	) : BYTE;
    BEGIN
        LOBYTE := BYTE(w); EXIT;
    END;

FUNCTION HIBYTE (
	w : WORD
	) : BYTE;
    BEGIN
	HIBYTE := Wtype(w).B2; EXIT;
    END;

FUNCTION GlobalDiscard (
	h : HANDLE
	) : HANDLE;
    BEGIN
        GlobalDiscard := GlobalReAlloc(h, 0, GMEM_MOVEABLE); EXIT;
    END;
    
FUNCTION LocalDiscard (
	h : HANDLE
	) : HANDLE;
    BEGIN
        LocalDiscard := LocalReAlloc(h, 0, LMEM_MOVEABLE); EXIT;
    END;

FUNCTION LockData (
	dummy : INTEGER
	) : HANDLE;
    BEGIN
        LockData := LockSegment($0FFFF); EXIT;
    END;
    
PROCEDURE UnlockData (
	dummy : INTEGER
	);
    BEGIN
         UnlockSegment($0FFFF);
    END;
    
PROCEDURE LocalFreeze (
	dummy : INTEGER
	);
    BEGIN
    END;
    
PROCEDURE LocalMelt (
	dummy : INTEGER
	);
    BEGIN
    END;

PROCEDURE LocalHandleDelta (
	delta : WORD
	);
    BEGIN
    END;
    
FUNCTION MAKEINTATOM (
	a : INTEGER
	) : LPSTR;
    VAR
        b : LType;
    BEGIN
         b.W1 := a;
	 b.W2 := 0;
	 MAKEINTATOM := b.A; EXIT;
    END;
    
FUNCTION max (
	value1, value2 : INTEGER
	) : INTEGER;
    BEGIN
        IF value1 > value2 THEN BEGIN
	    max := value1; EXIT;
	END;
	max := value2; EXIT;
    END;
    	    
FUNCTION min (
	value1, value2 : INTEGER
	) : INTEGER;
    BEGIN
        IF value1 < value2 THEN BEGIN
	    min := value1; EXIT;
	END;
	min := value2; EXIT;
    END;

FUNCTION GetRValue (
	rgb : DWORD
	) : BYTE;
    BEGIN
	GetRValue := Ltype(rgb).B1; EXIT;
    END;
    
FUNCTION GetBValue (
	rgb : DWORD
	) : BYTE;
    BEGIN
	GetBValue := Ltype(rgb).B2; EXIT;
    END;
    
FUNCTION GetGValue (
	rgb : DWORD
	) : BYTE;
    BEGIN
	GetGValue := Ltype(rgb).B3; EXIT;
    END;

FUNCTION RGB (
	r, g, b : BYTE
	) : DWORD;
    VAR
        l : Ltype;
    BEGIN
        l.B1 := r;
	l.B2 := g;
	l.B3 := b;
	l.B4 := 0;
	RGB := l.L; EXIT;
    END;

FUNCTION PALETTEINDEX (
	n : INTEGER
	) : DWORD;
    VAR
        l : Ltype;
    BEGIN
        l.L := 0;
	l.W1 := n;
	l.B4 := 1;
	PALETTEINDEX := l.L; EXIT;
    END;
    
FUNCTION PALETTERGB (
	r, g, b : BYTE
	) : DWORD;
    VAR
        l : Ltype;
    BEGIN
        l.B1 := r;
	l.B2 := g;
	l.B3 := b;
	l.B4 := 2;
	PALETTERGB := l.L; EXIT;
    END;
    
END.
