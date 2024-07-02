


                                     Aztec C86
                                   Release notes
                                 Beta version 5.2a
                                    17 Nov 1992

            This release document describes version 5.2a of Aztec C86.
          It's organized into the following sections:
            
            1. Installation instructions, which describes how to install
               the Aztec C files from the distribution disks onto your
               disks;
            2. Disk contents, which describes what's on the distribution
               disks;
            3. New features, which describes what's changed in going
               from version 4.2b to the current release;
            4. New features, which describe what's changed in going from
               the 9 April beta release to the current release.
            5. New features, which describe what's changed in going from
               the 4 Oct beta release to the current release.

            After installation, additional documentation is also
          available in file README2.TXT in the DOC subdirectory that's
          within your root Aztec directory.

            To report problems with this beta release, please call Manx
          Tech Support at 908-542-1795, between 2:30pm and 5pm Eastern
          time.


          1. Installation

            To install Aztec C86, put the first distribution disk in a
          floppy drive, make that drive the current drive, and type
               
               install

            The install program will display a dialog box containing
          text fields, check box fields, and button fields that you can
          adjust to customize the installation. To move around within
          this dialog box, you can use a mouse, or the tab key. You can
          get help by pressing the F1 key.

            Once you've made your selections, press the "Proceed" button
          to continue with the installation, or press the "Abort" button
          to terminate the installation. After you press the "Proceed"
          button, insert the distribution disks in the source drive as
          prompted by the program.

            When the files are all installed to the hard disk, the
          program will return to DOS.

            After the installation program is complete, the bin
          subdirectory of your main Aztec directory will contain a batch
          file named AZ86.BAT. The commands in this file will initialize
          your system for use with Aztec C86. You may wish to place the
          contents of this file directly in your AUTOEXEC.BAT file.





Release notes                   page 1


Aztec C86, beta v5.2a                                                11/17/92

            The following paragraphs describe the fields in the
          installation program's dialog box.

          1.1 The 'Source drive' text field

            In the 'source drive' text field, type the name of the
          floppy drive in which you will place the distribution disks.
          This field defaults to the A: drive.

          1.2 The 'Destination directory' text field

            In the 'destination directory' text field, type the name of
          the drive and directory into which you want the installation
          program to place the Aztec C86 files. This field defaults to
          C:\AZ86.

            The installation program will place files in the following
          subdirectories of the destination directory:
                 
                 BIN     The executable programs;
                 INCLUDE Include files;
                 LIB     Library source, object modules, and libraries;
                 MON86   Code for RDB monitor program.

          1.3 The 'Install programs, includes, and source' check boxes

            Check these boxes depending on what you want installed.

            You toggle the setting of a box by pressing the space bar,
          or by clicking the mouse in the box.

          1.4 The 'Object libraries' check boxes

            The Aztec C86 distribution disks contain the following
          categories of object module libraries:
            
            C libraries            Non-floating point functions;
            IEEE math libraries    Floating point functions, which
                                   perform calculations using software;
            8087 math libraries    Floating point functions, which
                                   perform calculations using an 8087;
            Sensing math libraries Floating point functions, which
                                   perform calculations using an 8087 if
                                   present or using software if not;
            Screen libraries       Functions for accessing the screen
                                   and keyboard via the ROM BIOS;
            Graphics libraries     Graphics functions.

            Check the boxes that define the libraries you want
          installed.

          1.5 The 'Memory models' check boxes

            Check on the 'library memory models' boxes to define the
          memory models of the libraries that you want installed.






Release notes                   page 2


