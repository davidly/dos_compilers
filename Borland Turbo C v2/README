                        WELCOME TO TURBO C 2.0
                        ----------------------

This README file contains important, last minute information
about Turbo C 2.0. The HELPME!.DOC file on the COMMAND LINE/UTILITIES
disk also answers many common Technical Support questions.


TABLE OF CONTENTS
-----------------
  1. How to Get Help
  2. Installation
  3. Important Notes
  4. Corrections to the Manuals
  5. Additional Notes
  6. Notes for Turbo Prolog Users
  7. Files on the Disks


 1. HOW TO GET HELP
-------------------

  If you have any problems, please read this file, the
  HELPME!.DOC file, and the Turbo C manuals first. If you still
  have a question and need assistance, help is available from
  the following sources:

  1. Type GO BOR on the CompuServe bulletin board system for
     instant access to the Borland forums with their libraries of
     technical information and answers to common questions.

     If you are not a member of CompuServe, see the enclosed special
     offer, and write for full details on how to receive a free
     IntroPak containing a $15 credit toward your first month's on-
     line charges.

  2. Check with your local software dealer or users' group.

  3. Write to us at the following address:

     Borland International
     Turbo C Technical Support
     1800 Green Hills Road
     P.O. Box 660001
     Scotts Valley, CA  95066-0001

     Please remember to include your serial number or we will be
     unable to process your letter.

  4. If you have an urgent problem that cannot wait and you have sent
     in the license agreement from the front of your manual, you may
     call the Borland Technical Support Department at (408) 438-5300.
     Please have the following information ready before calling:

     a. Product name and serial number on your original distribution
        disk.  Please have your serial number ready or we will be
        unable to process your call.

     b. Product version number. The version number for Turbo C is
        displayed when you first load the program and before you
        press any keys.

     c. Computer brand, model, and the brands and model numbers of
        any additional hardware.

     d. Operating system and version number. (The version number can
        be determined by typing VER at the MSDOS prompt.)

     e. Contents of your AUTOEXEC.BAT file.

     f. Contents of your CONFIG.SYS file.


 2. INSTALLATION
----------------
  The INSTALL/HELP disk contains a program called INSTALL.EXE that
  will assist you with the installation of Turbo C 2.0. There are
  three options for installation:

  1. Hard Disk - This option allows you to pick the subdirectories
     where the files will be loaded. It will create a TURBOC.CFG
     file based on those directories.

  2. Update from TC 1.5 - This allows for an easy update from version
     1.5.  After the files are copied, all the installed options
     from your current TC.EXE will be transferred to the new one.
     This is especially useful if you have modified the colors or
     editor keys.

  3. Floppy Disk - This option will build either a command line or
     Integrated Development Environment version for a two drive
     system. Be sure to have three formatted disks ready before
     you start.

  To start the installation, change your current drive to the one
  that has the install program on it and type INSTALL.  You will
  be given instructions in a box at the bottom of the screen for
  each prompt. For example, if you will be installing from drive
  A:, type:

    A:
    INSTALL

  You should read the rest of this README file to get further
  information about this release before you do the installation.


 3. IMPORTANT NOTES
