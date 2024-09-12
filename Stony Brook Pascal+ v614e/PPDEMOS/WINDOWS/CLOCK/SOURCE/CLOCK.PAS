(***************************************************************************
 *                                                                         *
 *  PROGRAM   : Clock.c                                                    *
 *                                                                         *
 *  PURPOSE   : To give a demonstration on the use of a timer in a windows *
 *              application.                                               *
 *                                                                         *
 *  MACROS    : HourHandPos  - Computes the hour hand position based on    *
 *                             both the hour and minute values.            *
 *                                                                         *
 *              VertEquiv    - Computes the raster line equivalent to the  *
 *                             given pixel value.                          *
 *                                                                         *
 *              HorzEquiv    - Computes the pixel equivalent to the given  *
 *                             raster line value.                          *
 *                                                                         *
 *  FUNCTIONS : About        - Dialog function for the About Dialog.       *
 *                                                                         *
 *              ClockWndProc - Window function for the application.        *
 *                                                                         *
 *              CreateTools  - Creates brushes and pens to coincide with   *
 *                             the current system colors.                  *
 *                                                                         *
 *              DeleteTools  - Destroys the brushes and pens created by    *
 *                             CreateTools.                                *
 *                                                                         *
 *              ClockCreate  - Performs the necessary initialization for   *
 *                             drawing the clock correctly and gets the    *
 *                             initial time to be displayed by the clock.  *
 *                                                                         *
 *              ClockSize    - Resize the clock to the largest possible    *
 *                             circle that will fit in the client area.    *
 *                                                                         *
 *              ClockTimer   - Update the clock to reflect the most recent *
 *                             time.                                       *
 *                                                                         *
 *              ClockPaint   - Paint the clock to display the most recent  *
 *                             time.                                       *
 *                                                                         *
 *              DrawFace     - Draws the clock face.                       *
 *                                                                         *
 *              DrawHand     - Draws a thin hand with the specified brush  *
 *                             in the specified hand position.             *
 *                                                                         *
 *              DrawFatHand  - Draws a fat hand with the specified brush   *
 *                             in the specified hand position.             *
 *                                                                         *
 *              CircleClock  - Resizes clock rectangle to keep clock       *
 *                             circular.                                   *
 *                                                                         *
 *              WinMain      - Calls the initialization function, creates  *
 *                             the main application window, and enters the *
 *                             message loop.                               *
 *                                                                         *
 *              ClockInit    - Registers the application window class and  *
 *                             initializes the circle values for the clock *
 *                             face.                                       *
 *                                                                         *
 ***************************************************************************)
 
PROGRAM Clock;
{$X+}

USES Windows;

CONST
    BUFLEN        = 30; (* name buffer length *)
    
    MAXDOTWIDTH   = 25; (* maximum hour-marking dot width  *)
    MINDOTWIDTH   = 2;  (* minimum hour-marking dot width  *)
    MINDOTHEIGHT  = 1;  (* minimum hour-marking dot height *)
    
    (* Defines for menu items *)
    IDM_ABOUT     = 1001;
    IDS_ABOUTMENU = 1;
    IDS_APPNAME   = 2;
    IDS_DATA      = 3;
    IDS_TOOMANY   = 4;
    
    (* hand and paint flags *)
    HHAND         = wTRUE;
    MHAND         = wFALSE;
    PAINTALL      = 0;
    HANDPAINT     = 1;
    
    (* timer interval when the clock window is ...            *)
    OPEN_TLEN     = 450;    (* ... open   (every second) *)
    ICON_TLEN     = 59000;  (* ... iconic (every minute) *)
    
    (* distance from the center of the clock to ...                 *)
    HOURSIDE      = 7;   (* ... either side of the hour hand   *)
    MINUTESIDE    = 5;   (* ... either side of the minute hand *)
    HOURTIP       = 65;  (* ... the tip of the hour hand       *)
    MINUTETIP     = 80;  (* ... the tip of the minute hand     *)
    SECONDTIP     = 80;  (* ... the tip of the second hand     *)
    HOURTAIL      = 15;  (* ... the tail of the hour hand      *)
    MINUTETAIL    = 20;  (* ... the tail of the minute hand    *)
    
    (* conversion factors *)
    CIRTABSCALE   = 8000; (* circle table values scale down value  *)
    MMPERDM       = 100;  (* millimeters per decimeter             *)
    
    (* number of hand positions on ...                                     *)
    HANDPOSITIONS = 60;                   (* ... entire clock         *)
    SIDESHIFT     = (HANDPOSITIONS DIV 4); (* ...  90 degrees of clock *)
    TAILSHIFT     = (HANDPOSITIONS DIV 2); (* ... 180 degrees of clock *)
    
