(*
   This unit is a sample of how to create a custom version of OVLCMDOPTS
   for use with the Pascal+ virtual overlay manager.  OVLCMDOPTS gets called
   by the overlay manager during its initialization process to allow the pro-
   gram to provide a command-line interface to certain global options within
   the overlay mgr.  Available for command-line control are these options:
   (1) NOEMS - so program's end-user can tell the overlay mgr not to use any
   expanded memory at all; (2) NOEMSRUN to tell the overlay mgr not to execute
   overlays in expanded memory, but it can cache them there; (3) EMSPAGESxxxx
   to set the number of pages of expanded memory allowed for use by the over-
   lay manager from the command-line.  This module shows how to call functions
   of the virtual overlay manager to provides these command-line controls.

   In addition, there is an example of how to provide some runtime control
   over the amount of a program's heap space that can be used by the virtual
   overlay manager for loading overlays that must execute in conventional mem-
   ory.

   There is a dummy version of OVLCMDOPTS in the Pascal+ runtime library that
   gets linked into an executable if no custom version is supplied.  It does
   nothing.

NOTE:
   Users of virtual overlays will only need to write a custom version of
   OVLCMDOPTS if they wish to provide a command-line interface to the availa-
   ble options.  These same options, with the exception of setting the number
   of pages of expanded memory usage, are available in the .EDF file.  The
   EMS pages setting is only useful as a runtime function anyway.  (For info
   on how to use EMS within a program in harmony with the virtual overlay
   manager's usage of EMS, see MYEMS.PAS source file.)

   The functions of the virtual overlay manager that are used in this custom
   version of OVLCMDOPTS (OVLGETBUF, OVLSETBUF, OVLSETEMSBUF) can only be
   called in a version of OVLCMDOPTS.  If a direct call is made to any of them
   after the program code begins, each one will return an error value of -1.
   These functions reference values used by the overlay manager only during
   its initialization process, so there is no point to calling them after pro-
   gram code begins.
*)

{$F+,S-,D-,X+,O-}
{$//NOMODINIT}

unit MyCmdOpt;

interface

function OvlCmdOpts: Word; public 'OVLCMDOPTS';

implementation

type
  CmdLineStrings = array [0..3] of string[14];

const
  CmdLineTable: CmdLineStrings = ('NOEMS',
				  'NOEMSRUN',
				  'EMSPAGES',
				  'CONVBUFFERSIZE');
const
  NOEMS    = $0003;
  NOEMSRUN = $0001;

function OvlGetBuf: Longint; far; external 'OVLGETBUF';
function OvlSetBuf(BufSize: Longint): Word; far; external 'OVLSETBUF';
function OvlSetEMSBuf(NumPages: Word): Word; far; external 'OVLSETEMSBUF';

function OvlCmdOpts: Word;
type
  PtrRec = record
    Ofst, Segm: Word;
  end;
var
  NumParams: Integer;
  EntryLen: Integer;
  CmdLineEntry: string[20];
  SubEntry1: string[14];
  SubEntry2: string[6];
  i, V, Code: Integer;
  LV: Longint;
  TempCmdOpts: Word;
  ConvBufSize, RunHeapSize: Longint;
  ConvBufPages: Integer;
begin
  TempCmdOpts := 0;
  NumParams := ParamCount;
  while NumParams > 0 do
  begin
    CmdLineEntry := Copy(ParamStr(NumParams), 1, 20);
    EntryLen := Length(CmdLineEntry);
    for i := 1 to EntryLen do
      CmdLineEntry[i] := UpCase(CmdLineEntry[i]);
    case EntryLen of
      5: if CmdLineEntry = CmdLineTable[0] then
	   TempCmdOpts := TempCmdOpts OR NOEMS;
      8: if CmdLineEntry = CmdLineTable[1] then
	   TempCmdOpts := TempCmdOpts OR NOEMSRUN;
      9..12: begin
	       SubEntry1 := Copy(CmdLineEntry,1,8);
	       if SubEntry1 = CmdLineTable[2] then
	       begin
		 SubEntry2 := Copy(CmdLineEntry,9,4);
		 Val(SubEntry2, V, Code);
		 OvlSetEMSBuf(V);
	       end;
	     end;
     15..20: begin
	       SubEntry1 := Copy(CmdLineEntry,1,14);
	       if SubEntry1 = CmdLineTable[3] then
	       begin
		 SubEntry2 := Copy(CmdLineEntry,15,6);
		 Val(SubEntry2, LV, Code);
		 OvlSetBuf(LV);
	       end;
	     end;
    end;
    Dec(NumParams);
  end;
  OvlCmdOpts := TempCmdOpts;

{This next section of code gives our custom version of OVLCMDOPTS runtime con-
 trol over the amount of the program's heap space made available to the over-
 lay manager.  The size set for __OVLBUFSIZE__ in the .EDF file would be rela-
 tive to the /$M option settings for the program's heap.  Runtime fine-tuning
 of __OVLBUFSIZE__ is provided here based on the actual amount of heap space
 the program gets from DOS when it runs.

 When the overlay manager initializes, unless all overlays are allowed to exe-
 cute in expanded memory and there is enough of it available to hold them all,
 it will use __OVLBUFSIZE__ converted to an integral multiple of 16k pages as
 the basis for setting up its conventional memory overlay buffer.  It will
 ONLY use more heap space than set here by the call to OvlSetBuf, if it must
 increase the value upward to the next 16k increment or if the largest overlay
 to run in the conventional overlay buffer is greater in size (converted to
 16k pages) than the amount set here.

NOTE:
 In addition to the conventional memory overlay buffer there is an amount of
 heap space required for 3 purposes: (1) the mgr's data structures; (2) when
 the EMS management code is overlaid an additional (approximately) 2000 bytes
 of heap is used for it (it never gets discarded after it's loaded); (3) a
 buffer to hold the largest segment relocations table for any overlay (this
 overlay mgr loads only the overlaid code in the overlay buffer space; segment
 relocations are handled separately in a single buffer).  To accomodate these
 additional heap requirements of the overlay mgr, factor in an additional 4k
 in the calculations to determine how much total heap space is actually going
 to be needed at runtime.

 Here we assume the program needs at least 8k of heap space for its data. We
 attempt to assure it gets it.  However, if it is critical to have 8k of heap
 for data, a test should be made at the beginning of the program's code to see
 that at least 8k is still available after the overlay mgr takes what it must
 have for its own use.

 REMEMBER, if a program uses virtual overlays, the manager must be able to
 load them into memory on demand.  So it must have any heap space it needs,
 or the program won't execute properly.}

  ConvBufSize  := OvlGetBuf;
  ConvBufPages := (ConvBufSize + 16383) div 16384; {overlay mgr rounds it up,
						    too}
  ConvBufSize  := Longint(ConvBufPages) * Longint(16384);
  RunHeapSize := Longint((PtrRec(HeapEnd).Segm - PtrRec(HeapOrg).Segm)) * Longint(16);
  if RunHeapSize < (ConvBufSize + 4096 + 8192) then
  begin
    ConvBufPages := (RunHeapSize - (4096 + 8192)) div 16384;
    OvlSetBuf(Longint(ConvBufPages) * Longint(16384)); {convert allowed pages
							back to bytes}
  end;
end;

end.
