;
; Low level graphics functions
;
;    Copyright (c) Mix Software 1988
;
            global
LONGNAME    equ >FFFF
SHORTNAME   equ >FFFF
PARM1       equ 6
HERCMODE    equ 99
HRES        equ 6
GBW         equ 4
GCOLOR      equ 5
MONO        equ 7
PENCOLOR    equ >FF
TRANSPAR    equ >FE
            endglobal
            include fillm.asm
;
; ------------------------------------------------------------
;
;  Clear the screen
;            clrscrn2(attribute)
;            unsigned int attribute;
;
         idt  clrscrn2
         def  clrscrn2
         fref getvmode
         fref setvmode
         fref crt_lock
         lfref crt_unlock
         dref _vapage
         dref _vusemem
;
attrib   equ  PARM1
;
clrscrn2 push bp
         mov  bp,sp
         callfar getvmode
         cmp  al,GBW
         jb   text
         cmp  al,MONO
         jnz  graphic
text     mov  ax,>0600
         xor  cx,cx
         mov  bh,[bp][%attrib]
         mov  dx,>184f
         int  >10
         xor  dx,dx           ; set cursor to 0,0
         mov  bh,%[_vapage]
         mov  ah,2
         int  >10
         pop  bp
         retfar
graphic  cmp  al,HERCMODE
         jz   clrherc
         cmp  [_vusemem],0
         jz   nomem
         cmp  al,HRES
         jz   clrhres
         cmp  al,GBW
         jz   clrlres
         cmp  al,GCOLOR
         jz   clrlres
nomem    push ax              ; save current mode
;        mov  ax,MONO         ; set to text format
;        push ax
;        callfar setvmode     ; reset to previous mode
;        pop  ax
;        mov  ax,>0600        ; clear with bios scroll
;        xor  cx,cx
;        mov  bh,[bp][%attrib]
;        mov  dx,>184f
;        int  >10
         callfar setvmode
         add  sp,%2
         pop  bp
         retfar
clrherc  callfar crt_lock
         cmp  [_vapage],0
         jnz  page1
         mov  ax,>b000
         jmps herc1
page1    mov  ax,>b800
herc1    mov  es,ax
         mov  cx,>4000
onebit   xor  ax,ax
         test %[bp][%attrib],%1   ; white or black
         jz   clear
         dec  ax              ; set to all 1
clear    xor  di,di
         cld
         rep
         stosw
         callfar crt_unlock
         pop  bp
         retfar
clrhres  callfar crt_lock
         mov  ax,>b800
         mov  es,ax
         mov  cx,>2000
         jmps onebit
clrlres  callfar crt_lock
         mov  ax,>b800
         mov  es,ax
         mov  ax,[bp][%attrib]
         and  ax,>0003
         mov  dl,al
         mov  cl,2
         shl  al,cl
         or   al,dl
         mov  dl,al
         add  cl,cl
         shl  al,cl
         or   al,dl
         mov  ah,al
         mov  cx,>2000
         jmps clear
         end
;
; ------------------------------------------------------------
;int setvmode(int mode);
;   attempts to set video to mode
;   returns actual video mode
;   stores actual video mode in _vmode
; ------------------------------------------------------------
             idt     setvmode
             def     setvmode
             ref     _vmode
             ref     _vpages
             ref     _vmaxh
             ref     _vminh
             ref     _vmaxv
             ref     _vminv
             ref     _vlimits
             fref    getvmode
             dref    $$XTRC
             dref    $$XTRC2
; ------------------------------------------------------------
;
;            8086
; tos -->    bp
;            return offset
;            return segment
mode         equ    6
;
;***** hercules junk *****
;
;       port addresses
index   equ     03b4h
cntrl   equ     03b8h
config  equ     03bfh
;
;       control codes
scrn_on equ     8
grph    equ     2
twopage equ     3
onepage equ     1
;
;       tables
gtable  db      35h,2dh,2eh,07h
        db      5bh,02h,57h,57h
        db      02h,03h,00h,00h
;
;************************
;
;
default     equ    >FF
            setcpu 8086
setvmode    push   bp
            mov    bp,sp
            mov    al,%[bp][%mode] ;get mode argument
            cmp    al,default
            jnz    svmode
            mov    al,[dfltmode]
            cmp    al,default
            jz     exit            ; mode was never changed
            jmps   setmode
svmode      cmp    %[dfltmode],default   ; first time?
            jnz    setmode
            callfar getvmode
            mov    %[dfltmode],al
            mov    al,%[bp][%mode] ;get mode argument
setmode     mov    [_vminh],0
            mov    [_vminv],0
            cmp    al,HERCMODE     ;check for hercules mode
            je     hgraph          ;set video to hercules graphics mode
            cmp    [_vmode],HERCMODE
            jnz    setbios
            call   clrherc
setbios     mov    ah,0            ;call set mode function of int 10h
            int    10h
            mov    ah,15           ;call get mode function of int 10h
            int    10h
            xor    ah,ah
            mov    [_vmode],ax     ;store mode in global variable
            cmp    ax,[_vlimits]
            ja     nolimits
            mov    bx,ax
            add    bx,bx
            add    bx,bx
            add    bx,%2
            mov    dx,[_vlimits][bx]
            mov    [_vmaxh],dx
            add    bx,%2
            mov    dx,[_vlimits][bx]
            mov    [_vmaxv],dx
            mov    ax,[_vmode]
exit        pop    bp              ;get frame pointer
            retseg                 ;return
nolimits    mov    [_vmaxh],-1
            mov    [_vmaxv],-1
            mov    ax,[_vmode]
            pop    bp
            retseg
;
hgraph      call   setherc
            mov    [_vmaxh],719
            mov    [_vmaxv],347
            mov    al,twopage
            cmp    %[_vpages],2
            jge    cont
            mov    al,onepage
cont        mov    dx,config
;           out    dx,al
            db     >ee
            mov    al,grph
            mov    si,gtable
            mov    bx,0
            mov    cx,4000h
            push   ax
            push   bx
            push   cx
;   change mode but without scrn_on
            mov    dx,cntrl
;           out    dx,al
            db     >ee
;   intialize the 6845
            mov    ax,ds
            mov    es,ax
            mov    dx,index
            mov    cx,12
            xor    ah,ah
parms       mov    al,ah
;            out    dx,al
            db     >ee
            inc    dx
            segcs
            lodsb
