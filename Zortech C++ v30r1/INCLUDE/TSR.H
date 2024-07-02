/*
                           HEADER FILE
                   Zortech C and C++ TSR Toolkit 
             (c)1989 Zortech Ltd, Written by Kevin Powis
*/

#ifndef	__TSR_H
#define __TSR_H

#define POPONLY   0
#define TIMESLICE 1
#define TSR_DEBUG 2

/*      SCAN CODES FOR KEYS A-Z        */
#define NO_SCAN 0
#define SCAN_Q 16
#define SCAN_W 17
#define SCAN_E 18
#define SCAN_R 19
#define SCAN_T 20
#define SCAN_Y 21
#define SCAN_U 22
#define SCAN_I 23
#define SCAN_O 24
#define SCAN_P 25
#define SCAN_A 30
#define SCAN_S 31
#define SCAN_D 32
#define SCAN_F 33
#define SCAN_G 34
#define SCAN_H 35
#define SCAN_J 36
#define SCAN_K 37
#define SCAN_L 38
#define SCAN_Z 44
#define SCAN_X 45
#define SCAN_C 46
#define SCAN_V 47
#define SCAN_B 48
#define SCAN_N 49
#define SCAN_M 50

#define SCAN_F1 59     /* Function keys */
#define SCAN_F2 60
#define SCAN_F3 61
#define SCAN_F4 62
#define SCAN_F5 63
#define SCAN_F6 64
#define SCAN_F7 65
#define SCAN_F8 66
#define SCAN_F9 67
#define SCAN_F10 68

/*      VALUES FOR SHIFT KEYS           */

#define RSHIFT 1
#define LSHIFT 2
#define CTRL   4
#define ALT    8


/*      FUNCTION PROTOTYPES             */

#if __cplusplus
	extern "C" {
#endif

int _cdecl tsr_install(int);
int _cdecl tsr_uninstall(void);
void _cdecl tsr_service(void);
void _cdecl popmain(void);
extern int _cdecl _tsr_debug;

#if __cplusplus
	}
#endif

int _cdecl _okbigbuf;

#endif

