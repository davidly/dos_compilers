echo off
rem    Batch File to Compile, Link and Run the TICTAC demonstration program.
rem    This batch file can be run from your DOS prompt. If you specify the
rem    "animate" parameter to the batch file then the TICTAC program will be
rem    compiled and then ANIMATED.
cls
echo .
echo     *------------------* TICTAC demonstration program *-------------------*
echo     *                                                                     *
echo     * Please ensure that you have followed the installation instructions  *
echo     * for COBOL, which are found in the COBOL Getting Started manual.
echo     * This means that you have included the directory containing your     *
echo     * COBOL Compiler on your DOS PATH and you will have to set up the
echo     * COBDIR environment variable to also include the COBOL Compiler      *
echo     * directory.                                                          *
echo     *                                                                     *
echo     * Press Ctrl+C to exit if you have NOT properly installed your        *
echo     * COBOL Compiler, or copied the required files.                       *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
pause
if not exist TICTAC.CBL goto errtic
:cobret
if %1. == animate. goto doanim
if %1. == ANIMATE. goto doanim
cls
echo     *---------------------------------------------------------------------*
echo     *          Compiling the TICTAC demonstration program                 *
echo     *---------------------------------------------------------------------*
echo on
COBOL TICTAC.CBL;
echo off
if errorlevel 1 goto nocob
echo     *---------------------------------------------------------------------*
echo     *                Compiling successfully completed                     *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                   Linking the TICTAC program                        *
echo     *                                                                     *
echo     *  Notice inclusion of ADIS.                                          *
echo     *                                                                     *
if %1. == lcobol. goto ltxtl
if %1. == LCOBOL. goto ltxtl
echo     *  The program will be linked to run with the shared run-time,        *
echo     *  COBLIB. The EXE file created requires the file COBLIB.DLE to be    *
echo     *  present in the COBOL system directories in order to operate.       *
echo     *                                                                     *
echo     *  Restart this batch file with the parameter, LCOBOL, to see the     *
echo     *  program statically linked so that it is independent of any other   *
echo     *  files at run-time. (i.e. enter TTDEMO LCOBOL)                      *
goto ltxte
:ltxtl
echo     *  The program will be statically linked. That is, the COBOL run-time *
echo     *  support required for this program is linked into the EXE file      *
echo     *  making it independent of any other files at run-time.              *
:ltxte
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
if %1. == lcobol. goto linkl
if %1. == LCOBOL. goto linkl
:linkc
echo on
LINK TICTAC+ADIS+ADISKEY+ADISINIT/NOD,,,COBLIB+COBAPI                           ;
echo off
if errorlevel 1 goto nolink
goto linke
:linkl
echo on
LINK TICTAC+ADIS+ADISKEY+ADISINIT/NOD,,,LCOBOL+COBAPI                           ;
echo off
if errorlevel 1 goto nolink
:linke
echo off
echo     *---------------------------------------------------------------------*
echo     *                 Linking successfully completed                      *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                         Running TICTAC                              *
echo     *                                                                     *
echo     *  Can you beat the Program?    It is possible !!                     *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo on
TICTAC
echo off
echo .
cls
echo     *---------------------------------------------------------------------*
echo     *                                                                     *
echo     * Have you tried the COBOL ANIMATOR ?                                 *
echo     *                                                                     *
echo     * For an example of how to get going with the ANIMATOR, rerun this    *
echo     * batch file with the "animate" parameter. That is, type the          *
echo     * following:  "TTDEMO ANIMATE"                                        *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
goto endtic
:doanim
cls
echo     *---------------------------------------------------------------------*
echo     *     Compiling the TICTAC demonstration program for Animation        *
echo     *---------------------------------------------------------------------*
echo on
COBOL TICTAC.CBL ANIM;
echo off
if errorlevel 1 goto nocob
echo     *---------------------------------------------------------------------*
echo     *                Compiling successfully completed                     *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                    Animating the TICTAC program                     *
echo     *---------------------------------------------------------------------*
echo on
ANIMATE TICTAC
echo off
if errorlevel 1 goto nocob
echo     *---------------------------------------------------------------------*
echo     *                Animating successfully completed                     *
echo     *---------------------------------------------------------------------*
pause
goto endtic
:nocob
echo     ***********************************************************************
echo     *                                                                     *
echo     * An error occurred while running the Compiler. Please ensure that    *
echo     * you have installed all the necessary files.                         *
echo     *                                                                     *
echo     ***********************************************************************
goto endtic
:nolink
echo     ***********************************************************************
echo     *                                                                     *
echo     * An error occurred while running the Linker. Please ensure that you  *
echo     * have installed all the necessary files.                             *
echo     *                                                                     *
echo     ***********************************************************************
goto endtic
:errtic
echo     ***********************************************************************
echo     *                                                                     *
echo     * The TICTAC program is not in the current directory. Either change   *
echo     * directory or copy TICTAC.CBL from your issue disks.                 *
echo     *                                                                     *
echo     ***********************************************************************
:endtic
echo     *---------------------------------------------------------------------*
echo     *                   End of TICTAC Demonstration                       *
echo     *---------------------------------------------------------------------*
