// mulmix.c
// Mixed-language program example for demonstrating
// Windows support in Microsoft FORTRAN 5.1

#include "windows.h"
#include "mulmix.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


HANDLE hInst;
long dNums[2];
BOOL   bNumsOK[2] = {FALSE, FALSE};

int PASCAL WinMain( HANDLE hInstance,     // current instance
                    HANDLE hPrevInstance, // previous instance
                    LPSTR lpCmdLine,      // command line
                    int nCmdShow )        // show-window type (open/icon)
{
    MSG msg;

    if (!hPrevInstance)                  // Other instances of app running?
        if (!InitApplication(hInstance)) // Initialize shared things
            return (FALSE);              // Exit if unable to initialize

    // Perform initializations that apply to a specific instance

    if (!InitInstance( hInstance, nCmdShow ))
        return( FALSE );

    // Get, translate, and dispatch messages until WM_QUIT is received

    while( GetMessage( &msg,    // Message structure
                       NULL,    // Handle of window receiving the message
                       NULL,    // Lowest message to examine
                       NULL ) ) // Highest message to examine
    {
        TranslateMessage( &msg );    // Translates virtual key codes
        DispatchMessage( &msg );     // Dispatches message to window
    }
    return( msg.wParam );       // Returns the value from PostQuitMessage
} // WinMain

// Function: InitApplication
// Initialize the application: fill in the window-class structure
// and register the window class. Return TRUE on success, FALSE
// on failure.

BOOL InitApplication( HANDLE hInstance )        // current instance
{
    WNDCLASS  wc;

    // Fill in window class structure with parameters that describe the
    // main window.

    wc.style = NULL;                    // Class style(s).
    wc.lpfnWndProc = MainWndProc;       // Function to retrieve messages for
                                        //     windows of this class.
    wc.cbClsExtra = 0;                  // No per-class extra data.
    wc.cbWndExtra = 0;                  // No per-window extra data.
    wc.hInstance = hInstance;           // Application that owns the class.
    wc.hIcon = LoadIcon( NULL, IDI_APPLICATION );
    wc.hCursor = LoadCursor( NULL, IDC_ARROW );
    wc.hbrBackground = GetStockObject( WHITE_BRUSH );
    wc.lpszMenuName =  "MulMixMenu";   // Name of menu resource in .RC file.
    wc.lpszClassName = "MulMixWinClass"; // Name used in call to CreateWindow.

    // Register the window class and return success/failure code.

    return ( RegisterClass( &wc ) );

} // InitApplication


// Function: InitInstance
// Save the instance handle and create the main window for this instance.

BOOL InitInstance( HANDLE hInstance, // Current instance identifier.
                   int nCmdShow )     // Param for first ShowWindow() call.
{
    HWND hWnd;               // Main window handle.
    // Save the instance handle in a static variable, which will be used in
    // many subsequent calls from this application to Windows.

    hInst = hInstance;

    // Create a main window for this application instance.

    hWnd = CreateWindow(
        "MulMixWinClass",               // See RegisterClass() call.
        "FORTRAN 5.1 Mixed-Language Example",   // Text for window title bar.
        WS_OVERLAPPEDWINDOW,            // Window style.
        CW_USEDEFAULT,                  // Default horizontal position.
        CW_USEDEFAULT,                  // Default vertical position.
        CW_USEDEFAULT,                  // Default width.
        CW_USEDEFAULT,                  // Default height.
        NULL,                           // Overlapped windows have no parent.
        NULL,                           // Use the window class menu.
        hInstance,                      // This instance owns this window.
        NULL                            // Pointer not needed.
    );

    // If window could not be created, return "failure"

    if( !hWnd )
        return( FALSE );

    // Make the window visible; update its client area; and return "success"

    ShowWindow( hWnd, nCmdShow );  // Show the window
    UpdateWindow( hWnd );          // Sends WM_PAINT message
    return( TRUE );                // Returns the value from PostQuitMessage

} // InitInstance


// Function: MainWndProc
// Process messages sent to the main window. Display results
// when user clicks the "Ok" button on the "Multiply" dialog box.

