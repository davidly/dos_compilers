/* CHRTOPT.C - Options module for presentation graphics demonstration
 * program.
 */

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <graph.h>
#include <pgchart.h>
#include "chrtdemo.h"

/* Structures for system configuration and chart environment. */
extern struct videoconfig vc;
extern chartenv ce;

/* Variable used to track control and screen position.  */
extern struct SCREENINFO si;

/* Colors of menus and prompts. */
extern struct tagColor co;

/* Arrays of strings used by the Menu function. The first string is the
 * menu title. The next non-null strings are the menu selections. A null
 * string indicates the end of the list.
 */
char *pszAxes[] =
    { "Axis", "X Axis", "Y Axis", "" };

char *pszAxis[] =
    { "? Options", "Grid", "Axis Title", "Color",
      "Range Type", "Scale", "Tic Marks", "" };

char *pszAuto[] =
    { "Auto", "Auto", "Manual", "" };

char *pszBorder[] =
    { "Type", "Color", "Style", "" };

char *pszChartWindow[] =
    { "Chart", "Size", "Color (Background)", "Border", "" };

char *pszDataWindow[] =
    { "Data", "Color (Background)", "Border", "" };

char * pszFontOpt[] =
    { "Font Options", "Change Typeface", "Set Character Size", "" };

char *pszJustify[] =
    { "Justify", "Left", "Center", "Right", "" };

char *pszLegendWindow[] =
    { "Options", "Place", "Text Color", "Size", "Color (Background)",
      "Border", "" };

char *pszPlace[] =
    { "Place", "Right", "Bottom", "Overlay", "" };

char *pszScale[] =
    { "Scale", "Low (Min)", "High (Max)", "Scale Factor", "Title", "" };

char *pszSize[] =
    { "Size", "Top", "Left", "Bottom", "Right", "" };

char *pszTic[] =
    { "Tic Type", "Interval", "Format", "Decimals", "" };

char *pszTitleOpt[] =
    { "", "Text", "Color", "Justify", "" };

char *pszTitles[] =
    { "Title", "Main Title", "Sub Title", "" };

char *pszTypeface[] =
    { "Type Faces", "Courier", "Helv", "Tms Rmn", "Modern", "Script",
           "Roman", "None", "" };

char *pszWindows[] =
    { "Window", "Chart Window", "Data Window", "" };

/*  Axes - Selects X or Y axis.
 *
 *  Params: none
 */
void Axes()
{
    int iChoice;
    static axistype *patAxis[2] = { &ce.xaxis, &ce.yaxis };

    /* Get menu choice and call appropriate axis Menu. */
    PushTitle( pszAxes[0] );
    Help( "Choose 'X' or 'Y' Axis", co.InputColor );
    while( (iChoice = Menu( pszAxes )) != ESCAPE )
    {
        /* Modify axis title, depending on choice. */
        pszAxis[0][0] = (--iChoice == 0) ? 'X' : 'Y';

        /* Obtain axis information for appropriate axis. */
        Axis( patAxis[iChoice] );
    }
    PopTitle();
}

/*  Axis - Selects axis options.
 *
 *  Params: pat - Pointer to axistype variable
 */
