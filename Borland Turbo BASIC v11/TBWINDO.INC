mw% = 30
ScrnArray = 8000

dim wrow%(mw%),wrows%(mw%),wcol%(mw%),wcols%(mw%),wattr%(mw%),wbrdr%(mw%)
dim wshdw%(mw%),scrn%(ScrnArray),wptr(mw%)

sub MakeWindow(Row%,Col%,Rows%,Cols%,Attr%,BrdrSel%,Shadow%,Zoom%) static
  shared wrow%(),wrows%(),wcol%(),wcols%(),wattr%(),wbrdr%(),wshdw%(),scrn%(),wptr(),LI
  local r1%,r2%,c1%,c2%,colratio%,wsize
  select case shadow%
    Rem Left
    case = 1
      c1%=col%-2 : c2%=cols%+2 : r2%=rows%+1
    Rem Right
    case = 2
      c1%=col%   : c2%=cols%+2 : r2%=rows%+1
    case else
      c1%=col%   : c2%=cols%   : r2%=rows%
  end select
  wsize = (r2% * c2%) * 2
  LI = LI + 1
  Wptr(LI+1) = Wptr(LI)+WSize+1
  WRow%(LI)  = Row%
  WCol%(LI)  = Col%
  WRows%(LI) = Rows%
  WCols%(LI) = Cols%
  Wattr%(LI) = Attr%
  WBrdr%(LI) = BrdrSel%
  WShdw%(LI) = Shadow%
  Call Qsave(Row%,c1%,r2%,c2%,scrn%(Wptr(LI)))
  if zoom% = 1 then
    r1% = row% +       (rows%\2)
    r2% = row% + rows%-(rows%\2)
    c1% = col% +       (cols%\2)
    c2% = col% + cols%-(cols%\2)
    colratio% = (cols% \ rows%)+1
    if colratio% > 4 then colratio%=4
    do
      if r1%>row%         then r1%=r1%-1
      if r2%<(row%+rows%) then r2%=r2%+1
      if c1%>col%         then c1%=c1%-colratio%
      if c1%<col%         then c1%=col%
      if c2%<(col%+cols%) then c2%=c2%+colratio%
      if c2%>(col%+cols%) then c2%=col%+cols%
      call Qbox(r1%,c1%,r2%-r1%,c2%-c1%,attr%,brdrsel%)
    loop until c1%=col% and c2%=col%+cols% and r1%=row% and r2%=row%+rows%
  else
    call Qbox(row%,col%,rows%,cols%,attr%,brdrsel%)
  end if
  select case shadow%
    rem Left
    case = 1
      call qfill(row%+1    ,col%-2    ,rows%-1,2    ,asc(" "),0)
      call qfill(row%+rows%,col%-2    ,1      ,cols%,asc(" "),0)
    rem Right
    case = 2
      call qfill(row%+1    ,col%+cols%,rows%-1,2    ,asc(" "),0)
      call qfill(row%+rows%,col%+2    ,1      ,cols%,asc(" "),0)
    case else
  end select
end sub

sub TitleWindow(dir%,title$) static
shared wrow%(),wcol%(),wrows%(),wcols%(),wattr%(),LI
  select case dir%
    rem UpperLeft
    case = 1
      call qprint(wrow%(LI),wcol%(LI)+2,title$,wattr%(LI))
    rem UpperCenter
    case = 2
      call qprintc(wrow%(LI),wcol%(LI),wcol%(LI)+wcols%(LI)-1,title$,wattr%(LI))
    rem UpperRight
    case = 3
      call qprint(wrow%(LI),wcol%(LI)+wcols%(LI)-len(title$)-2,title$,wattr%(LI))
    rem LowerLeft
    case = 4
      call qprint(wrow%(LI)+wrows%(LI)-1,wcol%(LI)+2,title$,wattr%(LI))
    rem LowerCenter
    case = 5
      call qprintc(wrow%(LI)+wrows%(LI)-1,wcol%(LI),wcol%(LI)+wcols%(LI)-1,title$,wattr%(LI))
    rem LowerRight
    case = 6
      call qprint(wrow%(LI)+wrows%(LI)-1,wcol%(LI)+wcols%(LI)-len(title$)-2,title$,wattr%(LI))
    case else
  end select
end sub

sub RemoveWindow static
shared Wrow%(),WCol%(),WRows%(),Wcols%(),Wattr%(),WShdw%(),Scrn%(),Wptr(),LI
  if LI = 0 then
    print "NO WINDOW TO REMOVE"
  else
    select case WShdw%(LI)
    case = 1
      call qrest(Wrow%(LI),WCol%(LI)-2,WRows%(LI)+1,WCols%(LI)+2,Scrn%(Wptr(LI)))
    case = 2
      call qrest(WRow%(LI),WCol%(LI)  ,WRows%(LI)+1,WCols%(LI)+2,Scrn%(Wptr(LI)))
    case else
      call qrest(WRow%(LI),Wcol%(LI)  ,WRows%(LI)  ,WCols%(LI)  ,Scrn%(Wptr(LI)))
    end select
    LI = LI -1
  end if
