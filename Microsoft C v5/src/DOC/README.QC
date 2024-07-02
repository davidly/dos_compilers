
			    README.QC File

	    Release notes for the Microsoft(R) QuickC(TM) Compiler
			     Version 1.01

	      (C) Copyright Microsoft Corporation, 1988


This document contains information on the Microsoft(R) QuickC(TM) Compiler
that is more up to date than that in the printed manuals.

Microsoft improves its languages documentation at the time of reprinting, so
some of the information in this on-line file may already be included in your
manuals.


======================< Other On-Line Documents >==============================

See the README.DOC file for a list of other on-line documents included with
this release.


==============< Requesting Assistance from Microsoft >=========================

If you need to contact Microsoft Product Support for assistance, the four-digit
phone code for the Microsoft QuickC Compiler is 1222.


===========================< Contents >========================================


This file has five parts. Parts 1 - 3 contain notes for each of the manuals
included in this release. Within each of those parts, every note indicates
the manual page to which it refers.

	Part	Information:
	----	------------
	1	Microsoft QuickC Programmer's Guide

	2	Microsoft C Optimizing Compiler Run-Time Library Reference

	3	Microsoft C Optimizing Compiler Language Reference

	4	Differences between QuickC 1.01 and the Microsoft C Optimizing
		Compiler Version 5.10

	5	Bugs Fixed in QuickC 1.01



=========< Part 1: Notes on Microsoft QuickC Programmer's Guide >==============


Important: QuickC Setup
-----------------------
The installation process for QuickC has changed significantly since the
Microsoft QuickC Programmer's Guide was printed. Be sure to read the file
SETUP.DOC before you install QuickC on your system.


The following notes refer to specific pages in the Microsoft QuickC Compiler
Programmer's Guide.

Page	Note
----	----