CONST
    bFirst : BOOL = wTRUE;   (* TRUE if this is the 1st instance; FALSE otherwise  *)
    TimerID : INTEGER = 1;      (* number used for timer-id                           *)
    bIconic : BOOL = wFALSE;  (* TRUE if clock is currently iconic; FALSE otherwise *)

TYPE
    TIME =
	RECORD
	    hour : INTEGER;
	    minute : INTEGER;
	    second : INTEGER;
	END;

(* this is needed because C allowed a declared pointer to record to be
   accessed as a pointer to array of record *)
TYPE
    arrPOINT = ARRAY [0..60*2-1] OF POINT; 

VAR
    oTime : TIME;       (* the time currently displayed on the clock          *)

    hbrForegnd : HBRUSH;      (* foreground brush -- system window text color       *)
    hbrBackgnd : HBRUSH;      (* background brush -- system window backbround color *)
    hpenForegnd : HPEN;     (* foreground pen   -- system window text color       *)
    hpenBackgnd : HPEN;     (* background pen   -- system window background color *)

    hCirTab : HANDLE;      (* Circle table for the circular clock face positions *)
    lpCirTab : ^arrPOINT;    (* Pointer to the circle table                        *)

    szBuffer : ARRAY [0..BUFLEN] OF CHAR; (* buffer for stringtable data                        *)
    ClockRect : RECT;        (* rectangle that EXACTLY bounds the clock face       *)
    ClockRadius : LONGINT;      (* clock face radius                                  *)
    ClockCenter : POINT;      (* clock face center                                  *)

    HRes : INTEGER;          (* width of the display (in pixels)                   *)
    VRes : INTEGER;          (* height of the display (in raster lines)            *)
    AspectH : LONGINT;          (* number of pixels per decimeter on the display      *)
    AspectV : LONGINT;          (* number of raster lines per decimeter on the display*)


VAR
    Wnd : HWND;
    mess : MSG;
    Menu : HMENU;
    nTime : TIME;
    sysWidth : INTEGER;  (* width of left and right frames                  *)
    sysHeight : INTEGER; (* height of caption bar and top and bottom frames *)
    width : INTEGER;     (* width of entire clock window                    *)
    height : INTEGER;    (* height of entire clock window                   *)
    pszTooMany : LPSTR;
    
PROCEDURE GetTime(VAR t : TIME); ASSEMBLER;
    asm
        mov     ax, 2c00h           {get time}
        int     21h
        cmp     ch, 12                  {if hour <12}
        jl      @lt12                    {we're ok}
        sub     ch,12                   {else adjust it}
@lt12:
        xor     ax,ax
        mov     al,ch
	les	bx, t
        mov     es:[bx].TIME.hour, ax
        mov     al,cl
        mov     es:[bx].TIME.minute, ax
        mov     al,dh
        mov     es:[bx].TIME.second, ax
    end;

(***************************************************************************
 *                                                                         *
 *  MACRO    : HourHandPos (TIME)                                          *
 *                                                                         *
 *  PURPOSE  : Computes the hour hand position based on both the hour and  *
 *             minute values in the given time record.                     *
 *                                                                         *
 ***************************************************************************)

FUNCTION HourHandPos(t : TIME) : INTEGER;
BEGIN
    HourHandPos := (t.hour*5) + (t.minute DIV 12);
END;

(***************************************************************************
 *                                                                         *
 *  MACRO    : VertEquiv (int)                                             *
 *                                                                         *
 *  PURPOSE  : Computes the raster line (vertical) equivalent to the given *
 *             pixel (horizontal) value.                                   *
 *                                                                         *
 ***************************************************************************)

FUNCTION VertEquiv(l : INTEGER) : INTEGER;
BEGIN
    VertEquiv := LONGINT(l) * AspectV DIV AspectH;
END;

(***************************************************************************
 *                                                                         *
 *  MACRO    : HorzEquiv (int)                                             *
 *                                                                         *
 *  PURPOSE  : Computes the pixel (horizontal) equivalent to the given     *
 *             raster line (vertical) value.                               *
 *                                                                         *
 ***************************************************************************)

FUNCTION HorzEquiv(l : INTEGER) : INTEGER;
BEGIN
    HorzEquiv := LONGINT(l) * AspectH DIV AspectV;
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : CreateTools ()                                              *
 *                                                                         *
 *  PURPOSE  : Creates brushes and pens to coincide with the current       *
 *             system colors.                                              *
 *                                                                         *
 ***************************************************************************)