void Axis( axistype *pat )
{
    int iChoice;

    PushTitle( pszAxis[0] );
    while( (iChoice = Menu( pszAxis )) != ESCAPE )
    {

        /* Get Axis option.  */
        switch( iChoice )
        {
            case 1:
                /* Grid or not? */
                iChoice = BlankMenu( "Grid", "Grid", "No Grid" );
                switch( iChoice )
                {

                    case 1:
                        /* If yes, set grid flag and get the grid style. */
                        pat->grid = TRUE;
                        Help( "Enter a number in the range 0-10.",
                              co.InputColor );
                        pat->gridstyle =
                            InputInt( "Grid Style? ", pat->gridstyle, 0, 10 );
                        break;

                    case 2:
                        /* If no, clear grid flag.  */
                        pat->grid = FALSE;
                }
                PopTitle();
                break;

            case 2:
                /* Select axis title options. */
                pszTitleOpt[0] = "Axis Title";
                TitleOpt( &pat->axistitle );
                break;

            case 3:
                /* Select color. */
                Help( "Enter a number in the range 0-15.", co.InputColor );
                pat->axiscolor =
                    InputInt( "Axis Color? ", pat->axiscolor, 0, 15 );
                break;

            case 4:
                /* Get the axis range.  */
                AxisRange( pat );
                break;

            case 5:
                /* Get the axis scale.  */
                AxisScale( pat );
                break;

            case 6:
                /* Get axis tic mark options.  */
                AxisTics( pat );
                break;

        }
    }
    PopTitle();
}

/*  AxisRange - Selects range for an axis.
 *
 *  Params: pat - pointer to axistype variable
 */
void AxisRange( axistype *pat )
{
    int iChoice;

    iChoice = BlankMenu( "Range Type", "Normal", "Log" );
    switch( iChoice )
    {
        case 1:
            /* Set range type to linear.  */
            pat->rangetype = _PG_LINEARAXIS;
            break;

        case 2:
            /* Set range type to log, then query for log base.  */
            pat->rangetype = _PG_LOGAXIS;
            Help( "Enter a value greater than or equal 2.", co.InputColor );
            pat->logbase = (float)InputInt( "Log base? ",
                                            (int)pat->logbase, 2, 0 );
            break;
    }
    PopTitle();
}

/*  AxisScale - Selects scale options for an axis.
 *
 *  Params: pat - pointer to axistype variable
 */
void AxisScale( axistype *pat )
{
    int iChoice;

    PushTitle( pszAuto[0] );
    iChoice = Menu( pszAuto );
    switch( iChoice )
    {

        case 1:
            /* Set AutoScale flag.  */
            pat->autoscale = TRUE;
            break;

        case 2:

            /* Clear AutoScale flag and get scale options.  */
            pat->autoscale = FALSE;
            PushTitle( pszScale[0] );
            while( (iChoice = Menu( pszScale )) != ESCAPE )
            {

                switch( iChoice )
                {

                    case 1:  
                        /* Query for scale minimum.  */
                        Help( "Enter the range minimum value.", co.InputColor );
                        pat->scalemin =
                            (float)InputInt( "Minimum? ",
                                             (int)pat->scalemin, 1, 0 );
                        break;

                    case 2:  
                        /* Query for scale maximum.  */
                        Help( "Enter the range maximum value.", co.InputColor );
                        pat->scalemin =
                            (float)InputInt( "Minimum? ",
                                             (int)pat->scalemin, 1, 0 );
                        break;

                    case 3:
                        /* Query for scale factor.  */
                        Help( "Enter scale factor (must be 1 or greater).",
                                 co.InputColor );
                        pat->scalefactor =
                            (float)InputInt( "Scale Factor? ",
                                             (int)pat->scalefactor, 1, 0 );
                        break;

                    case 4:  
                        /* Modify scale title, then use menu to get
                         * title options.
                         */
                        pszTitleOpt[0] = "Scale Title";
                        TitleOpt( &pat->scaletitle );

                }
            }
            PopTitle();
    }
    PopTitle();
}

/*  AxisTics - Selects tic options for an axis.
 *
 *  Params: pat - pointer to axistype variable
 */