Aztec C86, beta v5.2a                                                11/17/92

            For example, if you want the C libraries installed that use
          the small code and small data memory model, you would check
          the 'C libraries' and the 'small code, small data' boxes.

          1.6 The 'Optional components' check boxes

            If you've purchased the optional Level 2 or Level 3
          Extensions to Aztec C86, check the appropriate boxes to
          specify which of the Extension components you want installed.

            Don't check these boxes if you don't have the extensions.

          1.7 Bypassing the installation program

            Most of the files on the distribution disks are in standard
          LHARC format. So if you want, you can bypass the installation
          program altogether and dearchive the archive files that are on
          the distribution disks using the LHARC program that is
          provided with Aztec C. This archive program is installed in
          the Aztec root directory's BIN subdirectory; this program, and
          documentation on how to use it, is also on distribution disk
          1. The LHARC program is in file LHA.EXE, and documentation is
          in file LHA.DOC.

          1.8 Re-entering the installation program

            The installation program can be run more than once. For
          example, during one execution you could install the programs,
          include files, and object libraries; and during a second
          execution you could install the library source files.


          2. Contents of distribution disks

            v5.2a of Aztec C86 is packaged into a base package and two
          levels of optional extensions. The components of these
          packages are:
            *  Base package:
                 +  Compiler, assembler, DOS linker
                 +  Include files
                 +  Object module utilities
                 +  Object libraries
                 +  SDB source level debugger.
            *  Level 2 extensions:
                 +  Library source;
                 +  HEX86, startup routines, and heap-management
                    routines, for ROMming programs that have non-complex
                    segmentation requirements.
            *  Level 3 extensions:
                 +  RDB debugger and MON86 monitor, for remote source-
                    level debugging of ROM- and DOS-based programs;
                 +  ALN linker, ALOC locator, AHEX hexer, and startup
                    routines, for ROMming programs that have complex
                    segmentation requirements

            The following paragraphs describe the files that are on the
          Aztec distribution disks.




Release notes                   page 3


Aztec C86, beta v5.2a                                                11/17/92

          2.1 Disk 1 contents
               File           Contents
               INSTALL.EXE    Installation program
               LHA.EXE        LHARC program (this replaces the ARCV
                              and MKARCV programs that are described
                              in the manual)
               LHA.HLP        LHARC help
               LHA.DOC        LHARC documentation

          2.2 Disk 2 contents
               File           Contents
               CC.LZH         Compiler
               AS.LZH         Assembler
               LN.LZH         Linker
               INCLUDE.LZH    include files
               UTIL.LZH       Object module utilities, HEX86, and
                              miscellaneous utilities
               UNITOOLS.LZH   Unix-compatible programs

          2.3 Disk 3 contents
               File           Contents
               SDB.LZH        SDB source level debuger

          2.4 Disk 4 contents
               File           Contents
               C.LZH          Small code, small data c & m libraries
               CL.LZH         Large code, large data c & m libraries
               CLC.LZH        Large code, small data c & m libraries
               CLD.LZH        Small code, large data c & m libraries
               M87.LZH        8087 math libraries (all memory models)
               MS.LZH         Sensing math libraries (all models);
               G.LZH          Graphics libraries
               S.LZH          Screen libraries

          2.5 Disk 5 contents

            Disk 5 contains the optional Level 2 extensions.
               File           Contents
               86SUP.LZH      LIB\86SUP source files
               DOS.LZH        LIB\DOS source
               GRAPHICS.LZH   LIB\GRAPHICS source
               INP.LZH        LIB\INP files
               LIB.LZH        LIB files
               MISC.LZH       LIB\MISC source
               MATH.LZH       LIB\MATH source
               ROM86.LZH      LIB\ROM86 source
               SCREEN.LZH     LIB\SCREEN source
               STDIO.LZH      LIB\STDIO source
               STDLIB.LZH     LIB\STDLIB source
               STRING.LZH     LIB\STRING source
               SYSIO.LZH      LIB\SYSIO source
               TIME.LZH       LIB\TIME source
               UTIL2.LZH      Programs for level 2 extensions

          2.6 Disk 6 contents

            Disk 6 contains the optional Level 3 extensions.
               File           Contents



Release notes                   page 4