PROCEDURE CreateTools;
BEGIN
    hbrForegnd  := CreateSolidBrush(GetSysColor(COLOR_WINDOWTEXT));
    hbrBackgnd  := CreateSolidBrush(GetSysColor(COLOR_WINDOW));
    hpenForegnd := CreatePen(0, 1, GetSysColor(COLOR_WINDOWTEXT));
    hpenBackgnd := CreatePen(0, 1, GetSysColor(COLOR_WINDOW));
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : DeleteTools ()                                              *
 *                                                                         *
 *  PURPOSE  : Destroys the brushes and pens created by CreateTools.       *
 *                                                                         *
 ***************************************************************************)

PROCEDURE DeleteTools;
BEGIN
    DeleteObject(hbrForegnd);
    DeleteObject(hbrBackgnd);
    DeleteObject(hpenForegnd);
    DeleteObject(hpenBackgnd);
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockCreate ()                                              *
 *                                                                         *
 *  PURPOSE  : First, for drawing the clock, ClockCreate computes the      *
 *             aspect ratio and creates the necessary pens and brushes.    *
 *             Then, if this is the first instance of the app running,     *
 *             ClockCreate scales the circle table values according to the *
 *             aspect ratio. Finally, ClockCreate gets the initial time.   *
 *                                                                         *
 ***************************************************************************)

PROCEDURE ClockCreate;
VAR
    pos : INTEGER;      (* hand position index into the circle table *)
    vSize : INTEGER; (* height of the display in millimeters      *)
    hSize : INTEGER; (* width of the display in millimeters       *)
    DC : HDC;
    rc : RECT;
BEGIN
    (* Get display size in (pixels X raster lines) *)
    (* and in (millimeters X millimeters)          *)

    DC := GetDC(NULL);
    VRes := GetDeviceCaps(DC, VERTRES);
    HRes := GetDeviceCaps(DC, HORZRES);
    vSize := GetDeviceCaps(DC, VERTSIZE);
    hSize := GetDeviceCaps(DC, HORZSIZE);
    ReleaseDC(NULL, DC);

    (* Compute (raster lines / decimeter) and (pixels / decimeter) *)

    AspectV := (LONGINT(VRes) * MMPERDM) DIV LONGINT(vSize);
    AspectH := (LONGINT(HRes) * MMPERDM) DIV LONGINT(hSize);

    CreateTools();

    (* Scale cosines for aspect ratio if this is the first instance *)

    IF bFirst = wTRUE THEN
    BEGIN
{	lpCirTab := GlobalLock(hCirTab);}
	pos := 0;
	WHILE pos < HANDPOSITIONS DO
	BEGIN
	    lpCirTab^[pos].y := VertEquiv(lpCirTab^[pos].y);
	    INC(pos);
	END;
{	GlobalUnlock(hCirTab);}
    END;

    GetTime(oTime);
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : CircleClock (int, int)                                      *
 *                                                                         *
 *  PURPOSE  : Resizes the clock rectangle to keep the face circular.      *
 *                                                                         *
 ***************************************************************************)

PROCEDURE CircleClock(maxWidth, maxHeight : INTEGER);
VAR
    clockHeight : INTEGER; (* tallest height that will keep face circular *)
    clockWidth : INTEGER;  (* widest width that will keep face circular   *)
