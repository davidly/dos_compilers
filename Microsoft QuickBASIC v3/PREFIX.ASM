	title	prefix
_CODE		segment para public 'BC_CODE'
_CODE		ends
CSEG		segment para public 'CODESG'
CSEG 		ends
CODE		segment para public 'CODE'
CODE		ends
SHELL		segment para public 'CODESG'
SHELL		ends
CLEAR		segment para public 'CODESG'
CLEAR		ends
BC_ICN_CODE	segment para public 'INIT_CODE'
BC_ICN_CODE	ends
BC_IDS_CODE	segment para public 'INIT_CODE'
BC_IDS_CODE	ends
INIT_CODE	segment para public 'INIT_CODE'
INIT_CODE	ends

; DSEG must come first and not be CONST or _DATA so that other language
; obj's do not mess with the location of DSEG
DSEG 		segment	common 'DATASG'
DSEG		ends
CONST		segment para public 'CONST'
CONST		ends
_BSS		segment word public 'BSS'
_BSS		ends
c_common	segment word public 'BSS'
c_common	ends
DATA		segment para public 'DATA'
DATA		ends
BC_DATA		segment word public 'BC_VARS'
BC_DATA		ends
named_common 	segment word common 'BC_VARS'
named_common	ends
BC_FT		segment word public 'BC_SEGS'
BC_FT		ends
BC_CN		segment para public 'BC_SEGS'
BC_CN		ends
BC_DS		segment para public 'BC_SEGS'
BC_DS		ends
COMMON		segment para common 'BLANK'
COMMON		ends
LAST_SEGMENT	segment para public 'LAST_SEGMENT'
LAST_SEGMENT	ends
DGROUP		group DSEG,CONST,_BSS,DATA,BC_DATA,BC_FT,BC_CN,BC_DS,COMMON

	public	__acrtused
__acrtused equ	1

	end