;            out    dx,al
            db     >ee
            inc    ah
            dec    dx
            loop   parms
            pop    cx
;
            mov    ax,>b000
            cld
            mov    es,ax
            xor    di,di
            pop    ax
            rep
            stosw
;
            cmp    %[_vpages],2
            jl     continue
            mov    cx,>4000
            mov    ax,>b800
            mov    es,ax
            xor    di,di
            xor    ax,ax
            rep
            stosw
;
;   scrn_on, page 0
continue    mov    dx,cntrl
            pop    ax
            add    al,scrn_on
;            out    dx,al
            db     >ee
            mov    al,HERCMODE
            xor    ah,ah
            mov    [_vmode],ax
            pop    bp
            retseg
;
;   if CTrace is present, notify it about hercules mode
;
setherc  cmp  [$$XTRC2],0
         jz   goback
         push ax
         mov  ah,3
calltrc  push bx
         mov  bx,2
         callseg [$$XTRC]
         pop  bx
         pop  ax
goback   ret
clrherc  cmp  [$$XTRC2],0
         jz   goback
         push ax
         mov  ah,4
         jmps calltrc
;
            dorg   0
dfltmode    dw     >FFFF
            end

;
;int getvmode(void);
;   getvmode sets global variable _vmode to current video mode
;   and returns current video mode
;********************************************************************
             idt     getvmode
             def     getvmode
             ref     _vmode
             ref     _vvpage
;********************************************************************
;
;            8086
; tos -->    return offset
;            return segment
;
            setcpu 8086
getvmode    mov    ax,[_vmode]
            cmp    al,HERCMODE
            jne    continue
            retseg
continue    push   bp              ;save bp
            mov    ah,15           ;call get mode function of int 10h
            int    10h
            xor    ah,ah
            mov    [_vmode],ax     ;store mode in global variable
            mov    bl,bh
            xor    bh,bh
            mov    [_vvpage],bx    ;store visual page in global variable
            pop    bp              ;restore bp
            retseg                 ;return
            end
;
;int setvpage(int page);
;   sets video visual page
;   stores the video visual page number in _vvpage
;   returns current video visual page number
;********************************************************************
             idt     setvpage
             def     setvpage
             ref     _vmode
             ref     _vvpage
;********************************************************************
;
;            8086
; tos -->    bp
;            return offset
;            return segment
page         equ    6
;
;***** hercules junk *****
;
;       control port address
cntrl   equ     03b8h
;
;       control codes
page0   equ     0ah
page1   equ     8ah
;
;************************
;
;
            setcpu 8086
setvpage    push   bp
            mov    bp,sp
            cmp    %[_vmode],HERCMODE
            je     hpage
            mov    ah,15           ;call get page function of int 10h
            int    10h
            push   ax
            mov    al,%[bp][%page] ;get page argument
            mov    ah,5            ;call select page function of int 10h
            int    10h
exit        mov    al,bh
            xor    ah,ah
            mov    [_vvpage],ax    ;store mode in global variable
            pop    ax
            xor    ah,ah
            pop    bp              ;restore bp
            retseg                 ;return
;
hpage       push   [_vvpage]
            mov    bh,%[bp][%page] ;get page argument
            mov    dx,cntrl
            mov    al,page0        ;set al to page0
            or     bh,bh
            jz     continue
            mov    bh,1            ;return page number 1
            mov    al,page1        ;set al to page1
;           out    dx,al
continue    db     >ee
            jmp    exit
            end
;
; -----------------------------------------------------------------
;
; void writedot(int row, int col, int color);
;   writes a dot of color at coordinates (row, col).
;   for HERCMODE, color of 1 turns dot on, 0 turns dot off,
;
             idt     writedot
             def     writedot
             ref     _vmode
             ref     _vapage
             ref     _vmaxh
             ref     _vminh
             ref     _vmaxv
             ref     _vminv
             ref     _v_color
             fref    crt_lock
             lfref   crt_unlock
;
;
;            8086
; tos -->    bp
;            return offset
;            return segment
row          equ   6
col          equ   8
color        equ   10
VGA256       equ   >13
;
;
             setcpu 8086
writedot     push   bp
             mov    bp,sp
             mov    cx,[bp][%col]       ;cx = col
             cmp    cx,[_vmaxh]         ;clip to screen boundary
             ja     exit
             cmp    cx,[_vminh]
             jb     exit
             mov    dx,[bp][%row]       ;dx = row
             cmp    dx,[_vmaxv]
             ja     exit
             cmp    dx,[_vminv]
             jb     exit
             mov    al,%[bp][%color]    ;al = color
             cmp    al,TRANSPAR
             jz     exit
             cmp    al,PENCOLOR
             jnz    w1
             mov    al,%[_v_color]
w1           cmp    %[_vmode],HERCMODE
             je     hwrite
             cmp    %[_vmode],VGA256
             jae    w2
             and    al,>7F              ; remove sign(xor flag) bit
w2           mov    ah,12               ;use writedot funtion of int 10h
             mov    bx,[_vapage]
;            mov    cx,[bp][%col]       ;cx = col
;            mov    dx,[bp][%row]       ;dx = row
             int    10h
exit         pop    bp                  ;restore
             retseg                     ;return
;
hwrite       mov    bh,al
             callfar crt_lock
             mov    dx,>b000            ;dx = page 0
             cmp    %[_vapage],0
             je     setes
             mov    dx,>b800            ;dx = page 1
setes        mov    es,dx
             mov    ax,[bp][%row]
             mov    si,ax
             and    si,>0003
             mov    cl,13
             shl    si,cl           ; (y % 4) * 0x2000
             shr    ax,1
             shr    ax,1            ; y/4
             mul    [k90]
             add    si,ax
             mov    ax,[bp][%col]
             mov    cx,ax
             shr    ax,1            ; x/8
             shr    ax,1
             shr    ax,1
             add    si,ax
             and    cx,>0007        ; x % 8
             mov    ah,>80
             jcxz   bitset
             shr    ah,cl
bitset       seges
             mov    al,[si]             ; previous contents
             cmp    bh,%0
             jz     turnoff
             or     al,ah               ; set the bit
             jmps   setvalue
turnoff      not    ah
             and    al,ah               ; clear the bit
setvalue     seges
             mov    %[si],al
             callfar crt_unlock
             pop    bp
             retseg
             dorg   0