BEGIN
    IF maxWidth > HorzEquiv(maxHeight) THEN
    BEGIN

	(* too wide -- decrease width to keep face circular *)

	clockWidth := HorzEquiv(maxHeight);
	ClockRect.left := ClockRect.left + ((maxWidth - clockWidth) DIV 2);
	ClockRect.right := ClockRect.left + clockWidth;
    END
    ELSE
    BEGIN

	(* too tall -- decrease height to keep face circular *)

	clockHeight := VertEquiv(maxWidth);
	ClockRect.top := ClockRect.top + ((maxHeight - clockHeight) DIV 2);
	ClockRect.bottom := ClockRect.top + clockHeight;
    END;
END;

(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockSize (HWND, int, int, WORD)                            *
 *                                                                         *
 *  PURPOSE  : Resize the clock to the largest possible circle that will   *
 *             fit in the client area. If switching from not iconic to     *
 *             iconic, alter the timer to update every minute.  And if     *
 *             switching back to non iconic, restore the timer to update   *
 *             every second.                                               *
 *                                                                         *
 ***************************************************************************)

PROCEDURE ClockSize(W : HWND;
		    newWidth, newHeight : INTEGER;
		    sizeType : WORD);
BEGIN

    (* Set ClockRect to bound the largest possible circle in the window *)

    SetRect(ClockRect, 0, 0, newWidth, newHeight);
    CircleClock(newWidth, newHeight);

    IF sizeType = SIZEICONIC THEN
    BEGIN

	(* Update once every minute in the iconic state *)

	KillTimer(W, TimerID);
	SetTimer(W, TimerID, ICON_TLEN, pointer(0));
	bIconic := wTRUE;
    END
    ELSE IF bIconic = wTRUE THEN
    BEGIN

	(* Update every second in the opened state (ignore tiling) *)

	KillTimer(W, TimerID);
	SetTimer(W, TimerID, OPEN_TLEN, pointer(0));
	bIconic := wFALSE;
    END;
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : DrawFace (HDC)                                              *
 *                                                                         *
 *  PURPOSE  : Draws the clock face.                                       *
 *                                                                         *
 ***************************************************************************)

PROCEDURE DrawFace(DC : hDC);
VAR
    pos : INTEGER;       (* hand position index into the circle table *)
    dotHeight : INTEGER; (* height of the hour-marking dot            *)
    dotWidth : INTEGER;  (* width of the hour-marking dot             *)
    dotCenter : POINT; (* center point of the hour-marking dot      *)
    rc : RECT;
BEGIN

    (* Compute hour-marking dot width, height, and center point *)

    dotWidth := (MAXDOTWIDTH * LONGINT(ClockRect.right - ClockRect.left)) DIV HRes;
    dotHeight := VertEquiv(dotWidth);

    IF dotHeight < MINDOTHEIGHT THEN
	dotHeight := MINDOTHEIGHT;

    IF dotWidth < MINDOTWIDTH THEN
	dotWidth := MINDOTWIDTH;

    dotCenter.x := dotWidth DIV 2;
    dotCenter.y := dotHeight DIV 2;

    (* Compute the clock center and radius *)

    InflateRect(ClockRect, -dotCenter.y, -dotCenter.x);
    ClockRadius := ((ClockRect.right - ClockRect.left) DIV 2);
    ClockCenter.x := ClockRect.left + ClockRadius;
    ClockCenter.y := ClockRect.top + ((ClockRect.bottom - ClockRect.top) DIV 2);
    InflateRect(ClockRect, dotCenter.y, dotCenter.x);

    (* Draw the large hour-marking dots and small minute-marking dots *)

    FOR pos := 0 TO HANDPOSITIONS-1 DO
    BEGIN
	rc.top := (lpCirTab^[pos].y * ClockRadius) DIV CIRTABSCALE + ClockCenter.y;
	rc.left := (lpCirTab^[pos].x * ClockRadius) DIV CIRTABSCALE + ClockCenter.x;
	IF (pos MOD 5) <> 0 THEN
	BEGIN
	    IF ((dotWidth > MINDOTWIDTH) AND (dotHeight > MINDOTHEIGHT)) THEN
	    BEGIN

		(* Draw small minute-marking dot *)

		rc.right := rc.left + 1;
		rc.bottom := rc.top + 1;
		FillRect(DC, rc, hbrForegnd);
	    END;
	END
	ELSE
	BEGIN

	    (* Draw large hour-marking dot *)

	    rc.right := rc.left + dotWidth;
	    rc.bottom := rc.top + dotHeight;
	    OffsetRect(rc, -dotCenter.x, -dotCenter.y);
	    FillRect(DC, rc, hbrForegnd);
	END;
    END;
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : DrawHand (HDC, int, HPEN, int, int)                         *
 *                                                                         *
 *  PURPOSE  : Draws a thin hand with the specified pen in the specified   *
 *             hand position.                                              *
 *                                                                         *
 ***************************************************************************)

