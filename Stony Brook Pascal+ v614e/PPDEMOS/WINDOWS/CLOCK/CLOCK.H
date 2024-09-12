/****************************************************************************
 *									    *
 *  FILE	: Clock.h                                                   *
 *									    *
 *  DESCRIPTION : Header file for the Clock sample application.             *
 *									    *
 ****************************************************************************/

#define BUFLEN        30 /* name buffer length */

#define MAXDOTWIDTH   25 /* maximum hour-marking dot width  */
#define MINDOTWIDTH   2  /* minimum hour-marking dot width  */
#define MINDOTHEIGHT  1  /* minimum hour-marking dot height */

/* Defines for menu items */
#define IDM_ABOUT     1001
#define IDS_ABOUTMENU 1
#define IDS_APPNAME   2
#define IDS_DATA      3
#define IDS_TOOMANY   4

/* hand and paint flags */
#define HHAND         TRUE
#define MHAND         FALSE
#define PAINTALL      0
#define HANDPAINT     1

/* timer interval when the clock window is ...            */
#define OPEN_TLEN     450    /* ... open   (every second) */
#define ICON_TLEN     59000  /* ... iconic (every minute) */

/* distance from the center of the clock to ...                 */
#define HOURSIDE      7   /* ... either side of the hour hand   */
#define MINUTESIDE    5   /* ... either side of the minute hand */
#define HOURTIP       65  /* ... the tip of the hour hand       */
#define MINUTETIP     80  /* ... the tip of the minute hand     */
#define SECONDTIP     80  /* ... the tip of the second hand     */
#define HOURTAIL      15  /* ... the tail of the hour hand      */
#define MINUTETAIL    20  /* ... the tail of the minute hand    */

/* conversion factors */
#define CIRTABSCALE   8000 /* circle table values scale down value  */
#define MMPERDM       100  /* millimeters per decimeter             */

/* number of hand positions on ...                                     */
#define HANDPOSITIONS 60                   /* ... entire clock         */
#define SIDESHIFT     (HANDPOSITIONS >> 2) /* ...  90 degrees of clock */
#define TAILSHIFT     (HANDPOSITIONS >> 1) /* ... 180 degrees of clock */

/* declarations for exported functions */
long FAR PASCAL ClockWndProc(HWND, unsigned, WORD, LONG);
BOOL FAR PASCAL About(HWND, unsigned, WORD, LONG);
