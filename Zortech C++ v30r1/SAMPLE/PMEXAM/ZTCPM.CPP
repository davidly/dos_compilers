// ZTCPM.CPP -- A C++/PM Demo Program
//
// This is a simple demonstration, it is not particularly elegant or useful!
// to aid presentation there is no header file. Ideally the class definition
// would be in it...
//

#define INCL_WIN
#include <os2.h>
#include <string.h>

// typedef for a pointer to a windows export function
typedef MRESULT (EXPENTRY * PCP)(HWND, USHORT, MPARAM, MPARAM);

// where we've stored the 'this' pointer
#define QWP_THIS 0

// a (very) basic PM window class
class Window {
	HAB hab;
	HWND Parent;
	BYTE *ClientClass;
	PCP ClientProc;
	HWND hwndFrame;
	HWND hwndClient;
    ULONG FrameFlags;
public:
	Window(HAB h, char *name, PCP cwp, HWND Parent = HWND_DESKTOP);
	void Open(ULONG style, ULONG fcf);
	void Close()   { WinDestroyWindow(hwndFrame); }
	void Write(char *text);
	~Window() { delete ClientClass; }
};

// The export function prototype(the extern is not strictly needed
// in v2.06) but it aids clarity.
extern "Pascal" MRESULT EXPENTRY ClientWndProc(HWND, USHORT, MPARAM, MPARAM);

int main (void)
{
    HAB hab;
    HMQ hmq;
    QMSG qmsg ;
    
    hab = WinInitialize(0);
    hmq = WinCreateMsgQueue(hab, 0) ;
     
    Window Client(hab,"ztcpm", ClientWndProc);
   
    Client.Open(WS_VISIBLE , FCF_TITLEBAR | FCF_SYSMENU |  FCF_SIZEBORDER
	       			| FCF_MINMAX  | FCF_SHELLPOSITION | FCF_TASKLIST);
         			
    while (WinGetMsg(hab, &qmsg, NULL, 0, 0))
        WinDispatchMsg(hab, &qmsg) ;

    Client.Close();
     
    WinDestroyMsgQueue(hmq) ;
	WinTerminate(hab);
    return 0 ;
}

MRESULT EXPENTRY ClientWndProc(HWND hwnd, USHORT msg, MPARAM mp1, MPARAM mp2)
{
    static CHAR Text [] = "Here is a C++ program that uses Presentation Manager";

	// get the object which is using this export
	// a pointer to it is stashed in the window
	// reserved data space
	
	Window *me;
	me = (Window *) WinQueryWindowPtr(hwnd,QWP_THIS);

    if (msg == WM_PAINT) {
			me->Write(Text);
            return 0;
    }
    return WinDefWindowProc(hwnd, msg, mp1, mp2);
}

// This constructor simply registers the client class

Window::Window(HAB h, char *name, PCP pcp, HWND p)
{
	hab = h;
	Parent = p;
	ClientProc = pcp;

	ClientClass = new BYTE[strlen(name)+1];
	strcpy((char *) ClientClass, name);

	// register the class, reserve some space for the 'this' pointer
    WinRegisterClass(hab, ClientClass, ClientProc, 0L, sizeof(PVOID));
}

// Opens the window

void Window::Open(ULONG style, ULONG fcf)
{
    FrameFlags = fcf;

    hwndFrame = WinCreateStdWindow(Parent, style, &FrameFlags,
			                    ClientClass, NULL, 0L, NULL, 0, &hwndClient); 

	// put the this pointer in the client window reserved data
	WinSetWindowPtr(hwndClient,QWP_THIS,this);
    WinSendMsg(hwndFrame, WM_SETICON,
                 WinQuerySysPointer(Parent, SPTR_APPICON, FALSE),
                 NULL) ;
}

void Window::Write(char *text)
{
    HPS hps;
    RECTL rectl;

    hps = WinBeginPaint(hwndClient, NULL, NULL);
    WinQueryWindowRect(hwndClient, &rectl);
    WinDrawText(hps, -1, (BYTE *) text, &rectl, CLR_NEUTRAL, CLR_BACKGROUND,
                DT_CENTER | DT_VCENTER | DT_ERASERECT);

    WinEndPaint(hps);
}
     