void AxisTics( axistype *pat )
{
    int iChoice;

    PushTitle( pszTic[0] );
    while( (iChoice = Menu( pszTic )) != ESCAPE )
    {
        switch( iChoice )
        {

            case 1:
                /* Query for tic interval.  */
                Help( "Enter distance in data units.", co.InputColor );
                pat->ticinterval =
                    InputFloat( "Distance between tic marks? ",
                               pat->ticinterval );
                pat->autoscale = FALSE;
                break;

            case 2:
                /* Query for tic format.  */
                iChoice = BlankMenu( "Tic Format", "Normal", "Log" );
                if( iChoice != ESCAPE )
                    pat->ticformat = iChoice;
                break;

            case 3:
                /* Query for number of decimal places per tic.  */
                pat->ticdecimals =
                    InputInt( "Enter decimal places (0 to 9). ",
                               pat->ticdecimals, 0, 9 );
                pat->autoscale = FALSE;
                break;
        }

    }
    PopTitle();
}

/*  Border - Specifies border information for a window.
 *
 *  Params: pwt - Pointer to windowtype variable
 */
void Border( windowtype *pwt )
{
    int iChoice;

    /* Ask whether a border is wanted.  */
    iChoice = BlankMenu( "Border", "Border", "No Border" );
    switch( iChoice )
    {

        case 1:

            /* If border, set Border flag and query for border options.  */
            pwt->border= TRUE;
            PushTitle( pszBorder[0] );
            while( (iChoice = Menu( pszBorder )) != ESCAPE )
            {
                switch( iChoice )
                {
                    case 1:
                        /* Query for border color.  */
                        Help( "Enter a color in the range 0-15.",
                            co.InputColor );
                        pwt->bordercolor =
                            InputInt( "Border color? ",
                                       pwt->bordercolor, 0, 15 );
                        break;

                    case 2:
                        /* Query for border style.  */
                        Help( "Enter a style in the range 0-10.", co.InputColor );
                        pwt->borderstyle =
                            InputInt( "Border style? ",
                                       pwt->borderstyle, 0, 10 );
                }
            }
            PopTitle();
            break;

        case 2:
            /* If no border, clear Border flag.  */
            pwt->border= FALSE;
    }
    PopTitle();
}

/*  ChangeTypeface - Allow the user to specify a new type face.
 *
 *  Params: iFaceIndex - index of last typeface
 *
 *  Return: index of new typeface
 */

int ChangeTypeface( int iFaceIndex )
{
    int iChoice;

    /* Get menu choice and call appropriate axis Menu. */
    PushTitle( pszFontOpt[0] );
    Help( "Choose one of the type faces listed.", co.InputColor );

    if( (iChoice = Menu( pszTypeface ) - 1) != ESCAPE )
    {
        /* If the user wants the system font, unregister the other fonts. */
        if( iChoice == NOFONT )
            _unregisterfonts();

        /* If the user wants any font but the system font, make sure the
         *   fonts are registered.
         */
        else
        {
            /* If last face was NOFONT, register fonts. */
            if( iFaceIndex == NOFONT )
            {
                /* Assumes font files are in current directory.
                 * Could be enhanced to handle any directory.
                 */
                if( _registerfonts( "*.FON" ) < 0 )
                    ErrorMsg( "Font files must be in current directory" );
                else
                    iFaceIndex = iChoice;
            }
            else
                iFaceIndex = iChoice;
        }
    }

    PopTitle();
    return iFaceIndex;
}

/*  ChooseFont - Chooses a font from the font library.
 *
 *  Params: WhichFont - A member of the set [COURIER, HELV, TMS_RMN,
 *                        MODERN, SCRIPT, ROMAN, NOFONT]
 *          Height    - The desired height of the text (in pixels)
 */

void ChooseFont( int WhichFont, int Height )
{
    static char *FontIds[] =
    {
        "courier", "helv", "tms rmn", "modern", "script", "roman"
    };
    char SetCommand[30];

    /* Construct the command to send to _setfont. */
    sprintf( SetCommand, "t'%s'h%dw0b", FontIds[WhichFont], Height );

    if( _setfont( SetCommand ) < 0 )
    {
        _outtext( "Could not set. Try different font or size" );
        getch();
    }
}

/*  ChartWindow - Gets chart window information.
 *
 *  Params: None
 */
