/* File: CHRTDEMO.H
 *
 * Common definitions for major modules of CHRTDEMO.
 */

/* Include only once */
#ifndef CHRTDEMO_H
#define CHRTDEMO_H

/* --- For graphics adaptors that are color capable: --- */
#define C_INPUTCOLOR  11      /* Color for data input                 */
#define C_HILITECOLOR 10      /* Color for first-letter highlights    */
#define C_FORMCOLOR   15      /* Color for screen form lines and help */
#define C_TITLECOLOR  15      /* Color for QuickCHART title           */
#define C_ERRORCOLOR  14      /* Color for error lines                */
#define C_INFOCOLOR    7      /* Color non-input data on screen       */

/* --- For graphics adaptors that are not color capable: --- */
#define M_INPUTCOLOR   7      /* Color for data input                 */
#define M_HILITECOLOR 15      /* Color for first-letter highlights    */
#define M_FORMCOLOR    7      /* Color for screen form lines and help */
#define M_TITLECOLOR  15      /* Color for QuickCHART title           */
#define M_ERRORCOLOR  15      /* Color for error lines                */
#define M_INFOCOLOR    7      /* Color non-input data on screen       */

/* Define macros to determine whether the graphics adaptor is color-capable. */
#define ismono(m) ( ((m) == _MRESNOCOLOR) || ((m) == _HRESBW)      || \
                    ((m) == _HERCMONO)    || ((m) == _ERESNOCOLOR) || \
                    ((m) == _VRES2COLOR) )
#define iscolor(m) (!ismono(m))

/* ASCII codes for commonly used control functions. */
#define BEEP        7
#define ESCAPE     27

/* Constant limits. */
#define MAXVALUES  12
#define MAXSERIES  4

/* Constants that identify typefaces to ChooseFont. */
enum tagTypeFace
{
    COURIER,
    HELV,
    TMS_RMN,
    MODERN,
    SCRIPT,
    ROMAN,
    NOFONT
};

typedef enum tagBool { FALSE, TRUE } BOOL;

/* Variables used to track control and screen position.  */
struct SCREENINFO
{
    int  top;                        /* Row under top form line      */
    int  bot;                        /* Row above bottom form line   */
    int  mid;                        /* Middle line of form          */
    int  help;                       /* Line number of help line     */
    int  mode;                       /* Current screen mode          */
    int  xMax;
    int  yMax;
    BOOL fColor;
};

/* This variable holds either the constants #defined for color
 * graphics adaptors (those that are formed: C_xxxxxCOLOR) or those
 * #defined for monochrome graphics adaptors (those that are formed:
 * M_xxxxxCOLOR).  They do NOT control the color of the presentation
 * graphics -- just the color of the menus and prompts.
 */
struct tagColor
{
    short InputColor;                /* Color for input requests     */
    short HiliteColor;               /* Color for prompt highlights  */
    short FormColor;                 /* Color for input forms/menus  */
    short TitleColor;                /* Color for titles             */
    short ErrorColor;                /* Color for error messages     */
    short InfoColor;                 /* Color for informations msgs. */
};

/* Declarations of functions in CHRTDEMO.C  */
void ChartOptions( void );
void ChartType( void );
void ClearData( BOOL fConfirm );
void DefaultData( short iType, short iStyle, BOOL fClear );
int  FindVideoMode( struct videoconfig vc );
void Initialize( void );
int  main( void );
void MainMenu( void );
void ResetOptions( void );
void Demo( void );
BOOL SetGraphMode( int mode );
void ShowError( int iErr );
void ShowChartData( void );
int  ShowAxisType( int iRow, int iCol, axistype theAxis );
int  ShowFontInfo( int iRow, int iCol, struct _fontinfo theFont );
int  ShowLegendType( int iRow, int iCol, legendtype theLegend );
void ShowSampleData( void );
int  ShowTitleType( int iRow, int iCol, titletype theTitle );
int  ShowWindowType( int iRow, int iCol, windowtype theWindow );
int  ViewChart( void );

/* Declarations of functions in CHRTOPT.C  */
void Axes( void );
void Axis( axistype *pat );
void AxisRange( axistype *pat );
void AxisScale( axistype *pat );
void AxisTics( axistype *pat );
void Border( windowtype *pwt );
int  ChangeTypeface( int iFaceIndex );
void ChooseFont( int WhichFont, int Height );
void ChartWindow( void );
void DataWindow( void );
void FontOptions( void );
void Justify( titletype *ptt );
void Legend( void );
void LegendPlace( void );
void ScreenMode( void );
void TitleOpt( titletype *ptt );
void Titles( void );
void Windows( void );
void WindowSize( windowtype *pwt );

/* Declaration of functions in CHRTSUPT.C */
int  BlankMenu( char *pchTitle, char *pchChoice1, char *pchChoice2 );
void ClrForm( void );
void ClrHelp( void );
void ErrorMsg( char *pchMsg );
void Help( char *pchMsg, short sColor );
int  InputCh( char *pchPrompt, char *pchAccept );
int  InputInt( char *pchPrompt, int iOld, int iMin, int iMax );
float InputFloat( char *pchPrompt, float fOld );
char *InputStr( char *pchPrompt, char *pchOld );
BOOL InRange( int Value, int iMin, int iMax );
int  Menu( char *pszMenuList[] );
void PopTitle( void );
void PushTitle( char *pchOldTitle );
void PrintAt(int row, int column, char far * lpszString, short sColor);
void PrintChar(int row, int column, char cChar, short sColor);
void SetDisplayColors( void );
void SprintAt( int iRow, int iCol, char * szFmt, ... );
void WrtForm( int yBot );

#endif /* CHRTDEMO_H */