-------------------

  o The file HELPME!.DOC contains discussions of common questions
    and answers concerning Turbo C 2.0. You should consult it for
    answers to problems that aren't covered in this file or in
    the manuals.

  o If you are running INSTALL or TCINST on a laptop or any other
    system that uses an LCD or composite display, you should set
    your system to black and white mode before running INSTALL
    or TCINST. You can do this from DOS with the following command
    line:

      mode bw80

    or, you can force INSTALL or TCINST to come up in black and
    white mode by using the /b switch:

      tcinst /b

  o /P PARAMETER FOR TC.EXE. A new command-line switch controls
    palette swapping on EGA video adapters. Using this switch

      tc /p hello

    is recommended only when the user program modifies the EGA
    palette registers. When /P is specified, the EGA palette will be
    restored each time the screen is swapped. In general, you don't
    need to use this switch unless your program modifies the EGA
    palette registers, or unless your program uses BGI to change
    the palette.

  o A program that takes over interrupt 9 cannot be debugged
    with the integrated debugger. Use the standalone Turbo Debugger
    instead.

  o exec() WITH NOVELL NETWORK. Versions of the Novell network
    system software earlier than 2.01-2 do not support a DOS
    call used by exec(), spawn(), and system(). If you are using
    the Integrated Development Environment to run a program that
    uses any of these functions and you have early Novell system
    software, run the program from DOS. To do this from the
    Integrated Development Environment you can use Alt-F/O.

  o If you used the INSTALL program to upgrade from version 1.5,
    or if you used CINSTXFR to transfer options from an
    installation of version 1.5, check the setting of the
    standard stack frame option in the Integrated Development
    Environment (Alt-O/C/C/S). If you are going to use the
    integrated debugger this option should be turned ON.

  o If you are having problems with the call stack or qualified
    names, make sure you have compiled with the standard stack
    frame option turned on.

  o The ANSI draft has changed the syntax of labels.  A label now
    must always be followed by a statement.  This means that code
    like this is no longer accepted:

      {
        .
        .
        .
        jump_label:
      }

    If you have code like this, change it to look like this:

      {
        .
        .
        .
        jump_label:
        ;       /* need a statement here! */
      }

  o TCC has a switch to specify which assembler to look for. By
    default, it will look for TASM.EXE. If you want to use a
    different assembler, use -E<filename>, as described in the
    Reference Guide.

  o When using THELP on an AT&T 6300, be sure to use the /L25
    command-line option, as described in the file THELP.DOC.

  o When you use qualified variable names as described on page
    57 of the User's Guide you don't need to use the module
    name to access a variable that is local to a global
    function. The module name is only needed when you access a
    static variable or a variable that is local to a static
    function.

  o Because of the limited memory available in the Tiny model,
    it no longer supports graphics functions.

  o The Version 1.5 graphics drivers (*.BGI) are not compatible
    with the Version 2.0 graphics library. Use the graphics drivers
    distributed with Version 2.0.

  o When used with a Zenith Z-449 card, the BGI autodetection code
    will always select the 640X480 enhanced EGA mode. If you are
    using the Z-449 with a monitor that is not compatible with
    this mode, it will be necessary to override the GraphDriver
    and GraphMode parameters used in the BGI initgraph() call.


 4. CORRECTIONS TO THE MANUALS
------------------------------

 REFERENCE GUIDE:

 Page

 159  The prototype for the function getdefaultpallette() is
      incorrect. It should be

        struct palettetype * far _Cdecl getdefaultpalette( void );


USER'S GUIDE:

 Page

  57  In the section entitled "Qualifying Variable Names," the
      last sentence should read "...need to type only myfunc.myvar."

  66 The directions for compiling the WORDCNT program are
     incorrect. There is no WORDCNT.PRJ file; all you need to do
     is load the file WORDCNT.C into the editor. Once you have
     done that, the rest of the instructions are correct.

 5. ADDITIONAL NOTES
