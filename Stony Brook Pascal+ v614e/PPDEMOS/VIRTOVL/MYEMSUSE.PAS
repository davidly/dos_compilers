(************************ THIS UNIT CAN BE OVERLAID *************************)
{
  Since only one of the procs in this module would be called in a program, a
  little program space will be conserved by compiling to LIB instead of OBJ.
  For that reason the //LIBRARY option is included in the compiler directives
  below.
}

(*
   This unit shows how to control the Pascal+ virtual overlay manager's usage
   of expanded memory in a program that needs to use EMS for its own purposes
   (usually data storage).  Two alternatives exist for program control over
   the EMS overlay buffer.  One is available within a custom version of the
   function OVLCMDOPTS.  The other is provided by the OVLPROGEMSINIT function
   in conjunction with global option PROGRAMEMS in the .EDF file.  The two
   are not mutually exclusive, but each can be used without the other. (See
   MYEMS.PAS for more detailed descriptions.)


NOTE:
   OVLPROGEMSINIT and OVLEMSNEED each return a -1 error value if called in
   OVLCMDOPTS, because they are for use strictly within the program code.

WARNING:
   When a program will use EMS for its own purposes, care must be taken to
   avoid a conflict between the Virtual Overlay Manager's use of EMS and that
   of the program.  The simple solution is to include the global option
   NOEMSRUN in the .EDF file at link-time.  This will allow the overlay mgr
   to use EMS for caching overlays to minimize disk access, but no overlaid
   code will execute in EMS.  The manager saves and restores the EMS mapping
   context each time it accesses EMS when the NOEMSRUN option is in effect.
   Thus, at runtime the program can forget that the overlay mgr is even using
   EMS.

   If it is desirable to allow the overlay manager to execute overlays in EMS
   while the program is using EMS for its own needs, some careful planning of
   how the executable is built will be needed.  Of course, no program usage
   of EMS can coincide with overlay execution in EMS.  This means no code in-
   volved in the program's usage of EMS can be allowed to execute in EMS. In
   addition, the program's EMS management code must save and restore the map-
   ping context each time it accesses EMS.  This will ensure that overlays
   executing there will still be properly mapped into the EMS standard page
   frame when code within them must run.

   The Virtual Overlay Manager does not 'hook' int 67h (the EMS device driv-
   er's interface to programs).  Therefore, it is not aware of any usage of
   EMS other than its own.  Currently, it only uses the standard EMS page
   frame (64k) and works fine with EMS versions 3.2 and higher.

   It is feasible for programs that use EMS directly and require at least
   version 4.0, to use pages that are mappable outside the standard page
   frame for their own EMS needs.  This would avoid the necessity of the
   program's EMS management code having to save and restore the mapping con-
   text of the standard page frame each time it accesses EMS.  Then the over-
   lay manager can continue to execute overlaid code in EMS without fear of
   conflict.  This 'space diversity' technique is worth considering. Be aware,
   however, that memory managers such as QEMM-386 and 386 MAX often are con-
   figured to use the mappable pages outside the standard page frame for UMBs
   (upper memory blocks).
*)


{$F+,S-,D-,L-,X+,O+}
{$//NOMODINIT//LIBRARY}

unit MyEmsUse;

interface

const
  ProgEmsHandle: word = $FFFF;  { handle 0 is reserved for operating system
				  usage of EMS; we want an invalid one here }

  ProgEmsPages: word = 0;	{ will include the count of pages used both
				  by the program and the overlay manager if
				  the program will assign the manager's EMS
				  handle and pages directly via a call to
				  OVLPROGEMSINIT }

function SetPgmEmsUsage_1: boolean; {usable only when MYEMS unit is linked in}
function SetPgmEmsUsage_2: boolean; {for use when MYEMS unit is not linked in}


implementation

uses MyEmsCt;

function OvlProgEmsInit(emmhandle, startpage, numpages: word): word;
					   far; external 'OVLPROGEMSINIT';
function OvlEmsNeed: word; far; external 'OVLEMSNEED';


(****************************************************************************)
{	Proc for use in ExitProc so the EMS handle and pages allocated by    }
{	the program will be automatically released at termination.	     }
(****************************************************************************)

var
  SaveOldExitProc: pointer;

procedure ReleasePgmEmsUsage;
begin
  ExitProc := SaveOldExitProc;  { restore previous exit procedure's address }
  ASM
	mov	ah,45h { relase program's EMS handle & pages back to system }
	mov	dx,ProgEmsHandle
	int	67h    { do the EMS }
  END;
end;


(*
 Here we assume the program needs at least 4 pages of expanded memory for its
 own use.
*)

(****************************************************************************)
{    Example #1 of a proc for program code to call to set up its own EMS     }
{    usage, and to notify the Virtual Overlay Manager what EMS it can use.   }
{    This proc represents the greatest degree of control possible over EMS   }
{    usage by the Manager.  It depends upon results from an EMS availability }
{    test in the custom OVLCMDOPTS defined in MYEMS.PAS.  Also, the overlay  }
{    manager will have already allocated its EMS buffer if more than one (1) }
{    handle was found available in OVLCMDOPTS.  In that case, OVLPROGEMSINIT }
{    will not be called here.						     }
(****************************************************************************)

function SetPgmEmsUsage_1: boolean;
label
  BadExitInPgm;
var
  PagesToAllocate: word;
begin
  if WhatsAvailable.Handles > 0 then  { WhatsAvailable gets inited by the cus-
					tom OVLCMDOPTS function in MYEMS.PAS }
  begin
    if WhatsAvailable.Pages >= 4 then
      if WhatsAvailable.Handles = 1 then
	PagesToAllocate := OvlEmsNeed + 4
      else
	PagesToAllocate := 4
    else
      goto BadExitInPgm;
    if PagesToAllocate > WhatsAvailable.Pages then
      PagesToAllocate := WhatsAvailable.Pages;
    ASM
	mov	ah,43h	{ allocate EMS handle & pages }
	mov	bx,PagesToAllocate	{ pages needed in BX }
	int	67h	{ do the EMS }
	shl	ah,1
	jc	BadExitInPgm
	mov	ProgEmsPages,bx
	mov	ProgEmsHandle,dx
    END;
    if (PagesToAllocate > 4) and (WhatsAvailable.Handles = 1) then
      OvlProgEmsInit(ProgEmsHandle, 4 {program uses logical pages 0-3 },
						    PagesToAllocate - 4);
    SaveOldExitProc := ExitProc;
    ExitProc := @ReleasePgmEmsUsage;
    SetPgmEmsUsage_1 := True;
    Exit;
  end;

BadExitInPgm:
  SetPgmEmsUsage_1 := False;

end;


(****************************************************************************)
{    Example #2 of a proc for program code to call to set up its own EMS     }
{    usage, and to notify the Virtual Overlay Manager what EMS it can use.   }
{    This proc is designed to be used when no custom version of OVLCMDOPTS   }
{    will be created for a program.  Also, it does not require CheckEms      }
{    from MYEMS.PAS.							     }
{    In other words, DON'T LINK the MYEMS unit into the program.	     }
(****************************************************************************)

function SetPgmEmsUsage_2: boolean;
label
  BadExitInPgm;
var
  AvailableHandles, AvailablePages, PagesToAllocate: word;
begin
  ASM
	mov	ax,3567h
	int	21h	{ returns int 67h vector address (EMS device handler)
			  in es:bx }
	mov	di,0Ah	{ offset in device driver header of device's "name" }
	push	ds
	push	cs
	pop	ds
	mov	si,offset @EmsDeviceName
	mov	cx,08h	{ len device name }
	cld		{ must never forget this }
	repz	cmpsb
	pop	ds
	jnz	BadExitInPgm { if driver is not present, no EMS available }
	mov	ah,40h	{ get EMS status; verify EMS system functional }
	int	67h
	shl	ah,1
	jc	BadExitInPgm
	mov	ah,46h	{ get EMS version # }
	int	67h
	or	ah,ah
	jnz	BadExitInPgm
	cmp	al,40h	{ next EMS operation uses a function not available in
			  versions below 4.0; (however, overlay mgr can use
			  EMS version 3.2) }
	jb	BadExitInPgm
	mov	ax,5402h { get total handles supported by EMS system; 4.0 }
	int	67h
	shl	ah,1
	jc	BadExitInPgm
	mov	cx,bx
	mov	ah,4Bh	{ get total EMS handles in use }
	int	67h
	shl	ah,1
	jc	BadExitInPgm
	sub	cx,bx	{ how many free handles? }
	mov	AvailableHandles,cx
	mov	ah,42h	{ get unallocated pages count }
	int	67h
	shl	ah,1
	jc	BadExitInPgm
	mov	AvailablePages,bx
	jmp	@ExitAsmCode

@EmsDeviceName:	db	'EMMXXXX0'

@ExitAsmCode:
  END;

  if AvailableHandles > 0 then
  begin
    if AvailablePages >= 4 then
    begin
      PagesToAllocate := OvlEmsNeed + 4;
      if PagesToAllocate > AvailablePages then
	PagesToAllocate := AvailablePages;
      ASM
	mov	ah,43h	{ allocate EMS handle & pages }
	mov	bx,PagesToAllocate	{ pages needed in BX }
	int	67h	{ do the EMS }
	shl	ah,1
	jc	BadExitInPgm
	mov	ProgEmsPages,bx
	mov	ProgEmsHandle,dx
      END;
      if PagesToAllocate > 4 then
	OvlProgEmsInit(ProgEmsHandle, 4 {program uses logical pages 0-3 },
						    PagesToAllocate - 4);
      SaveOldExitProc := ExitProc;
      ExitProc := @ReleasePgmEmsUsage;
      SetPgmEmsUsage_2 := True;
      Exit;
    end;
  end;

BadExitInPgm:
  SetPgmEmsUsage_2 := False;

end;

end.