xxii	System Requirements: Western Digital Hard-Disk Problem
	------------------------------------------------------
	A certain Western Digital hard-disk controller BIOS
	(EPROM #62-000043-010) caused problems when used with QuickC 1.00.
	This release of QuickC eliminates the problem. However, anyone who has
	this BIOS should still contact Western Digital at (800) 847-6181 to
	obtain a revised BIOS.


xxii	System Requirements: Mouse Driver
	---------------------------------
	If you use a Microsoft Mouse, QuickC requires Version 6.0 or later of
	the mouse software. If you have an earlier release, use the MOUSE.COM
	driver provided on distribution disk 3. See your Mouse manual for
	instructions. Don't forget to delete any outdated MOUSE.SYS drivers
	from your CONFIG.SYS file.


xxii	System Requirements: Fixing Keyboard Problems with  FIXSHIFT.COM
	----------------------------------------------------------------
	On some COMPAQ(R) machines with keyboards that have separate arrow
	keys (not part of the numeric keypad), and on some machines with
	compatible keyboards, a bug in the ROM BIOS may cause problems with
	the QuickC editor. A program named FIXSHIFT.COM is provided on
	distribution disk 4 to fix this bug. Simply copy this program to the
	directory where you have loaded the QuickC program files, type

	    fixshift

	and press ENTER. If your machine's BIOS does not have the bug, FIXSHIFT
	displays a message to tell you so.  If your machine's BIOS has the bug,
	FIXSHIFT displays prompts that guide you through the appropriate
	actions.

	FIXSHIFT requires approximately 450 bytes of memory.  Except for fixing
	the BIOS bug, FIXSHIFT has no effect on other programs that you run. It
	can be placed in your AUTOEXEC.BAT file.


xxii	System Requirements: Changing Video Modes
	-----------------------------------------
	If your system has more than one video card, you cannot change video
	modes with the DOS Shell command from within the QuickC programming
	environment. Instead, you should exit to DOS, change to the desired
	mode, then restart the QuickC environment.


8	Installing QuickC: Building GRAPHICS.QLB
	----------------------------------------
	The SETUP program does not build GRAPHICS.QLB, the Quick library that
	allows you to call graphics library functions in the QuickC programming
	environment. You can build GRAPHICS.QLB with the QLIB utility, using
	the following command:

	    qlib /s graph.h /n graphics.qlb


22	Case Sensitivity of QC Command Options
	--------------------------------------
	Options to the QC command line are case sensitive.


22	Invalid QC Command Options
	--------------------------
	If you type more than one invalid option on the QC command line,
	QuickC displays an error box only for the first invalid option.


30     Context Indicator on Status Line
       --------------------------------
       The Context indicator on the status line refers to the compilation state
       of an in-memory program, not to files compiled as executable files.


37	File-Name Conventions
	---------------------
	The QuickC compiler does not check files for a ".C" extension. In list
	boxes, QuickC highlights directories that begin with letters, but not
	those that begin with numbers or special characters. QuickC pays
	attention to leading underscores in file/directory names: for instance,
	typing "m" in a list box moves the input focus to "mktemp" rather than
	to "_makepath."


79	Further Graphics Resources
	--------------------------
	Add the following reference to the references listed in this section:

	    Wilton, Richard. The Programmer's Guide to PC(R) and PS/2(TM)
	    Video System. Redmond, WA: Microsoft Press, 1987. (A detailed
	    overview of programming techniques for the most popular graphics
	    adapters on IBM PC and PS/2 systems.)


126	Core Library Functions
	----------------------
	The following functions have been added to the QuickC core library.

	    _dos_read, _dos_write, fcomp, raise, spawnvpe, _strdate, _strtime

	The following functions and macros have been removed from the core
	library.

	    _fheapchk, _fheapset, _fheapwalk, _heapchk, _heapset, _heapwalk,
	    _nheapchk, _nheapset, _nheapwalk


135	Line Feeds in Source Files
	--------------------------
	Although QuickC can load files containing only a line-feed (LF)
	character at the end of each line, it has problems editing or compiling
	them. XENIX(R) source files must be downloaded in text mode, so that
	each line ends with a carriage-return and line-feed character (CR/LF).


140	Directories in Program List
	---------------------------
	If you do not specify a path when adding a file to a program list, the
	programming environment uses the current directory.


155	Search Menu/Selected Text
	-------------------------
	The Selected Text command from the Search menu now works if the cursor
	is on any letter of the word you are searching for.


158	Wrapping of Search/Change Command
	---------------------------------
	If you begin a Search/Change/Find and Verify command with the cursor
	somewhere other than the beginning of the file, the operation wraps
	around the end of the file and resumes at the beginning. You must
	explicitly choose the Cancel command button to terminate a search-
	and-replace operation before all replacements are made.


165	Run Menu/Compile with Debug
	---------------------------
	This version of QuickC contains a bug fix that changes some of the
	interrupts used by the QuickC integrated debugger. This change requires
	that you rebuild certain programs created with QuickC Version 1.00.
	You need to rebuild a Version 1.00 program ONLY if it contains modules
	that were created:

	    - using a program list
	    - with the Debug option of the Compile dialog box turned on

	If you attempt to run such a program in this version of QuickC, the
	following message appears:

	    Incompatible executable
	    Please rebuild all modules

	To rebuild the program, choose Run/Compile and select Rebuild All.


165	Run Menu/Continue
	-----------------
	If you change a program and then choose the Continue command, QuickC
	asks you if you want to rebuild the program. If so, the command
	resumes execution at the beginning of the program. If you do not
	rebuild the program, the Continue command resumes execution at the
	statement following the statement where the program stopped.


167	Compiling Program Lists: Files Left on Disk
	-------------------------------------------
	When you create an executable file with a program list from within the
	QuickC environment, the executable file can be used ONLY within the
	environment. If you try to run such an executable file from the DOS
	command level, QuickC generates the following message:

	    program too big to fit in memory

	The same result occurs if you link the object files created when you
	compile an in-memory program with a program list: the resulting
	executable file can be run only within the QuickC environment.


167	Using the Debug Option
	----------------------
	If you turn on the Debug option when you compile an in-memory program
	with a program list, or if you link the resulting object files, you
	cannot use the Microsoft CodeView(R) debugger with the resulting
	executable file. If you try to load such an executable file into the
	CodeView debugger, you get the following message:

	    not enough space

	If you compile with both the Debug option and the Obj output option
	turned on, you can use LINK to link the object files you create and
	then debug the resulting executable file with the CodeView debugger.
	However, you cannot debug this executable file with the QuickC
	debugger.


172	Definitions in Define Box
	-------------------------
	QuickC does not check the validity of definitions that you type in the
	Define text box of the Compile dialog box.


174	Changing Command-Line Options
	-----------------------------
	The command-line options for a program (entered with the Set Runtime
	Options command from the Run menu) remain set even after you load a
	new program. You must choose Set Runtime Options again to clear these
	options before running a new program.


178	Watching External Arrays
	------------------------
	If you declare an array with the extern storage class, as in the
	following example

	    extern int sample[];

	then you will not see any elements if you display sample as a watch
	variable. To display the entire array sample, do one of the following:

	    1. Declare sample with an explicit size in the program. For
	       instance,

		   extern int sample[10];

	    2. Display the individual elements of sample as watch variables.
	       For example, type

		   sample[0]; sample[1]; ... sample[10]

	       in the list box for the Add Watch... command.

	    3. Display all the elements of sample by giving a length and type
	       specifier in the text box for the Add Watch... command. For
	       example, type

		   sample, d10

	       in the text box.


193	Specifying Overlays
	-------------------
	You can specify overlays on the QCL command line. Simply enclose the
	names of the overlay source or object files in parentheses. For
	example, if you enter the command line

	    qcl src_1.c (src_2.c obj_1) obj_2

	the modules SRC_2.OBJ and OBJ_1.OBJ are treated as overlays in the
	SRC_1.EXE file. They are read into memory from disk only if and when
	they are needed.


213	/Ol Option (Loop Optimization)
	------------------------------
	The /Ol option tells the compiler to perform loop optimizations. When
	you choose this option, the compiler automatically places frequently
	used loop variables into registers to speed program execution.

	This option is turned on implicitly when you compile with the /Ox
	(maximum optimization) option.

	The Microsoft C Optimizing Compiler, Versions 5.0 and above, includes
	a pragma named loop_opt that turns loop optimizations on and off on a
	local basis. If this pragma appears in programs that you compile with
	the Microsoft QuickC Compiler, QuickC ignores the pragma without
	generating a warning.


214	Deleting Old Linker
	-------------------
	It is important that you use the linker (LINK.EXE) supplied with this
	release. If your system has an earlier version of the Microsoft linker,
	or a linker that was supplied with your version of DOS, you should
	either delete that file or move it out of the path defined by the PATH
	environment variable in your system configuration file(s).


221	The /NOE Option
	---------------
	The following new option has been added to the linker:

	/NOE[XTDICTIONARY]

	The /NOE option tells the linker to not use the extended dictionary
	in searching libraries.  Use this option if you redefine a
	standard-library routine (such as _setargv or _nullcheck)
	in a program module, or if you get linker error L2044 during
	linking. This option may slow the linking process on some
	programs.

	The "extended dictionary" is a block of data telling the
	linker about interlibrary dependencies; that is, for each
	module in the library, the extended dictionary tells the
	linker which other modules in the same library are also
	required.  Although the linker can process libraries faster
	with this information, it has trouble in processing if
	you redefine symbols (such as the names of standard-library
	routines) that otherwise would have been defined in one of
	the modules described in the extended dictionary.


237	Building Quick Libraries:  The QLIB Utility
	-------------------------------------------
	This release includes the utility QLIB.EXE, which is used to build
	Quick libraries. See the file QLIB.DOC, also included in this release,
	for instructions on using QLIB.EXE.

	On a hard-disk system, QLIB.EXE is installed in the same directory as
	the other QuickC executable files (by default, \<dest>\BIN). On a
	floppy-disk system, you will find QLIB.EXE on your working copy of
	distribution disk 3.


237	Global Data in Quick Libraries
	------------------------------
	Modules in Quick libraries can reference global data items only if the
	items are defined in one of the modules of the Quick library.


237	Compiling Modules for the QuickC Environment
	--------------------------------------------
	Use the /AM (medium-model) option to compile any modules that you want
	to put in a Quick library. This option is required because the QuickC
	environment uses the medium memory model for all programs. The QCL
	command uses the small memory model by default.


252	Backslash (\) as Continuation Character
	---------------------------------------
	Note that MAKE considers a backslash immediately followed by a new-line
	character to be a continuation character. When it finds this
	combination in a description file, MAKE concatenates the line
	immediately following to the current line.

	If you define a macro that ends in a backslash, make sure that you put
	a space after the terminating backslash.  For example:

	    BINPATH=C:\SRC\BIN\<space><new-line>
	    LIBPATH=C:\SRC\LIB\<space><new-line>


256	The /X Option
	-------------
	The /X option for MAKE has the following syntax:

	    /X <filename>

	This option redirects errors generated by MAKE, or by any programs that
	MAKE runs, to the given file. If the <filename> argument is a dash (-),
	MAKE redirects error output to the standard output. You may send both
	error output and standard output to the same file by combining the
	"/X -" form of this option with DOS redirection, as in the following
	example:

	    MAKE /X - project.mak >make.log

	Do NOT specify the same file name to /X as the file name following the
	redirection symbol (>).


263	Using .MAK Files with MAKE
	--------------------------
	If you have defined the inference rule

	    [make]
		.c.obj:

	in the TOOLS.INI file, you cannot use MAKE with the .MAK file generated
	by QuickC. QuickC places its own ".c.obj" inference rule in the .MAK
	file, and that inference rule is then overridden by the rule in
	the TOOLS.INI file.


294	Linking with MASM Files
	-----------------------
	If you are linking C modules with modules created by the Microsoft
	Macro Assembler (MASM), either assemble the MASM modules with the /MX
	option to preserve case sensitivity in these modules, or use the LINK
	command to link in a separate step and do NOT specify the /NOI linker
	option.


305	Initialized Global Arrays: Large Model
	--------------------------------------
	Unlike the Microsoft C Optimizing Compiler, Version 5.0 and higher,
	QuickC places initialized global arrays in the FAR_DATA segment
	instead of the _DATA segment for large-model programs.


311	Memory Considerations
	---------------------
	If compiler error messages are generated while QuickC is low on memory,
	these messages may appear without text.


311	Critical-Error Messages
	-----------------------
	In addition to the error messages documented in Appendix D of the
	Microsoft QuickC Compiler Programmer's Guide (and later in this
	section), a set of error messages known as "critical-error messages"
	may appear when you are running programs within the QuickC programming
	environment. Critical-error messages appear in a message box, and the
	text of the message begins with the words "CRITICAL ERROR."

	The following critical error messages may appear:

	    User interrupt encountered
	    --------------------------
	    You pressed CTRL+BREAK to abort a compilation.

	    Load of user program failed
	    ---------------------------
	    This error occurs when QuickC is setting up a program for in-memory
	    execution. It may be caused by one of the following:

		-  Not enough memory was present.

		-  The size of the data, variables, and stack exceeded 64K.

		-  QuickC could not find the Quick library you specified when
		   you started QuickC.

		-  The Quick library you specified was internally inconsistent
		   or in a bad format.

		-  Debugging information was inconsistent or otherwise bad (try
		   recompiling with the Debug option turned on).

	    Compiler failed
	    ---------------
	    QuickC could not start compilation. This error may be caused by any
	    of the following:

		-  QuickC could not load the compiler from an overlay
		   (because either QC.EXE or QC.OVL was not found).

		-  Not enough memory was present.

		-  The Quick library you specified was bad or missing.

	    Linker failed
	    -------------
	    QuickC could not invoke the linker. This error may be caused by any
	    of the following:

		-  QuickC could not find the LINK.EXE file in the current
		   directory or in any of the directories given in the PATH
		   environment variable.

		-  Not enough memory was present.

		-  QuickC could not create the temporary disk file required by
		   the linker, probably because there was not enough room on
		   the disk.

	    Unable to load floating-point emulator
	    --------------------------------------
	    QuickC could not load the floating-point emulator. This error may
	    be caused by any of the following:

		-  Not enough memory was available.

		-  QuickC could not find the QC.EXE file, which contains the
		   emulator.