--------------------

  5.1 NOTES FOR VERSION 1.0 & 1.5 USERS
  -------------------------------------

  o You must use the Version 2.0 libraries with the 2.0 compilers.

  o The Integrated Development Environment no longer displays the
    message "Press any key to return to Turbo C..." when your
    program terminates. Instead, at the end of your program the
    User screen is replaced by the Integrated Development
    Environment. To view the User screen, press Alt-F5 or
    select Alt-R/S. When you are viewing the User screen,
    pressing any key will return you to the Integrated
    Development Environment.

  o A new pseudo-variable has been added. _FLAGS now contains the
    value of the flags register so you can test the flags at any
    point in your program.

  o The ssignal() and gsignal() functions are no longer
    supported. See the section in this README on how to convert
    programs that use them.

  o The cprintf() function now works as documented. It does not
    translate line-feeds into CR/LF combinations.

  o Some compatibles had a problem under Version 1.5 because it
    used interrupt 18H. Version 2.0 does not use this interrupt,
    so you shouldn't encounter this problem anymore.

  o The program TCINST.COM in Version 1.0 has been changed to an
    .EXE file. You should delete the TCINST.COM program before
    trying to run the new TCINST.EXE. Otherwise, MS-DOS will actually
    run the old one.

  o The FILE structure for streams in Version 1.0 (but not 1.5) has
    been changed, so that the function tmpfile() could be implemented.
    You should recompile any modules that use stream I/O.

  5.2  THELP
  ----------

  THELP is a memory-resident utility program that gives you
  access to the Turbo C context-sensitive help system from any
  program. You don't need to use THELP if you're in the
  Integrated Development Environment, but it is especially useful
  if you use the command line compiler and your own text editor,
  or if you are debugging with the standalone Turbo Debugger. To
  use THELP, load THELP.COM into memory by typing at the DOS
  command line:

    thelp

  You activate ("pop-up") THELP by typing its hot key -- by
  default numeric keypad <5>. All Turbo C help commands apply
  (F1, Ctrl-F1, Alt-F1). For a complete description of THELP,
  refer to THELP.DOC in the Documentation Subdirectory.

  5.3 USING CINSTXFR.EXE
  ----------------------

  Your Turbo C 2.0 package contains a program named CINSTXFR.EXE,
  which can be used to transfer the configuration of the
  Integrated Development Environment from your copy of Turbo C
  1.5 (not for 1.0) to your new installation of Turbo C 2.0. This
  program is run automatically by INSTALL.EXE if you select the
  option to "Update Hard Drive Copy of Turbo C 1.5 to Turbo C 2.0."
  If you prefer to do this yourself, you can run CINSTXFR.EXE from
  the DOS command line.

  CINSTXFR.EXE takes two arguments: the first is the name of your
  Turbo C 1.5 Integrated Development Environment file (usually
  TC.EXE), and the second is the name of your Turbo C 2.0
  Integrated Development Environment file (also usually TC.EXE).
  Either one of these names can also include a path name.

  For example, if your copy of the Turbo C 1.5 Integrated
  Development Environment file is named TC.EXE and is in a
  directory named \TURBOC and your copy of the Turbo C 2.0
  Integrated Development Environment file is also named TC.EXE
  but is located in a directory named \TC2, the command line to
  copy the configuration from 1.5 to 2.0 would look like this:

    CINSTXFR \TURBOC\TC.EXE \TC2\TC.EXE

  This will transfer all the options that you installed in
  your copy of Turbo C 1.5 to your copy of Turbo C 2.0.

  CINSTXFR.EXE does not work with Turbo C 1.0. If you are
  upgrading from Turbo C 1.0, you will have to install the
  options yourself.

  5.4 CHANGED SWITCHES FOR OBJXREF
  --------------------------------

  OBJXREF is an object module cross reference utility and is
  described on page 528 of the Turbo C Reference Guide.
  The /O option (object files directory) has been changed to the
  /D (directories) option. The switch now allows for multiple
  search directories to be specified. The new syntax is:

    OBJXREF /Ddir1[;dir2[;dir3]]
                or
    OBJXREF /Ddir1 [/Ddir2] [/Ddir3]

  OBJXREF will search each of the directories in the specified
  order for all object and library files. If no /D option is
  used, only the current directory will be searched. However,
  if a /D option is used, the current directory will NOT be
  searched unless it is included in the directory list. For
  example, to first search the BORLAND directory for files and
  then search the current directory, you would type

    OBJXREF /Dborland;.

  If multiple search directories are specified and a file
  matching the file specification is found, OBJXREF will include
  the file as part of the cross-reference. OBJXREF will only
  continue to search the other directories for the same file
  specification if the file specification contains wildcards.

  A new option has been added to allow you to specify an output
  file where OBJXREF will send any reports generated. The new
  option is the /O option, and has the following syntax:

    OBJXREF myfile.obj /RU /Ofilename.ext

  By default, all output is sent to the console.

  5.5 CONVERSION INFORMATION FOR ssignal() AND gsignal()
  ------------------------------------------------------

  Note: The C library and SIGNAL.H no longer support the ssignal()
  and gsignal() functions.

  ssignal() and gsignal() were from the old UNIX System III
  days. The ANSI standard no longer supports them nor does the
  current UNIX System V Interface Definition specification. To
  ease portation problems for people moving older code to Turbo
  C, we supply the source for the functions that came with TC
  1.0 and TC 1.5. Also, the following discussion describes how
  code can be converted to do the same sort of things that
  ssignal() and gsignal() do without actually using them.

  NOTE: The constants defined in SIGNAL.H for SIG_IGN and
        SIG_DFL are different from the constants that were in
        TC 1.0 and TC 1.5.

  By using a globally declared array of function pointers, you
  can simulate the actions of ssignal() and gsignal() by using
  the following macros. Notice how the global table entry [0] is
  used as a temporary variable in the ssignal macro allowing the
  macro to swap the values and still return the original one.

    int (*_sigTable[16]) =
        {
        SIG_IGN, SIG_IGN, SIG_IGN, SIG_IGN,
        SIG_IGN, SIG_IGN, SIG_IGN, SIG_IGN,
        SIG_IGN, SIG_IGN, SIG_IGN, SIG_IGN,
        SIG_IGN, SIG_IGN, SIG_IGN, SIG_IGN,
        };

    #define ssignal(num, action) \
    ( \
    (((num) < 1) || ((num) > 15)) ? SIG_DFL : \
      ( \
      (_sigTable[0] = _sigTable[(num)]),  /* List of actions     */ \
         _sigTable[(num)] = (action),     /* The last expression */ \
            _sigTable[0]                  /* is the return value */ \
      ) \
    ) \

    #define gsignal(num) \
    ( \
    (((num) < 1) || ((num) > 15)) ? 0 : \
      ( \
      (_sigTable[(num)] == SIG_IGN) ? 1 : \
         ( \
           (_sigTable[(num)] == SIG_DFL) ? 0 : (*_sigTable[(num)])() \
      ) \
    ) \
   ) \


 6. NOTES FOR TURBO PROLOG USERS
