(*
   This unit is a sample of how to create a custom version of OVLSETREADFUNC
   for use with the Pascal+ virtual overlay manager.  It simply returns the
   the address of a custom disk read procedure to be called by the overlay mgr
   when it must read an overlay and its relocations table from disk.  The disk
   read proc will be called twice for each overlay loaded, if the overlay has
   segment relocations within its code.

   There is a dummy version of OVLSETREADFUNC in the Pascal+ runtime library,
   which gets linked into an executable if no custom version is provided.

NOTE:
   Most users of virtual overlays will not need to supply a custom disk read
   proc.  To write one requires intimate knowledge of how overlays are struc-
   tured in the executable file.
*)

{$F+,S-,D-,O-}
{$//NOMODINIT}

unit MyDisk;

interface

type
  OvlReadFunc = function(OvlyFilePos: Longint; LoadAddr: Pointer;
						NumBytes: Word): Word;

function MyDiskRead(OvlyFilePos: Longint; LoadAddr: Pointer;
				NumBytes: Word): Word; external 'MYDISKREAD';

function OvlSetReadFunc: OvlReadFunc; public 'OVLSETREADFUNC';

implementation

function OvlSetReadFunc: OvlReadFunc;
begin
  OvlSetReadFunc := MyDiskRead;
end;

end.