Aztec C86, beta v5.2a                                                11/17/92

               LNKLOC.LZH     Advanced linker, locator, and hexer
                              programs
               RDB.LZH        Remote source level debugger


          3. New Features since v4.2a

            This section describes functional changes that have been
          made in going from the v4.2b release to the 9 April v5.2a beta
          release.

          3.1 Compiler changes

            The following paragraphs describe the changes that have been
          made to the compiler in going from version 4.2b to 5.2a.

          3.1.1 New compiler options
            -J Enable trigraph support.
            -F Generate prototypes for static functions, without
               generating executable code. Send prototypes by default to
               a file whose name is derived from input file, by changing
               the extension to .PRO. The -O option can be used to
               select the output file name. This option replaces the
               PROTO program.
            -X Generate prototypes for non-static functions, without
               generating executable code. Send prototypes by default to
               a file whose name is derived from input file, by changing
               the extension to .PRO. The -O option can be used to
               select the output file name.
            -W Preprocess source. Send preprocessed C source by default
               to a file whose name is derived from input file, by
               changing the extension to .PRE. The -O option can be used
               to select the output file name. This option replaces the
               CPP program.

          3.1.2 New predefined symbols
            __VERSION    Predefined with the version of the compiler. It
                         has the value 520;
            _LARGE_CODE  Predefined with value 1 if program is compiled
                         to use the large code memory model;
            _LARGE_DATA  Predefined with value 1 if program is compiled
                         to use the large data memory model;

          3.1.3 New language features

            Support for the following language features has been added
          to the v5.2 compiler:
            *  Initialization of auto aggregate variables;
            *  Trigraphs.

          3.1.4 New support for 8086 segmentation

            The compiler now allows you to define, using the new
          "#pragma segment" directive, the segments into which variables
          are placed. This directive has the following form:
               





Release notes                   page 5


Aztec C86, beta v5.2a                                                11/17/92

               #pragma segment [segname]
                    [class classname] [at addr] [near | far]
                    sym1, sym2 ...

          where the parameters have the following meanings:
                 sym1, sym2, ...
                              Symbols that are to be placed in a
                              specified segment;
                 segname
                              'segname' is the segment that's to hold
                              the symbols.
                 class classname
                              'classname' is the class in which the
                              segment is located. If not specified, the
                              class defaults to 'DATA'.
                 at addr      'addr' is the segment's starting address;
                 near | far   A NEAR segment is always accessible via
                              the DS segment register, and a FAR segment
                              is not. To access a FAR segment, the ES
                              register must first be loaded with the
                              segment's paragraph address. Defaults to
                              FAR.

            Previous versions of the compiler allowed you to specify
          that variables were to go into their own segments, but the
          compiler itself chose the names of these segments. With the
          ability to choose segment names yourself, and with the new ALN
          linker and ALOC locator, you can now easily position variables
          in special areas of memory. For example, if your system has
          memory-mapped I/O, you can create structure that matches the
          memory-mapped I/O section of memory, place that structure in
          its own segment, and position the segment at the memory-mapped
          I/O's section of memory.

            Previous versions of the compiler did not allow you to put
          near data items into special segments. With this capability,
          and with the new ALN linker and ALOC locator, you can now
          easily take advantage of battery-backed-up RAM. For example,
          you can place variables that should not be initialized on
          system startup in a  DS-accessible near segment, and position
          that segment at the beginning of RAM. The other standard
          Aztec-created, DS-accessible, near segments can be placed
          after the special segment in RAM, where they can safely be
          initialized on system startup.

          3.2 Assembler changes
            *  ORG directive now fully supported;
            *  The "AT addr" clause of the SEGMENT directive is now
               supported.

          3.3 DOS linker changes
            *  None.

          3.4 Library changes
            *  Libraries are now ANSI compatible (previously they were
               K&R compatible). Probably the main change you will have
               to make to your programs is to change your calls to
               fopen(), to support fopen's TEXT and BINARY modes.



Release notes                   page 6


Aztec C86, beta v5.2a                                                11/17/92

            *  The time() function now returns the current time as the
               number of seconds that have elapsed since Jan 1, 1970.
               Previously it returned the current time in the format
               used for file directory time fields.

          3.5 Include file changes
            *  Include files are now completely ANSI compatible
               (previously they were K&R compatible).

          3.6 Level 2 extensions for creating ROMable code

            The optional Level 2 extensions contain components for
          creating ROMable code of systems whose segmentation
          requirements are not too demanding. For example, a typical
          system might have its code in one set of ROM chips and its
          data in one set of RAM chips.

            These components are:
            *  The HEX86 utility that was in v4.2b, for converting a
               program into Intel hex code;
            *  BEGIN-SD.ASM and HEAP-SD.ASM, the startup and heap
               management routines for programs that use the small data
               memory model;
            *  BEGIN-LD.ASM and HEAP-LD.ASM, the startup and heap
               management routines for programs that use the large data
               memory model;

            The heap management routines are new; the routines in 4.2b
          and earlier releases were for DOS-based systems.

            BEGIN-SD.ASM and BEGIN-LD.ASM have replaced the ROM86.ASM
          startup routine that was in 4.2b. They were changed so that
          they now initialize the heap as required by the new heap
          management routines.

          3.7 Level 3 extensions for creating ROMable code

            The new, optional, Level 3 extensions to Aztec C86 contain
          the following utility programs and startup code for creating
          multi-segmented romable code:
            *  The ALN linker. This program links object modules
               together, and outputs a relocatable object module. The
               input modules can be in Aztec object format, Microsoft
               OMF format, or Intel OMF format. The output module is in
               Intel OMF format.
            *  The ALOC locator. This program 'locates' an object module
               that is in relocatable Intel OMF format; that is, defines
               the starting memory addresses of the module's segments
               and converts relocatable items to absolute.
            *  The AHEX hexer. This program converts an object module
               that is in absolute Intel OMF format into Intel hex code
               or binary code.
            *  The ABEGINSD and ABEGINLD startup routines, which gain
               control when a program created with ALN, ALOC, and AHEX
               is activated.






