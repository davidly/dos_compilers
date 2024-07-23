#define BUFFERSIZE 32

#define IDM_ABOUT    100
#define IDM_MULTIPLY (IDM_ABOUT+1)
#define ID_MULT_NUM1 (IDM_MULTIPLY+1)
#define ID_MULT_NUM2 (ID_MULT_NUM1+1)


int PASCAL WinMain( HANDLE, HANDLE, LPSTR, int );
BOOL InitApplication( HANDLE );
BOOL InitInstance( HANDLE, int );
long FAR PASCAL MainWndProc( HWND, unsigned, WORD, LONG );
BOOL FAR PASCAL AboutBoxFunc( HWND, unsigned, WORD, LONG );
BOOL FAR PASCAL MultiplyBoxFunc( HWND, unsigned, WORD, LONG );
void _fortran mul( long, long );