k90          dw     90
             end
;
; -----------------------------------------------------------------
;
;  int readdot(int row, int col);
;   returns the color of the dot at coordinates (row, col).
;   for HERCMODE, a return value of 1 means dot on, 0 means dot off
;
             idt     readdot
             def     readdot
             ref     _vmode
             ref     _vapage
             fref    crt_lock
             lfref   crt_unlock
;
row          equ    6
col          equ    8
;
;
readdot      push   bp
             mov    bp,sp
             cmp    %[_vmode],HERCMODE
             je     hread
             mov    ah,13
             mov    bx,[_vapage]
             mov    cx,[bp][%col]
             mov    dx,[bp][%row]
             int    10h
             pop    bp
             xor    ah,ah
             retseg
;
hread        callfar crt_lock
             mov    dx,>b000            ;dx = page 0
             cmp    %[_vapage],0
             je     setes
             mov    dx,>b800            ;dx = page 1
setes        mov    es,dx
             mov    ax,[bp][%row]
             mov    si,ax
             and    si,>0003
             mov    cl,13
             shl    si,cl           ; (y % 4) * 0x2000
             shr    ax,1
             shr    ax,1            ; y/4
             mul    [k90]
             add    si,ax
             mov    ax,[bp][%col]
             mov    cx,ax
             shr    ax,1            ; x/8
             shr    ax,1
             shr    ax,1
             add    si,ax
             and    cx,>0007        ; x % 8
             neg    cx
             add    cx,%7
             seges
             mov    al,%[si]       ; read 8 pixels
             jcxz   mask           ; alrerady in position
             shr    al,cl
mask         and    ax,>0001
             push   ax
             callfar crt_unlock
             pop    ax
             pop    bp
             retseg
             dorg   0
k90          dw     90
             end
;
;void writech(int c);
;    writes character ch at current position in active page
;    returns ch
;********************************************************************
             idt     writech
             def     writech
             ref     _vapage
;********************************************************************
;
; tos -->    bp
;            return offset
;            return segment
c            equ    6
;
;
             setcpu 8086
writech      push   bp
             mov    bp,sp
             mov    al,%[bp][%c]    ;get character
             mov    ah,10           ;use write character of int 10h
             mov    bh,%[_vapage]   ;set active page
             mov    cx,1            ;write one character
             int    10h             ;write ch
             pop    bp              ;restore bp
             xor    ah,ah
             retseg
             end
;
;void writechs(int c, int attr, int n);
;   writes c with attribute attr n times at current position in active page
;********************************************************************
             idt     writechs
             def     writechs
             ref     _vapage
;********************************************************************
;
;            8086
; tos -->    bp
;            return offset
;            return segment
c            equ    6
attr         equ    8
n            equ    10
;
;
             setcpu 8086
writechs     push   bp
             mov    bp,sp
             mov    cx,[bp][%n]         ;get number of times to write
             mov    bl,%[bp][%attr]     ;get attribute of character
             mov    al,%[bp][%c]        ;get character
             mov    ah,9                ;set write attribute of int 10h
             mov    bh,%[_vapage]       ;set active page
             int    10h                 ;write character/attribute n times
             pop    bp                  ;restore bp
             xor    ah,ah
             retseg
             end

;void poscurs(int row, int col);
;   positions cursor in active page
;
             idt    poscurs
             def    poscurs
             ref    _vapage
;
; tos -->    bp
;            return offset
;            return segment
row          equ    6
col          equ    8
;
;
            setcpu  8086
poscurs     push    bp
            mov     bp,sp
            mov     dh,%[bp][%row]
            mov     dl,%[bp][%col]
            mov     bh,%[_vapage]
            mov     ah,2
            int     10h
            pop     bp
            retseg
            end

;int cursrow(void);
;   returns row position of cursor in active page
;
;***********************************************************
            idt     cursrow
            def     cursrow
            ref     _vapage
;***********************************************************
;   tos -> bp
;          return offset
;          return segment
;
            setcpu 8086
cursrow     push    bp
            mov     ah,3
            mov     bh,%[_vapage]
            int     10h
            mov     al,dh
            pop     bp
            xor     ah,ah
            retseg
            end
;int curscol(void);
;   returns row position of cursor in active page
;
;***********************************************************
            idt     curscol
            def     curscol
            ref     _vapage
;***********************************************************
;   tos -> bp
;          return offset
;          return segment
;
            setcpu 8086
curscol     push    bp
            mov     ah,3
            mov     bh,%[_vapage]
            int     10h
            mov     al,dl
            pop     bp
            xor     ah,ah
            retseg
            end
;
; ------------------------------------------------------------
;
;  int flood(x_size, y_size);
;
;  Fill a rectangular area with the current pattern.
;  Current graphics cursor defines the upper left corner of the area
;
         idt  flood
         def  flood
         dref _vxcurs         ; position
         dref _vycurs
         dref _vmode          ; current mode
         dref _vf_pat         ; pattern
         dref _vf_wid         ; width of pattern
         dref _vf_hgt         ; width of pattern
         dref _v_color        ; pen color
         dref _vapage         ; active page
         dref _vusemem        ; direct access to memory
         dref _vmaxh          ; screen limit
         dref _vmaxv
         fref _vhwhere
         fref _v4where
         fref _v6where
         fref crt_lock
         lfref crt_unlock
xlimit   equ  0
ylimit   equ  2
xstart   equ  4
xmax     equ  6
memorg   equ  8
nextrow  equ  10
localsz  equ  nextrow+2
x_size   equ  localsz+PARM1
y_size   equ  localsz+PARM1+2
;
flood    push bp
         sub  sp,localsz
         mov  bp,sp
         cmp  [bp][%x_size],0
         jle  done01
         cmp  [bp][%y_size],0
         jg   fl001
done01   jmp  done
fl001    mov  ax,[_vf_pat]
         mov  [bp][%xstart],ax
         add  ax,[_vf_wid]
         mov  [bp][%xlimit],ax
         mov  ax,[_vf_wid]
         mul  [_vf_hgt]
         add  ax,[_vf_pat]
         mov  [bp][%ylimit],ax
         mov  ax,[_vxcurs]
         add  ax,[bp][%x_size]
         cmp  ax,[_vmaxh]
         jna  limit1
         mov  bx,[_vmaxh]     ; beyond screen boundary
         sub  ax,bx
         sub  [bp][%x_size],ax
         mov  bx,ax