311	Error Messages for Features Not in Microsoft QuickC
	---------------------------------------------------
	For the benefit of those who use QuickC to compile programs written
	for the Microsoft C Optimizing Compiler, Version 5.0 and higher, the
	QuickC Compiler performs "silent" syntax checking on some features
	found in Version 5.x but not in QuickC. If these features are
	syntactically correct in a program, the QuickC compiler ignores them;
	if they are syntactically incorrect, the QuickC compiler generates an
	error message.

	For example, the C 5.x compiler includes a pragma named same_seg,
	which tells the compiler to assume that the data items given in the
	pragma reside in the same data segment. If no data items are given in
	the pragma, the QuickC compiler generates the warning message

	    C4082   expected an identifier

	Consult the Microsoft C Optimizing Compiler User's Guide for
	explanations of error messages caused by Version 5.x features if these
	messages are not documented in the QuickC Programmer's Guide.

	The Microsoft QuickC Compiler does not generate the following
	documented error messages:

	    Fatal errors: C1033-C1034, C1036, C1039-C1040, C1050
	    Errors: C2049, C2129, C2163, C2167-C2169
	    Warnings: C4043, C4056-C4057, C4059, C4063, C4066, C4069, C4072,
		      C4073, C4097


334	Error Message C2125
	-------------------
	Declaring an array to be exactly 64K in size generates error message
	C2125, "allocation exceeds 64K," in this release of QuickC.