void ChartWindow()
{
    int iChoice;

    PushTitle( pszChartWindow[0] );
    while( (iChoice = Menu( pszChartWindow )) != ESCAPE )
    {

        /* Get window options.  */
        switch( iChoice )
        {

            case 1:
                /* Get window size.  */
                WindowSize( &ce.chartwindow );
                break;

            case 2:
                /* Query for background color.  */
                Help( "Enter a number in the range 0-15", co.InputColor );
                ce.chartwindow.background =
                    InputInt( "Background Color? ", ce.chartwindow.background,
                              0, 15 );
                break;

            case 3:

                /* Get border options.  */
                Border( &ce.chartwindow );

        }
    }
    PopTitle();
}

/*  DataWindow - Geta data window information.
 *
 *  Params: None
 */
void DataWindow()
{
    int iChoice;

    PushTitle( pszDataWindow[0] );
    while( (iChoice = Menu( pszDataWindow )) != ESCAPE )
    {

        /* Get data window menu options.  */
        switch( iChoice )
        {

            case 1: 
                /* Query for background color.  */
                Help( "Enter a number in the range 0-15", co.InputColor );
                ce.datawindow.background =
                    InputInt( "Background Color? ",
                               ce.datawindow.background,
                               0, 15 );
                break;

            case 2:
                /* Get border options.  */
                Border( &ce.datawindow );
                break;

        }
    }
    PopTitle();
}

/*  FontOptions - Allows the user to modify the font used for display.
 *
 *  Params: None
 */

void FontOptions()
{
    int iChoice;
    static int iFaceIndex = NOFONT;
    static int iTypeSize = 8;

    /* Get menu choice and call appropriate axis Menu. */
    PushTitle( pszFontOpt[0] );

    while( (iChoice = Menu( pszFontOpt )) != ESCAPE )
    {
        switch( iChoice )
        {
            /* Change Typeface. */
            case 1:
                iFaceIndex = ChangeTypeface( iFaceIndex );
                ChooseFont( iFaceIndex, iTypeSize );
                break;

            /* Change Type Size. */
            case 2:

                if( iFaceIndex == NOFONT )
                {
                    ErrorMsg( "Select a font first" );
                    break;
                }

                iTypeSize = InputInt( "Enter a type size. ", iTypeSize,
                                       8, 128 );

                ChooseFont( iFaceIndex, iTypeSize );
                break;

            default:
                break;
        }
    }
    PopTitle();
}

/*  Justify - Gets title justification option.
 *
 *  Params: Pointer to titletype variable
 */
void Justify( titletype *ptt )
{
    int iChoice;

    PushTitle( pszJustify[0] );
    iChoice = Menu( pszJustify );
    switch( iChoice )
    {

        /* Set justification.  */
        case 1:
        case 2:
        case 3:
            ptt->justify = iChoice;
    }
    PopTitle();
}

/*  Legend - Asks whether a legend is desired, and if so, gets
 *  legend options.
 *
 *  Params: None
 */