limit1   mov  [bp][%xmax],ax
         mov  ax,[bp][%y_size]
         add  ax,[_vycurs]
         cmp  ax,[_vmaxv]
         jna  limit2
         mov  ax,[_vmaxv]
         inc  ax
         sub  ax,[_vycurs]
         jz   done01
         mov  [bp][%y_size],ax
limit2   mov  al,[_vmode]     ; check current mode
         cmp  al,HERCMODE
         jz   herc
         cmp  [_vusemem],0
         jz   bios
         cmp  al,HRES
         jz   cga6
         cmp  al,GBW
         jz   cga4i
         cmp  al,GCOLOR
         jz   cga4i
;
;  fill using the bios
;
bios     mov  si,[_vf_pat]
         mov  dx,[_vycurs]
         mov  cx,[_vxcurs]
         mov  bx,[_vapage]
         jmps bitset
nextbit  inc  cx              ; next x coordinate
         cmp  cx,[bp][%xmax]
         jae  nexty
         cmp  si,[bp][%xlimit]
         jb   bitset
         mov  si,[bp][%xstart]
bitset   lodsb                ; next color in pattern
         cmp  al,TRANSPAR
         jz   nextbit
         cmp  al,PENCOLOR
         jnz  bitput
         mov  al,[_v_color]
bitput   mov  ah,>0c
         int  >10
         jmps nextbit
nexty    dec  [bp][%y_size]
         jz   done
         inc  dx              ; next y coordinate
         mov  si,[bp][%xstart]
         add  si,[_vf_wid]
         cmp  si,[bp][%ylimit]
         jb   setxlim
         mov  si,[_vf_pat]
setxlim  mov  [bp][%xstart],si
         mov  ax,si
         add  ax,[_vf_wid]
         mov  [bp][%xlimit],ax
         mov  cx,[_vxcurs]
         jmps bitset
done     lea  sp,[bp][%localsz]
         pop  bp
         retfar
cga4i    jmp  cga4
;
herc     callfar crt_lock
         callfar _vhwhere     ; calculate memory address
         mov  ax,incyh
         mov  [bp][%nextrow],ax
         jmps onebit
cga6     callfar crt_lock
         callfar _v6where
         mov  ax,incy6
         mov  [bp][%nextrow],ax
;
onebit   mov  ch,cl           ; save bit offset
         mov  [bp][%memorg],di   ; save memory address
         mov  dx,[bp][%x_size]   ; horizontal counter
         seges
         mov  bl,[di]         ; get first group of pixels
         mov  si,[bp][%xstart]
         jmps hbitset
hnextbit inc  cl              ; next x coordinate
         cmp  cl,8            ; next byte?
         jnz  h001
         seges
         mov  [di],bl         ; save current group
         inc  di              ; get next 8 pixels
         seges
         mov  bl,[di]
         xor  cl,cl
h001     dec  dx
         jz   hnexty          ; end of row
         cmp  si,[bp][%xlimit]
         jb   hbitset
         mov  si,[bp][%xstart]
hbitset  lodsb                ; next color in pattern
         cmp  al,TRANSPAR
         jz   hnextbit
         cmp  al,PENCOLOR
         jnz  hbitput
         mov  al,[_v_color]
hbitput  and  al,1
         ror  al,1
         mov  ah,>7f
         cmp  cl,0
         jz   h002
         ror  ah,cl
         shr  al,cl
h002     and  bl,ah           ; mask previous contents
         or   bl,al           ; set new bit
         jmps hnextbit
hnexty   seges
         mov  [di],bl         ; save last 8 pixels
         dec  [bp][%y_size]
         jz   donemem1
         mov  di,[bp][%memorg]
         call [bp][%nextrow]
         mov  [bp][%memorg],di
         mov  si,[bp][%xstart]
         add  si,[_vf_wid]
         cmp  si,[bp][%ylimit]
         jb   h004
         mov  si,[_vf_pat]
h004     mov  [bp][%xstart],si
         mov  ax,si
         add  ax,[_vf_wid]
         mov  [bp][%xlimit],ax
         mov  cl,ch           ; reset bit number
         mov  dx,[bp][%x_size]   ; horizontal counter
         seges
         mov  bl,[di]
         jmps hbitset
donemem1 jmp  donemem
;
cga4     callfar crt_lock
         callfar _v4where
         mov  ax,incy4
         mov  [bp][%nextrow],ax
;
twobit   shl  cl,1
         mov  ch,cl           ; save bit offset
         mov  [bp][%memorg],di   ; save memory address
         mov  dx,[bp][%x_size]   ; horizontal counter
         seges
         mov  bl,[di]         ; get first group of pixels
         mov  si,[bp][%xstart]
         jmps set4
next4    add  cl,%2           ; next x coordinate
         cmp  cl,8            ; next byte?
         jnz  t001
         seges
         mov  [di],bl         ; save current group
         inc  di              ; get next 4 pixels
         seges
         mov  bl,[di]
         xor  cl,cl
t001     dec  dx
         jz   nexty4          ; end of row
         cmp  si,[bp][%xlimit]
         jb   set4
         mov  si,[bp][%xstart]
set4     lodsb                ; next color in pattern
         cmp  al,TRANSPAR
         jz   next4
         cmp  al,PENCOLOR
         jnz  put4
         mov  al,[_v_color]
put4     and  al,3
         ror  al,1
         ror  al,1
         mov  ah,>3f
         cmp  cl,0
         jz   t002
         ror  ah,cl
         shr  al,cl
t002     and  bl,ah           ; mask previous contents
         or   bl,al           ; set new bit
         jmps next4
nexty4   seges
         mov  [di],bl         ; save last 8 pixels
         dec  [bp][%y_size]
         jz   donemem
         mov  di,[bp][%memorg]
         call [bp][%nextrow]
         mov  [bp][%memorg],di
         mov  si,[bp][%xstart]
         add  si,[_vf_wid]
         cmp  si,[bp][%ylimit]
         jb   t004
         mov  si,[_vf_pat]
t004     mov  [bp][%xstart],si
         mov  ax,si
         add  ax,[_vf_wid]
         mov  [bp][%xlimit],ax
         mov  cl,ch           ; reset bit number
         mov  dx,[bp][%x_size]   ; horizontal counter
         seges
         mov  bl,[di]
         jmps set4
