PROGRAM Generic;
{$X+}

USES Windows;

CONST

  (* ID of "About" dialog. Must also define this in resource file. *)

  IDM_ABOUT = 100;

(* "About" box message processing *)

FUNCTION About (        hDlg : HWND;
		 wMsg, wParam : WORD;
		 lParam : LONGINT) : BOOL [WINDOWS];
		 FAR; PUBLIC 'About';
BEGIN
    About := wFALSE;
    CASE wMsg OF
    WM_INITDIALOG:
	About := wTRUE;
    WM_COMMAND:
	IF (wParam = IDOK) OR (wParam = IDCANCEL) THEN
	BEGIN
	    EndDialog(hDlg, wTRUE);
	    About := wTRUE;
	END;
    END;
END;

(* This is the windows procedure.  Windows automatically calls this *)
(* procedure whenever the window needs repainting, among other things *)

FUNCTION MainWndProc (Wnd : HWND;
			wMsg, wParam : WORD;
			lParam : LONGINT) : DWORD [WINDOWS];
			FAR; PUBLIC 'MainWndProc';
CONST
    aboutstr : ARRAY [0..8] OF CHAR = 'AboutBox' + #0;
VAR
    lpProcDialog : POINTER;
BEGIN
    MainWndProc := 0;
    CASE wMsg OF
    WM_COMMAND:
    BEGIN
	IF wParam = IDM_ABOUT THEN
	BEGIN
	    lpProcDialog := MakeProcInstance(@About, hInstance);
	    DialogBox(hInstance, @aboutstr, Wnd, lpProcDialog);
	    FreeProcInstance(lpProcDialog);
	END
	ELSE
	    MainWndProc := DefWindowProc(Wnd, wMsg, wParam, lParam);
    END;
    
    WM_DESTROY:
	PostQuitMessage(0);

    ELSE
	MainWndProc := DefWindowProc(Wnd, wMsg, wParam, lParam);
    END;
END;

(* The following application creates the window class shared by
   all instances of the program. Several instances might be running
   at once, so this procedure is only called by the first to run. *)

FUNCTION InitApplication() : BOOL;
CONST
    menuName : ARRAY [0..11] OF CHAR = 'GenericMenu' + #0;
    wClassname : ARRAY [0..13] OF CHAR = 'GenericWClass' + #0;
    iconname : ARRAY [0..11] OF CHAR = 'GenericIcon' + #0;
VAR
    wClass : WNDCLASS;
BEGIN
    WITH wClass DO
    BEGIN
	style := NULL;
	lpfnWndProc := @MainWndProc;
	cbClsExtra := 0;
	cbWndExtra := 0;
	hCursor := LoadCursor(NULL, IDC_ARROW);
	hbrBackground := GetStockObject(WHITE_BRUSH);
	lpszMenuName := @menuName;
	lpszClassName := @wClassname;
    END;
    wClass.hIcon := LoadIcon(hInstance, @iconname);
    wClass.hInstance := hInstance;
    InitApplication := RegisterClass(wClass);
END;

(* The following procedure creates the data structures and main window
   for a specific instance of the application. *)

FUNCTION InitInstance() : BOOL;
CONST
    wndClass : ARRAY [0..13] OF CHAR = 'GenericWClass' + #0;
    pname : ARRAY [0..26] OF CHAR = 'Generic Sample Application' + #0;
VAR
    Wnd : HWND;
BEGIN
    InitInstance :=  wFALSE;
    Wnd := CreateWindow(
		    @wndClass,
		    @pname,
		    WS_OVERLAPPEDWINDOW,
		    CW_USEDEFAULT,
		    CW_USEDEFAULT,
		    CW_USEDEFAULT,
		    CW_USEDEFAULT,
		    NULL,
		    NULL,
		    hInstance,
		    POINTER(0));

    IF hInstance = NULL THEN
	EXIT;

    ShowWindow(Wnd, CmdShow);
    UpdateWindow(Wnd);
    InitInstance := wTRUE;
END;

VAR
    Mess    : MSG;

BEGIN

    (* Register the window class if we are the first instance to run *)

    IF hPrevInst = NULL THEN
	IF InitApplication() = wFALSE THEN
	    HALT;

    (* Create the main window *)

    IF InitInstance() = wFALSE THEN
	HALT;

    WHILE GetMessage(Mess, NULL, NULL, NULL) > wFALSE DO
    BEGIN
	TranslateMessage(mess);
	DispatchMessage(mess);
    END;
END.