Release notes                   page 7


Aztec C86, beta v5.2a                                                11/17/92

            For heap management, programs that use the Level 3
          extensions should use the heap management routines that are in
          the Level 2 extensions.

            ALN, ALOC, and AHEX are described at the end of this
          document. ABEGIN is described in the following section.

          3.8 The ABEGIN startup routine.

            ABEGIN is the startup routine that's used by programs that
          have been generated using the ALN, ALOC, and AHEX programs.

          3.8.1 ABEGIN files

            To support different memory models, ABEGIN is provided in
          two source files and four object module files, in directory
          LIB\ROM86. Source files:
               ABEGINSD.ASM   Source for programs that use small data
                              memory model;
               ABEGINLD.ASM   Source for programs that use large data
                              memory model;

            Object files:
               ABEGINSD.O     Object module for programs that use small
                              code, small data memory model. Generated
                              from ABEGINSD.ASM;
               ABEGINSD.OLC   Object module for programs that use large
                              code, small data memory model; Generated
                              from ABEGINSD.ASM;
               ABEGINLD.OLD   Object module for programs that use small
                              code, large data memory model; Generated
                              from ABEGINLD.ASM;
               ABEGINLD.OL    Object module for programs that use large
                              code, large data memory model. Generated
                              from ABEGINLD.ASM;

          3.8.2 Notes about ABEGIN
            *  By default, ABEGIN initializes a program's DATA class in
               RAM from a copy in ROM. The copy must immediately follow
               the program's CODE class in ROM.
            *  ABEGIN can optionally initialize a program's FAR_DATA
               class in RAM from a copy in ROM. This is the class in
               which the compiler by default places a program's far
               data. This class must immediately follow the program's
               DATA class in ROM.
            *  ABEGIN contains the target system's reset code, in the
               RESET_CODE segment. By default, AHEX will position this
               segment so that it resides at the system's reset vector
               location.
            *  ABEGIN contains code that will initialize an 80186. To
               enable generation of this code, assemble ABEGINxx.ASM
               with the symbol CPU_186 defined.
            *  The small data version of ABEGIN (ABEGINSD.ASM) puts a
               program's stack within the program's uninitialized data
               area, beginning at the location defined by symbol
               'cstack'. The number of paragraphs in the stack area is
               defined by the symbol 'stacksize', which defaults to 80h
               paragraphs.



Release notes                   page 8