352	Nested Include Files
	--------------------
	The limit for nested include files refers to the total number of open
	files that the compiler allows. Since the original source file counts
	as an open file, you may have a total of nine nested include files in
	addition to the original file.



=======< Part 2: Notes on Microsoft C Run-Time Library Reference >=============


Definitions of Standard Library Functions
-----------------------------------------
The most recent documentation of the standard library functions is contained
in the QC.HLP file. If a definition given in the QuickC on-line-help facility
is in conflict with the definition in the Microsoft C Optimizing Compiler
Run-Time Library Reference, use the definition given in the on-line help.


Quick Libraries and Program Lists
---------------------------------
In addition to the core routines that are always available from the QuickC
programming environment, there are two other means for accessing routines from
within the environment: the Quick library and the program list. See Section
6.1.5, "Common Questions About In-Memory Programs and Program Lists," in the
Microsoft QuickC Compiler Programmer's Reference Guide, for more information
about the use of Quick libraries and program lists.


The following notes refer to specific pages in the Microsoft C Optimizing
Compiler Run-Time Library Reference.


249	fclose, fcloseall
	-----------------
	In this version of the QuickC compiler, if a program closes the
	stdaux or stdprn stream, the system reopens these streams as device
	"con:" (rather than "aux:" for stdaux or "prn:" for stdprn) when the
	program exits.


