	page	60,132
	name	RTSBIN
	title	RTSBIN - Micro Focus RTS.BIN compatibility addendum
	subttl	Copyright (C) 1987 by  Micro Focus Ltd. Palo Alto, Ca


	public	__USRCAL_TAB


;-----------------------------------------------------------------------
;
; This module shows how to include your x"00" thru x"7f" routines
; formerly dynamically loaded in RTS.BIN, into IBM COBOL 2.X EXE files.
;
; You should have the current source code for your RTS.BIN file.
;
; IBM COBOL 2.00 does not dynamically load RTS.BIN.
; Instead it uses LINK to include OBJ code corresponding to RTS.BIN contents
; into your EXE file.
; If you have coded your routines carefully they can be shared in a
; multi-tasking environment using this process.
; So on FlexOs or OS/2 you do not need to have multiple copies of RTS.BIN
; for each user of your program.
;
;
;
; This file contains a JUMP TABLE which you can change to support your
; RTS.BIN routines.
;
; The jump table is a table of 128 words corresponding to the call numbers
; between x"00" and x"7f" inclusive. Each entry points either to a
; near return or to one of your routines. You can point any entry at one
; of your routines which then becomes accessible at run time. The parameter
; ordering and machine register state are the same as those defined for
; RTS.BIN.
;
; Example:
;
;	Suppose your application (TEST.CBL say ) executes code similar to
;	CALL X"00" USING PARM-1.
;	Edit the source file from which you produce RTS.BIN to extract
;	the code which satisfies this call number. Insert that code into
;	this module. Change the _USRCAL_TAB entry for call x"00" from
;	offset csbase:usrcall_ret to offset csbase:your_routine_name.
;	Assemble this module with MASM to produce RTSBIN.OBJ.
;	Compile your application to produce TEST.OBJ.
; 	Link your application with the command line
;	LINK TEST+RTSCALL+RTSBIN;
;	The EXE file which results now contains your code for x"00".
;	
;
; NOTE: You should seriously consider re-coding your COBOL source code
;       to avoid using CALL x"00" through x"7f" in order to avoid the
;       extra overhead of linking RTSCALL and RTSBIN into your EXE file.
;	Linking in these files can dramatically increase the size of your
;	executable file, which can be avoided.
;       The alternative to this type of call-by-number programming is
;	to use CALL <_literal-name>  (the first character of the literal
;	is an underscore character ). In this case the linker includes
;	your subprogram (which declares <_literal-name> as a public )
;	into your executable file.
;
;-----------------------------------------------------------------------



CSEG	segment	word	public	'CODE'	
	assume	cs:CSEG
	csbase	equ CSEG