PROCEDURE DrawHand(DC : HDC; pos : INTEGER; Pen : HPEN; scale, patMode : INTEGER);
VAR
    radius : LONGINT;
BEGIN
    (* scale length of hand *)

    radius := (ClockRadius * scale) DIV 100;

    (* set pattern mode for hand *)

    SetROP2(DC, patMode);

    (* select pen for hand *)

    SelectObject(DC, Pen);

    (* Draw thin hand *)

    MoveTo(DC, ClockCenter.x, ClockCenter.y);
    LineTo(DC, ClockCenter.x + ((lpCirTab^[pos].x * radius) DIV CIRTABSCALE),
	    ClockCenter.y + ((lpCirTab^[pos].y * radius) DIV CIRTABSCALE));
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : DrawFatHand (HDC, int, HPEN, BOOL)                          *
 *                                                                         *
 *  PURPOSE  : Draws a fat hand with the specified pen in the specified    *
 *             hand position.                                              *
 *                                                                         *
 ***************************************************************************)

PROCEDURE DrawFatHand(DC : HDC; pos : INTEGER; Pen : HPEN; whichHand : BOOL);
VAR
    ptTip : POINT;  (* coordinates for the tip of the hand        *)
    ptTail : POINT; (* coordinates for the tail of the hand       *)
    ptSide : POINT; (* coordinates for the side of the hand       *)
    index : INTEGER;  (* position index into the circle table       *)
    scale : LONGINT;  (* ClockRadius percentage to scale drawing to *)
BEGIN
    (* set pattern mode for hand *)

    SetROP2(DC, 13);

    (* select pen for hand *)

    SelectObject(DC, Pen);

    (* compute coordinates for the side of the hand *)

    IF whichHand = wTRUE THEN
	whichHand := HOURSIDE
    ELSE
	whichHand := MINUTESIDE;
	
    scale := (ClockRadius * whichHand) DIV 100;
    index := (pos + SIDESHIFT) MOD HANDPOSITIONS;
    ptSide.y := (lpCirTab^[index].y * scale) DIV CIRTABSCALE;
    ptSide.x := (lpCirTab^[index].x * scale) DIV CIRTABSCALE;

    (* compute coordinates for the tip of the hand *)

    IF whichHand = wTRUE THEN
	whichHand := HOURTIP
    ELSE
	whichHand := MINUTETIP;
	
    scale := (ClockRadius * whichHand) DIV 100;
    ptTip.y := (lpCirTab^[pos].y * scale) DIV CIRTABSCALE;
    ptTip.x := (lpCirTab^[pos].x * scale) DIV CIRTABSCALE;

    (* compute coordinates for the tail of the hand *)

    IF whichHand = wTRUE THEN
	whichHand := HOURTAIL
    ELSE
	whichHand := MINUTETAIL;
	
    scale := (ClockRadius * whichHand) DIV 100;
    index := (pos + TAILSHIFT) MOD HANDPOSITIONS;
    ptTail.y := (lpCirTab^[index].y * scale) DIV CIRTABSCALE;
    ptTail.x := (lpCirTab^[index].x * scale) DIV CIRTABSCALE;

    (* Draw tip of hand *)

    MoveTo(DC, ClockCenter.x + ptSide.x, ClockCenter.y + ptSide.y);
    LineTo(DC, ClockCenter.x +  ptTip.x, ClockCenter.y +  ptTip.y);
    MoveTo(DC, ClockCenter.x - ptSide.x, ClockCenter.y - ptSide.y);
    LineTo(DC, ClockCenter.x +  ptTip.x, ClockCenter.y +  ptTip.y);

    (* Draw tail of hand *)

    MoveTo(DC, ClockCenter.x + ptSide.x, ClockCenter.y + ptSide.y);
    LineTo(DC, ClockCenter.x + ptTail.x, ClockCenter.y + ptTail.y);
    MoveTo(DC, ClockCenter.x - ptSide.x, ClockCenter.y - ptSide.y);
    LineTo(DC, ClockCenter.x + ptTail.x, ClockCenter.y + ptTail.y);
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockPaint (HWND, HDC, int)                                 *
 *                                                                         *
 *  PURPOSE  : Paint the clock to display the most recent time.            *
 *                                                                         *
 ***************************************************************************)