long FAR PASCAL MainWndProc( HWND     hWnd,    // window handle
                             unsigned message, // type of message
                             WORD     wParam,  // additional information
                             LONG     lParam ) // additional information
{
    FARPROC lpProc;          // pointer to dialog-box functions
    long dResult;
    BOOL bReadyToGo;

    switch( message )
    {
    case WM_COMMAND:       // message: command from application menu
        switch( wParam )
        {
        case IDM_ABOUT:
            lpProc = MakeProcInstance( AboutBoxFunc, hInst );
            DialogBox( hInst,         // current instance
                       "AboutBox",    // resource to use
                       hWnd,          // parent handle
                       lpProc );      // AboutBoxFunc() instance address
            FreeProcInstance(lpProc);
            break;

        case IDM_MULTIPLY:
            lpProc = MakeProcInstance( MultiplyBoxFunc, hInst );
            bReadyToGo = DialogBox( hInst,         // current instance
                                    "MultiplyBox", // resource to use
                                    hWnd,          // parent handle
                                    lpProc );      // MultiplyBoxFunc() instance address
            FreeProcInstance( lpProc );
            if( bReadyToGo )
            {   // Show the result
                mul( dNums[0], dNums[1] );
            }
            break;

        default:                // Let Windows process it
            return( DefWindowProc( hWnd, message, wParam, lParam ) );
        } // switch( wParam )
        break;

    case WM_DESTROY:          // message: window being destroyed
        PostQuitMessage( 0 );
        break;

    default:              // Passes message on if unproccessed
        return( DefWindowProc( hWnd, message, wParam, lParam ) );
    }
    return( NULL );
} // MainWndProc


// Function: AboutBoxFunc
// Process messages sent to the "About MulMix..." dialog box.

BOOL FAR PASCAL AboutBoxFunc(
                      HWND hDlg,        // window handle of the dialog box
                      unsigned message, // type of message
                      WORD     wParam,  // message-specific information
                      LONG     lParam )
{
    switch( message )
    {

    case WM_INITDIALOG:             // message: initialize dialog box
        return( TRUE );

    case WM_COMMAND:                      // message: received a command
        if( wParam == IDOK                // "OK" box selected?
            || wParam == IDCANCEL)        // System menu close command?
        {
            EndDialog( hDlg, TRUE );      // Exits the dialog box
            return( TRUE );
        }
    break;
    }
    return( FALSE );               // Didn't process a message
} // AboutBoxFunc


// Function: MultiplyBoxFunc
// Process messages sent to the "Multiply" dialog box. When
// user's input is valid, stuff values into the global variables
// dNums[0] and dNums[1].

BOOL FAR PASCAL MultiplyBoxFunc(
                    HWND hDlg,        // window handle of the dialog box
                    unsigned message, // type of message
                    WORD     wParam,  // message-specific information
                    LONG     lParam )
{
    DWORD nNumChars;
    int n;
    char szBuffer[BUFFERSIZE];
    char * pc;

    switch( message )
    {
    case WM_INITDIALOG:             // message: initialize dialog box
        for ( n = 0; n <= 1; n++ )
        {
            if( bNumsOK[n] )
            {
                sprintf(szBuffer, "%ld", dNums[n]);
                SetDlgItemText( hDlg, ID_MULT_NUM1 + n, szBuffer );
            }
        }

        // disable the "OK" button unless both numbers are valid
        EnableWindow( GetDlgItem( hDlg, IDOK ), bNumsOK[0] && bNumsOK[1] );
        return( TRUE );

    case WM_COMMAND:        // message: received a command
        switch( wParam )    // wParam is ID of control
        {
        case ID_MULT_NUM1:
        case ID_MULT_NUM2:

            if( HIWORD( lParam ) == EN_KILLFOCUS      // notification code
                || HIWORD( lParam ) == EN_UPDATE)
            {

                szBuffer[0] = (char)BUFFERSIZE - 1;

                // Which edit control is it?
                n = ( wParam == ID_MULT_NUM1 ) ? 0 : 1;

                // Copy edit-control contents to szBuffer
                nNumChars = SendMessage( (HWND) LOWORD( lParam ),
                                         EM_GETLINE,
                                         0, (LONG)(LPSTR)szBuffer );

                if( nNumChars )
                {
                    dNums[n] = strtol( szBuffer, &pc, 10 );
                    bNumsOK[n] = (*pc == '\0') || (*pc == ' ');
                }
                else
                {
                    bNumsOK[n] = FALSE;
                }

                // disable the "OK" button unless both numbers are valid
                EnableWindow( GetDlgItem( hDlg, IDOK ),
                              bNumsOK[0] && bNumsOK[1] );
                return( bNumsOK[0] && bNumsOK[1] );
            }
            else
            {
                return( FALSE );
            }
        case IDOK:       // "OK" box selected?
            EndDialog( hDlg, TRUE );  // Exits the dialog box
            return( TRUE );
        case IDCANCEL:   // System menu Close command or Cancel button?
            EndDialog( hDlg, FALSE );  // Exits the dialog box
            return( FALSE );
        }
        break;
    }
    return( FALSE );               // Didn't process a message
} // MultiplyBoxFunc