--------------------------------

  o If you are linking C code with programs generated by Turbo
    Prolog 2.0, use the file INIT.OBJ provided on the
    EXAMPLES/BGI/MISC disk of the Turbo C 2.0 package instead of
    the file provided with Turbo Prolog 2.0.  There have been some
    changes made in Turbo C 2.0 that require the use of this new file.

  o If your C code uses floating point math and you link with the
    emulator library, Prolog will not automatically detect a math
    coprocessor chip. If you want to force the program to use the
    coprocessor, link it with FP87.LIB instead of EMU.LIB.


 7. FILES ON THE DISKS
----------------------

  INSTALL/HELP
  ------------
  INSTALL  EXE  -  Installation program
  README   COM  -  Reads this README
  TCHELP   TCH  -  Help file for Turbo C
  THELP    COM  -  Pop-up utility to access TCHELP.TCH
  THELP    DOC  -  Documentation for THELP.COM
  README        -  This file

  INTEGRATED DEVELOPMENT ENVIRONMENT
  ----------------------------------
  TC       EXE  -  Turbo C Compiler
  TCCONFIG EXE  -  Program to convert configuration files
  MAKE     EXE  -  Program for managing projects
  GREP     COM  -  Turbo GREP program
  TOUCH    COM  -  Program that updates a file's date and time

  COMMAND LINE/UTILITIES
  ----------------------
  TCC      EXE  -  Command-line version of Turbo C Compiler
  CPP      EXE  -  Turbo C preprocessor
  TCINST   EXE  -  Installation program for TC.EXE
  TLINK    EXE  -  Borland Turbo Linker
  HELPME!  DOC  -  Common questions and answers

  LIBRARIES
  ---------
  C0S      OBJ  -  Small model startup code
  C0T      OBJ  -  Tiny model startup code
  C0L      OBJ  -  Large model startup code
  MATHS    LIB  -  Small model math library
  MATHL    LIB  -  Large model math library
  CS       LIB  -  Small model run-time library
  CL       LIB  -  Large model run-time library
  EMU      LIB  -  8087 emulator library
  GRAPHICS LIB  -  Graphics library
  FP87     LIB  -  8087 library
  TLIB     EXE  -  Borland Turbo Librarian

  HEADER FILES/LIBRARIES
  ----------------------
  ???????? H    -  Turbo C header files
  <SYS>         -  Subdirectory with SYS\*.H header files
  C0C      OBJ  -  Compact model startup code
  C0M      OBJ  -  Medium model startup code
  MATHC    LIB  -  Compact model math library
  MATHM    LIB  -  Medium model math library
  CC       LIB  -  Compact model run-time library
  CM       LIB  -  Medium model run-time library

  EXAMPLES/BGI/MISC
  -----------------
  UNPACK   COM  -  Program to unpack the .ARC files
  OBJXREF  COM  -  Object file cross-reference utility
  C0H      OBJ  -  Huge model startup code
  MATHH    LIB  -  Huge model math library
  CH       LIB  -  Huge model run-time library
  GETOPT   C    -  Parses options in command line
  HELLO    C    -  Example Turbo C program
  MATHERR  C    -  Source code for handling math library exceptions
  SSIGNAL  C    -  Source code for ssignal and gsignal functions
  CINSTXFR EXE  -  Program to copy TC 1.5 installation to TC 2.0
  INIT     OBJ  -  Initialization code for use when linking with Prolog

  BGI      ARC  -  BGI drivers and fonts
    BGIOBJ   EXE - Conversion program for fonts and drivers
    ATT      BGI - Graphics driver for ATT400 graphics card
    CGA      BGI - Graphics driver for CGA
    EGAVGA   BGI - Graphics driver for EGA and VGA
    HERC     BGI - Graphics driver for Hercules
    IBM8514  BGI - Graphics driver for IBM 8514 graphics card
    PC3270   BGI - Graphics driver for PC3270
    GOTH     CHR - Font for gothic character set
    LITT     CHR - Font for small character set
    SANS     CHR - Font for sans serif character set
    TRIP     CHR - Font for triplex character set
    BGIDEMO  C   - Graphics demonstration program

  STARTUP  ARC  -  ARC file with startup source code and related files
    RULES    ASI - Assembler include file for interfacing with Turbo C
    C0       ASM - Assembler source for startup code
    SETARGV  ASM - Assembler source code for parsing the command line
    SETENVP  ASM - Assembler source code for preparing the environment
    BUILD-C0 BAT - Batch file for building the startup code modules
    MAIN     C   - Alternative, stripped-down C main file
    EMUVARS  ASI - Assembler variable declarations for emulator
    WILDARGS OBJ - Object code for module to expand wildcard arguments

  EXAMPLES ARC  -  Various C examples code
    CPASDEMO PAS - Pascal program that demonstrates Turbo Pascal 4.0 -
                   Turbo C interface
    CPASDEMO C   - C example module for the Turbo Pascal 4.0 - Turbo C
                   interface demonstration
    CTOPAS   TC  - Configuration file for use with TC.EXE that
                   creates Turbo C modules in the correct format
                   for linking with Turbo Pascal 4.0 programs
    CBAR     C   - Example function to be used with PBAR.PRO
    PBAR     PRO - Example Turbo Prolog program demonstrating interface
                   with Turbo C
    WORDCNT  C   - Example program demonstrating source level debugging.
                   NOTE: DO NOT RUN THIS PROGRAM WITHOUT READING THE
                         DISCUSSION IN THE MANUAL.  IT CONTAINS
                         DELIBERATE ERRORS.
    WORDCNT  DAT - Data file for use by WORDCNT.C

  MCALC    ARC  -  Mcalc sources and doc
    MCALC    DOC - MicroCalc documentation
    MCALC    C   - MicroCalc main program source code
    MCINPUT  C   - MicroCalc input routines source code
    MCOMMAND C   - MicroCalc commands source code
    MCPARSER C   - MicroCalc input parser source code
    MCUTIL   C   - MicroCalc utilities source code
    MCDISPLY C   - MicroCalc screen display source code
    MCALC    H   - The header file for MicroCalc
    MCALC    PRJ - The MicroCalc project file
