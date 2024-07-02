/* CHRTDEMO.C - Presentation graphics demonstration program.
 *
 * If GRAPHICS.LIB and PGCHART.LIB were not included in your run-time
 * libraries during setup, you must you must add them to the CHRTDEMO.MAK
 * program list or give them on the QCL command line.
 */

#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <graph.h>
#include <pgchart.h>
#include "chrtdemo.h"

/* Structures for system configuration and chart environment. */
struct videoconfig vc;
chartenv ce;

/* Category variables.  */
short cCat;
char _far *aCat[MAXVALUES];

/* Series variables.  */
short cSeries;
short _far acSeries[MAXSERIES];
char _far *aSeriesName[MAXSERIES];

/* Temporary holding array for all data. Data values for multi-series
 * bar, column, and line charts remain here. Data for other kinds of
 * charts are transferred to the arrays below.
 */
float _far aValue[MAXSERIES][MAXVALUES];

/* Data values for single-series charts. First array is used for
 * bar, column, line, and pie. First and second are both used for
 * single-series scatter.
 */
float _far axValue[MAXVALUES];
float _far ayValue[MAXVALUES];

/* Data values for multi-series scatter charts.  */
float _far axValueMS[MAXVALUES][MAXVALUES];
float _far ayValueMS[MAXVALUES][MAXVALUES];

/* Exploded flags for pie chart.  */
short _far aExplode[MAXVALUES];

/* Variable used to track control and screen position.  */
struct SCREENINFO si;

/* Colors of menus and prompts. */
struct tagColor co;

/* Flags to indicate whether to use imported or default data.  */
BOOL fDefault = TRUE;

/* Arrays of strings used by the Menu function. The first string is the
 * menu title. The next non-null strings are the menu selections. A null
 * string indicates the end of the list.
 */
char *pszChartOpt[] =
    { "Options", "Screen Mode", "Windows", "Titles",
      "Axis (X and Y)", "Legend", "Fonts", "Reset", "" };

char *pszChartType[] =
    { "Type", "Bar", "Column", "Line", "Scatter", "Pie", "" };

char *pszMainMenu[] =
    { "Main Menu", "Demo", "View Chart", "Chart Type", "Options",
      "Show Chart Data", "Quit", "" };

/* Sample data.  */
#define O_JUICE 0
#define I_TEA   1
#define H_CHOC  2
#define TEMPERATURE  3

char _far *aQuarters[] =
    { "First", "Second", "Third", "Fourth" };

