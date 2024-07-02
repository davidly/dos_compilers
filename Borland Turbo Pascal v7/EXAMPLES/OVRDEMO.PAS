{************************************************}
{                                                }
{ Overlay Demo                                   }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

{$F+,O+}
program OvrDemo;
(*
  This is a simple example of how to use the new overlay system. For
  more complete documentation, refer to the overlay chapter in the
  Programmer's Guide. Here's a quick checklist:

    1.  Turn "far calls" on {$F+} (to be safe, in all overlaid units and
        the main program).
    2.  Turn "Overlays allowed" on {$O+}
    3.  Use Overlay unit in main program.
    4.  Issue separate {$O} directives for each overlaid unit.
    5.  Make sure to call OvrInit and pass the name of the .OVR file.
    6.  Test OvrResult after OvrInit calls (optional).
    7.  Compile to disk (cannot run in memory).

  Here are the overlay error returns for quick reference:

    const
      ovrOk          =  0;   { Success }
      ovrError       = -1;   { Overlay manager error }
      ovrNotFound    = -2;   { Overlay file not found }
      ovrNoMemory    = -3;   { Not enough memory for overlay buffer }
      ovrIOError     = -4;   { Overlay file I/O error }
      ovrNoEMSDriver = -5;   { EMS driver not installed }
      ovrNoEMSMemory = -6;   { Not enough EMS memory }
*)

uses
  Overlay, Crt, OvrDemo1, OvrDemo2;

{$O OvrDemo1}                  { overlay 'em }
{$O OvrDemo2}

begin
  TextAttr := White;
  ClrScr;
  OvrInit('OVRDEMO.OVR');       { init overlay system, reserve heap space }
  if OvrResult <> 0 then
  begin
    Writeln('Overlay error: ', OvrResult);
    Halt(1);
  end;
  repeat
    Write1;
    Write2;
  until KeyPressed;
end.