page
__USRCAL_TAB label byte
_FCAL00		dw	offset csbase:__cblreturn
_FCAL01		dw	offset csbase:__cblreturn
_FCAL02		dw	offset csbase:__cblreturn
_FCAL03		dw	offset csbase:__cblreturn
_FCAL04		dw	offset csbase:__cblreturn
_FCAL05		dw	offset csbase:__cblreturn
_FCAL06		dw	offset csbase:__cblreturn
_FCAL07		dw	offset csbase:__cblreturn
_FCAL08		dw	offset csbase:__cblreturn
_FCAL09		dw	offset csbase:__cblreturn
_FCAL0A		dw	offset csbase:__cblreturn
_FCAL0B		dw	offset csbase:__cblreturn
_FCAL0C		dw	offset csbase:__cblreturn
_FCAL0D		dw	offset csbase:__cblreturn
_FCAL0E		dw	offset csbase:__cblreturn
_FCAL0F		dw	offset csbase:__cblreturn
_FCAL10		dw	offset csbase:__cblreturn
_FCAL11		dw	offset csbase:__cblreturn
_FCAL12		dw	offset csbase:__cblreturn
_FCAL13		dw	offset csbase:__cblreturn
_FCAL14		dw	offset csbase:__cblreturn
_FCAL15		dw	offset csbase:__cblreturn
_FCAL16		dw	offset csbase:__cblreturn
_FCAL17		dw	offset csbase:__cblreturn
_FCAL18		dw	offset csbase:__cblreturn
_FCAL19		dw	offset csbase:__cblreturn
_FCAL1A		dw	offset csbase:__cblreturn
_FCAL1B		dw	offset csbase:__cblreturn
_FCAL1C		dw	offset csbase:__cblreturn
_FCAL1D		dw	offset csbase:__cblreturn
_FCAL1E		dw	offset csbase:__cblreturn
_FCAL1F		dw	offset csbase:__cblreturn
_FCAL20		dw	offset csbase:__cblreturn
_FCAL21		dw	offset csbase:__cblreturn
_FCAL22		dw	offset csbase:__cblreturn
_FCAL23		dw	offset csbase:__cblreturn
_FCAL24		dw	offset csbase:__cblreturn
_FCAL25		dw	offset csbase:__cblreturn
_FCAL26		dw	offset csbase:__cblreturn
_FCAL27		dw	offset csbase:__cblreturn
_FCAL28		dw	offset csbase:__cblreturn
_FCAL29		dw	offset csbase:__cblreturn
_FCAL2A		dw	offset csbase:__cblreturn
_FCAL2B		dw	offset csbase:__cblreturn
_FCAL2C		dw	offset csbase:__cblreturn
_FCAL2D		dw	offset csbase:__cblreturn
_FCAL2E		dw	offset csbase:__cblreturn
_FCAL2F		dw	offset csbase:__cblreturn
page
_FCAL30		dw	offset csbase:__cblreturn
_FCAL31		dw	offset csbase:__cblreturn
_FCAL32		dw	offset csbase:__cblreturn
_FCAL33		dw	offset csbase:__cblreturn
_FCAL34		dw	offset csbase:__cblreturn
_FCAL35		dw	offset csbase:__cblreturn
_FCAL36		dw	offset csbase:__cblreturn
_FCAL37		dw	offset csbase:__cblreturn
_FCAL38		dw	offset csbase:__cblreturn
_FCAL39		dw	offset csbase:__cblreturn
_FCAL3A		dw	offset csbase:__cblreturn
_FCAL3B		dw	offset csbase:__cblreturn
_FCAL3C		dw	offset csbase:__cblreturn
_FCAL3D		dw	offset csbase:__cblreturn
_FCAL3E		dw	offset csbase:__cblreturn
_FCAL3F		dw	offset csbase:__cblreturn
_FCAL40		dw	offset csbase:__cblreturn
_FCAL41		dw	offset csbase:__cblreturn
_FCAL42		dw	offset csbase:__cblreturn
_FCAL43		dw	offset csbase:__cblreturn
_FCAL44		dw	offset csbase:__cblreturn
_FCAL45		dw	offset csbase:__cblreturn
_FCAL46		dw	offset csbase:__cblreturn
_FCAL47		dw	offset csbase:__cblreturn
_FCAL48		dw	offset csbase:__cblreturn
_FCAL49		dw	offset csbase:__cblreturn
_FCAL4A		dw	offset csbase:__cblreturn
_FCAL4B		dw	offset csbase:__cblreturn
_FCAL4C		dw	offset csbase:__cblreturn
_FCAL4D		dw	offset csbase:__cblreturn
_FCAL4E		dw	offset csbase:__cblreturn
_FCAL4F		dw	offset csbase:__cblreturn
_FCAL50		dw	offset csbase:__cblreturn
_FCAL51		dw	offset csbase:__cblreturn
_FCAL52		dw	offset csbase:__cblreturn
_FCAL53		dw	offset csbase:__cblreturn
_FCAL54		dw	offset csbase:__cblreturn
_FCAL55		dw	offset csbase:__cblreturn
_FCAL56		dw	offset csbase:__cblreturn
_FCAL57		dw	offset csbase:__cblreturn
_FCAL58		dw	offset csbase:__cblreturn
_FCAL59		dw	offset csbase:__cblreturn
_FCAL5A		dw	offset csbase:__cblreturn
_FCAL5B		dw	offset csbase:__cblreturn
_FCAL5C		dw	offset csbase:__cblreturn
_FCAL5D		dw	offset csbase:__cblreturn
_FCAL5E		dw	offset csbase:__cblreturn
_FCAL5F		dw	offset csbase:__cblreturn
_FCAL60		dw	offset csbase:__cblreturn
_FCAL61		dw	offset csbase:__cblreturn
_FCAL62		dw	offset csbase:__cblreturn
_FCAL63		dw	offset csbase:__cblreturn
_FCAL64		dw	offset csbase:__cblreturn
_FCAL65		dw	offset csbase:__cblreturn
_FCAL66		dw	offset csbase:__cblreturn
_FCAL67		dw	offset csbase:__cblreturn
_FCAL68		dw	offset csbase:__cblreturn
_FCAL69		dw	offset csbase:__cblreturn
_FCAL6A		dw	offset csbase:__cblreturn
_FCAL6B		dw	offset csbase:__cblreturn
_FCAL6C		dw	offset csbase:__cblreturn
_FCAL6D		dw	offset csbase:__cblreturn
_FCAL6E		dw	offset csbase:__cblreturn
_FCAL6F		dw	offset csbase:__cblreturn
_FCAL70		dw	offset csbase:__cblreturn
_FCAL71		dw	offset csbase:__cblreturn
_FCAL72		dw	offset csbase:__cblreturn
_FCAL73		dw	offset csbase:__cblreturn
_FCAL74		dw	offset csbase:__cblreturn
_FCAL75		dw	offset csbase:__cblreturn
_FCAL76		dw	offset csbase:__cblreturn
_FCAL77		dw	offset csbase:__cblreturn
_FCAL78		dw	offset csbase:__cblreturn
_FCAL79		dw	offset csbase:__cblreturn
_FCAL7A		dw	offset csbase:__cblreturn
_FCAL7B		dw	offset csbase:__cblreturn
_FCAL7C		dw	offset csbase:__cblreturn
_FCAL7D		dw	offset csbase:__cblreturn
_FCAL7E		dw	offset csbase:__cblreturn
_FCAL7F		dw	offset csbase:__cblreturn
page

__cblreturn	proc	near
	ret	
__cblreturn	endp
;-----------------------------------------------------------------------
;
; include the rest of your (RTS.BIN) ASM source code  here
;
;-----------------------------------------------------------------------


CSEG	ends
	end
