
{ Copyright (c) 1985, 88 by Borland International, Inc. }

unit MCVARS;

interface

uses Crt;

{$IFOPT N+}

type
  Real = Extended;

const
  EXPLIMIT = 11356;
  SQRLIMIT = 1E2466;
  MAXPLACES = 8;
  MAXEXPLEN = 4;

{$ELSE}

const
  EXPLIMIT = 88;
  SQRLIMIT = 1E18;
  MAXPLACES = 4;
  MAXEXPLEN = 3;

{$ENDIF}

const
  MSGHEADER = 'MICROCALC - A Turbo Pascal Demonstration Program';
  MSGKEYPRESS = 'Press any key to continue.';
  MSGCOMMAND = 'Press / for the list of commands';
  MSGMEMORY = 'Memory Available:';
  MSGLOMEM = 'Not enough memory to allocate cell.';
  MSGERRORTXT = 'ERROR';
  MSGEMPTY = 'Empty';
  MSGTEXT = 'Text';
  MSGVALUE = 'Value';
  MSGFORMULA = 'Formula';
  MSGAUTOCALC = 'AutoCalc';
  MSGFORMDISPLAY = 'Form';
  MSGFILENAME = 'Enter the file name of the spreadsheet:';
  MSGNAME = 'Turbo Pascal MicroCalc Spreadsheet';
  MSGCOLWIDTH = 'Enter the new column width:';
  MSGNOOPEN = 'Can''t open the file.';
  MSGOVERWRITE = 'The file exists.  Do you want to overwrite it?';
  MSGFILELOMEM = 'Not enough memory for entire spreadsheet.';
  MSGNOMICROCALC = 'That is not a Turbo Pascal MicroCalc spreadsheet.';
  MSGBADREALS = 'The reals in the file are in a different format.';
  MSGNOEXIST = 'The file does not exist.';
  MSGGOTO = 'Enter the cell to go to:';
  MSGBADNUMBER = 'You must enter a number from';
  MSGBADCELL = 'That is not a legal cell.';
  MSGCELL1 = 'Enter the first cell to format:';
  MSGCELL2 = 'Enter the last cell to format:';
  MSGDIFFCOLROW = 'The row or the column must be the same.';
  MSGRIGHTJUST = 'Do you want the cell right-justified?';
  MSGDOLLAR = 'Do you want numbers in a dollar format?';
  MSGCOMMAS = 'Do you want commas in numbers?';
  MSGPLACES = 'How many decimal places should the number be rounded to?';
  MSGCOLUMNS = 'Do you want to print in 132 columns?';
  MSGPRINT = 'Enter the file name to print to, or press ENTER to print on the printer.';
  MSGBORDER = 'Print the border?';
  MSGLOADING = 'Loading...';
  MSGSAVING = 'Saving...';
  MSGSAVESHEET = 'Save current spreadsheet?';
  MSGSTACKERROR = 'Parser stack overflow.';

  MNU = 'Spreadsheet, Format, Delete, Goto, Col, Row, Edit, Utility, Auto, Quit';
  COMMAND = 'SFDGCREUAQ';
  SMNU = 'Load, Save, Print, Clear';
  SCOMMAND = 'LSPC';
  CMNU = 'Insert, Delete, Width';
  CCOMMAND = 'IDW';
  RMNU = 'Insert, Delete';
  RCOMMAND = 'ID';
  UMNU = 'Recalc, Formula display, Toggle 43-line mode';
  UCOMMAND = 'RFT';

  MAXCOLS = 100;     { Maximum is 702 }
  MAXROWS = 100;
  LEFTMARGIN = 3;
  MINCOLWIDTH = 3;
  MAXCOLWIDTH = 77;
  SCREENCOLS = 26;
  DEFAULTWIDTH = 10;
  DEFAULTFORMAT = $42;
  MAXINPUT = 79;
  TOPMARGIN = 5;
  PARSERSTACKSIZE = 20;

  TXTCOLOR = White;
  ERRORCOLOR = 140;  { LightRed + Blink }
  VALUECOLOR = LightCyan;
  FORMULACOLOR = LightMagenta;
  BLANKCOLOR = Black;
  HEADERCOLOR = 79;  { White on Red }
  HIGHLIGHTCOLOR = 31;  { White on Blue }
  HIGHLIGHTERRORCOLOR = 159; { White + Blink on Blue }
  MSGAUTOCALCCOLOR = LightCyan;
  MSGFORMDISPLAYCOLOR = LightMagenta;
  MSGMEMORYCOLOR = LightGreen;
  MSGHEADERCOLOR = LightCyan;
  PROMPTCOLOR = Yellow;
  COMMANDCOLOR = LightCyan;
  LOWCOMMANDCOLOR = White;
  MEMORYCOLOR = LightRed;
  CELLTYPECOLOR = LightGreen;
  CELLCONTENTSCOLOR = Yellow;

  HIGHLIGHT = True;
  NOHIGHLIGHT = False;
  UPDATE = True;
  NOUPDATE = False;
  DOFORMAT = True;
  NOFORMAT = False;
  LEFT = 0;
  RIGHT = 1;
  UP = 2;
  DOWN = 3;
  TXT = 0;
  VALUE = 1;
  FORMULA = 2;
  COLADD = 0;
  COLDEL = 1;
  ROWADD = 2;
  ROWDEL = 3;
  OVERWRITE = $80;
  RJUSTIFY = $40;
  COMMAS = $20;
  DOLLAR = $10;
  LETTERS : set of Char = ['A'..'Z', 'a'..'z'];

  NULL = #0;
  BS = #8;
  FORMFEED = #12;
  CR = #13;
  ESC = #27;
  HOMEKEY = #199;
  ENDKEY = #207;
  UPKEY = #200;
  DOWNKEY = #208;
  PGUPKEY = #201;
  PGDNKEY = #209;
  LEFTKEY = #203;
  INSKEY = #210;
  RIGHTKEY = #205;
  DELKEY = #211;
  CTRLLEFTKEY = #243;
  CTRLRIGHTKEY = #244;
  F1 = #187;
  F2 = #188;
  F3 = #189;
  F4 = #190;
  F5 = #191;
  F6 = #192;
  F7 = #193;
  F8 = #194;
  F9 = #195;
  F10 = #196;

type
  IString = String[MAXINPUT];
  CellRec = record
    Error : Boolean;
    case Attrib : Byte of
      TXT : (T : IString);
      VALUE : (Value : Real);
      FORMULA : (Fvalue : Real;
                 Formula : IString);
  end;
  CellPtr = ^CellRec;

var
  Cell : array [1..MAXCOLS, 1..MAXROWS] of CellPtr;
  CurCell : CellPtr;
  Format : array [1..MAXCOLS, 1..MAXROWS] of Byte;
  ColWidth : array [1..MAXCOLS] of Byte;
  ColStart : array [1..SCREENCOLS] of Byte;
  LeftCol, RightCol, TopRow, BottomRow, CurCol, CurRow, LastCol,
    LastRow : Word;
  Changed, FormDisplay, AutoCalc, Stop, ColorCard : Boolean;
  ColorTable : array [0..255] of Byte;
  ScreenRows : Byte;
  OldMode : Word;
  UMenuString : String[80];
  UCommandString : String[3];

implementation

end.
