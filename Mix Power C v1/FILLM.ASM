;
;    Copyright (c) Mix Software 1988
;
;  void _fill_pm(border_color)
;     fill a region with a pattern.
;     Uses direct access to the screen memory.
;     For cga modes 4, 5, and 6 and (hercules monochrome).
;     _vxcurs, _vycurs = current coordinate.
;     Fill pattern is described by _vf_pat, _vf_wid and _vf_hgt.
;
         idt  _fill_pm
         def  _fill_pm
         dref _vapage         ; active page
         dref _vmaxh          ; window limits
         dref _vminh
         dref _vmode
         dref _vmaxv
         dref _vminv
         dref _v_color        ; pen color
         dref _vxcurs         ; current cursor column
         dref _vycurs         ; current cursor row
         dref _vf_pat         ; address of fill pattern
         dref _vf_wid         ; width of fill pattern
         dref _vf_hgt         ; height of fill pattern
         dref $$MAXS
         fref $_STKCHK
         fref getvmode
         fref crt_lock
         lfref crt_unlock
CGAHIGH  equ  6
CGALOW   equ  4
CGALOWBW equ  5
;
;   local variables
;
chain    equ  >0              ; state structure for next level
cy       equ  0               ;   offsets at next level
cminx    equ  2
cmaxx    equ  4
cnext    equ  6
chainy   equ  chain+cy        ; current y coordinate
minx     equ  chain+cminx     ; minimum x coordinate
maxx     equ  chain+cmaxx     ; minimum x coordinate
lastptr  equ  chain+cnext     ; address of previous frame
local    equ  lastptr+2
;
;  parameters
;
x        equ  4+local
y        equ  6+local
previous equ  8+local
bordcol  equ  4
;
;
_fill_pm callfar crt_lock
         mov  bx,sp
         mov  ax,[bx][%bordcol]
         mov  [border],ax     ; save border color
         mov  [bits],1        ; bits per pixel
         mov  [fill],l1fill   ; fill for 1 bit per pixel
         callfar getvmode
         cmp  ax,HERCMODE
         jnz  notherc
         mov  [where],whereh  ; pointer to address calculation
         mov  dx,>b000        ; set base address to active page
         cmp  %[_vapage],0
         jz   pageset
         mov  dx,>b800        ; page 1
pageset  mov  es,dx
         jmps callfill
notherc  mov  dx,>b800        ; memory base for cga
         mov  es,dx
         cmp  ax,CGAHIGH
         jnz  nothigh
         mov  [where],where6  ; address calculation for mode 6
         jmps callfill
nothigh  cmp  ax,CGALOW
         jz   lowres
         cmp  ax,CGALOWBW
         jnz  badmode
lowres   mov  [where],where4  ; address calculation function
         mov  [bits],2        ; 2 bits per pixel
         mov  [fill],l2fill   ; multi-bit fill function
callfill xor  ax,ax
         push ax              ; null previous block list
         push [_vycurs]       ; starting position
         push [_vxcurs]
         call fill_m
         callfar crt_unlock
         add  sp,%6
         xor  ax,ax
         retfar
badmode  callfar crt_unlock
         mov  ax,-1
         retfar
;
fill_m   push bp
         sub  sp,local
         cmp  sp,[$$MAXS]     ; check for stack overflow
         jnb  noflo
         callfar $_STKCHK
noflo    mov  bp,sp
         mov  ax,[bp][%y]
         xor  dx,dx
         div  [_vf_hgt]       ; dx = y mod _vf_hgt
         mov  ax,dx
         mul  [_vf_wid]       ; ax = offset to row of pattern
         add  ax,[_vf_pat]
         mov  [xstart],ax     ; start of pattern row
         mov  bx,ax
         add  ax,[_vf_wid]
         mov  [xlimit],ax     ; end of pattern row
         mov  ax,[bp][%x]
         xor  dx,dx
         div  [_vf_wid]       ; dx = x mod _vf_wid
         add  bx,dx           ; bx = initial pattern pointer
         mov  [patptr],bx
;
;  compute memory address and bit mask for (x,y)
;
         call [where]
         mov  [memaddr],si
         mov  [bitmask],ax
         mov  dx,[bp][%x]
         mov  bx,[patptr]
         call [fill]
