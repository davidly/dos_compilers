	page	,132
	title	unit - unit management table
;***
;unit.asm - unit management table for FORTRAN
;
;	Copyright (c) 1989-91, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Declare the FORTRAN unit list data structure.
;
;	Increasing the maximum number of open files:
;	--------------------------------------------
;	FORTRAN allows you to increase the maximum number of open files
;	(the default is 20). To use this feature, you MUST be running OS2 or
;	DOS 3.3 (or later).  Use the following procedure to increase the 
;	maximum number of open files for a non-Multithread, non-Dynamic Link 
;	application	 (see note 5 below for Multithread or Dynamic Link 
;	applications) :
;
;		1. Increasing file handles: To increase the number of file 
;		   handles, edit the startup source file CRT0DAT.ASM, which 
;		   is provided in this release. Change the line
;
;				_NFILE_ = 20
;
;		   so that _NFILE_ is set to the desired maximum (limit 256).
;		   For example, to set the maximum number of file handles to 40,
;		   change the line as shown here:
;
;				_NFILE_ = 40		
;			
;		2. Increasing units: Next, you must increase the size of the 
;		   table which FORTRAN uses to manage units. To increase the 
;		   size of the table, edit this source file (UNIT.ASM). Change 
;		   the line
;	
;				_NFILE_ = 20
;
;		   so that _NFILE_ is set to the same value you chose in 
;		   CRT0DAT.ASM. Note that the number of handles must be greater
;		   than or equal to the number of units. Thus if you increase 
;		   the number of units in this file, you must also increase the
;		   value of _NFILE_ in CRT0DAT.ASM.
;
;		3. Increasing the System Limit: To use more than 20 files at 
;		   a time, you must increase the file limit imposed on your 
;		   process by the operating system.
;
;			A. Increasing the System-Wide Limit: Increase the 
;			   number of files available on your system as a whole 
;			   by editing your system configuration file (for 
;			   instance, CONFIG.SYS). For example, to allow 100 
;			   files open at a time on your system, put this
;			   statement in your configuration file:
;
;					FILES=100
;
;			B. Increase the Per Process Limit: You must also 
;			   increase the number of files that the operating 
;			   system makes available to your particular process. 
;			   To do this, edit CRT0DAT.ASM and enable the 
;			   commented-out code that is preceded by the 
;			   appropriate description.
;	
;			   In the DOS version of CRT0DAT.ASM, for example, 
;			   the commented-out code appears as shown here:
;
;					;	mov	ah,67H
;					;	mov bx,_NFILE_
;					;	callos
;
;			   In the OS/2 version of CRT0DAT.ASM, the code appears
;			   as a call to DOSSETMAXFH. Under OS/2, you must also 
;			   enable the 'extrn DOSSETMAXFH:far' declaration that 
;			   appears near the beginning of the file.	
;
;			   In either case, remove the ';' comment characters.	
;
;		4. Using the Modified Startup Files: After you modify 
;		   CRT0DAT.ASM and UNIT.ASM, assemble the files. 
;
;		   To use the new objects, either explicitly link your program 
;		   with the new CRT0DAT.OBJ and UNIT.OBJ files, or replace the 
;		   CRT0DAT.OBJ and UNIT.OBJ objects in the appropriate model of
;		   the FORTRAN runtime library.	
;
;		5. For Multithread and Dynamic Link applications: The default 
;		   number of files which can be opened when linking using the 
;		   Multithread or Dynamic Link Libraries is 40. To increase 
;		   this default, you need only edit the UNIT.ASM file and set 
;		   the _NFILE_ constant defined between the "else" and "endif" 
;		   to the desired number of files, as described in Step 2, 
;		   above. When assembling UNIT.ASM, be sure to define MTHREAD 
;		   on the command line to get the correct definition:
;			
;				masm -DMTHREAD unit.asm 	
;
;		   Editing CRT0DAT.ASM is not required. Instead, the user must 
;		   make an explicit call to DOSSETMAXFH in his user code. The 
;		   form of this call is shown in the commented-out sections of 
;		   code in the OS2 version of CRT0DAT.ASM. The user must also 
;		   increase the System-Wide Limit as described in Step 3A, 
;		   above.
;
;***

ifndef	MTHREAD
_NFILE_		equ 20; change this to the desired number of units
				; NOTE: must be =< _NFILE_ in crt0dat.asm !!!
else
_NFILE_		equ 40		; change this to the desired number of units
endif



AVAILABLE	equ 8000H	; marks slot in unit list as unused
MAXUNITS	equ _NFILE_+1	; reserve extra slot for TERMINAL FCB

UENTRY	STRUC
unun	DW	AVAILABLE	; unit number
pfcb	DW	0		; near pointer to FCB
UENTRY	ENDS

_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA

PUBLIC	__FFmaxunits		; runtime limit
PUBLIC	__FFunit_lst

_DATA SEGMENT
	ASSUME  DS:DGROUP

__FFmaxunits	DW	MAXUNITS	
__FFunit_lst	UENTRY MAXUNITS DUP (<>)

_DATA ENDS

END
