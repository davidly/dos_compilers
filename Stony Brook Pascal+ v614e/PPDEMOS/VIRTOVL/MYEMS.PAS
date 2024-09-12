(********************** THIS UNIT CANNOT BE OVERLAID ************************)
(**************  REPEAT! REPEAT! - DO NOT OVERLAY THIS UNIT  ****************)

{ Example #1 in the companion file MYEMSUSE.PAS uses the results obtained by
  linking this module into a program.  Example #2 in that source file is to
  be used WITHOUT linking this module.  Both are examples of how a program can
  control the EMS used by the Virtual Overlay Manager. }


(*
   This unit shows how to control the Pascal+ virtual overlay manager's usage
   of expanded memory in a program that needs to use EMS for its own purposes
   (usually data storage).  Two alternatives exist for program control over
   the EMS overlay buffer.  One is available within a custom version of the
   function OVLCMDOPTS.  The other is provided by the OVLPROGEMSINIT function
   in conjunction with global option PROGRAMEMS in the .EDF file.  The two
   are not mutually exclusive, as can be seen in the descriptions that follow;
   but each can be used without the other.


Method 1 (in brief):

   OVLCMDOPTS gets called by the overlay manager during its initialization
   process.  Its primary purpose is to provide an interface between the pro-
   gram's command-line and the overlay manager to control certain global
   options at runtime.  However, a custom version of OVLCMDOPTS can also
   supply advance control, before program code is entered, over the sizes of
   the EMS and conventional heap overlay buffers.  (See MYCMDOPTS.PAS for an
   example of conventional heap overlay buffer sizing).

   There is a dummy version of OVLCMDOPTS in the Pascal+ runtime library that
   gets linked into an executable IF NO CUSTOM VERSION IS SUPPLIED.  It does
   nothing.


Method 2 (not so brief):

   OVLPROGEMSINIT and a companion function, OVLEMSNEED, are NOT intended for
   use in a version of OVLCMDOPTS.  They are solely for use inside program
   code.  OVLPROGEMSINIT should be called as early as possible after program
   code is entered.  It provides strict control over the EMS handle and pages
   to be used by the virtual overlay manager.  The manager delays its usage of
   EMS until this proc is called in the program.  That is the reason for the
   importance of calling it early in program code.  OVLEMSNEED does not have
   to be used.  However, if called after program code is entered, it will
   return the amount of EMS pages the overlay manager needs for optimum per-
   formance with runtime EMS resources.

   To use OVLPROGEMSINIT inside a program, the global option PROGRAMEMS must
   be specified in the program's .EDF file at link-time.  If the option is
   not set, OVLPROGEMSINIT returns an error code (-1) at runtime and the man-
   ager will have automatically set up its EMS usage prior to entering program
   code.

   When OVLPROGEMSINIT is used inside a program, there is a possibility that
   the program may not permit the overlay manager to use many of the EMS pages
   expected to be available.  In that case, the program may run at a slower
   speed than desirable.  A situation like this can be forestalled by use of
   the advance control available in a custom OVLCMDOPTS function, or by having
   the program code check the value returned from a call to OVLEMSNEED against
   EMS availability and its own EMS needs.  Then the program can make an edu-
   cated decision about how much EMS to allow for overlays.


Some details:

   The virtual overlay manager checks availability of EMS during its init
   process and compares the result to a private variable that holds the
   allowed size of the EMS overlay buffer.  It makes a determination of how
   large a conventional overlay buffer to create based on the results of the
   EMS calculations and the size specified by __OVLBUFSIZE__ (set in the .EDF
   file) for the maximum allowed conventional buffer.

   A custom OVLCMDOPTS can be created that performs its own test of EMS avail-
   ability and calls OVLSETEMSBUF to set a new value in the private variable.
   The value to set is calculated from the results of the EMS check compared
   to the program's own requirements for EMS usage.  Since OVLCMDOPTS is
   called very early in the manager's init process, the manager will receive a
   fine-tuned value for the allowed EMS buffer size.  This will ensure its EMS
   and conventional buffer calculations can be relied upon to provide optimum
   performance when program code is entered.  Of course, a large enough value
   must be set for __OVLBUFSIZE__ (and there must be a large enough heap) to
   allow a conventional overlay buffer of sufficient size to soften the per-
   formance impact of limited EMS availability at runtime.

   If a custom OVLCMDOPTS is used as described, a call to OVLPROGEMSINIT would
   be needed after program code is entered only if there was just 1 EMS handle
   available for allocating pages.  In that case, the program must allocate
   pages both for its own use and for the overlay manager.  Each would share
   the single handle and would not use each others pages.  Again the value
   returned by OVLEMSNEED will help in calculations to determine how much EMS
   to allocate prior to calling OVLPROGEMSINIT.

   In conjunction with fine-tuning the allowed size of the EMS overlay buffer,
   the PROGRAMEMS option can be reset (nullified) inside OVLCMDOPTS to allow
   the program code to bypass a call to OVLPROGEMSINIT altogether, when enough
   EMS handles are found available by the EMS check inside OVLCMDOPTS.


NOTE:
   OVLSETEMSBUF can only be called in a version of OVLCMDOPTS.  If a direct
   call is made to it after the program code begins, it will return an error
   value of -1.  This function references a value used by the overlay manager
   only during its initialization process, so there is no point to calling it
   after program code begins.
*)