void Legend()
{
    int iChoice;

    /* Is legend desired?  */
    iChoice = BlankMenu( "Legend", "Legend", "No Legend" );
    switch( iChoice )
    {
        case 1:
            /* If legend, set legend flag and get options.  */
            ce.legend.legend = TRUE;
            PushTitle( pszLegendWindow[0] );
            do
            {
                iChoice = Menu( pszLegendWindow );
                switch( iChoice )
                {

                    case 1:
                        /* Get legend place.  */
                        LegendPlace();
                        break;

                    case 2:
                        /* Query for legend color.  */
                        Help( "Enter a number in the range 0-15.", co.InputColor );
                        ce.legend.textcolor =
                            InputInt( "Text color? ",
                                       ce.legend.textcolor,
                                       0, 15 );
                        break;

                    case 3:
                        /* Get auto or manual sizing.  */
                        PushTitle( "Auto Legend" );
                        iChoice = Menu( pszAuto );

                        /* Set or clear the autosize flag. If manual
                         * sizing was selected, get legend size.
                         */
                        switch( iChoice )
                        {
                            case 1:
                                ce.legend.autosize = TRUE;
                                break;

                            case 2:
                                ce.legend.autosize = FALSE;
                                WindowSize( &ce.legend.legendwindow );
                        }
                        PopTitle();
                        break;

                    case 4:
                        /* Query for background color.  */
                        Help( "Type a number in the range 0-15.", co.InputColor );
                        ce.legend.legendwindow.background =
                            InputInt( "Background color? ",
                                       ce.legend.legendwindow.background,
                                       0, 15 );
                        break;

                    case 5:
                        /* Get border options for legend window.  */
                        Border( &ce.legend.legendwindow );
                }

            } while( iChoice != ESCAPE );
            PopTitle();
            break;

        case 2:
            /* If no legend wanted, clear flag.  */
            ce.legend.legend = FALSE;

    }
    PopTitle();
}

/*  LegendPlace - Gets legend placement option.
 *
 *  Params: None
 */
void LegendPlace()
{
    int iChoice;

    /* Get legend placement.  */
    PushTitle( pszPlace[0] );
    iChoice = Menu( pszPlace );
    switch( iChoice )
    {

        case 1:
            ce.legend.place = _PG_RIGHT;
            break;

        case 2:
            ce.legend.place = _PG_BOTTOM;
            break;

        case 3:
            ce.legend.place = _PG_OVERLAY;
    }
    PopTitle();
}

/*  ScreenMode - Gets a new screen mode.
 *
 *  Params: None
 */
void ScreenMode()
{
    int iMode, i;
    char szTmp[80], szHlp[80];
    static int iLegal[5][11] =
    {
        { 3, 4, 5, 6 },
        { 4, 4, 5, 6, 64 },
        { 4, 4, 5, 6, 19 },
        { 7, 4, 5, 6, 13, 14, 15, 16 },
        { 10, 4, 5, 6, 13, 14, 15, 16, 17, 18, 19 }
    };
    int iAdaptor;

    PushTitle( "Screen Mode" );

    /* Show appropriate help line for adaptor.  */
    switch( vc.adapter )
    {
        case _HGC:
            PopTitle();
            return;
        case _CGA:
            iAdaptor = 0;
            break;
        case _OCGA:
            iAdaptor = 1;
            break;
        case _MCGA:
            iAdaptor = 2;
            break;
        case _EGA:
        case _OEGA:
            if( vc.adapter == _MONO )
            {
                PopTitle();
                return;
            }
            else
                iAdaptor = 3;
            break;
        case _VGA:
        case _OVGA:
            iAdaptor = 4;
            break;
    }

    /* Form the help line (which gives the choices legal for
     * the adaptor sensed in the user's machine).
     */
    for( iMode = 0, szHlp[0] = '\0'; iMode <= iLegal[iAdaptor][0]; ++iMode )
    {
        if( iMode == 0 )
            strcpy( szTmp, "Enter " );
        else if( iMode < iLegal[iAdaptor][0] )
            sprintf( szTmp, "%d, ", iLegal[iAdaptor][iMode] );
        else
            sprintf( szTmp, "or %d", iLegal[iAdaptor][iMode] );
        strcat( szHlp, szTmp );
    }

    WrtForm( 18 );
    Help( szHlp, co.InputColor );

    /* Query for screen mode. */
    for( ;; )
    {
        iMode = InputInt( "Screen Mode? ", si.mode, 1, 64 );
        for( i = 1; i <= iLegal[iAdaptor][0]; ++i ) /* Test legal values    */
            if( iMode == iLegal[iAdaptor][i] )      /* If a match is found  */
                break;                              /* Terminate for loop   */
        if( iMode == iLegal[iAdaptor][i] )          /* If it's a match,     */
            break;                                  /* terminate do loop,   */
        else                                        /* otherwise BEEP, and  */
            putchar( BEEP );                        /* solicit correct data */
    }

    PopTitle();
    if( SetGraphMode( iMode ) )
        _setvideomode( _DEFAULTMODE );
    else
        ShowError( _PG_BADSCREENMODE );

    /* Force rescaling of the chart by resetting the window
     * rectangles for the chart and data windows to zero size.
     */
    ce.chartwindow.x1 = ce.chartwindow.x2 = ce.chartwindow.y1 =
        ce.chartwindow.y2 = 0;
    ce.datawindow = ce.chartwindow;
}

