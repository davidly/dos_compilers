echo off
rem    Batch File to Compile, Link and Run the SORTDEMO demonstration program.
rem    This batch file can be run from your OS/2 prompt. If you specify the
rem    "animate" parameter to the batch file then the SORTDEMO program will be
rem    compiled, linked and then ANIMATED.
rem                                                                 v 1.2.2
cls
echo .
echo     *------------------* SORTDEMO demonstration program *-----------------*
echo     *                                                                     *
echo     * The SORTDEMO program demonstrates how to use OS/2 function calls    *
echo     * in COBOL programs, and how to animate programs containing such      *
echo     * calls. This batch stream will compile, link and run, or compile     *
echo     * and animate the SORTDEMO program. To obtain animation, invoke this  *
echo     * batch stream with the parameter, ANIMATE.                           *
echo     *                                                                     *
echo     * Please ensure that you have followed the installation instructions  *
echo     * for COBOL, using SETUP to load the OS/2 compiler and the Microsoft  *
echo     * Utilities, including the OS/2 specific files.                       *
echo     *                                                                     *
echo     * Press Ctrl+C to exit if you have NOT properly installed your        *
echo     * COBOL Compiler, or copied the required files.                       *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
pause
cls
if %COBDIR%. == . goto errcob
if not exist SORTDEMO.CBL goto errtic
if %1. == animate. goto doanim
if %1. == ANIMATE. goto doanim
:
if %1. == LCOBOL. if not exist %cobdir%\LCOBOL.LIB goto errlib
if %1. == lcobol. if not exist %cobdir%\LCOBOL.LIB goto errlib
if %1. == . if not exist %cobdir%\COBLIB.LIB goto errlib
if %1. == . if not exist %cobdir%\COBLIB.DLL goto errlib
cls
echo     *---------------------------------------------------------------------*
echo     *          Compiling the SORTDEMO demonstration program               *
echo     *---------------------------------------------------------------------*
echo on
COBOL SORTDEMO.CBL OPTSPEED NOTRICKLE ;
echo off
if errorlevel 1 goto nocob
echo     *---------------------------------------------------------------------*
echo     *          Compilation of SORTDEMO has completed successfully         *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                   Linking the SORTDEMO program                      *
echo     *                                                                     *
if %1. == lcobol. goto ltxtl
if %1. == LCOBOL. goto ltxtl
echo     *  The program will be linked to run with the shared run-time,        *
echo     *  COBLIB. The EXE file created requires the file COBLIB.DLL to be    *
echo     *  present in the current or COBOL system directories in order to     *
echo     *  operate. (The directory must also be on your LIBPATH.)             *
echo     *                                                                     *
echo     *  Restart this batch file with the parameter, LCOBOL, to see the     *
echo     *  program statically linked so that it is independent of any other   *
echo     *  files at run-time. (i.e. enter SRTDEM LCOBOL)                      *
goto ltxte
:ltxtl
echo     *  The program will be statically linked. That is, the COBOL run-time *
echo     *  support required for this program is linked into the EXE file      *
echo     *  making it independent of any other files at run-time.              *
:ltxte
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
if %1. == LCOBOL. goto linkl
if %1. == lcobol. goto linkl
echo on
LINK SORTDEMO/NOD,,,COBLIB+OS2;
echo off
goto linke
:linkl
echo on
LINK SORTDEMO/NOD,,,LCOBOL+OS2;
echo off
:linke
if errorlevel == 1 goto linkerr
if not exist SORTDEMO.EXE goto linkerr
echo     *---------------------------------------------------------------------*
echo     *            Linking of SORTDEMO has completed successfully           *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                         Running SORTDEMO                            *
echo     *---------------------------------------------------------------------*
echo on
SORTDEMO
echo off
if errorlevel == 1 goto runerr
cls
echo .
echo     *---------------------------------------------------------------------*
echo     *                                                                     *
echo     * For an example of how to Animate this program, and others using     *
echo     * calls to OS/2 API functions, rerun this demo, but with a parameter  *
echo     * of ANIMATE (i.e. enter SRTDEM ANIMATE)                              *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
goto endsort
:doanim
cls
echo     *---------------------------------------------------------------------*
echo     *     Compiling the SORTDEMO demonstration program for Animation      *
echo     *---------------------------------------------------------------------*
echo on
COBOL SORTDEMO.CBL ANIM;
echo off
if errorlevel 1 goto nocob
echo     *---------------------------------------------------------------------*
echo     *          Compilation of SORTDEMO has completed successfully         *
echo     *---------------------------------------------------------------------*
pause
cls
echo     *---------------------------------------------------------------------*
echo     *                    Animating the SORTDEMO program                   *
echo     *                                                                     *
echo     * The program calls VIO API functions. In order to ensure that these  *
echo     * write to the user screen rather than the Animator screen, the       *
echo     * FLASH-CALLS directives is used.                                     *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
pause
echo on
ANIMATE SORTDEMO FLASH-CALLS
echo off
echo     *---------------------------------------------------------------------*
echo     * If you terminated the Animation without completing the program your *
echo     * screen may be in the wrong mode. You can restore the default mode   *
echo     * using the "MODE" command. For example, enter                        *
echo     *                  MODE CO80                                          *
echo     *---------------------------------------------------------------------*
goto endsort
:nocob
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * An error occured while compiling SORTDEMO. Please ensure that you   *
echo     * have installed all the necessary files.                             *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:linkerr
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     *    An error occured while linking. Please ensure that you have      *
echo     *    correctly installed all the necessary files.                     *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:runerr
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     *    An error occured while running. Please ensure that you have      *
echo     *    correctly installed the COBOL system.                            *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:errcob
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * The COBDIR environment variable is not set. Please ensure that you  *
echo     * have installed the COBOL system correctly.                          *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:errtic
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * The SORTDEMO program is not in the current directory. Either change *
echo     * directory or copy SORTDEMO.CBL from your issue disks.               *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:errlib
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
if %1. == LCOBOL. goto los2l
if %1. == lcobol. goto los2l
echo     * One or both of the files COBLIB.LIB and COBLIB.DLL (the shared      *
echo     * run-time) required for linking and running this program are         *
goto los2e
:los2l
echo     * The file, LCOBOL.LIB, needed for statically linking this program is *
:los2e
echo     * not in the COBOL system directory (identified by the environment    *
echo     * variable, COBDIR). The link processes in this batch stream will     *
echo     * not work correctly without these files. Please load them into the   *
echo     * COBOL system directory before restarting SRTDEM.                    *
echo     *                                                                     *
echo     ***********************************************************************
:endsort
echo     *---------------------------------------------------------------------*
echo     *                   End of SORTDEMO Demonstration                     *
echo     *---------------------------------------------------------------------*