{$F+,S-,D-,L-,X+,O-}
{$//NOMODINIT//NOLIBRARY}

unit MyEms;

interface

function OvlCmdOpts: word; public 'OVLCMDOPTS';


implementation

uses MyEmsCt;

const
  NOCHANGE	= $0000;
  NOTPROGRAMEMS = $0010;	{ Overlay Manager handles complementing this }

function OvlSetEMSBuf(NumPages: word): word; far; external 'OVLSETEMSBUF';


(****************************************************************************)
{	Helper function for custom version of OvlCmdOpts to check EMS	     }
(****************************************************************************)

function CheckEms(var Avail: CheckEmsRec): boolean; pureasm;
ASM
	push	bp
	mov	bp,sp
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
	jnz	@BadExit { if driver is not present, no EMS is available }
	mov	ah,40h	{ get EMS status; verify EMS system functional }
	int	67h
	shl	ah,1
	jc	@BadExit
	mov	ah,46h	{ get EMS version # }
	int	67h
	or	ah,ah
	jnz	@BadExit
	cmp	al,40h	{ next EMS operation uses a function not available in
			  versions below 4.0; (however, overlay mgr can use
			  EMS version 3.2) }
	jb	@BadExit
	mov	ax,5402h { get total handles supported by EMS system; 4.0 }
	int	67h
	shl	ah,1
	jc	@BadExit
	mov	cx,bx
	mov	ah,4Bh	{ get total EMS handles in use }
	int	67h
	shl	ah,1
	jc	@BadExit
	sub	cx,bx	{ how many free handles? }
	les	di,Avail
	mov	word ptr es:[di].CheckEmsRec.Handles,cx { return available
							  EMS handles }
	mov	ah,42h	{ get unallocated pages count }
	int	67h
	shl	ah,1
	jc	@BadExit
	mov	word ptr es:[di].CheckEmsRec.Pages,bx  { return available EMS
							 pages }
	mov	al,True
@ExitCKEms:
	pop	bp
	ret	0004h

@BadExit:
	mov	al,False
	jmp	near ptr @ExitCKEms

@EmsDeviceName: db	'EMMXXXX0';

end;


(****************************************************************************)
{		Custom version of OvlCmdOpts for EMS usage		     }
(****************************************************************************)

function OvlCmdOpts: Word;
begin

(*
 Here we assume the program needs at least 4 pages of expanded memory for its
 own use.  We ensure the overlay manager only expects to receive the use of
 any pages available beyond 4.  We also facilitate EMS preloading by resetting
 the PROGRAMEMS global option flag, when 2 or more EMS handles remain for
 allocation.
*)
  OvlCmdOpts := NOCHANGE;	{ in case we get an error before we exit; this
				  is ABSOLUTELY ESSENTIAL so no other availa-
				  ble global options in the Virtual Overlay
				  Manager will be affected }
  if CheckEms(WhatsAvailable) = True then
  begin
   if WhatsAvailable.Handles > 0 then
   begin
    if (WhatsAvailable.Pages > 4) then
      OvlSetEMSBuf(WhatsAvailable.Pages - 4) { overlay mgr can use all beyond
					       the first 4 pages (0-3) }
    else
      OvlSetEMSBuf(0);
    if WhatsAvailable.Handles > 1 then	    { reset global option PROGRAMEMS }
      OvlCmdOpts := NOTPROGRAMEMS;
   end;
  end;

end;

end.