;
         mov  ax,[bp][%y]     ; values for use by next level
         mov  [bp][%chainy],ax
         mov  ax,[bp][%previous]
         mov  [bp][%lastptr],ax
;
;  scan lines above and below for unfilled areas
;
         dec  [bp][%y]
         call scan
         add  [bp][%y],%2
         call scan
         mov  ax,[bp][%maxx]
         lea  sp,[bp][%local]
         pop  bp
         ret
;
;  scan a line from (minx+1,y) to (maxx-1,y)
;     for any group with a non-border pixel
;     check whether visited before and if not, make
;     recursive call to fill the line.
;
scan     mov  ax,[bp][%y]
         cmp  ax,[_vminv]     ; check y for boundary
         jb   scandone
         cmp  ax,[_vmaxv]
         ja   scandone
         mov  dx,[bp][%minx]
         inc  dx
         mov  [bp][%x],dx
         call [where]          ; get screen memory address
         mov  dx,[bp][%x]
scannxt  cmp  dx,[bp][%maxx]
         jae  scandone
         seges
         mov  ch,%[si]        ; read group of pixels
         and  ch,ah           ; select one
         cmp  ch,al           ; compare to border color
         jz   scaninc         ; border color, skip
;                             ; search for previously visited
         mov  cx,[bp][%y]
         mov  bx,[bp][%previous]
srch     test bx,bx
         jz   nextline        ; not done before
         cmp  cx,[bx]         ; same value of y?
         jnz  nextsrch
         cmp  dx,[bx][%cminx]
         jle  nextsrch        ; not in range
         cmp  dx,[bx][%cmaxx]
         jge  nextsrch
         mov  dx,[bx][%cmaxx] ; skip this region
         dec  dx
         mov  [bp][%x],dx
         call [where]
         mov  dx,[bp][%x]
         jmps scaninc
nextsrch mov  bx,[bx][%cnext]
         jmps srch
nextline lea  ax,[bp][%chain] ; call for next line
         push ax              ; link record
         push [bp][%y]
         push dx
         call fill_m
         add  sp,%6
         mov  dx,ax
         mov  [bp][%x],dx
         call [where]
         mov  dx,[bp][%x]
scaninc  inc  dx              ; next x
         mov  cl,[bits]
         ror  al,cl
         ror  ah,cl           ; move to next pixel
         jnc  nocarry3
         inc  si              ; first pixel in next byte
nocarry3 jmp  scannxt         ; find next region
scandone ret
;
;  fill dots to the left until boundary or window edge
;  Special version for 1 bit per pixel
;        bx is the pattern pointer
;        dx is the value of x
;        es:si is the screen address
;        ah is the bit mask
;        al is the border color
;
;   sets minx and maxx to the edges of the area
;
l1fill   cmp  dx,[_vminh]
         jl   l1done
         seges
         mov  ch,[si]         ; read 8 dots
         mov  cl,ch
         and  cl,ah
         cmp  cl,al
         jz   l1done
         mov  cl,%[bx]        ; color of pattern
         cmp  cl,TRANSPAR     ; if transparent, do not set
         jz   l1next
         cmp  cl,PENCOLOR     ; use pen color
         jnz  l1set2
         mov  cl,%[_v_color]
l1set2   test cl,%1
         jz   l1clr
         or   ch,ah           ; set the pixel to 1
         jmps l1put
l1clr    not  ah
         and  ch,ah           ; set the pixel to 0
         not  ah
l1put    seges
         mov  %[si],ch
l1next   dec  dx              ; decrease x coordinate
         rol  al,1            ; border color to next bit
         rol  ah,1            ; move to next bit
         jnc  l1nc
         dec  si              ; last bit in previous byte
l1nc     dec  bx              ; move back one in pattern
         cmp  bx,[xstart]
         jae  l1fill
         mov  bx,[xlimit]     ; move to end of pattern
         dec  bx
         jmps l1fill
l1done   mov  [bp][%minx],dx
;
         mov  dx,[bp][%x]
         mov  si,[memaddr]
         mov  ax,[bitmask]
         mov  bx,[patptr]
         jmps r1next
