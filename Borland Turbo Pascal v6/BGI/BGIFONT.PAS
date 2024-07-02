
{ Copyright (c) 1985, 1990 by Borland International, Inc. }

unit BGIFont;
{ Sample unit to accompany BGILINK.PAS. This unit links all the BGI graphics
  fonts into a single TPU file. This makes it easy to incorporate the font
  files directly into an .EXE file. See BGILINK.PAS for more information.
}
interface

procedure GothicFontProc;
procedure SansSerifFontProc;
procedure SmallFontProc;
procedure TriplexFontProc;

implementation

procedure GothicFontProc; external;
{$L GOTH.OBJ }

procedure SansSerifFontProc; external;
{$L SANS.OBJ }

procedure SmallFontProc; external;
{$L LITT.OBJ }

procedure TriplexFontProc; external;
{$L TRIP.OBJ }

end.