end sub

sub Qbox(Row%,Col%,Rows%,Cols%,attr%,BrdrSel%) static
  if rows%>2 and cols%>2 then
    if brdrsel% > 0 and brdrsel% < 6 then
      on brdrsel% gosub single,double,mixed12,mixed21,doubleleftarrow
      call qprint(row%        ,col%        ,tl$                     ,attr%)
      call qfill (row%        ,col%+1      ,1      ,cols%-2,asc(th$),attr%)
      call qprint(row%        ,col%+cols%-1,tr$                     ,attr%)
      call qfill (row%+1      ,col%        ,rows%-2,1      ,asc(lv$),attr%)
      call qfill (row%+1      ,col%+cols%-1,rows%-2,1      ,asc(rv$),attr%)
      call qprint(row%+rows%-1,Col%        ,bl$                     ,attr%)
      call qfill (row%+rows%-1,Col%+1      ,1      ,cols%-2,asc(bh$),attr%)
      call qprint(row%+rows%-1,col%+cols%-1,br$                     ,attr%)
      call qfill (row%+1      ,col%+1      ,rows%-2 ,cols%-2,asc(" "),attr%)
    else
      call qfill (row%,col%,rows%,cols%,asc(" "),attr%)
    end if
  end if
  exit sub

Single:
  TL$=CHR$(218):TH$=CHR$(196):TR$=CHR$(191)
  LV$=CHR$(179):RV$=CHR$(179)
  BL$=CHR$(192):BH$=CHR$(196):BR$=CHR$(217)
  Return
Double:
  TL$=CHR$(201):TH$=CHR$(205):TR$=CHR$(187)
  LV$=CHR$(186):RV$=CHR$(186)
  BL$=CHR$(200):BH$=CHR$(205):BR$=CHR$(188)
  Return
Mixed12:
  TL$=CHR$(214):TH$=CHR$(196):TR$=CHR$(183)
  LV$=CHR$(186):RV$=CHR$(186)
  BL$=CHR$(211):BH$=CHR$(196):BR$=CHR$(189)
  Return
Mixed21:
  TL$=CHR$(213):TH$=CHR$(205):TR$=CHR$(184)
  LV$=CHR$(179):RV$=CHR$(179)
  BL$=CHR$(212):BH$=CHR$(205):BR$=CHR$(190)
  Return
DoubleLeftArrow:
  TL$=CHR$(17):TH$=CHR$(205):TR$=CHR$(187)
  LV$=CHR$(186):RV$=CHR$(186)
  BL$=CHR$(200):BH$=CHR$(205):BR$=CHR$(188)
  Return
end sub

sub ClearWindow static
shared wrow%(),wcol%(),wrows%(),wcols%(),wattr%(),LI
   call qfill (wrow%(LI)+1,wcol%(LI)+1,wrows%(LI)-2,wcols%(LI)-2,asc(" "),wattr%(LI))
end sub

sub PrtWindow(row%,col%,StrDat$) static
shared wrow%(),wcol%(),wrows%(),wcols%(),wattr%(),LI
   call qprint(wrow%(LI)+row%,wcol%(LI)+col%,StrDat$,wattr%(LI))
end sub

sub PrtCWindow(row%,StrDat$) static
shared wrow%(),wcol%(),wrows%(),wcols%(),wattr%(),LI
   call qprintc(wrow%(LI)+row%,wcol%(LI),wcol%(LI)+wcols%(LI),StrDat$,wattr%(LI))
end sub

def fnattr%(fore%,back%)
  local temp%
  temp%=(back%*16)+fore%
  if fore%>15 then temp% = temp% + 112
  fnattr% = temp%
end def

SUB QPRINT INLINE
  $INLINE "QPRINT.BIN"
END SUB
rem CALL QPRINT(ROW%,COL%,STR$,ATTR%)

SUB QPRINTC INLINE
  $INLINE "QPRINTC.BIN"
END SUB
rem CALL QPRINTC(ROW%,COLL%,COLR%,STRDAT$,ATTR%)

SUB QFILL INLINE
  $INLINE "QFILL.BIN"
END SUB
rem CALL QFILL(ROW%,COL%,ROWS%,COLS%,CHAR%,ATTR%)

SUB QATTR INLINE
  $INLINE "QATTR.BIN"
END SUB
rem CALL QATTR(ROW%,COL%,ROWS%,COLS%,ATTR%)

SUB QSAVE INLINE
  $INLINE "QSAVE.BIN"
END SUB
rem CALL QSAVE(ROW%,COL%,ROWS%,COLS%,SCRN%(??))

SUB QREST INLINE
  $INLINE "QREST.BIN"
END SUB
rem CALL QREST(ROW%,COL%,ROWS%,COLS%,SCRN%(??))