;
r1fill   cmp  dx,[_vmaxh]
         ja   r1done
         seges
         mov  ch,[si]         ; read 8 dots
         mov  cl,ch
         and  cl,ah
         cmp  cl,al
         jz   r1done
         mov  cl,%[bx]        ; color of pattern
         cmp  cl,TRANSPAR     ; if transparent, do not set
         jz   r1next
         cmp  cl,PENCOLOR     ; use pen color
         jnz  r1set2
         mov  cl,%[_v_color]
r1set2   test cl,%1
         jz   r1clr
         or   ch,ah           ; set the pixel to 1
         jmps r1put
r1clr    not  ah
         and  ch,ah           ; set the pixel to 0
         not  ah
r1put    seges
         mov  %[si],ch
r1next   inc  dx              ; increase x coordinate
         ror  al,1
         ror  ah,1            ; move to next bit
         jnc  r1nc
         inc  si              ; first bit in next byte
r1nc     inc  bx              ; move forward one in pattern
         cmp  bx,[xlimit]
         jnz  r1fill
         mov  bx,[xstart]     ; move to end of pattern
         jmps r1fill
r1done   mov  [bp][%maxx],dx
         ret
;
;  fill dots to the left until boundary or window edge
;  Each pixel is 2 bits
;        bx is the pattern pointer
;        dx is the value of x
;        es:si is the screen address
;        ah is the bit mask
;        al is the border color
;
;   sets minx and maxx to the edges of the area
;
l2fill   mov  di,bx
l2fill0  cmp  dx,[_vminh]
         jl   l2done
         seges
         mov  ch,[si]         ; read 4 dots
         mov  cl,ch
         and  cl,ah           ; isolate this pixel
         cmp  cl,al
         jz   l2done          ; border color
         mov  bl,%[di]        ; color of pattern
         cmp  bl,TRANSPAR     ; if transparent, do not set
         jz   l2next
         cmp  bl,PENCOLOR     ; use pen color
         jnz  l2set2
         mov  bl,%[_v_color]
l2set2   and  bl,3
         mov  cl,dl           ; x coordinate
         and  cl,%3           ; mask bit number
         neg  cl
         add  cl,3
         jz   l2noshf
         add  cl,cl           ; number of shifts needed
         shl  bl,cl           ; shift color into position
l2noshf  not  ah
         and  ch,ah           ; mask previous contents
         not  ah
         or   ch,bl           ; load new color value
         seges
         mov  %[si],ch
l2next   dec  dx              ; decrease x coordinate
         rol  al,1            ; border color to next position
         rol  al,1
         rol  ah,1            ; move to next pixel
         rol  ah,1
         jnc  l2nc
         dec  si              ; last bit in previous byte
l2nc     dec  di              ; move back one in pattern
         cmp  di,[xstart]
         jae  l2fill0
         mov  di,[xlimit]     ; move to end of pattern
         dec  di
         jmps l2fill0
l2done   mov  [bp][%minx],dx
;
         mov  dx,[bp][%x]
         mov  si,[memaddr]
         mov  ax,[bitmask]
         mov  di,[patptr]
         jmps r2next
;
r2fill   cmp  dx,[_vmaxh]
         ja   r2done
         seges
         mov  ch,[si]         ; read 4 dots
         mov  cl,ch
         and  cl,ah
         cmp  cl,al
         jz   r2done
         mov  bl,%[di]        ; color of pattern
         cmp  bl,TRANSPAR     ; if transparent, do not set
         jz   r2next
         cmp  bl,PENCOLOR     ; use pen color
         jnz  r2set2
         mov  bl,%[_v_color]
r2set2   and  bl,3
         mov  cl,dl           ; x coordinate
         and  cl,3            ; mask bit number
         neg  cl
         add  cl,3
         jz   r2noshf
         add  cl,cl           ; number of shifts needed
         shl  bl,cl           ; shift color into position
r2noshf  not  ah
         and  ch,ah           ; mask previous contents
         not  ah
         or   ch,bl           ; load new color value
         seges
         mov  %[si],ch