Aztec C86, beta v5.2a                                                11/17/92

            *  The small data version of ABEGIN puts a program's heap
               right after the program's uninitialized data area. The
               number of paragraphs in the heap is defined by the symbol
               'heapsize', which defaults to 80h paragraphs.
            *  The large data version of ABEGIN (ABEGINLD.ASM) puts a
               program's stack right after the program's uninitialized
               data area. The symbol 'stacksize' defines the number of
               paragraphs in this area, and defaults to 80h paragraphs.
            *  The large data version of ABEGIN puts a program's heap
               right after the program's stack area. The symbol
               'heapsize' defines the number of paragraphs in this area,
               and defaults to 80h paragraphs.

          3.9 SDB changes
            *  There are now two versions of SDB: the regular SDB; and
               RDB, which allows remote source level debugging of a
               program that resides in another MSDOS/PCDOS- or ROM-based
               system.
            *  Both SDB and RDB have a new windowed interface, and
               hypertext help.
            *  INITSDB is no longer needed for configuring SDB.
            *  RDB and SDB occupy significantly more RAM memory than
               v4.10d SDB. This is not a problem for RDB, since the
               program being debugged resides in a separate machine. But
               it is a problem with SDB since it and the program being
               debugged must reside in the same system. Until we resolve
               this problem with SDB, which we will probably do by
               moving SDB up into extended memory, we are providing the
               v4.10d SDB, in file SDB410D.EXE, and INITSDB (for
               configuring the SDB410D).

          3.10 Z changes
            *  The command :se 50=1 can be used on VGA screens to
               display 50 lines.

          3.11 Other program changes

            Other new programs in v5.2 are these:
            *  XREF, which generates a cross-reference listing of symbol
               references and definitions in object modules.

            Programs that are no longer provided:
            *  PROTO, which has been replaced with the new compiler
               options -F and -X;
            *  CPP, which has been replaced with the new compiler option
               -W;
            *  ENGTOC;
            *  CTOENG;
            *  ARCV.

          3.12 Building libraries

            Library source is in the optional Level 1 extensions to
          Aztec C86. The INSTALL program will create a LIB subdirectory
          of the root Aztec directory and several subdirectories of LIB,
          and then install the source in these subdirectories.





Release notes                   page 9


Aztec C86, beta v5.2a                                                11/17/92

            You can build one or more libraries by CD'ing into the LIB
          directory and then invoking MAKE with codes that identify the
          libraries you want made. The codes and their associated
          libraries are:
            
                    ALL       All libraries
                    C_ALL     All C libraries
                    C         C.LIB
                    CL        CL.LIB
                    CLC       CLC.LIB
                    CLD       CLD.LIB
                    M_ALL     All M libraries
                    M         M.LIB
                    ML        ML.LIB
                    MLC       MLC.LIB
                    MLD       MLD.LIB
                    M87_ALL   All M87 libraries
                    M87       M87.LIB
                    M87L      M87L.LIB
                    M87LC     M87LC.LIB
                    M87LD     M87LD.LIB
                    MS_ALL    All MS (8087-sensing) math libraries
                    MS        MS.LIB
                    MSL       MSL.LIB
                    MSLC      MSLC.LIB
                    MSLD      MSLD.LIB
                    S_ALL     All S (screen) libraries
                    S         S.LIB
                    SL        SL.LIB
                    SLC       SLC.LIB
                    SLD       SLD.LIB
                    G_ALL     All G (graphics) libraries
                    G         G.LIB
                    GL        GL.LIB
                    GLC       GLC.LIB
                    GLD       GLD.LIB

            To build libraries, MAKE will invoke a second copy of MAKE,
          passing to it parameters that define what's to be made.

            For each library that it's to make, this second MAKE will do
          the following:
            
            *  CD into each required subdirectory of the LIB
               subdirectory and invoke a third copy of MAKE. This third
               MAKE will generate object modules for the library, from
               the source that's in the subdirectory.
            *  CD into the INP subdirectory and sort the names of the
               object modules that will go into the library, using the
               ORD utility;
            *  Build the library into the LIBS subdirectory of the LIB
               directory, using the LB utility.









Release notes                  page 10


