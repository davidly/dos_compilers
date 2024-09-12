
DATA SEGMENT BYTE PUBLIC
DATA ENDS
    
    EXTRN GRAPHGETMEMPTR:DWORD
    EXTRN GRAPHFREEMEMPTR:DWORD

    EXTRN GRAPHERRORMSG:FAR
    EXTRN GRAPHRESULT:FAR
    EXTRN DETECTGRAPH:FAR
    EXTRN GETDRIVERNAME:FAR
    EXTRN INITGRAPH:FAR
    EXTRN REGISTERBGIFONT:FAR
    EXTRN REGISTERBGIDRIVER:FAR
    EXTRN INSTALLUSERDRIVER:FAR
    EXTRN INSTALLUSERFONT:FAR
    EXTRN SETGRAPHBUFSIZE:FAR
    EXTRN GETMAXMODE:FAR
    EXTRN GETMODERANGE:FAR
    EXTRN GETMODENAME:FAR
    EXTRN SETGRAPHMODE:FAR
    EXTRN GETGRAPHMODE:FAR
    EXTRN GRAPHDEFAULTS:FAR
    EXTRN RESTORECRTMODE:FAR
    EXTRN CLOSEGRAPH:FAR
    EXTRN GETX:FAR
    EXTRN GETY:FAR
    EXTRN GETMAXX:FAR
    EXTRN GETMAXY:FAR
    EXTRN CLEARDEVICE:FAR
    EXTRN SETVIEWPORT:FAR
    EXTRN GETVIEWSETTINGS:FAR
    EXTRN CLEARVIEWPORT:FAR
    EXTRN SETVISUALPAGE:FAR
    EXTRN SETACTIVEPAGE:FAR
    EXTRN PUTPIXEL:FAR
    EXTRN GETPIXEL:FAR
    EXTRN SETWRITEMODE:FAR
    EXTRN LINETO:FAR
    EXTRN LINEREL:FAR
    EXTRN MOVETO:FAR
    EXTRN MOVEREL:FAR
    EXTRN LINE:FAR
    EXTRN GETLINESETTINGS:FAR
    EXTRN SETLINESTYLE:FAR
    EXTRN RECTANGLE:FAR
    EXTRN BAR:FAR
    EXTRN BAR3D:FAR
    EXTRN DRAWPOLY:FAR
    EXTRN FILLPOLY:FAR
    EXTRN GETFILLSETTINGS:FAR
    EXTRN GETFILLPATTERN:FAR
    EXTRN SETFILLSTYLE:FAR
    EXTRN SETFILLPATTERN:FAR
    EXTRN FLOODFILL:FAR
    EXTRN ARC:FAR
    EXTRN GETARCCOORDS:FAR
    EXTRN CIRCLE:FAR
    EXTRN ELLIPSE:FAR
    EXTRN FILLELLIPSE:FAR
    EXTRN GETASPECTRATIO:FAR
    EXTRN SETASPECTRATIO:FAR
    EXTRN PIESLICE:FAR
    EXTRN SECTOR:FAR
    EXTRN SETBKCOLOR:FAR
    EXTRN SETCOLOR:FAR
    EXTRN GETBKCOLOR:FAR
    EXTRN GETCOLOR:FAR
    EXTRN SETALLPALETTE:FAR
    EXTRN SETPALETTE:FAR
    EXTRN GETPALETTE:FAR
    EXTRN GETPALETTESIZE:FAR
    EXTRN GETDEFAULTPALETTE:FAR
    EXTRN GETMAXCOLOR:FAR
    EXTRN SETRGBPALETTE:FAR
    EXTRN IMAGESIZE:FAR
    EXTRN GETIMAGE:FAR
    EXTRN PUTIMAGE:FAR
    EXTRN GETTEXTSETTINGS:FAR
    EXTRN OUTTEXT:FAR
    EXTRN OUTTEXTXY:FAR
    EXTRN SETTEXTJUSTIFY:FAR
    EXTRN SETTEXTSTYLE:FAR
    EXTRN SETUSERCHARSIZE:FAR
    EXTRN TEXTHEIGHT:FAR
    EXTRN TEXTWIDTH:FAR
    
CODE SEGMENT BYTE PUBLIC

    ASSUME CS:CODE, DS:DATA

;CS relative variables, we switch Data segments left and right
theirDS		   DW		?
ourDS		   DW		?
retaddr		   DD		?
saveHeapError	   DD		?
HeapErrorAddr	   DW		?
regCX		   DW		?
regSI		   DW		?
regDI		   DW		?


