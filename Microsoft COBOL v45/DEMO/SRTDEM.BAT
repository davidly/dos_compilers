echo off
rem    Batch File to Compile, Link, Bind and Run the SORTDEMO demonstration
rem    program. This batch file can be run from your DOS prompt.
rem                                                                 v 1.2.3
cls
echo .
echo     *------------------* SORTDEMO Demonstration Program *-----------------*
echo     *                                                                     *
echo     * This batch stream demonstrates how a program can be "bound" to      *
echo     * enable it to run on DOS and OS/2.                                   *
echo     *                                                                     *
echo     * Bound programs are linked as OS/2 programs prior to binding.        *
echo     * Therefore, in order for this batch stream to operate it is          *
echo     * necessary to have the OS/2 version of the compiler available as     *
echo     * well as the DOS version. This will ensure that the files needed for *
echo     * linking an OS/2 program, and for binding, are all loaded.           *
echo     *                                                                     *
echo     * Please ensure that you have followed the installation instructions  *
echo     * for COBOL, using SETUP to load the DOS compiler, the OS/2 compiler  *
echo     * and the Microsoft Utilities, including the OS/2 specific files.     *
echo     *                                                                     *
echo     * Press Ctrl+C to exit if you have NOT properly installed your        *
echo     * COBOL Compiler, or copied the required files.                       *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
pause
cls
echo .
echo     *------------------* SORTDEMO demonstration program *-----------------*
echo     *                                                                     *
echo     * SORTDEMO must be "bound" before it will run under DOS, since it     *
echo     * contains calls to OS/2 API functions.                               *
echo     *                                                                     *
echo     * To bind the program, the files API.LIB and OS2.LIB must be copied   *
echo     * into the current directory. They will have been loaded by SETUP     *
echo     * into the directory you selected for the Microsoft Utilities.        *
echo     *                                                                     *
echo     * Also, BIND.EXE must be available in the current directory or in a   *
echo     * directory on the DOS PATH.                                          *
echo     *                                                                     *
echo     * Press Ctrl+C to exit if these files are not present.                *
echo     *                                                                     *
echo     *---------------------------------------------------------------------*
echo .
pause
cls
if %COBDIR%. == . goto errcob
if not exist API.LIB goto errpre
if not exist OS2.LIB goto errpre
if not exist %cobdir%\CBLBIND.NOT goto erros2
if not exist %cobdir%\CBLBIND.LIB goto erros2
if %1. == lcobol. if not exist %cobdir%\LCOBOL.LIB goto erros2
if %1. == LCOBOL. if not exist %cobdir%\LCOBOL.LIB goto erros2
if %1. == . if not exist %cobdir%\COBLIB.LIB goto erros2
if %1. == . if not exist %cobdir%\COBLIB.DLE goto erros2
if not exist SORTDEMO.CBL goto errtic
:cobret
if %1. == animate. goto doanim
if %1. == ANIMATE. goto doanim
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
echo     *  Note that the program is linked to run under OS/2. The binding     *
echo     *  process which follows the link enables it to be run under DOS as   *
echo     *  well as OS/2.                                                      *
echo     *                                                                     *
if %1. == lcobol. goto ltxtl
if %1. == LCOBOL. goto ltxtl
echo     *  The program will be linked to run with the shared run-time,        *
echo     *  COBLIB. The EXE file created requires the file COBLIB.DLE to be    *
echo     *  present in the COBOL system directories in order to operate.       *
echo     *                                                                     *
echo     *  Since the shared run-time handles all memory under DOS, we need    *
echo     *  to free some back to allow the API calls to work. Setting          *
echo     *  environment variable COBPOOL will do this.                         *
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
if %1. == lcobol. goto linkl
if %1. == LCOBOL. goto linkl
:linkc
echo on
LINK SORTDEMO/NOD,,,COBLIB+OS2 ;
SET COBPOOL=10
echo off
goto linke
:linkl
echo on
LINK SORTDEMO/NOD,,,LCOBOL+OS2 ;
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
echo     *                   Binding the SORTDEMO program                      *
echo     *---------------------------------------------------------------------*
echo on
BIND SORTDEMO %cobdir%\CBLBIND.LIB OS2.LIB -N @%cobdir%\CBLBIND.NOT
echo off
if errorlevel == 1 goto binderr
echo     *---------------------------------------------------------------------*
echo     *            Binding of SORTDEMO has completed successfully           *
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
goto endsort
:nocob
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     *  An error occured while compiling SORTDEMO. Please ensure that you  *
echo     *  have installed all the necessary files.                            *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:linkerr
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * An error occured while linking. Please ensure that you have         *
echo     * installed all the necessary files.                                  *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:binderr
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * An error occured during the Bind process. Please ensure that you    *
echo     * have installed all the necessary files and that these files are in  *
echo     * the current working directory or accessible via the DOS PATH, as    *
echo     * appropriate.                                                        *
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
:doanim
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * The SORTDEMO program cannot be Animated on DOS.                     *
echo     *                                                                     *
echo     ***********************************************************************
goto endsort
:errpre
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
echo     * One or both of the files API.LIB and OS2.LIB are not in the         *
echo     * current directory. The bind process will not work correctly without *
echo     * these files. Please copy them into the current directory before     *
echo     * restarting SRTDEM.                                                  *
echo     *                                                                     *
echo     ***********************************************************************
if not exist %cobdir%\CBLBIND.NOT goto erros2
if not exist %cobdir%\CBLBIND.LIB goto erros2
if %1. == LCOBOL. if not exist %cobdir%\LCOBOL.LIB goto erros2
if %1. == lcobol. if not exist %cobdir%\LCOBOL.LIB goto erros2
if %1. == . if not exist %cobdir%\COBLIB.LIB goto erros2
if %1. == . if not exist %cobdir%\COBLIB.DLE goto erros2
if not exist SORTDEMO.CBL goto errtic
goto endsort
:erros2
echo     ***********************************************************************
echo     *                          *** ERROR ***                              *
echo     *                                                                     *
if %1. == LCOBOL. goto los2l
if %1. == lcobol. goto los2l
echo     * Some or all of the files CBLBIND.LIB, CBLBIND.NOT, COBLIB.LIB and   *
echo     * COBLIB.DLL which are loaded by SETUP with the OS/2 compiler, are    *
goto los2e
:los2l
echo     * Some or all of the files CBLBIND.LIB, CBLBIND.NOT, and              *
echo     * LCOBOL.LIB which are loaded by SETUP with the OS/2 compiler, are    *
:los2e
echo     * not in the COBOL system directory (identified by the environment    *
echo     * variable, COBDIR). The link and bind processes in this batch stream *
echo     * will not work correctly without these files. Please load them into  *
echo     * the COBOL system directory before restarting SRTDEM.                *
echo     *                                                                     *
echo     ***********************************************************************
if not exist SORTDEMO.CBL goto errtic
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
:endsort
echo     *---------------------------------------------------------------------*
echo     *                   End of SORTDEMO Demonstration                     *
echo     *---------------------------------------------------------------------*
