PAGE 56,132
	title	entxstub	- Pascal OS/2 Initialization stub for psp
?DF = 1
include pasrun.inc
include sysi.inc

CreateSeg	_DATA,	data,	word,	public, DATA,	DGROUP
DefGrp	DGROUP

; System resident public data

;	these could be communal variables and off in some other segment

sBegin	data
assumes ds,data

globalW __psp,0 		; program segment prefix paragraph #

sEnd

end