PROCEDURE ClockPaint(W : HWND; DC : HDC; paintType : INTEGER);
VAR
    nTime : TIME;
BEGIN
    SetBkMode(DC, TRANSPARENT);

{    lpCirTab := GlobalLock(hCirTab);}

    IF paintType = PAINTALL THEN
    BEGIN

	(* Paint entire clock -- face and hands *)

	FillRect(DC, ClockRect, hbrBackgnd);
	DrawFace(DC);
	DrawFatHand(DC, HourHandPos(oTime), hpenForegnd, HHAND);
	DrawFatHand(DC, oTime.minute, hpenForegnd, MHAND);
	IF bIconic = wFALSE THEN
	BEGIN

	    (* Erase old second hand *)

	    DrawHand(DC, oTime.second, hpenBackgnd, SECONDTIP, R2_NOT);
	END;
    END
    ELSE IF paintType = HANDPAINT THEN
    BEGIN
	GetTime(nTime);

	IF ((bIconic = wFALSE) AND (nTime.second <> oTime.second)) THEN
	    (* Second has changed -- erase old second hand *)
	    DrawHand(DC, oTime.second, hpenBackgnd, SECONDTIP, R2_NOT);

	IF ((nTime.minute <> oTime.minute) OR (nTime.hour <> oTime.hour)) THEN
	BEGIN

	    (* Hour and/or minute have changed -- update hands *)

	    IF bIconic = wTRUE THEN
	    BEGIN

		(* Erase old minute and hour hands *)

		DrawHand(DC, oTime.minute,
			 hpenBackgnd, MINUTETIP, R2_COPYPEN);
		DrawHand(DC, HourHandPos(oTime),
			 hpenBackgnd, HOURTIP, R2_COPYPEN);

		(* Draw new minute and hour hands *)

		DrawHand(DC, nTime.minute,
			 hpenForegnd, MINUTETIP, R2_COPYPEN);
		DrawHand(DC, HourHandPos(nTime),
			 hpenForegnd, HOURTIP, R2_COPYPEN);
			
	    END
	    ELSE
	    BEGIN

		(* Erase old minute and hour fat hands *)

		DrawFatHand(DC, oTime.minute,
			    hpenBackgnd, MHAND);
		DrawFatHand(DC, HourHandPos(oTime),
			    hpenBackgnd, HHAND);

		(* Draw new minute and hour fat hands *)

		DrawFatHand(DC, nTime.minute,
			    hpenForegnd, MHAND);
		DrawFatHand(DC, HourHandPos(nTime),
			    hpenForegnd, HHAND);
	    END;
	END;

	IF ((bIconic = wFALSE) AND (nTime.second <> oTime.second)) THEN

	    (* second has changed -- draw new second hand *)

	    DrawHand(DC, nTime.second, hpenBackgnd, SECONDTIP, R2_NOT);

	(* Store most recent time *)

	oTime.minute := nTime.minute;
	oTime.hour   := nTime.hour;
	oTime.second := nTime.second;
    END;
{    GlobalUnlock(hCirTab);}
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockTimer (HWND)                                           *
 *                                                                         *
 *  PURPOSE  : Update the clock to reflect the most recent time.           *
 *                                                                         *
 ***************************************************************************)

PROCEDURE ClockTimer(W : HWND);
VAR
    nTime : TIME;
    DC : HDC;