donemem  callfar crt_unlock
         jmp  done
;
;  add 1 to the y coordinate (hercules)
;
incyh    add  di,>2000        ; next y coordinate
         cmp  di,>8000
         jb   incyh1
         sub  di,>8000-90D
incyh1   ret
;
;  add 1 to the y coordinate (cga)
;
incy6    add  di,>2000        ; next y coordinate
         cmp  di,>4000
         jb   incy61
         sub  di,>4000-80D
incy61   ret
;
;  add 1 to the y coordinate (cga)
;
incy4    add  di,>2000        ; next y coordinate
         cmp  di,>4000
         jb   incy41
         sub  di,>4000-80D
incy41   ret
         end
;
; ------------------------------------------------------------
;
;  int plotch(char c);
;
;  Write a character to the screen in graphics mode.
;  For modes 4,5,6,99 the horizontal position is rounded to the
;      nearest mulitple of 8 (byte boundary)
;  For other modes, the bios is used.
;
         idt  plotch
         def  plotch
         dref _vchpat1        ; character font table
         dref _vxcurs         ; position
         dref _vycurs
         dref _vmode          ; current mode
         dref _v_color        ; pen color
         dref _vapage         ; active page
         fref _vhwhere
         fref _v4where
         fref _v6where
         fref crt_lock
         lfref crt_unlock
;
plotch   push bp
         mov  bp,sp
         mov  si,[bp][%PARM1] ; fetch value of character
         cmp  si,>7f
         ja   exit
         shl  si,1
         shl  si,1
         shl  si,1
         add  si,_vchpat1     ; si = address of pattern
         mov  al,[_vmode]     ; check current mode
         cmp  al,HERCMODE
         jz   herc
         cmp  al,HRES
         jz   cga6i
         cmp  al,GBW
         jz   cga4i
         cmp  al,GCOLOR
         jz   cga4i
;
;  write a character using write dot
;
         mov  ah,[si]
         mov  di,8*8          ; 64 points
         mov  dx,[_vycurs]
         mov  cx,[_vxcurs]
         mov  bx,[_vapage]
         jmps next
nextbit  inc  cx              ; next x coordinate
         test di,>0007
         jnz  next
         sub  cx,%8           ; next row of pattern
         inc  dx
         inc  si
         mov  ah,[si]
next     xor  al,al
         shl  ah,1
         push ax
         jnc  putbit
         mov  al,[_v_color]   ; bit is on
putbit   mov  ah,>0c
         int  >10
         pop  ax
         dec  di
         jnz  nextbit
done     add  [_vxcurs],%8
exit     pop  bp
         retfar
cga4i    jmp  cga4
cga6i    jmp  cga6
;
;  write a character to hercules monochrome graphics card
;    si contains address of character pattern
;
herc     callfar crt_lock
         callfar _vhwhere
         mov  dx,[_v_color]
         jcxz hbyte
;  write to hercules (not on byte boundary)
         mov  dh,8
hnbnext  mov  bx,>ff00
         ror  bx,cl
         seges
         and  bx,[di]         ; remove previous bits
         lodsb
         test dl,%1
         jnz  posh2
         not  al
posh2    xor  ah,ah
         ror  ax,cl           ; bring into position
         or   bx,ax
         seges
         mov  [di],bx
         add  di,>2000
         cmp  di,>8000
         jb   nexth2
         sub  di,>8000-90D
nexth2   dec  dh
         jnz  hnbnext
doneh    callfar crt_unlock
         jmps done
;  write to hercules, character on byte boundary
hbyte    mov  cx,8
puth     lodsb
         test dl,%1
         jnz  posh
         not  al
posh     seges
         mov  [di],al
         add  di,>2000
         cmp  di,>8000
         jb   nexth
         sub  di,>8000-90D
nexth    loop puth
         jmp  doneh
;
cga6     callfar crt_lock
         callfar _v6where
         mov  dx,[_v_color]
         jcxz cgabyte
;  write to cga mode 6 (not on byte boundary)
         mov  dh,8
cga6nxt  mov  bx,>ff00
         ror  bx,cl
         seges
         and  bx,[di]         ; remove previous bits
         lodsb
         test dl,%1
         jnz  pos62
         not  al
pos62    xor  ah,ah
         ror  ax,cl           ; bring into position
         or   bx,ax
         seges
         mov  [di],bx
         add  di,>2000
         cmp  di,>4000
         jb   next62
         sub  di,>4000-80D
next62   dec  dh
         jnz  cga6nxt
done6    callfar crt_unlock
         jmp  done
cgabyte  mov  cx,8
put6     lodsb
         test dl,%01
         jnz  pos6
         not  al
pos6     seges
         mov  [di],al
         add  di,>2000
         cmp  di,>4000
         jb   next6
         sub  di,>4000-80D
next6    loop put6
         jmp  done6
;
cga4     callfar crt_lock
         callfar _v4where
         mov  ax,[_v_color]   ; get color of pen
         jcxz cga4byte
         shl  cl,1
         mov  dl,cl           ; save starting offset
         push di
         mov  dh,8            ; number of rows
cga4row  mov  ch,8            ; bits per row
         lodsb
cga4lp1  xor  ah,ah
         shl  al,1
         jnc  cga4zero
         mov  ah,[_v_color]
         and  ah,>3
         ror  ah,1
         ror  ah,1
cga4zero mov  bh,>3f          ; mask previous contents
         cmp  cl,0
         jz   cga4set
         shr  ah,cl           ; move color into position
         ror  bh,cl
cga4set  seges
         and  bh,[di]
         or   bh,ah
         seges
         mov  [di],bh         ; set pixel
         add  cl,%2
         cmp  cl,6
         jbe  cga4nxt
         inc  di
         xor  cl,cl
cga4nxt  dec  ch
         jnz  cga4lp1
         mov  cl,dl           ; restore bit offset
         pop  di              ; restore origin
         add  di,>2000        ; next row address
         cmp  di,>4000
         jb   cga4a
         sub  di,>4000-80D
cga4a    push di
         dec  dh
         jnz  cga4row
         pop  di
done4    callfar crt_unlock
         jmp  done
;  cga mode 4 or 5 on byte boundary
cga4byte mov  ax,[_v_color]
         xor  dx,dx
         mov  cx,8