r2next   inc  dx              ; increase x coordinate
         ror  al,1
         ror  al,1
         ror  ah,1            ; move to next bit
         ror  ah,1
         jnc  r2nc
         inc  si              ; first pixel in next byte
r2nc     inc  di              ; move forward one in pattern
         cmp  di,[xlimit]
         jnz  r2fill
         mov  di,[xstart]     ; move to end of pattern
         jmps r2fill
r2done   mov  [bp][%maxx],dx
         ret
;
;  compute address and bit mask for a pixel (Hercules)
;  inputs:
;      [bp][y] = y coordinate
;      [bp][x] = x coordinate
;  outputs:
;      si = memory address
;      ah = bit mask
;      al = border color
;      cx, dx are altered
;
whereh   mov  ax,[bp][%y]
         mov  si,ax
         and  si,>0003
         mov  cl,13
         shl  si,cl           ; (y % 4) * 0x2000
         mov  cl,2
         shr  ax,cl           ; y/4
         shl  ax,1            ; (y/4) * 0x02
         add  si,ax
         shl  ax,cl           ; (y/4) * 0x08
         add  si,ax
         shl  ax,1            ; (y/4) * 0x10
         add  si,ax
         shl  ax,cl           ; (y/4) * 0x40
         add  si,ax
         mov  ax,[bp][%x]
         mov  cx,ax
         shr  ax,1            ; x/8
         shr  ax,1
         shr  ax,1
         add  si,ax
         and  cx,>0007        ; x % 8
         mov  ah,>80
         mov  al,[border]
         ror  al,1
         jcxz noshifth
         shr  ax,cl
noshifth ret
;
;  compute address and bit mask for a pixel (cga mode 6)
;  inputs:
;      [bp][y] = y coordinate
;      [bp][x] = x coordinate
;  outputs:
;      si = memory address
;      ah = bit mask
;      al = border color
;      cx is altered
;
where6   mov  ax,[bp][%y]
         mov  si,ax
         and  si,>0001
         mov  cl,13
         shl  si,cl           ; (y % 2) * 0x2000
         shr  ax,1            ; y/2
         mov  cl,4
         shl  ax,cl           ; (y/2) * 0x10
         add  si,ax
         shl  ax,1
         shl  ax,1            ; ax = (y/2) * 0x40
         add  si,ax
         mov  ax,[bp][%x]
         mov  cx,ax
         shr  ax,1            ; x/8
         shr  ax,1
         shr  ax,1
         add  si,ax
         and  cx,>0007        ; x % 8
         mov  ah,>80
         mov  al,[border]
         ror  al,1
         jcxz noshift6
         shr  ax,cl
noshift6 ret
;
;  compute address and bit mask for a pixel (cga mode 4 or 5)
;  inputs:
;      [bp][y] = y coordinate
;      [bp][x] = x coordinate
;  outputs:
;      si = memory address
;      ah = bit mask
;      al = border color
;      cx is altered
;
where4   mov  ax,[bp][%y]
         mov  si,ax
         and  si,>0001
         mov  cl,13
         shl  si,cl           ; (y % 2) * 0x2000
         shr  ax,1            ; y/2
         mov  cl,4
         shl  ax,cl           ; (y/2) * 0x10
         add  si,ax
         shl  ax,1
         shl  ax,1            ; ax = (y/2) * 0x40
         add  si,ax
         mov  ax,[bp][%x]
         mov  cx,ax
         shr  ax,1            ; x/4
         shr  ax,1
         add  si,ax
         and  cx,>0003        ; x % 4
         mov  ah,>C0
         mov  al,[border]
         ror  al,1
         ror  al,1
         jcxz noshift4
         shr  ax,cl
         shr  ax,cl
noshift4 ret
;
;  local static variables
;
         dorg 0
xstart   dw   0-0             ; beginning of line of fill pattern
xlimit   dw   0-0             ; end of line of fill pattern
memaddr  dw   0-0             ; address of pixel in memory
bitmask  dw   0-0             ; bit position of pixel
patptr   dw   0-0             ; initial fill pattern pointer
border   dw   0-0             ; border color
bits     dw   0-0             ; number of bits per pixel
where    dw   0-0             ; address calculation function
fill     dw   0-0             ; fill current line function
         end
