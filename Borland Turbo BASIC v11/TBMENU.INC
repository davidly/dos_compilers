sub makemenu static
shared wrow%(),wrows%(),wcol%(),wcols%(),wattr%(),wbrdr%(),wshdw%(),scrn%(),wptr(),LI
shared mrow%,mcol%,mwidth%,mattr%,mhiattr%,mbrdrsel%,mshadow%,mzoom%,mtitle$
shared item$(),itemcount%,startpos%
shared curntpos%
call makewindow(mrow%,mcol%,itemcount%+2,mwidth%,mattr%,mbrdrsel%,mshadow%,mzoom%)
call titlewindow(2,mtitle$)
for mloop% = 1 to itemcount%
  call qprintc(wrow%(LI)+mloop%,wcol%(LI),wcol%(LI)+wcols%(LI),item$(mloop%),wattr%(LI))
next
if curntpos% = 0 then if startpos% = 0 then curntpos% = 1 else curntpos% = startpos%
tryagain:
call qattr(wrow%(LI)+curntpos%,wcol%(LI)+1,1,wcols%(LI)-2,mhiattr%)
while not instat
wend
ans$=inkey$
if len(ans$)=2 then ans$=right$(ans$,1)
call qattr(wrow%(LI)+curntpos%,wcol%(LI)+1,1,wcols%(LI)-2,wattr%(LI))
select case ans$
  case chr$(72),chr$(75),"-","8","4"
    decr curntpos%
  case chr$(80),chr$(77),"+","2","6"
    incr curntpos%
  case chr$(13)
    call removewindow
    exit sub
  case chr$(27)
    curntpos%=0
    call removewindow
    exit sub
  case else
    curntpos% = curntpos%
end select
if curntpos% > itemcount% then curntpos% = 1
if curntpos% < 1 then curntpos% = itemcount%
goto tryagain
end sub