411	matherr
	-------
	The matherr function cannot be redefined in an in-memory program.



===< Part 3: Notes for Microsoft C Optimizing Compiler Language Reference >====


The following notes refer to specific pages in the Microsoft C Optimizing
Compiler Language Reference.


83	External-Variable Declarations in Function Scope
	------------------------------------------------
	The QuickC Compiler treats external declarations within functions
	as if they had global scope. As a result, redefinition errors may
	occur if the declarations in different functions are not identical.

	For example, the following declarations cause a redefinition error
	because of the type mismatch between the two declarations of malloc:


	    func1()
		{
		    extern int	* malloc();
		}

	    func2()
		{
		    extern char * malloc();
		}

	To avoid the redefinition error in this example, declare malloc
	the same in both functions, and cast the variable that is assigned the
	return value to the appropriate type, as illustrated below:

	    func1()
		{
		    extern char * malloc();
		    ip = (int *) malloc();
		}

	    func2()
		{
		    extern char * malloc();
		    cp = malloc();
		}

	Redefinition errors may also occur if identical external structure
	variables are declared in separate functions, so that the variables
	appear to be different. In the following example, the structure
	variable datum appears to be redefined:

	    func1()
		{
		extern struct
		    {
			int a,b;
		    } datum;
		}

	    func2()
		{
		extern struct
		    {
			int a,b;
		    } datum;
		}

	To avoid this problem, define a named structure type at the external
	level and then declare variables with this type within each function,
	as illustrated below:

	    struct sample
		{
		    int a,b;
		};

	    func1()
		{
		    extern struct sample datum;
		}

	    func2()
		{
		    extern struct sample datum;
		}