BEGIN
    GetTime(nTime);

    (* It's possible to change any part of the system at any time through *)
    (* the Control Panel. Check for any change in second, minute, or hour *)

    IF ((nTime.second <> oTime.second) OR
	(nTime.minute <> oTime.minute) OR
	(nTime.hour   <> oTime.hour)) THEN
    BEGIN

	(* The time has changed -- update the clock *)

	DC := GetDC(Wnd);
	ClockPaint(W, DC, HANDPAINT);
	ReleaseDC(W, DC);
    END;
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : About (HWND, unsigned, WORD, LONG)                          *
 *                                                                         *
 *  PURPOSE  : Dialog function for the "About..." menu item dialog.        *
 *                                                                         *
 ***************************************************************************)

FUNCTION About(hDlg : HANDLE;
		message : WORD;
		wParam : WORD;
		lParam : LONGINT) : BOOL [WINDOWS];
		FAR; PUBLIC 'About';
BEGIN
    About := wTRUE;
    CASE message OF
	WM_INITDIALOG:;
	WM_COMMAND:
	    EndDialog(hDlg, wTRUE);
    ELSE
	About := wFALSE;
    END;
END;


(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockWndProc (HWND, unsigned, WORD, LONG)                   *
 *                                                                         *
 *  PURPOSE  : Window function for the application.                        *
 *                                                                         *
 ***************************************************************************)

FUNCTION ClockWndProc(wnd : HWND;
			message : WORD;
			wParam : WORD;
			lParam : LONGINT) : DWORD [WINDOWS];
			FAR; PUBLIC 'ClockWndProc';
VAR
    ps : PAINTSTRUCT;
    rc : RECT;