char _far *aMonths[] =
    { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

float _far aSales[3][12] =
{
    {  3.6F,  3.2F,  3.3F,  3.4F,  3.1F,  2.9F,
       3.0F,  3.6F,  3.2F,  3.3F,  3.5F,  3.9F },
    {  1.0F,  1.3F,  1.4F,  1.7F,  2.2F,  2.9F,
       2.9F,  3.1F,  2.6F,  1.8F,  1.1F,  1.2F },
    {  2.4F,  2.3F,  2.0F,  1.6F,  1.3F,  1.0F,
       0.9F,  0.8F,  1.1F,  1.4F,  1.9F,  2.5F }
};
  
float _far aTemperature[12] =
    {  2.9F,  3.2F,  3.9F,  4.8F,  6.0F,  6.5F,
       7.0F,  7.2F,  6.0F,  4.7F,  4.1F,  3.0F };

char _far *aSalesTitles[] =
    { "Orange Juice Sales", "Iced Tea Sales", "Hot Chocolate Sales" };

char *TempTitle = "Average Temperature";

int main()
{
    Initialize();
    MainMenu();

    /* Reset the video mode and screen colors prior to leaving. */
    _setvideomode( _DEFAULTMODE );
    _settextcolor( co.InfoColor );
    _clearscreen( _GCLEARSCREEN );

    return 0;
}

/*  ChartOptions - Gets chart options.
 *
 *  Params: None
 */
void ChartOptions()
{
    int iChoice;

    PushTitle( pszChartOpt[0] );
    while( (iChoice = Menu( pszChartOpt )) != ESCAPE )
    {

        /* Get chart options.  */
        switch( iChoice )
        {

            /* Branch to the appropriate menu.  */
            case 1:
                ScreenMode();
                break;

            case 2:
                Windows();
                break;

            case 3:
                Titles();
                break;

            case 4:
                Axes();
                break;

            case 5:
                Legend();
                break;

            case 6:
                FontOptions();
                break;

            case 7:
                ResetOptions();
                break;

        }
    }
    PopTitle();
}

/*  ChartType - Gets chart type.
 *
 *  Params: None
 */
void ChartType()
{
    int iChoice;

    /* Get chart type.  */
    PushTitle( pszChartType[0] );
    iChoice = Menu( pszChartType );

    if( iChoice != ESCAPE )
    {
        /* Set the chart type, and get the chart style.  */
        ce.charttype = iChoice;
        switch( iChoice )
        {

            case 1:
            case 2:
                iChoice = BlankMenu( "Style", "Plain Bars", "Stacked Bars" );
                break;

            case 3:
            case 4:
                iChoice = BlankMenu( "Style", "Lines-Points", "Points Only" );
                break;

            case 5:
                iChoice = BlankMenu( "Style", "Percent", "No Percent" );
        }

        if( iChoice != ESCAPE)
            ce.chartstyle = iChoice;

        /* Set default data without changing environment defaults.  */
        DefaultData( ce.charttype, ce.chartstyle, FALSE );
        PopTitle();
    }
    PopTitle();
}

/*  ClearData - Clears category and value data.
 *
 *  Params: fConfirm - flag specifying whether to query for confirmation
 */
void ClearData( BOOL fConfirm )
{
    char chResponse = 'Y';
    int iCat;

    WrtForm( 18 );

    /* Query for confirmation.  */
    if( fConfirm )
        chResponse = InputCh( "Are you sure? ", "YN\x1b" );

    if( chResponse == 'Y' )
    {

        /* Clear all relevant data.  */
        for( iCat = 0; iCat < cCat; iCat++ )
            aCat[iCat] = NULL;
        cCat = 0;
        cSeries = 0;
    }
}

/*  DefaultData - Initializes default data for each kind of chart.
 *
 *  Params: iType - Chart type to be initialized
 *          iStyle - Chart style
 *          fClear - Signal to clear all defaults
 */
void DefaultData( short iType, short iStyle, BOOL fClear )
{
    int iCat, iValue, iSubValue, iSeries;

    /* Call default chart to clear old values.  */
    if( fClear )
        _pg_defaultchart( &ce, iType, iStyle );

    /* Initialize category titles.  */
    cCat = 12;
    for( iCat = 0; iCat < cCat; iCat++ )
        aCat[iCat] = aMonths[iCat];

    switch( ce.charttype )
    {

        /* Initialize data for each chart type.  */
        case _PG_BARCHART:
        
            strcpy( ce.maintitle.title, "Orange Juice and Iced Tea Sales" );
            cSeries = 2;
            for( iSeries = 0; iSeries < cSeries; iSeries++ )
            {
                aSeriesName[iSeries] = aSalesTitles[iSeries];
                acSeries[iSeries] = cCat;
                for( iValue = 0; iValue < cCat; iValue++ )
                    aValue[iSeries][iValue]  = (float)aSales[iSeries][iValue];
            }
            break;

        case _PG_COLUMNCHART:
       
            strcpy( ce.maintitle.title, "Orange Juice Sales" );
            cSeries = 1;
            for( iSeries = 0; iSeries < cSeries; iSeries++ )
            {
                aSeriesName[iSeries] = aSalesTitles[iSeries];
                acSeries[iSeries] = cCat;
                for( iValue = 0; iValue < cCat; iValue++ )
                    aValue[iSeries][iValue]  = (float)aSales[iSeries][iValue];
            }
            break;

        case _PG_LINECHART:

            strcpy( ce.maintitle.title, "Beverage Sales" );
            cSeries = 3;
            for( iSeries = 0; iSeries < cSeries; iSeries++ )
            {
                aSeriesName[iSeries] = aSalesTitles[iSeries];
                acSeries[iSeries] = cCat;
                for( iValue = 0; iValue < cCat; iValue++ )
                    aValue[iSeries][iValue] = (float)aSales[iSeries][iValue];
            }
            break;

        case _PG_SCATTERCHART:

            strcpy( ce.maintitle.title,
                    "Average Temperature Compared to Beverage Sales" );
            /* ce.chartstyle = _PG_POINTONLY; */
            cSeries = 4;

            aSeriesName[0] = aSalesTitles[I_TEA];
            aSeriesName[2] = aSalesTitles[H_CHOC];
            acSeries[0] = acSeries[1] = acSeries[2] = acSeries[3] = 12;
            for( iValue = 0; iValue < 12; iValue++ )
            {
                aValue[0][iValue]  = (float)aSales[I_TEA][iValue] ;
                aValue[1][iValue]  = (float)aSales[TEMPERATURE][iValue] ;
                aValue[2][iValue]  = (float)aSales[H_CHOC][iValue] ;
                aValue[3][iValue]  = (float)aSales[TEMPERATURE][iValue] ;
            }
            break;
           
        case _PG_PIECHART:
        default:

            strcpy( ce.maintitle.title, "Iced Tea Sales" );
            cCat = 4;
            for( iCat = 0; iCat < cCat; iCat++ )
                aCat[iCat] = aQuarters[iCat];

            cSeries = 1;
            aSeriesName[0] = aSalesTitles[I_TEA];
            acSeries[0] = cCat;

            for( iValue = 0; iValue < cCat; iValue++ )
            {
                aValue[0][iValue] = 0.0;
                for( iSubValue = 0; iSubValue < 3; iSubValue++ )
                    aValue[0][iValue] += (float)aSales[I_TEA][iSubValue * iValue];
            }
            aExplode[3] = 1;
            break;
    }
}

/*  Demo - Displays a series of sample charts.
 *
 *  Params: None
 */
void Demo()
{
    int  cValue;
    palettetype palette_struct;

    /* Display the sample data in spreadsheet form. */
    ShowSampleData();

    DefaultData( _PG_PIECHART, _PG_NOPERCENT, TRUE );

    /* Set video mode and draw charts. For each chart, set default
     * data and modify any desired environment fields. If error,
     * terminate demo.
     */
    _setvideomode( si.mode );

    cValue = 4;
    strcpy( ce.subtitle.title, "Default Pie Chart" );
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    strcpy( ce.subtitle.title, "Customized Pie Chart" );
    ce.chartstyle = _PG_PERCENT;
    ce.legend.place = _PG_BOTTOM;
    if (si.fColor)
    {
        ce.maintitle.titlecolor = ce.subtitle.titlecolor = 0;
        ce.chartwindow.background = 1;
        ce.datawindow.background = ce.legend.legendwindow.background = 6;
        ce.legend.textcolor = 1;
    }
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    cValue = 12;
    DefaultData( _PG_BARCHART, _PG_PLAINBARS, TRUE );
    strcpy( ce.subtitle.title, "Default Bar Chart" );
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    strcpy( ce.subtitle.title, "Customized Stacked Bar Chart" );
    strcpy( ce.xaxis.axistitle.title, "Sales in Thousands" );
    strcpy( ce.yaxis.axistitle.title, "Month" );
    ce.chartstyle = _PG_STACKEDBARS;
    ce.legend.place = _PG_RIGHT;
    ce.xaxis.ticdecimals = 2;
    if (si.fColor)
    {
        ce.maintitle.titlecolor = ce.subtitle.titlecolor = 12;
        ce.chartwindow.background = 7;
        ce.datawindow.background = 8;
        ce.legend.textcolor = 0;
        ce.legend.legendwindow.background = 8;
        ce.legend.autosize = FALSE;
        ce.legend.legendwindow.y1 = vc.numypixels - 85;
        ce.legend.legendwindow.y2 = vc.numypixels - 45;
    }
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    DefaultData( _PG_COLUMNCHART, _PG_PLAINBARS, TRUE );
    strcpy( ce.subtitle.title, "Default Column Chart" );
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    strcpy( ce.subtitle.title, "Customized Column Chart" );
    strcpy( ce.xaxis.axistitle.title, "Month" );
    strcpy( ce.yaxis.axistitle.title, "Sales in Thousands" );
    ce.legend.place = _PG_BOTTOM;
    if (si.fColor)
    {
        ce.maintitle.titlecolor     = 0;
        ce.subtitle.titlecolor     = 0;
        ce.chartwindow.background = 8;
        ce.datawindow.background = 2;
        ce.legend.legendwindow.background = 10;
    }
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    DefaultData( _PG_LINECHART, _PG_POINTANDLINE, TRUE );
    strcpy( ce.subtitle.title, "Default Line Chart" );
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    strcpy( ce.subtitle.title, "Customized Line Chart" );
    strcpy( ce.xaxis.axistitle.title, "Month" );
    strcpy( ce.yaxis.axistitle.title, "Sales in Thousands" );
    ce.legend.place = _PG_RIGHT;
    if (si.fColor)
    {
        ce.maintitle.titlecolor = 1;
        ce.subtitle.titlecolor = 1;
        ce.chartwindow.background = 3;
        ce.datawindow.background = 7;
        ce.legend.legendwindow.background = 7;
        ce.legend.autosize = FALSE;
        ce.legend.legendwindow.y1 = vc.numypixels - 85;
        ce.legend.legendwindow.y2 = vc.numypixels - 45;
    }
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    DefaultData( _PG_SCATTERCHART, _PG_POINTONLY, TRUE );
    strcpy( ce.subtitle.title, "Default Scatter Chart" );
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    cSeries = 4;
    strcpy( ce.subtitle.title, "Customized Scatter Chart" );
    strcpy( ce.xaxis.axistitle.title, "Sales in Thousands" );
    strcpy( ce.yaxis.axistitle.title, "Average Temperature" );
    ce.legend.place = _PG_RIGHT;
    if (si.fColor)
    {
        ce.maintitle.titlecolor = 0;
        ce.subtitle.titlecolor = 0;
        ce.chartwindow.background = 4;
        ce.datawindow.background = 8;
        ce.legend.legendwindow.background = 8;
        ce.legend.autosize = FALSE;
        ce.legend.legendwindow.y1 = vc.numypixels - 85;
        ce.legend.legendwindow.y2 = vc.numypixels - 45;
    }
    if( ViewChart() )
        return;
    else
        _clearscreen( _GCLEARSCREEN );

    DefaultData( _PG_BARCHART, _PG_PERCENT, TRUE );
}

/*  FindVideoMode - Finds the "best" video mode for the adaptor in use.
 *
 *  Params: vc - structure of type struct videoconfig
 *
 *  Returns: Best mode
 */
int FindVideoMode( struct videoconfig vc )
{
    switch( vc.adapter )
    {
        case _CGA:
        case _OCGA:
            return _HRESBW;
        case _EGA:
        case _OEGA:
            return( vc.monitor == _MONO ) ? _ERESNOCOLOR : _ERESCOLOR;
        case _VGA:
        case _OVGA:
        case _MCGA:
            return _VRES16COLOR;
        case _HGC:
            return _HERCMONO;
        default:
            return _DEFAULTMODE;
    }
}

/*  Initialize - Does various initialization tasks.
 *
 *  Params: None
 */
void Initialize( void )
{
    int iSeries, iValue;

    /* Initialize all value arrays to missing.  */
    for( iSeries = 0; iSeries < MAXSERIES; iSeries++ )
    {

        axValue[iSeries] = _PG_MISSINGVALUE;
        ayValue[iSeries] = _PG_MISSINGVALUE;

        for( iValue = 0; iValue < MAXVALUES; iValue++ )
            aValue[iSeries][iValue] = _PG_MISSINGVALUE;

        for( iValue = 0; iValue < MAXVALUES; iValue++ )
        {
            axValueMS[iSeries][iValue] = _PG_MISSINGVALUE;
            ayValueMS[iSeries][iValue] = _PG_MISSINGVALUE;
        }
    }

    /* Initialize zero sets. */
    cSeries = 0;

    /* Initialize default chart environment, screen mode, and data.  */
    _pg_initchart();
    _getvideoconfig( &vc );

    /* Find the best available mode for display.
     * Don't set 256 color, medium resolution (_MRES256COLOR).
     */
    si.mode = FindVideoMode( vc );

    if( si.mode == _TEXTMONO )
    {
        _clearscreen( _GCLEARSCREEN );
        _outtext( "No graphics available.  Can't run chart demo." );
        exit( 1 );
    }

    SetDisplayColors();

    SetGraphMode( si.mode );
    DefaultData( _PG_BARCHART, _PG_PLAINBARS, TRUE );

    _setvideomode( _DEFAULTMODE );


}

/*  MainMenu - Manages the main menu.
 *
 *  Params: None
 */
void MainMenu( void )
{
    int iChoice;
    char chResponse = 'Y';
    char chVerify;

    PushTitle( pszMainMenu[0] );
    do
    {
        /* If the user selects Quit, iChoice will contain 6.  If the
         *   user presses ESCAPE, iChoice will be ESCAPE, which is
         *   equal to 27.  In any case, we can test both conditions
         *   by checking to see whether iChoice is less than 6.
         */
        while( (iChoice = Menu( pszMainMenu )) < 6 )
        {
            /* Get main menu selection.  */
            switch( iChoice )
            {

                case 1:
                    /* Display demo charts.  */
                    Demo();
                    _setvideomode( _DEFAULTMODE );
                    break;

                case 2:
                    /* Set graphics video mode, display current chart,
                     * and restore text video mode.
                     */
                    _setvideomode( si.mode );
                    ViewChart();
                    _setvideomode( _DEFAULTMODE );
                    break;

                case 3:
                    /* Get chart type and style.  */
                    ChartType();
                    break;

                case 4:
                    /* Get chart options.  */
                    ChartOptions();
                    break;
                case 5:
                    /* Show chart data. */
                    ShowChartData();
                    break;

            }

        }

        /* If the user is trying to leave the program using the ESCAPE
         *   key, we must verify the choice.  This is done to prevent
         *   an eager typist from pressing ESCAPE one time too often
         *   and exiting at an unanticipated point.
         */
        if( iChoice == ESCAPE )
        {
            Help( "Press \"Q\" to Actually Quit", co.InputColor );

            putchar( BEEP );
            _settextposition( si.help - 1, 32 );
            chVerify = getch();
            if( tolower( chVerify ) != 'q' )
                iChoice = 0;
            else
                iChoice = 6;
        }

    } while( iChoice != 6 );
    PopTitle();
}

/*  ResetOptions - After confirmation, resets chart options to default.
 *
 *  Params: None
 */
void ResetOptions()
{
    char chResponse;

    /* Prompt for confirmation before setting default environment.  */
    ClrForm();
    Help( "Type  'Y' to reset all options, 'N' to keep them.", co.InputColor );
    chResponse = InputCh( "Are you sure? ", "YN\x1b" );
    if( chResponse == 'Y' )
        _pg_defaultchart( &ce, 1, 1 );

}

/*  SetGraphMode - Tests the specified graphics mode and sets the xMax
 *  and yMax values in the si (Screen Information) structure.
 *
 *  Params: mode number
 *
 *  Return: FALSE if mode invalid, TRUE if valid
 */
BOOL SetGraphMode(int mode)
{
    if (!_setvideomode( mode ) )
        return FALSE;
    else
    {
        _getvideoconfig ( &vc );
        if( !vc.numxpixels )
            return FALSE;
        si.xMax = vc.numxpixels;
        si.yMax = vc.numypixels;
        si.mode = mode;

        /* Set flag to indicate whether multiple colors are available.  */
        si.fColor = iscolor( mode );

        return TRUE;
    }
}

/*  ShowChartData - Displays the data in the chart environment.
 *
 *  Params: None
 */
void ShowChartData()
{
    int iRow = 2;
    struct _fontinfo fd;
    static char *szContinue =
        "Press any key to continue, ESC to return to the menu.";

    _clearscreen( _GCLEARSCREEN );
    SprintAt( iRow++, 1, "short      charttype =  %d", ce.charttype );
    SprintAt( iRow++, 1, "short      chartstyle = %d", ce.chartstyle );
    SprintAt( iRow++, 1, "windowtype chartwindow =" );
    iRow = ShowWindowType( iRow, 1, ce.chartwindow );
    SprintAt( iRow++, 1, "windowtype datawindow =" );
    iRow = ShowWindowType( iRow, 1, ce.datawindow );
    SprintAt( ++iRow, 1, szContinue );
    if( getch() == ESCAPE )
        return;

    iRow = 2;
    _clearscreen( _GCLEARSCREEN );
    SprintAt( iRow++, 1, "titletype  maintitle =" );
    iRow = ShowTitleType( iRow, 1, ce.maintitle );
    SprintAt( iRow++, 1, "titletype   subtitle =" );
    iRow = ShowTitleType( iRow, 1, ce.subtitle );
    SprintAt( ++iRow, 1, szContinue );
    if( getch() == ESCAPE )
        return;

    iRow = 2;
    _clearscreen( _GCLEARSCREEN );
    SprintAt( iRow++, 1, "axistype       xaxis =" );
    iRow = ShowAxisType( iRow, 1, ce.xaxis );
    SprintAt( ++iRow, 1, szContinue );
    if( getch() == ESCAPE )
        return;

    iRow = 2;
    _clearscreen( _GCLEARSCREEN );
    SprintAt( iRow++, 1, "axistype       yaxis =" );
    iRow = ShowAxisType( iRow, 1, ce.yaxis );
    SprintAt( ++iRow, 1, szContinue );
    if( getch() == ESCAPE )
        return;

    iRow = 2;
    _clearscreen( _GCLEARSCREEN );
    SprintAt( iRow++, 1, "legendtype     legend =" );
    iRow = ShowLegendType( iRow, 1, ce.legend );
    SprintAt( ++iRow, 1, szContinue );
    if( getch() == ESCAPE )
        return;

    iRow = 2;
    _clearscreen( _GCLEARSCREEN );
    if( _getfontinfo( &fd ) != -1 )
    {
        SprintAt( iRow++, 1, "struct _fontinfo =" );
        iRow = ShowFontInfo( iRow, 1, fd );
        SprintAt( ++iRow, 1, "Press any key to continue . . ." );
        getch();
    }
}

/*  ShowAxisType - Displays data in a variable of type "axistype".
 *
 *  Params: iRow - Row at which to start
 *          iCol - Column from which to indent
 *          theAxis - Variable of type "axistype" to display
 *
 *  Return: Next available row
 */
int ShowAxisType( int iRow, int iCol, axistype theAxis )
{
    SprintAt( iRow++, iCol + 5, "short        .grid = %d", theAxis.grid );
    SprintAt( iRow++, iCol + 5, "short   .gridstyle = %d", theAxis.gridstyle );
    SprintAt( iRow++, iCol + 5, "titletype axistitle=" );
    iRow = ShowTitleType( iRow, iCol + 5, theAxis.axistitle );
    SprintAt( iRow++, iCol + 5, "short   .axiscolor = %d", theAxis.axiscolor );
    SprintAt( iRow++, iCol + 5, "short     .labeled = %s",
        (theAxis.labeled) ? "TRUE" : "FALSE" );
    SprintAt( iRow++, iCol + 5, "short   .rangetype = %d", theAxis.rangetype );
    SprintAt( iRow++, iCol + 5, "float     .logbase = %f", theAxis.logbase );
    SprintAt( iRow++, iCol + 5, "short   .autoscale = %s",
        (theAxis.autoscale) ? "TRUE" : "FALSE" );
    SprintAt( iRow++, iCol + 5, "float    .scalemin = %f", theAxis.scalemin );
    SprintAt( iRow++, iCol + 5, "float    .scalemax = %f", theAxis.scalemax );
    SprintAt( iRow++, iCol + 5, "float .scalefactor = %f", theAxis.scalefactor );
    iRow = ShowTitleType( iRow, iCol + 5, theAxis.scaletitle );
    SprintAt( iRow++, iCol + 5, "float  .ticinterval = %f", theAxis.ticinterval );
    SprintAt( iRow++, iCol + 5, "short    .ticformat = %d", theAxis.ticformat );
    SprintAt( iRow++, iCol + 5, "short  .ticdecimals = %d", theAxis.ticdecimals );

    return iRow;
}

/*  ShowFontInfo - Displays data in a variable of type "_fontinfo".
 *
 *  Params: iRow - Row at which to start
 *          iCol - Column from which to indent
 *          theFont - Variable of type "_fontinfo" to display
 *
 *  Return: Next available row
 */
int ShowFontInfo( int iRow, int iCol, struct _fontinfo theFont )
{
    SprintAt( iRow++, iCol + 5, "int          .type = %d", theFont.type );
    SprintAt( iRow++, iCol + 5, "int        .ascent = %d", theFont.ascent );
    SprintAt( iRow++, iCol + 5, "int      .pixwidth = %d", theFont.pixwidth );
    SprintAt( iRow++, iCol + 5, "int     .pixheight = %d", theFont.pixheight );
    SprintAt( iRow++, iCol + 5, "int      .avgwidth = %d", theFont.avgwidth );
    SprintAt( iRow++, iCol + 5, "char     .filename = %s", theFont.filename );
    SprintAt( iRow++, iCol + 5, "char     .facename = %s", theFont.facename );

    return iRow;
}

/*  ShowLegendType - Displays data in a variable of type "legendtype".
 *
 *  Params: iRow - Row at which to start
 *          iCol - Column from which to indent
 *          theLegend - Variable of type "legendtype" to display
 *
 *  Return: Next available row
 */
int ShowLegendType( int iRow, int iCol, legendtype theLegend )
{
    SprintAt( iRow++, iCol + 5, "short      .legend = %s",
              (theLegend.legend) ? "TRUE" : "FALSE" );
    SprintAt( iRow++, iCol + 5, "short       .place = %d", theLegend.place );
    SprintAt( iRow++, iCol + 5, "short   .textcolor = %d", theLegend.textcolor );
    SprintAt( iRow++, iCol + 5, "short    .autosize = %d", theLegend.autosize );
    SprintAt( iRow++, iCol + 5, "windowtype legendwindow =" );
    iRow = ShowWindowType( iRow, iCol + 5, theLegend.legendwindow );

    return iRow;
}

/*  ShowSampleData - Displays the sample data for the demo.
 *
 *  Params: None
 */
void ShowSampleData()
{
    int  iCat, y, iSeries, iValue;
    char szTmp[80];

    /* Display data in table format. */
    _clearscreen( _GCLEARSCREEN );
    PrintAt( 1, 40 - strlen(szTmp) / 2, "Data in Table Format", -1 );

    /* Write titles and draw separator line. */
    y = 3;
    for( iCat = 1; iCat <= 12; iCat++ )
    PrintAt( y, iCat * 6, aMonths[iCat - 1], -1 );

    memset( szTmp, '-', 69 );
    szTmp[69] = 0;
    PrintAt( ++y, 6, szTmp, -1 );

    /* Write data. */
    for( iSeries = 1; iSeries <= 3; iSeries++ )
    {
        PrintAt( y += 2, 4, aSalesTitles[iSeries - 1], -1 );
        y += 2;
        for( iValue = 1; iValue <= 12; iValue++ )
        {
            sprintf( szTmp, "%#3.2f", aSales[iSeries - 1][iValue - 1] );
            PrintAt( y, iValue * 6, (char _far *)szTmp, -1 );
        }
    }
    PrintAt( y += 2, 4, TempTitle, -1 );
    y += 2;
    for( iValue = 1; iValue <= 12; iValue++ )
    {
        sprintf( szTmp, "%#3.1f", aTemperature[iValue - 1] );
        PrintAt( y, iValue * 6, szTmp, -1 );
    }

    PrintAt( y += 2, 1, "Press any key to continue . . .", -1 );
    getche();
}

/*  ShowTitleType - Displays data in a variable of type "titletype".
 *
 *  Params: iRow - Row at which to start
 *          iCol - Column from which to indent
 *          theTitle - Variable of type "titletype" to display
 *
 *  Return: Next available row
 */
int ShowTitleType( int iRow, int iCol, titletype theTitle )
{
    SprintAt( iRow++, iCol + 5, "char    .title[%d] = \"%s\"", _PG_TITLELEN,
                 theTitle.title );
    SprintAt( iRow++, iCol + 5, "short  .titlecolor = %d", theTitle.titlecolor );
    SprintAt( iRow++, iCol + 5, "short     .justify = %d", theTitle.justify );

    return iRow;
}

/*  ShowWindowType - Displays data in a variable of type "windowtype".
 *
 *  Params: iRow - Row at which to start
 *          iCol - Column from which to indent
 *          theWindow - Variable of type "windowtype" to display
 *
 *  Return: Next available row
 */
int ShowWindowType( int iRow, int iCol, windowtype theWindow )
{
    SprintAt( iRow++, iCol + 5, "short          .x1 = %d", theWindow.x1 );
    SprintAt( iRow++, iCol + 5, "short          .y1 = %d", theWindow.y1 );
    SprintAt( iRow++, iCol + 5, "short          .x2 = %d", theWindow.x2 );
    SprintAt( iRow++, iCol + 5, "short          .y2 = %d", theWindow.y2 );
    SprintAt( iRow++, iCol + 5, "short      .border = %d", theWindow.border );
    SprintAt( iRow++, iCol + 5, "short  .background = %d", theWindow.background );
    SprintAt( iRow++, iCol + 5, "short .borderstyle = %d", theWindow.borderstyle );
    SprintAt( iRow++, iCol + 5, "short .bordercolor = %d", theWindow.bordercolor );

    return iRow;
}

/*  ShowError - Displays error message for one of the chart library
 *  errors.
 *
 *  Params: iErr - Error number
 */
void ShowError( int iErr )
{
    char szTmp[50];

    /* Change to text screen.  */
    _setvideomode( _DEFAULTMODE );

    /* Select the error text.  */
    switch( iErr )
    {
        case _PG_NOTINITIALIZED:
            strcpy( szTmp, "Chart Library Not Initialized" );
            break;
        case _PG_BADSCREENMODE:
            strcpy( szTmp, "Invalid Screen Mode" );
            break;
        case _PG_BADCHARTTYPE:
            strcpy( szTmp, "Invalid Chart Type" );
            break;
        case _PG_BADCHARTSTYLE:
            strcpy( szTmp, "Invalid Chart Style" );
            break;
        case _PG_BADLEGENDWINDOW:
            strcpy( szTmp, "Invalid Legend Window" );
            break;
        case _PG_BADDATAWINDOW:
            strcpy( szTmp, "No Room for Data window" );
            break;
        case _PG_BADCHARTWINDOW:
            strcpy( szTmp, "Invalid Chart window coordinates" );
            break;
        case _PG_NOMEMORY:
            strcpy( szTmp, "Not Enough Memory for Data Arrays" );
            break;
        case _PG_BADLOGBASE:
            strcpy( szTmp, "X or Y log base <= 0" );
            break;
        case _PG_BADSCALEFACTOR:
            strcpy( szTmp, "X or Y scale factor = 0" );
            break;
        case _PG_TOOSMALLN:
            strcpy( szTmp, "Too few data values" );
            break;
        case _PG_TOOFEWSERIES:
            strcpy( szTmp, "No data series specified" );
            break;
        default:
            strcpy( szTmp, "Unknown error" );
    }

    ErrorMsg( szTmp );
}

/*  ViewChart - Draws the current chart.
 *
 *  Params: None
 */
int ViewChart()
{
    int cValue, iValue, iSeries, iErr;

    /* Make sure some data exists.  */
    if( cSeries <= 0 )
    {
        fDefault = TRUE;
        DefaultData( ce.charttype, ce.chartstyle, FALSE );
    }

    /* Find the longest series.  */
    cValue = 0;
    for( iSeries = 0; iSeries < cSeries; iSeries++ )
        if( acSeries[iSeries] > cValue )
            cValue = acSeries[iSeries];

    _setvideomode( si.mode );


    /* Process depending on the type of chart.  */
    switch( ce.charttype )
    {

        case _PG_PIECHART:
        case _PG_BARCHART:
        case _PG_COLUMNCHART:
        case _PG_LINECHART:

            /* Initialize data and draw pie chart or single-series bar,
             * column, or line chart.
             */
            if( (cSeries == 1) ||( ce.charttype == _PG_PIECHART) )
            {

                /* Transfer data into a single-dimension array.  */
                for( iValue = 0; iValue < cValue; iValue++ )
                   axValue[iValue] = aValue[0][iValue];

                /* Draw chart.  */
                if( ce.charttype == _PG_PIECHART )
                    iErr = _pg_chartpie( &ce, aCat, axValue,
                                         aExplode, cValue );
                else
                    iErr = _pg_chart( &ce, aCat, axValue, cValue );
            }
            /* If multiple-series, then data is OK. Just draw chart.  */
            else
                iErr = _pg_chartms( &ce, aCat, (float _far *)aValue,
                                    cSeries, cValue, cValue, aSeriesName );
            break;

        case _PG_SCATTERCHART:

            /* Make sure there are enough data sets.  */
            if( cSeries == 1 )
            {
                _setvideomode( _DEFAULTMODE );
                si.help = 10;
                ErrorMsg( "Too few value data columns for scatter chart." );
                return 1;

            }
            /* If it's a single-series scatter, transfer data to one-
             * dimensional arrays and make chart call.
             */
            else if( cSeries == 2 )
            {
                for( iValue = 0; iValue < cValue; iValue++ )
                {
                    axValue[iValue] = aValue[0][iValue];
                    ayValue[iValue] = aValue[1][iValue];
                }
                cSeries = 1;
                iErr = _pg_chartscatter( &ce, axValue, ayValue, cValue );

            }
            /* If it's a multiple-series scatter, transfer odd columns to
             * X-axis data array and even columns to Y-axis array and make
             * chart call.
             */
            else
            {

                for( iSeries = 1; iSeries < cSeries; iSeries += 2 )
                {
                    aSeriesName[iSeries / 2] = aSeriesName[iSeries - 1];
                    for( iValue = 0; iValue < cValue; iValue++ )
                    {
                        axValueMS[iSeries / 2][iValue] =
                            aValue[iSeries - 1][iValue];
                        ayValueMS[iSeries / 2][iValue] =
                            aValue[iSeries][iValue];
                    }
                }
                cSeries /= 2;

                iErr = _pg_chartscatterms( &ce, (float _far *)axValueMS,
                                           (float _far *)ayValueMS,
                                           cSeries, cValue, cValue,
                                           aSeriesName );
            }
    }

    if( !fDefault )
        ClearData( FALSE );

    /* If error, show it, else wait for keypress with chart on screen.  */
    if( iErr )
    {
        ShowError( iErr );
        return iErr;
    }
    else
        return ( getch() == ESCAPE );   /* ESCAPE means stop demo */
}