120	The sizeof Operator
	-------------------
	The sizeof(expression) construction gives unexpected results in some
	cases (for example, when subtracting pointers or data items of
	different types).



=====< Part 4: Differences Between QuickC and Microsoft C Version 5.10 >=======

This section describes differences between QuickC Version 1.01 and the
Microsoft C Optimizing Compiler Version 5.10.


Macros
------
Some self-recursive or mutually recursive macro definitions are not expanded
properly in QuickC 1.01 or Version 5.0 of the Microsoft C Optimizing Compiler.
All such cases are handled correctly by Version 5.10 of the C Optimizing
Compiler, however.

The following code works as expected in Version 5.10 of the C Optimizing
Compiler, but does not work correctly in Quick 1.01 or Version 5.0 of the
Optimizing Compiler:

    #define str(s)  #s
    #define xstr(s) str(s)
    #define SAMPLE  EXAMPLE

    xstr(SAMPLE)

In QuickC 1.01 and Version 5.0 of the C Optimizing Compiler, the preceding
code initializes the string as "SAMPLE" rather than "EXAMPLE" as expected.
This code does work correctly in Version 5.10 of the C Optimizing Compiler.


Modifiers
---------
The following modifiers are supported in Version 5.10 of the Microsoft C
Optimizing Compiler but are not supported in QuickC Version 1.01:

    huge
    _saveregs
    _loadds
    _export

The preceding modifiers cause a compilation error when used in a program
compiled with QuickC 1.01.


Pragmas
-------
The following pragmas are not supported in QuickC Version 1.01:

    check_stack
    check_pointer
    data_seg
    function
    linesize
    loop_opt
    message
    pack
    page
    pagesize
    skip
    subtitle
    title


Compiler Options
----------------
The following compiler options are not supported in in the QuickC 1.01
programming environment.

    /Zc
    /Lc
    /Lp
    /Lr

Note that the QCL command (or the /qc option of the CL command) does support
the options /Lc, /Lp, and /Lr (but not /Zc).


Miscellaneous Features
----------------------
The following features are supported by Version 5.10 of the Microsoft C
Optimizing Compiler but are not supported by QuickC Version 1.01:

    - the #error directive
    - the predefined macros __DATE, __TIME__, __STDC__, and __TIMESTAMP__
    - using the "//" character sequence for single-line comments
    - using ellipses (",...") in a function prototype to indicate a
	variable number of arguments but declaring the function with
	a fixed number of arguments



===============< Part 5: Bugs Fixed in QuickC Version 1.01 >===================


The following bugs have been fixed in QuickC Version 1.01.

- QuickC correctly restores the NMI vector upon termination.

- Miscellaneous changes to on-line help. Help is available for _HEAPINFO and
  the interrupt keyword.

- Change All operation caused an infinite loop if you replaced text with the
  same text (for instance, changing 'sample' to 'sample').

- No warning for internal (non-user) cast.

- Linker header message appeared unexpectedly in user interface when compiling
  in memory.

- Spurious "null pointer assignment" error message.

- Unexpected result using certain INCLUDE paths with QCL.

- Lockups when compiling alternately to memory and to an executable file.

- Inconsistent results with register variables.

- Unpredictable lockups related to character string continuation.

- Inconsistency between 'if' and 'while' comparisons of the same
  Boolean expression.

- Spurious "can't include <file>" error message.

- Spurious error message (C2152, "identifier: pointers to functions
  with different attributes") in a case where a function expects a
  pointer to a function returning an int value, and you pass a pointer to
  an int value.

- Omitting a comma between arguments to a pragma gave warning error
  messages C4079 and C4082 instead of C4081, "expected a comma."

- Lockup when you give a newline character in a pragma where it expects a
  comma, right parenthesis, or identifer.