;an array of procedure variables, TPC will do the necessary fixups
TABLE:
	DD GRAPHERRORMSG
	DD GRAPHRESULT
	DD DETECTGRAPH
	DD GETDRIVERNAME
	DD INITGRAPH
	DD REGISTERBGIFONT
	DD REGISTERBGIDRIVER
	DD INSTALLUSERDRIVER
	DD INSTALLUSERFONT
	DD SETGRAPHBUFSIZE
	DD GETMAXMODE
	DD GETMODERANGE
	DD GETMODENAME
	DD SETGRAPHMODE
	DD GETGRAPHMODE
	DD GRAPHDEFAULTS
	DD RESTORECRTMODE
	DD CLOSEGRAPH
	DD GETX
	DD GETY
	DD GETMAXX
	DD GETMAXY
	DD CLEARDEVICE
	DD SETVIEWPORT
	DD GETVIEWSETTINGS
	DD CLEARVIEWPORT
	DD SETVISUALPAGE
	DD SETACTIVEPAGE
	DD PUTPIXEL
	DD GETPIXEL
	DD SETWRITEMODE
	DD LINETO
	DD LINEREL
	DD MOVETO
	DD MOVEREL
	DD LINE
	DD GETLINESETTINGS
	DD SETLINESTYLE
	DD RECTANGLE
	DD BAR
	DD BAR3D
	DD DRAWPOLY
	DD FILLPOLY
	DD GETFILLSETTINGS
	DD GETFILLPATTERN
	DD SETFILLSTYLE
	DD SETFILLPATTERN
	DD FLOODFILL
	DD ARC
	DD GETARCCOORDS
	DD CIRCLE
	DD ELLIPSE
	DD FILLELLIPSE
	DD GETASPECTRATIO
	DD SETASPECTRATIO
	DD PIESLICE
	DD SECTOR
	DD SETBKCOLOR
	DD SETCOLOR
	DD GETBKCOLOR
	DD GETCOLOR
	DD SETALLPALETTE
	DD SETPALETTE
	DD GETPALETTE
	DD GETPALETTESIZE
	DD GETDEFAULTPALETTE
	DD GETMAXCOLOR
	DD SETRGBPALETTE
	DD IMAGESIZE
	DD GETIMAGE
	DD PUTIMAGE
	DD GETTEXTSETTINGS
	DD OUTTEXT
	DD OUTTEXTXY
	DD SETTEXTJUSTIFY
	DD SETTEXTSTYLE
	DD SETUSERCHARSIZE
	DD TEXTHEIGHT
	DD TEXTWIDTH


;a temporary HeapError procedure

SubsHeapError PROC FAR
	mov ax, 1
	ret 2
SubsHeapError ENDP

ProcTable:
	REPT 79
	call	DoIt		;3 bytes per
	ENDM
	
;this procedure does the real call to the BGI
;with all the necessary adjustments

Doit PROC NEAR
	mov CS:regCX, cx
	mov CS:regSI, si
	mov CS:regDI, di	;save some regs

;if you know where you came from, you know WHO you are!
	pop ax
	sub ax, OFFSET ProcTable+3
	mov bx, 3
	xor dx, dx
	div bx
	add ax, ax
	add ax, ax

	mov si, ax		;use si to index array
	mov bx, OFFSET Table	;set base of proc variable array
	
	pop WORD PTR CS:retaddr
	pop WORD PTR CS:retaddr+2	;take our return address of stack
	
	;in some places the BGI sets their own HeapError proc
	;it wants GetMem to return a NIL instead of doing a RunError
	;this is how we simulate this behavior
	
	mov di, CS:HeapErrorAddr
	les ax, [di]
	mov WORD PTR CS:saveHeapError, ax
	mov WORD PTR CS:saveHeapError+2, es
	mov [di], OFFSET SubsHeapError
	mov [di]+2, cs
	
	mov ds, CS:theirDS		;set the BGI DS value
	
	call DWORD PTR CS:[bx+si]	;call the BGI proc in the table
	
	mov ds, CS:ourDS		;restore our DS value

	mov bx, CS:HeapErrorAddr
	les cx, CS:saveHeapError
	mov [bx], cx
	mov [bx]+2, es
	
	mov cx, CS:regCX
	mov si, CS:regSI
	mov di, CS:regDI
	
	jmp DWORD PTR CS:retaddr	;return to user
Doit ENDP


PUBLIC InitProcVars

;this proc is only called from the Pascal+ user application

InitProcVars PROC FAR
	db 	20,'Stony Brook Software'

	push bp
	mov bp, sp
	push cx
	push si
	push di
	push ds
	
	mov CS:ourDS, ds		;save the users DS segment
	
	les di, [bp].6			;get addr of first proc var

	mov ax, OFFSET ProcTable
	mov cx, 79			;79 BGI procs

LoopTop:
	stosw
	mov es:[di], cs
	add di, 2		;store the addr of our table into each
				;successive procedure variable
	add ax, 3		;the table spacing is 3 bytes
	LOOP LoopTop
	
	mov ds, CS:theirDS	;need the BGI DS segment
	
	;here we will redirect the memory allocation to the users
	;Pascal+ procedures, from the BGI procedures
	
	les di, [bp].10
	mov WORD PTR GraphFreeMemPtr, di
	mov WORD PTR GraphFreeMemPtr+2, es

	les di, [bp].14
	mov WORD PTR GraphGetMemPtr, di
	mov WORD PTR GraphGetMemPtr+2, es
	
	;save the address of the Users HeapError procedure variable
	;it is DS realtive
	mov ax, [bp].18
	mov CS:HeapErrorAddr, ax

	pop ds
	pop di
	pop si
	pop cx
	pop bp
	ret 16
InitProcVars ENDP

PUBLIC DummyProc

DummyProc PROC NEAR
	pop ax			;pop the near return
	mov CS:theirDS, ds	;save the BGI DS value
	pop ax			;pop the pushed bp done by borland
	retf			;should be the far return we put on stack
				;from the Pascal+ Graph init code
DummyProc ENDP

CODE ENDS

END