/*  TitleOpt - Gets title options.
 *
 *  Params: ptt - Pointer to titletype variable
 */
void TitleOpt( titletype *ptt )
{
    int iChoice;

    PushTitle( pszTitleOpt[0] );
    do
    {
        iChoice = Menu( pszTitleOpt );
        switch( iChoice )
        {

            case 1: 
                /* Query for title text.  */
                Help( "70 characters maximum length.", co.InputColor );
                InputStr( "Enter Text: ", ptt->title );
                break;

            case 2: 
                /* Query for title color color.  */
                Help( "Enter a number in the range 0-15.", co.InputColor );
                ptt->titlecolor =
                    InputInt( "Title Color? ", ptt->titlecolor, 0, 15 );
                break;

            case 3:
                /* Get justify option.  */
                Justify( ptt );
        }
        ClrHelp();

    } while( iChoice != ESCAPE );
    PopTitle();
}

/*  Titles - Manages Main and Sub title menus.
 *
 *  Params: None
 */
void Titles()
{
    int iChoice;

    PushTitle( pszTitles[0] );
    do
    {
        iChoice = Menu( pszTitles );
        switch( iChoice )
        {

            case 1:
                /* Fix menu title and get options for main title.  */
                pszTitleOpt[0] = "MainTitle";
                TitleOpt( &ce.maintitle );
                break;

            case 2:
                /* Fix menu title and get options for subtitle.  */
                pszTitleOpt[0] = "Sub Title";
                TitleOpt( &ce.subtitle );
        }
    } while( iChoice != ESCAPE );
    PopTitle();
}

/*  Windows - Selects chart or data window, and gets options for either.
 *
 *  Params: None
 */
void Windows()
{
    int iChoice;

    PushTitle( pszWindows[0] );
    do
    {

        /* Select window and get options for it.  */
        iChoice = Menu( pszWindows );
        switch( iChoice )
        {

            case 1:
                ChartWindow();
                break;

            case 2:
                DataWindow();

        }
    } while( iChoice != ESCAPE );
    PopTitle();
}

/*  WindowSize - Gets coordinates for window location and size.
 *
 *  Params: pwt - pointer to windowtype variable
 */
void WindowSize( windowtype *pwt )
{
    int iChoice;

    /* Get window size settings.  */
    PushTitle( pszSize[0] );
    do
    {
        /* Query for top, bottom, left, or right of window.  */
        iChoice = Menu( pszSize );
        switch( iChoice )
        {

            case 1:
                Help( "Enter window top in pixels.", co.InputColor );
                pwt->y1 = InputInt( "Top? ", pwt->y1, 0, si.yMax );
                break;

            case 2:
                Help( "Enter window Left in pixels.", co.InputColor );
                pwt->x1 = InputInt( "Left? ", pwt->x1, 0, si.xMax );
                break;

            case 3:
                Help( "Enter window bottom in pixels.", co.InputColor );
                pwt->y2 = InputInt( "Bottom? ", pwt->y2, 0, si.yMax );
                break;

            case 4:
                Help( "Enter window right in pixels.", co.InputColor );
                pwt->x2 = InputInt( "Right? ", pwt->x2, 0, si.xMax );
        }
    } while( iChoice != ESCAPE );
    PopTitle();
}