BEGIN
    ClockWndProc := 0;

    CASE message OF
	WM_SYSCOMMAND:
	BEGIN
	    IF wParam = IDM_ABOUT THEN

		(* Draw and handle messages for the "About..." Dialog *)

		DialogBox(hInstance,
			  MAKEINTRESOURCE(1),
			  wnd,
			  MakeProcInstance(@About, hInstance)
			  )
	    ELSE

		(* Perform the default window processing *)

		ClockWndProc := DefWindowProc(wnd, message, wParam, lParam);
	END;

	WM_SIZE:
	BEGIN

	    (* Resize clock based on window size and redraw *)

	    ClockSize(wnd, LOWORD(lParam), HIWORD(lParam), wParam);
	    UpdateWindow(wnd);
	END;

	WM_DESTROY:
	BEGIN

	    (* Destroy clock's timer and tools before exiting *)

	    KillTimer(wnd, TimerID);
	    DeleteTools();
	    PostQuitMessage(0);
	END;

	WM_PAINT:
	BEGIN

	    (* Paint clock displaying current time *)

	    InvalidateRect(wnd, nullrect, wTRUE);
	    BeginPaint(wnd, ps);
	    ClockPaint(wnd, ps.hdc, PAINTALL);
	    EndPaint(wnd, ps);
	END;

	WM_TIMECHANGE, WM_TIMER:

	    (* Update clock to display new time *)

	    ClockTimer(wnd);

	WM_SYSCOLORCHANGE:
	BEGIN

	    (* Change tools to coincide with system window colors *)

	    DeleteTools();
	    CreateTools();
	END;

	WM_ERASEBKGND:
	BEGIN

	    (* Paint over the entire client area *)

	    GetClientRect(wnd, rc);
	    FillRect(wParam, rc, hbrBackgnd);
	END;
    ELSE

	(* Perform the default window processing *)

	ClockWndProc := DefWindowProc(wnd, message, wParam, lParam);
    END;
END;

(***************************************************************************
 *                                                                         *
 *  FUNCTION : ClockInit ()                                                *
 *                                                                         *
 *  PURPOSE  : Registers the applicatoin windwo class and initializes the  *
 *             circle values for the clock face.                           *
 *                                                                         *
 ***************************************************************************)

FUNCTION ClockInit() : BOOLEAN;
VAR
    hResource : HANDLE;
    szData : ARRAY [0..5] OF CHAR;
    ClockClass : WNDCLASS;
BEGIN
    ClockInit := FALSE;
    
    ClockClass.lpszClassName := @szBuffer;
    ClockClass.hbrBackground := NULL;
    ClockClass.style         := CS_VREDRAW + CS_HREDRAW + CS_BYTEALIGNCLIENT;
    ClockClass.hInstance     := hInstance;
    ClockClass.lpfnWndProc   := @ClockWndProc;
    ClockClass.hCursor       := LoadCursor(NULL, IDC_ARROW);
    ClockClass.hIcon         := NULL;
    
    (* added in conversion from C *)
    
    ClockClass.cbclsextra := 0;
    ClockClass.cbwndextra := 0;
    ClockClass.lpszmenuname := pointer(NULL);

    IF RegisterClass(ClockClass) = wFALSE THEN

	(* Error registering class -- return *)

	EXIT;

    (* Load in pre-computed circle table cosine values from resource file *)

    LoadString(hInstance, IDS_DATA, @szData, 5);
    hResource := FindResource(hInstance, @szBuffer, @szData);
    IF hResource = wFALSE THEN

	(* Could not find circle table resource data -- return *)

	EXIT;

    hCirTab := LoadResource(hInstance, hResource);
    lpCirTab := LockResource(hCirTab);

    ClockInit := TRUE;
END;

BEGIN
    LoadString(hInstance, IDS_APPNAME, @szBuffer, BUFLEN);

    IF hPrevInst = wFALSE THEN
    BEGIN

	(* First instance -- register window class *)

	IF NOT ClockInit() THEN
	BEGIN
	    HALT(1);
	END;
    END
    ELSE
    BEGIN

	(* Not first instance -- get circle table and reset bFirst flag *)

	GetInstanceData(hPrevInst, hCirTab, sizeof(HANDLE));
	bFirst := wFALSE;
    END;

    ClockCreate();

    (* compute window height and width *)

    sysWidth  := GetSystemMetrics(SM_CXFRAME) * 2;
    sysHeight := GetSystemMetrics(SM_CYCAPTION) + (GetSystemMetrics(SM_CYFRAME) * 2);
    width := (HRes DIV 3) + sysWidth;
    height := VertEquiv(width) + sysHeight;

    Wnd := CreateWindow( @szBuffer, (* class name              *)
			 @szBuffer, (* The window name         *)
			 WS_TILEDWINDOW,   (* window style            *)
			 CW_USEDEFAULT,    (* use default positioning *)
			 0,                (* y not used              *)
			 width,            (* window width            *)
			 height,           (* window height           *)
			 NULL,             (* NULL parent handle      *)
			 NULL,             (* NULL menu/child handle  *)
			 hInstance,            (* program instance        *)
			 pointer(NULL)     (* NULL data structure ref.*)
		       );

    GetTime(nTime);
    GetTime(oTime);
    WHILE ((nTime.second = oTime.second) AND
	   (nTime.minute = oTime.minute) AND
	   (nTime.hour   = oTime.hour)     ) DO
	GetTime(oTime);

    IF SetTimer(Wnd, TimerID, OPEN_TLEN, pointer(0)) = wFALSE THEN
    BEGIN

	(* 16 public timers already in use -- post error and exit *)

	pszTooMany := Ptr(Seg(szBuffer), LocalAlloc(LPTR, 40));
	LoadString(hInstance, IDS_TOOMANY, pszTooMany, 40);
	MessageBox(NULL, pszTooMany, @szBuffer,
		   MB_OK + MB_ICONHAND + MB_SYSTEMMODAL);
	DeleteTools();
	HALT(1);
    END;

    (* Add the "About..." menu item to the bottom of the system menu *)

    LoadString(hInstance, IDS_ABOUTMENU, @szBuffer, BUFLEN);
    Menu := GetSystemMenu(Wnd, wFALSE);
    ChangeMenu(Menu, 0, @szBuffer, IDM_ABOUT, MF_APPEND + MF_STRING);

    ShowWindow(Wnd, cmdShow);

    (* Process messages until program termination *)

    WHILE GetMessage(mess, NULL, 0, 0) > wFALSE DO
    BEGIN
	TranslateMessage(mess);
	DispatchMessage(mess);
    END;

END.