makemask shl  dl,1
         shl  dl,1
         or   dl,al
         loop makemask
         mov  dh,dl
         mov  cx,8
put4     lodsb
         push cx
         mov  cx,8
make4    shr  al,1            ; replicate bits
         rcr  bx,1
         sar  bx,1
         loop make4
         pop  cx
         and  bx,dx
         xchg bh,bl
         seges
         mov  [di],bx
         add  di,>2000
         cmp  di,>4000
         jb   next4
         sub  di,>4000-80D
next4    loop put4
         jmp  done4
         end
;
;  Generate memory address for a point on the screen
;     Hercules graphics card
;  Returns address in es:di and bit number in cl
;
         idt  _vhwhere
         def  _vhwhere
         dref _vxcurs
         dref _vycurs
         dref _vapage
;
_vhwhere mov  ax,[_vycurs]
         mov  di,ax
         and  di,>0003
         mov  cl,13
         shl  di,cl           ; (y % 4) * 0x2000
         mov  cl,2
         shr  ax,cl           ; y/4
         shl  ax,1            ; (y/4) * 0x02
         add  di,ax
         shl  ax,cl           ; (y/4) * 0x08
         add  di,ax
         shl  ax,1            ; (y/4) * 0x10
         add  di,ax
         shl  ax,cl           ; (y/4) * 0x40
         add  di,ax
         mov  ax,[_vxcurs]
         mov  cx,ax
         and  cx,>0007        ; bit number
         shr  ax,1            ; x/8
         shr  ax,1
         shr  ax,1
         add  di,ax           ; di = memory address
         mov  ax,>b000        ; select segment for active page
         cmp  %[_vapage],0
         je   sethpage
         mov  ax,>b800
sethpage mov  es,ax
         retfar
         end
;
;  Generate memory address for a point on the screen
;     CGA high resolution (mode 6)
;  Returns address in es:di and bit number in cl
;
         idt  _v6where
         def  _v6where
         dref _vxcurs
         dref _vycurs
;
_v6where mov  ax,[_vycurs]
         mov  di,ax
         and  di,>0001
         mov  cl,13
         shl  di,cl           ; (y % 2) * 0x2000
         shr  ax,1            ; y/2
         mov  cl,4
         shl  ax,cl           ; (y/2) * 0x10
         add  di,ax
         shl  ax,1
         shl  ax,1            ; ax = (y/2) * 0x40
         add  di,ax
         mov  ax,[_vxcurs]
         mov  cx,ax
         and  cx,>0007
         shr  ax,1            ; x/8
         shr  ax,1
         shr  ax,1
         add  di,ax
         mov  ax,>b800        ; segment of cga memory
         mov  es,ax
         retfar
         end
;
;  Generate memory address for a point on the screen
;     CGA low resolution (mode 4 or 5)
;  Returns address in es:di and bit number in cl
;
         idt  _v4where
         def  _v4where
         dref _vxcurs
         dref _vycurs
;
_v4where mov  ax,[_vycurs]
         mov  di,ax
         and  di,>0001
         mov  cl,13
         shl  di,cl           ; (y % 2) * 0x2000
         shr  ax,1            ; y/2
         mov  cl,4
         shl  ax,cl           ; (y/2) * 0x10
         add  di,ax
         shl  ax,1
         shl  ax,1            ; ax = (y/2) * 0x40
         add  di,ax
         mov  ax,[_vxcurs]
         mov  cx,ax
         and  cx,>0003
         shr  ax,1            ; x/4
         shr  ax,1
         add  di,ax
         mov  ax,>b800        ; segment of cga memory
         mov  es,ax
         retfar
         end
;
; ------------------------------------------------------------
;
;  crt_lock  -  lock the crt contents into physical screen memory
;        crt_lock should be called before the program writes directly
;        to screen memory
;
         idt  crt_lock
         def  crt_lock
         dref $$XTRC
         dref $$XTRC2
;
needmem  equ  PARM1-2
crt_lock cmp  [$$XTRC2],0
         jnz  request
         retfar
request  push bx
         mov  bx,2
         mov  ah,1
calltrc  callseg [$$XTRC]
         pop  bx
         xor  ax,ax
         retfar
         end
;
; ------------------------------------------------------------
;
;  crt_unlock  -  release the crt contents from screen memory
;
         idt  crt_unlock
         IF   LONGNAME
         LDEF crt_unlock
         ENDIF
         IF   SHORTNAME
         DEF  crt_unlo
         ENDIF
         dref $$XTRC
         dref $$XTRC2
;
needmem  equ  PARM1-2
crt_unlo cmp  [$$XTRC2],0
         jnz  request
         retfar
request  push bx
         mov  bx,2
         mov  ah,2
calltrc  callseg [$$XTRC]
         pop  bx
         xor  ax,ax
         retfar
         end
;
; ------------------------------------------------------------
;
            idt    _vdata
            ddef   _vmode
            ddef   _vpages
            ddef   _vapage
            ddef   _vvpage
            ddef   _vmaxh
            ddef   _vminh
            ddef   _vmaxv
            ddef   _vminv
            ddef   _vattr
            ddef   _vlimits
            ddef   _vusemem
            ddef   _v_color
            ddef   _vl_dpat
            ddef   _vl_pat
            ddef   _vl_psiz
            ddef   _vxcurs
            ddef   _vycurs
            ddef   _vf_pat
            ddef   _vf_wid
            ddef   _vf_hgt
;
            dorg    0
_vmode      dw  >ffff         ; screen mode
_vpages     dw  >0002         ; number of pages (graphics)
_vapage     dw  >0000         ; active page
_vvpage     dw  >0000         ; visible page
_vmaxh      dw  >ffff         ; horizontal boundaries
_vminh      dw  >0000
_vmaxv      dw  >ffff         ; vertical boundaries
_vminv      dw  >0000
_vattr      dw  7             ; attribute for scroll functions
_vusemem    dw  1             ; use direct access to screen memory
_v_color    dw  >FF           ; pen color
_vl_dpat    dw  >FF           ; default color for lines
_vl_pat     dw  _vl_dpat      ; line style
_vl_psiz    dw  1             ; size of line style
_vxcurs     dw  0             ; graphics cursor
_vycurs     dw  0
_vf_pat     dw  _vl_dpat      ; default fill pattern
_vf_wid     dw  1             ; width of fill pattern
_vf_hgt     dw  1             ; height of fill pattern
_vlimits    dw  16                         ; Maximum in table
            dw  39,24,39,24,79,24,79,24    ; 0..3  (text)
            dw  319,199,319,199,639,199    ; 4..6  (graphics)
            dw  79,24                      ; 7 (monochome)
            dw  159,199,319,199,639,199    ; 8..10 (pc Jr)
            dw  0,0,0,0                    ; 11..12 (undefined)
            dw  319,199,639,199,639,349    ; 13..15 (EGA)
            dw  639,349                    ; 16 (EGA)
