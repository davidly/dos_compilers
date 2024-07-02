
{ Copyright (c) 1985, 1990 by Borland International, Inc. }

program BgiLink;
{ This program demonstrates how to link graphics driver and font files
  into an EXE file. BGI graphic's drivers and fonts are kept in
  separate disk files so they may be dynamically loaded at runtime.
  However, sometimes it is preferable to place all auxiliary files
  directly into an .EXE. This program, along with its make file
  (BGILINK.MAK) and two units (BGIDRIV.PAS and BGIFONT.PAS) links all
  the drivers and fonts directly into BGILINK.EXE.

  Have these 3 programs in the current drive or directory, or
  have them available via a path (both are on Disk II):

    MAKE.EXE     - Make utility that will build BGILINK.EXE
    BINOBJ.EXE   - utility program to convert any file into an .OBJ file

  Place in the current drive or directory the following files (all
  are on Disk III):

    BGILINK.PAS  - this sample program
    BGIDRIV.PAS  - Pascal unit that will link in all BGI drivers
    BGIFONT.PAS    - Pascal unit that will link in all BGI fonts
    *.CHR        - BGI font files
    *.BGI        - BGI driver files
    BGILINK.MAK  - "make" file that builds BGIDRIV.TPU, BGIFONT.TPU, and
                   finally BGILINK.EXE

  DIRECTIONS:
  1. Run MAKE on the BGILINK.MAK file by typing the following command
     at a DOS prompt:

       make -fBGIlink.mak

     Using BINOBJ.EXE, this will first build .OBJ files out of the driver
     files (*.BGI) and then call Turbo Pascal to compile BGIDRIV.PAS.
     Next, the font files (*.CHR) will be converted to .OBJs and
     BGIFONT.PAS will be compiled. Finally, BGILINK.PAS will be compiled
     (it uses BGIDRIV.TPU and BGIFONT.TPU).

  2. Run BGILINK.EXE. It contains all the drivers and all the fonts, so it
     will run on any system with a graphics card supported by the Graph
     unit (CGA, EGA, EGA 64 K, EGA monochrome, Hercules monochrome,
     VGA, MCGA, IBM 3270 PC and AT&T 6400).

  EXPLANATION

    BGILINK.PAS uses BGIDRIV.TPU and BGIFONT.TPU in its uses statement:

      uses BGIDriv, BGIFont;

    Then, it "registers" the drivers it intends to use (in this case,
    all of them, so it will run on any graphics card). Then it registers
    all of the fonts it will use (again all of them, just for demonstration
    purposes) and finally it does some very modest graphics.

    You can easily modify BGILINK.PAS for your own use by commenting out
    the calls to RegisterBGIdriver and RegisterBGIfont for drivers and
    fonts that your program doesn't use.

    For a detailed explanation of registering and linking drivers and fonts,
    refer to the RegisterBGIdriver and RegisterBGIfont descriptions in
    GRAPH.DOC (on Disk III).
}

uses Graph,     { library of graphics routines }
     BGIDriv,   { all the BGI drivers }
     BGIFont;   { all the BGI fonts }
var
  GraphDriver, GraphMode, Error : integer;

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

begin
  { Register all the drivers }
  if RegisterBGIdriver(@CGADriverProc) < 0 then
    Abort('CGA');
  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then
    Abort('EGA/VGA');
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    Abort('Herc');
  if RegisterBGIdriver(@ATTDriverProc) < 0 then
    Abort('AT&T');
  if RegisterBGIdriver(@PC3270DriverProc) < 0 then
    Abort('PC 3270');


  { Register all the fonts }
  if RegisterBGIfont(@GothicFontProc) < 0 then
    Abort('Gothic');
  if RegisterBGIfont(@SansSerifFontProc) < 0 then
    Abort('SansSerif');
  if RegisterBGIfont(@SmallFontProc) < 0 then
    Abort('Small');
  if RegisterBGIfont(@TriplexFontProc) < 0 then
    Abort('Triplex');

  GraphDriver := Detect;                  { autodetect the hardware }
  InitGraph(GraphDriver, GraphMode, '');  { activate graphics }
  if GraphResult <> grOk then             { any errors? }
  begin
    Writeln('Graphics init error: ', GraphErrorMsg(GraphDriver));
    Halt(1);
  end;

  MoveTo(5, 5);
  OutText('Drivers and fonts were ');
  MoveTo(5, 20);
  SetTextStyle(GothicFont, HorizDir, 4);
  OutText('Built ');
  SetTextStyle(SmallFont, HorizDir, 4);
  OutText('into ');
  SetTextStyle(TriplexFont, HorizDir, 4);
  OutText('EXE ');
  SetTextStyle(SansSerifFont, HorizDir, 4);
  OutText('file!');
  Rectangle(0, 0, GetX, GetY + TextHeight('file!') + 1);
  Readln;
  CloseGraph;
end.