Aztec C86, beta v5.2a                                                11/17/92

          4. New Features since the 4/9/92 beta

            This section describes changes that have been made since the
          9 April 92 beta release. It first describes functional changes
          that have been made, and then bug fixes.

          4.1 Compiler changes
            *  The new -M option causes the compiler to issue a warning
               if a function is called without a prototype being in
               scope.
            *  The new +T option causes $$var statements (used to access
               far data) to be put into the code segment instead of the
               data segment.

          4.2 Z changes
            *  On a VGA display, the command :se 50=1 can be used to
               display 50 lines.

          4.3 Library changes
            *  The new TimeFile2TM() function converts a time value
               that's in the format used for file directory time fields
               to the format that's used by the time() function.
            *  The new TimeTM2File() function converts a time value
               that's in the format used by the time() function to file
               system format.
            *  The graphics functions now support VGA modes 0x10, 0x11,
               0x12, and 0x13.
            *  The movblock() function has been changed. A length
               argument of 0 now means don't copy anything; used to mean
               copy 64kbytes.
            *  The scdir() function has been changed. When passed a
               NULL, it resets itself so that the next call can specify
               a new pattern.

          4.4 SDB/RDB changes
            *  The DI command causes sdb/rdb to display information
               about the debugger's heap usage.


          5. New features since the 10/4/92 beta

          5.1 SDB/RDB changes
            *  The name of the default configuration file for SDB and
               RDB has been changed to SDB.SET, from SDB.INI.
            *  The sequence in which SDB/RDB search for SDB.SET has been
               changed. On startup they look in the following places:
                 1. The current directory;
                 2. The directory whose name is assigned to the AZTEC
                    environment variable;
                 3. If SDB.SET is not found and AZTEC environment
                    variable doesn't exist, SDB.SET is created in the
                    current directory.

          5.2 CNM changes
            *  The -U option has been added, to display information
               about a module's unnamed symbols.





Release notes                  page 11


Aztec C86, beta v5.2a                                                11/17/92

          5.3 Library changes
            *  The following functions have been added:
                 +  fnsplit(), which breaks a file name up into drive,
                    path, filename, and extension components; Calling
                    sequence:
                         int fnsplit(char *name, char *drive, char *dir,
                         char *fname, char *ext);
                    where
                      -  name points at the name to be broken down;
                      -  drive points at the area where the name's drive
                         component is placed;
                      -  dir points at the area where the name's
                         directory component is placed;
                      -  fname points at the area where the name's
                         filename component is placed;
                      -  ext points at the area where the name's
                         extension is placed.
                 +  fnmerge(), which creates a file name from drive,
                    path, filename, and extension components. It has the
                    same arguments as fnsplit(); a complete file name is
                    built up from the drive, dir, fname, and ext args,
                    and stored in the area pointed at by name.
                 +  strdup(), which makes a copy of a string in the
                    heap. Calling sequence:
                         char *strdup(char *str);
                 +  lfind(), which performs a linear search of an array
                    for a specified item. Calling sequence:
                         void *lfind(void *key, void *base, size_t *num,
                         size_t width, int (*fcmp)(void *, void *));
                    where:
                      -  key points at the value to be located;
                      -  base points at the array to be searched;
                      -  num points at the number of array elements;
                      -  width is the width in bytes of each array
                         element;
                      -  fcmp points at a function that compares two
                         keys. The function returns 0 if the items are
                         identical, and non-zero if different.
                    lfind() returns a pointer to the matching array
                    element, or NULL if not found.
                 +  lsearch(), same as lfind(), except it appends the
                    item if not found. The calling sequence is the same
                    as for lfind().
                 +  min(), returns the lesser of two ints. Calling
                    sequence:
                         int min(int a, int b);
                    where a and b are the items to be compared.
                 +  max(), returns the greater of two ints. Calling
                    sequence:
                         int max(int a, int b);
                    where a and b are the items to be compared.
            *  The following symbols were added to the ABEGINSD.ASM and
               ABEGINLD.ASM startup routines:
                 +  NEAR_DATA_INIT. If 1, the initialized near data
                    segment (dataseg) is initialized from a copy in ROM.
                    If 0, this initialization is not done. Default
                    value: 1.




Release notes                  page 12


Aztec C86, beta v5.2a                                                11/17/92

                 +  FAR_DATA_INIT. If 1, the initialized far data class
                    FAR_DATA is initialized from a copy in ROM. If 0,
                    this initialization is not done. Default value: 0.
                 +  FAR_BSS_INIT. If 1, the uninitialized fat data class
                    FAR_BSS is cleared. If 0, FAR_BSS is not cleared.
                    Default value: 0.
                 +  CPU_186. Set to 1 if processor is an 80186/80188, or
                    0 if not. Default value: 0.

          5.4 The AI program

            AI is a new program that displays information about Aztec
          C86 programs. For information, type AI.

          5.5 Bug fixes

               Numerous bugs have been fixed, in programs, library
               functions, and include files. These fixes are described
               in the CHANGES.* files that are stored in the BIN,
               INCLUDE, and LIB subdirectories of the main Aztec
               directory. Once you've finished examining these files,
               you can delete them.







































Release notes                  page 13