;
    end
;
;  Table of bit patterns for characters in graphics mode.
;  Characters fill an 8x8 cell.
;  Only the first 128 character codes are present.
;
         idt  _vchpat1
         ddef _vchpat1
;
         dorg  0
_vchpat1 db  >00,>00,>00,>00,>00,>00,>00,>00  ; 00
         db  >7e,>81,>a5,>81,>bd,>99,>81,>7e  ; 01
         db  >7e,>ff,>db,>ff,>c3,>e7,>ff,>7e  ; 02
         db  >6c,>fe,>fe,>fe,>7c,>38,>10,>00  ; 03
         db  >10,>38,>7c,>fe,>7c,>38,>10,>00  ; 04
         db  >38,>7c,>38,>fe,>fe,>7c,>38,>7c  ; 05
         db  >10,>10,>38,>7c,>fe,>7c,>38,>7c  ; 06
         db  >00,>00,>18,>3c,>3c,>18,>00,>00  ; 07
         db  >ff,>ff,>e7,>c3,>c3,>e7,>ff,>ff  ; 08
         db  >00,>3c,>66,>42,>42,>66,>3c,>00  ; 09
         db  >ff,>c3,>99,>bd,>bd,>99,>c3,>ff  ; 0a
         db  >0f,>07,>0f,>7d,>cc,>cc,>cc,>78  ; 0b
         db  >3c,>66,>66,>66,>3c,>18,>7e,>18  ; 0c
         db  >3f,>33,>3f,>30,>30,>70,>f0,>e0  ; 0d
         db  >7f,>63,>7f,>63,>63,>67,>e6,>c0  ; 0e
         db  >99,>5a,>3c,>e7,>e7,>3c,>5a,>99  ; 0f
         db  >80,>e0,>f8,>fe,>f8,>e0,>80,>00  ; 10
         db  >02,>0e,>3e,>fe,>3e,>0e,>02,>00  ; 11
         db  >18,>3c,>7e,>18,>18,>7e,>3c,>18  ; 12
         db  >66,>66,>66,>66,>66,>00,>66,>00  ; 13
         db  >7f,>db,>db,>7b,>1b,>1b,>1b,>00  ; 14
         db  >3e,>63,>38,>6c,>6c,>38,>cc,>78  ; 15
         db  >00,>00,>00,>00,>7e,>7e,>7e,>00  ; 16
         db  >18,>3c,>7e,>18,>7e,>3c,>18,>ff  ; 17
         db  >18,>3c,>7e,>18,>18,>18,>18,>00  ; 18
         db  >18,>18,>18,>18,>7e,>3c,>18,>00  ; 19
         db  >00,>18,>0c,>fe,>0c,>18,>00,>00  ; 1a
         db  >00,>30,>60,>fe,>60,>30,>00,>00  ; 1b
         db  >00,>00,>c0,>c0,>c0,>fe,>00,>00  ; 1c
         db  >00,>24,>66,>ff,>66,>24,>00,>00  ; 1d
         db  >00,>18,>3c,>7e,>ff,>ff,>00,>00  ; 1e
         db  >00,>ff,>ff,>7e,>3c,>18,>00,>00  ; 1f
         db  >00,>00,>00,>00,>00,>00,>00,>00  ; 20  
         db  >30,>78,>78,>30,>30,>00,>30,>00  ; 21 !
         db  >6c,>6c,>6c,>00,>00,>00,>00,>00  ; 22 "
         db  >6c,>6c,>fe,>6c,>fe,>6c,>6c,>00  ; 23 #
         db  >30,>7c,>c0,>78,>0c,>f8,>30,>00  ; 24 $
         db  >00,>c6,>cc,>18,>30,>66,>c6,>00  ; 25 %
         db  >38,>6c,>38,>76,>dc,>cc,>76,>00  ; 26 &
         db  >60,>60,>c0,>00,>00,>00,>00,>00  ; 27 '
         db  >18,>30,>60,>60,>60,>30,>18,>00  ; 28 (
         db  >60,>30,>18,>18,>18,>30,>60,>00  ; 29 )
         db  >00,>66,>3c,>ff,>3c,>66,>00,>00  ; 2a *
         db  >00,>30,>30,>fc,>30,>30,>00,>00  ; 2b +
         db  >00,>00,>00,>00,>00,>30,>30,>60  ; 2c ,
         db  >00,>00,>00,>fc,>00,>00,>00,>00  ; 2d -
         db  >00,>00,>00,>00,>00,>30,>30,>00  ; 2e .
         db  >06,>0c,>18,>30,>60,>c0,>80,>00  ; 2f /
         db  >7c,>c6,>ce,>de,>f6,>e6,>7c,>00  ; 30 0
         db  >30,>70,>30,>30,>30,>30,>fc,>00  ; 31 1
         db  >78,>cc,>0c,>38,>60,>cc,>fc,>00  ; 32 2
         db  >78,>cc,>0c,>38,>0c,>cc,>78,>00  ; 33 3
         db  >1c,>3c,>6c,>cc,>fe,>0c,>1e,>00  ; 34 4
         db  >fc,>c0,>f8,>0c,>0c,>cc,>78,>00  ; 35 5
         db  >38,>60,>c0,>f8,>cc,>cc,>78,>00  ; 36 6
         db  >fc,>cc,>0c,>18,>30,>30,>30,>00  ; 37 7
         db  >78,>cc,>cc,>78,>cc,>cc,>78,>00  ; 38 8
         db  >78,>cc,>cc,>7c,>0c,>18,>70,>00  ; 39 9
         db  >00,>30,>30,>00,>00,>30,>30,>00  ; 3a :
         db  >00,>30,>30,>00,>00,>30,>30,>60  ; 3b ;
         db  >18,>30,>60,>c0,>60,>30,>18,>00  ; 3c <
         db  >00,>00,>fc,>00,>00,>fc,>00,>00  ; 3d =
         db  >60,>30,>18,>0c,>18,>30,>60,>00  ; 3e >
         db  >78,>cc,>0c,>18,>30,>00,>30,>00  ; 3f ?
         db  >7c,>c6,>de,>de,>de,>c0,>78,>00  ; 40 @
         db  >30,>78,>cc,>cc,>fc,>cc,>cc,>00  ; 41 A
         db  >fc,>66,>66,>7c,>66,>66,>fc,>00  ; 42 B
         db  >3c,>66,>c0,>c0,>c0,>66,>3c,>00  ; 43 C
         db  >f8,>6c,>66,>66,>66,>6c,>f8,>00  ; 44 D
         db  >fe,>62,>68,>78,>68,>62,>fe,>00  ; 45 E
         db  >fe,>62,>68,>78,>68,>60,>f0,>00  ; 46 F
         db  >3c,>66,>c0,>c0,>ce,>66,>3e,>00  ; 47 G
         db  >cc,>cc,>cc,>fc,>cc,>cc,>cc,>00  ; 48 H
         db  >78,>30,>30,>30,>30,>30,>78,>00  ; 49 I
         db  >1e,>0c,>0c,>0c,>cc,>cc,>78,>00  ; 4a J
         db  >e6,>66,>6c,>78,>6c,>66,>e6,>00  ; 4b K
         db  >f0,>60,>60,>60,>62,>66,>fe,>00  ; 4c L
         db  >c6,>ee,>fe,>fe,>d6,>c6,>c6,>00  ; 4d M
         db  >c6,>e6,>f6,>de,>ce,>c6,>c6,>00  ; 4e N
         db  >38,>6c,>c6,>c6,>c6,>6c,>38,>00  ; 4f O
         db  >fc,>66,>66,>7c,>60,>60,>f0,>00  ; 50 P
         db  >78,>cc,>cc,>cc,>dc,>78,>1c,>00  ; 51 Q
         db  >fc,>66,>66,>7c,>6c,>66,>e6,>00  ; 52 R
         db  >78,>cc,>e0,>70,>1c,>cc,>78,>00  ; 53 S
         db  >fc,>b4,>30,>30,>30,>30,>78,>00  ; 54 T
         db  >cc,>cc,>cc,>cc,>cc,>cc,>fc,>00  ; 55 U
         db  >cc,>cc,>cc,>cc,>cc,>78,>30,>00  ; 56 V
         db  >c6,>c6,>c6,>d6,>fe,>ee,>c6,>00  ; 57 W
         db  >c6,>c6,>6c,>38,>38,>6c,>c6,>00  ; 58 X
         db  >cc,>cc,>cc,>78,>30,>30,>78,>00  ; 59 Y
         db  >fe,>c6,>8c,>18,>32,>66,>fe,>00  ; 5a Z
         db  >78,>60,>60,>60,>60,>60,>78,>00  ; 5b [
         db  >c0,>60,>30,>18,>0c,>06,>02,>00  ; 5c \
         db  >78,>18,>18,>18,>18,>18,>78,>00  ; 5d ]
         db  >10,>38,>6c,>c6,>00,>00,>00,>00  ; 5e ^
         db  >00,>00,>00,>00,>00,>00,>00,>ff  ; 5f _
         db  >30,>30,>18,>00,>00,>00,>00,>00  ; 60 `
         db  >00,>00,>78,>0c,>7c,>cc,>76,>00  ; 61 a
         db  >e0,>60,>60,>7c,>66,>66,>dc,>00  ; 62 b
         db  >00,>00,>78,>cc,>c0,>cc,>78,>00  ; 63 c
         db  >1c,>0c,>0c,>7c,>cc,>cc,>76,>00  ; 64 d
         db  >00,>00,>78,>cc,>fc,>c0,>78,>00  ; 65 e
         db  >38,>6c,>60,>f0,>60,>60,>f0,>00  ; 66 f
         db  >00,>00,>76,>cc,>cc,>7c,>0c,>f8  ; 67 g
         db  >e0,>60,>6c,>76,>66,>66,>e6,>00  ; 68 h
         db  >30,>00,>70,>30,>30,>30,>78,>00  ; 69 i
         db  >0c,>00,>0c,>0c,>0c,>cc,>cc,>78  ; 6a j
         db  >e0,>60,>66,>6c,>78,>6c,>e6,>00  ; 6b k
         db  >70,>30,>30,>30,>30,>30,>78,>00  ; 6c l
         db  >00,>00,>cc,>fe,>fe,>d6,>c6,>00  ; 6d m
         db  >00,>00,>f8,>cc,>cc,>cc,>cc,>00  ; 6e n
         db  >00,>00,>78,>cc,>cc,>cc,>78,>00  ; 6f o
         db  >00,>00,>dc,>66,>66,>7c,>60,>f0  ; 70 p
         db  >00,>00,>76,>cc,>cc,>7c,>0c,>1e  ; 71 q
         db  >00,>00,>dc,>76,>66,>60,>f0,>00  ; 72 r
         db  >00,>00,>7c,>c0,>78,>0c,>f8,>00  ; 73 s
         db  >10,>30,>7c,>30,>30,>34,>18,>00  ; 74 t
         db  >00,>00,>cc,>cc,>cc,>cc,>76,>00  ; 75 u
         db  >00,>00,>cc,>cc,>cc,>78,>30,>00  ; 76 v
         db  >00,>00,>c6,>d6,>fe,>fe,>6c,>00  ; 77 w
         db  >00,>00,>c6,>6c,>38,>6c,>c6,>00  ; 78 x
         db  >00,>00,>cc,>cc,>cc,>7c,>0c,>f8  ; 79 y
         db  >00,>00,>fc,>98,>30,>64,>fc,>00  ; 7a z
         db  >1c,>30,>30,>e0,>30,>30,>1c,>00  ; 7b {
         db  >18,>18,>18,>00,>18,>18,>18,>00  ; 7c |
         db  >e0,>30,>30,>1c,>30,>30,>e0,>00  ; 7d }
         db  >76,>dc,>00,>00,>00,>00,>00,>00  ; 7e ~
         db  >00,>10,>38,>6c,>c6,>c6,>fe,>00  ; 7f
         end
