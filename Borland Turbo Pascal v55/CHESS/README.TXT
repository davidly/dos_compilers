KC Chess 1.00.00 - by Craig Bruce and Kevin Phillips, 06-Apr-90.

Execution of this program requires a 100% IBM PC-DOS compatible computer with
640K of RAM and the VGA graphics card.

The following files are required in the current directory:
      CHESS.EXE     { main program }
      EGAVGA.BGI    { Turbo Pascal 5.5 graphics driver }
      TRIP.CHR      { Turbo Pascal 5.5 character font file }
      PIECES.IMG    { binary piece images }
      CHESS.HLP     { online help information }

      The DOS file COMMAND.COM must also be present either in the current
      directory or in some directory specified in the PATH environmental
      variable, and it MUST BE COMPATIBLE with the version of DOS the
      computer was booted up under.

The following non-required chess program source files are also included:
      CHESS.PAS     { main program }
      MISC.PAS      { miscellaneous functions }
      INIT.PAS      { initialization of global variables }
      DISPLAY.PAS   { display-oriented routines }
      INPUT.PAS     { keyboard input routines }
      MOVES.PAS     { move generation and making routines }
      SETUP.PAS     { default board and custom setup routines }
      PLAY.PAS      { computer thinking and player input routines }
      MENU.PAS      { main menu routines }

And the following non-required other files are also included:
      README.BAT    { batch file to display README.TXT }
      README.TXT    { this file, containing program notes }
      HELPTEXT.TXT  { help information in text format }
      HELPGEN.EXE   { program to convert HELPTEXT.TXT to CHESS.HLP }
      HELPGEN.PAS   { source of HELPGEN.EXE }
      PIECES.TXT    { piece images in text format }
      IMAGE.EXE     { program to convert PIECES.TXT to PIECES.IMG }
      IMAGE.PAS     { source code of IMAGE.EXE }
      EXAMPLE.CHS   { example saved game of chess }

To change the help information, edit the file HELPTEXT.TXT and then execute
the HELPGEN.EXE program; this will give the updated CHESS.HLP file.  To change
the piece images, edit the file PIECES.TXT and then execute the IMAGE.EXE
program; this will give the updated PIECES.IMG file.

To modify the chess program or any of the other source files, Turbo Pascal 4.0
or higher must be used to recompile the .EXE files.

The chess program is 3417 lines long and the project took 220 hours to
complete.  The work was carried out from JAN - APR 1990 as our CS 4993
undergraduate project.  The program may be distributed freely and is considered
Public Domain software.  A 30 page written report was also produced and
submitted with the rest of the work to Dr. J. D. Horton who was our project
supervisor.