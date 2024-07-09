\ TED.F
\
\ TED - A Tiny Text Editor for DX-Forth
\
\ Based on the HT-68K editor by J.Bartel
\
\ The HELP screen is only compiled for the
\ turnkey version
\
\    ^E   Up cursor      ^R   Prev page
\    ^X   Down cursor    ^C   Next page
\    ^D   Right cursor   ^G   Del next char
\    ^S   Left cursor    ^H   Del prev char
\    ^L   Restore line   ^M   New line
\    ^T   Erase to EOL   ^Y   Delete line
\    ^U   Exit editor    ^Z   Function
\    ^ZC  Clear text     ^ZH  Help
\    ^ZR  Read file      ^ZW  Write file
\
\ Revision
\ 2016-09-25 es  updated for DX-Forth
\ 2015-06-03 es  specify a filename
\ 2015-12-09 es  join lines with ^G or DEL
\ 2017-01-25 es  replace EXIT THEN with END

forth definitions  decimal

0 \ true for turnkey

( *) dup [if] application [then]

cr .( loading TED Text Editor )

\ Running DX-Forth for CP/M or DOS ?
: CPM? ( -- f )  $111 @ $4683 = ;

[undefined] ZCOUNT [if]
 : ZCOUNT ( a -- a u )  dup -1 0 scan drop over - ;
[then]

[undefined] ZPLACE [if]
 : ZPLACE ( a -- a u )  2dup + >r swap cmove 0 r> c! ;
[then]

[undefined] PACK [if]
 : PACK ( a u a2 -- a2 )  dup >r place r> ;
[then]

[undefined] TOKEN [if]
 : TOKEN ( "name" -- c-addr u )  bl word count ;
[then]

\ Video terminal specific

79 value XMAX  \ #columns - 1
24 value YMAX  \ #rows - 1

\ INSERT-LINE ( -- )  insert blank line at cursor;
\                     remaining rows scroll down
\ DELETE-LINE ( -- )  delete line at cursor;
\                     remaining rows scroll up
\ CLEAR-LINE ( -- )   blank from cursor to end of line

\ pointer operations
: 1+! ( a -- )  1 swap +! ;
: 1-! ( a -- )  -1 swap +! ;
: C@+ ( a -- c )  dup @ c@ swap 1+! ;
: C!+ ( c a -- )  tuck @ c! 1+! ;
: -C@ ( a -- c )  dup 1-! @ c@ ;
: -C! ( c a -- )  dup 1-! @ c! ;

\ max line length
132 constant COLS

0 value YBOT   \ edit bottom row
0 value BUF    \ edit buffer addr
0 value BUFE   \ edit buffer end + 1
0 value TBUF   \ text buffer addr
0 value LINES  \ line count
0 value MEM    \ top of memory
0 value FNAM   \ filename buffer addr
0 value FID    \ file handle

variable COL   \ current column#
variable LIN   \ current line#
variable LADR  \ current line addr
variable LTOP  \ absolute line# at top of screen
variable LPOS  \ current line# relative to top of screen
variable BPOS  \ address of char in edit buffer
variable NXT   \ next free addr in text (contains 0)
variable UPD   \ edit buffer change flag
variable XF    \ quit flag

: UKEY ( -- c )  key upcase ;
: LMAX ( -- n )  lines 1-  0 max ;
: GOXY ( x y -- )  1+ at-xy ;
: CXY  ( -- )  col @  XMAX min  lpos @  goxy ;
: MSG  ( -- )  0 0 at-xy  clear-line ;
: CHGD ( -- )  upd on ;

: CONT ( -- )  xf off
  ."   Press a key to continue "  key drop ;

: .FIL ( -- )  fnam count 20 min type ;

: .POS ( -- )
  13 0 at-xy  lin @ 1+ u.
  22 0 at-xy  col @ 1+ u.  cxy ;

: .HD ( -- )  msg  10 0 at-xy
[ dup ] [if]
  ." Ln       Cl     ^ZH Help   File "
[else]
  ." Ln       Cl     File "
[then]
  .fil  .pos ;

: .ERR ( a u -- )  msg  .fil  space space  type  cont  .hd ;

: SURE? ( a u -- f )
  msg  type  ." Are you sure? "  ukey  [char] Y = ;

: LINE ( -- a u )  ladr @ zcount ;

: .LINE ( -- )  line  XMAX 1+ min  type ;

: .RT ( -- )  \ display string right of cursor
  bpos @  bufe over -  XMAX 1+  bpos @  buf - - min  type ;

: ROOM? ( -- f )  bufe 1- c@ bl = ;

: LINE@ ( -- lin adr )  lin @  ladr @ ;
: LINE! ( lin adr -- )  ladr !  lin ! ;

: GOTOP ( -- )  tbuf ladr !  lin off ;

: CURTOP ( -- )
  gotop  ltop off  col off  lpos off ;

\ clear text, filename, reset cursor
: -TXT ( -- )  tbuf  dup 1- 3 erase ( nulls )
  1+ nxt !  1 to lines  0 fnam c!  curtop ;

: SETUP ( -- )
[ cpm? ] [if]
  $168 c@ 1-  to XMAX
  $169 c@ 1-  dup to YMAX  2- to YBOT
[else]
  get-window ( x1 y1 x2 y2 )
  rot -  dup to YMAX  2- to YBOT
  swap -  to XMAX
[then]
  application  here unused + to mem  pad 80 +
  dup to fnam  80 +  dup to buf  COLS +  dup to bufe
  2+  dup to tbuf  mem u> abort" no space"  -txt ;

: INSC ( c -- )  \ insert char in buf
  bpos @  dup 1+  bufe over - 1+ cmove>
  bpos c!+ ;

: LU ( -- )  \ go up one line in text
  lin 1-!
  ladr  dup 1-!  begin  dup -c@  0= until  1+! ;

: LD ( -- )  \ go down one line in text
  lin 1+!  ladr begin  dup c@+  0= until drop ;

: SETLIN ( n -- )  \ setup for line n
  tbuf  over 0 ?do  zcount + 1+  loop
  ladr !  lin ! ;

: LINES+ ( -- )  lines 1+ to lines ;
: LINES- ( -- )  lines 1- to lines ;

: ?MEM ( -- )
  nxt @  mem u< not if  s" no space" .err  then ;

: REPL ( a u -- )  \ replace line in text
  >r  line  r@ over - >r
  over +  dup r@ +  nxt @ 1+  dup >r
  2 pick - move  2r> +  dup off  nxt !
  r> cmove  ?mem ;

: BSTR ( -- a u )  \ string in buffer
  buf bufe over - -trailing ;

: LEAV ( -- )  \ leave the line we are on
  upd @ if  bstr repl  then  upd off ;

: ENTER ( -- )  \ start changes on this line
  line  buf  dup COLS blank  swap cmove
  buf  col @ +  bpos !  upd off ;

: .ALL ( -- )  \ update screen
  leav  enter
  page  line@
  ltop @  dup setlin
  lmax swap -  YBOT min
  1+ 0 ?do  0 i goxy  .line  ld  loop
  line!  .hd  cxy ;

: SLN ( ltop lin -- )
  >r  0 max  lmax min  dup  r> max  lmax min
  dup setlin  over -  lpos !  ltop !  .all ;

: PU ( -- )  \ ^R page up
  lin @ if
    leav  ltop @  YBOT -  lin @  YBOT -  sln
  then ;

: PD ( -- )  \ ^C page dn
  lin @  lines < if
    leav  ltop @  YBOT +  lin @  YBOT +  sln
  then ;

: SU ( -- )  \ scroll up, new line at bottom
  0 0 goxy  delete-line  0 YBOT  dup lpos !  goxy ;

: SD ( -- )  \ scroll down, new line at top
  0 0 goxy  insert-line  lpos off ;

-? : UP ( -- )  \ ^E line up
  lin @ if
    leav  lu
    lin @  ltop @  1-  = if
      sd  .line  ltop 1-!
    else
      lpos 1-!
    then
    enter  .pos
  then  ;

: DN ( -- )  \ ^X line dn
  lin @  lines < if
    leav  ld
    lin @  ltop @  YBOT 1+  +  = if
      su  .line  ltop 1+!
    else
      lpos 1+!
    then
    enter  .pos
  then ;

: RT ( -- )  \ ^D right
  col @  XMAX <  if
    col 1+!  bpos 1+!  .pos
  then ;

: LFT ( -- )  \ ^S left
  col @  if
    bpos 1-!  col 1-!  .pos
  then ;

: TAB ( -- )  \ ^I tab
  4 col @ over mod - 0 do rt loop ;

: NLN ( -- )  \ ^M new line
  room? if
    13 insc  chgd  leav
    ladr  begin  dup c@+  13 = until  0 over -c!  1+!
    lines+  lin 1+!
    clear-line  col off  enter
    lpos @  YBOT  = if
      su  ltop 1+!
    else
      lpos 1+!  insert-line  cxy
    then
    .all
  then ;

: DEL ( -- )  \ ^G del next
  bpos @  bstr +  < if ( del char)
    bpos @  dup 1+ swap  bufe bl over c!  over - 1+ cmove
    .rt  cxy  chgd
  else ( join line)
    chgd  leav  line  COLS over - >r
    +  dup 1+ zcount  r> min  rot zplace  .all
  then ;

: BS ( -- )  \ ^H del prev
  col @ if  lft  del  then ;

: DLN ( -- )  \ ^Y del line
  lin @  lines < if
    ladr @
    ld  enter  13 ladr -c!
    ladr !
    chgd  leav  enter
    lines-  lin 1-!
    delete-line
    ltop @  YBOT +  lines < if
      line@
      ltop @  YBOT +  setlin  0 YBOT goxy  .line
      line!
    then
    .pos
  then ;

: RST ( -- )  \ ^L restore line
  0 lpos @ goxy  clear-line  .line  cxy
  enter ;

: DEOL ( -- )  \ ^T delete to EOL
  bufe bpos @ - blank
  clear-line  cxy  chgd ;

: CHAROK ( c -- )
  dup bl 126 between  room? and  if
    dup insc  dup emit  col 1+!  .rt
    .pos  chgd
  then  drop ;

: CLR ( -- )  \ ^ZC
  s" *** Clear text: " sure? if  leav  -txt  then
  .all ;

: GETN ( -- a u )  msg  ." Filename: "
  pad dup XMAX 10 - accept ;

: STNAM ( a u -- a u )
  2dup fnam pack  count upper  0 to fid ;

: CLOSF ( -- )  fid ?dup if  close-file drop  then ;

: CLN ( a u -- )  \ ctl chars to spaces
  over + swap ?do  i c@  bl max  i c!  loop ;

: (RD) ( a u -- )
  stnam  r/w open-file throw  to fid
  0 to lines  tbuf  dup off  dup 1+ nxt !
  ( a)  begin
    dup COLS  2dup + mem u> throw
    fid read-line throw ( a u' f )
  while
    2dup cln  +  0 over c! ( null)
    1+  dup nxt !  lines+
  repeat  2drop  nxt @ off ;

: RD ( a u -- )
  s" F" +ext  ( append .F extension if none )
  leav  ['] (rd) catch if
    2drop  s" load/size error" .err  -txt
  then  closf  curtop  .all ;

: (WR) ( a u -- )
  stnam  r/w create-file throw  to fid
  tbuf  begin  ( a)
    dup nxt @ u<
  while
    zcount  2dup fid write-line drop + 1+
  repeat  drop ;

: WR ( a u -- )
  leav  ['] (wr) catch if
    2drop  s" save error" .err
  then  closf  .all ;

: ZRD ( -- )  \ ^ZR read file into text buffer
  getn  rd  .hd ;

: ZWR ( -- )  \ ^ZW write text to file
  getn  wr  .hd ;

: SAV ( -- )
  fnam count dup 0= if  2drop getn  then  wr ;

dup [if]
: HLP ( -- )  \ ^ZH help
  leav  page  14 spaces  ." Help Menu"
  cr  ." ^E   Up cursor      ^R   Prev page"
  cr  ." ^X   Down cursor    ^C   Next page"
  cr  ." ^D   Right cursor   ^G   Del next char"
  cr  ." ^S   Left cursor    ^H   Del prev char"
  cr  ." ^L   Restore line   ^M   New line"
  cr  ." ^T   Erase to EOL   ^Y   Delete line"
  cr  ." ^U   Exit editor    ^Z   Function"
  cr  ." ^ZC  Clear text     ^ZH  Help"
  cr  ." ^ZR  Read file      ^ZW  Write file"
  cr cr  cont  .all ;
[then]

: FN ( -- )  \ ^Z  function
[ dup ] [if]
  msg  ." *** (R)ead, (W)rite, (C)lear, (H)elp ? "  ukey
  [char] H  of  hlp  end  \ ^ZH help
[else]
  msg  ." *** (R)ead, (W)rite, (C)lear ? "  ukey
[then]
  [char] C  of  clr  end  \ ^ZC clear
  [char] R  of  zrd  end  \ ^ZR read
  [char] W  of  zwr  end  \ ^ZW write
  drop  .hd ;

: DONE ( -- )  \ ^U  Quit editor
  msg  ." *** Exit: (S)ave, (Q)uit ? "  ukey
  [char] Q  of  xf on       end
  [char] S  of  sav  xf on  end
  drop  .hd ;

: KMAP ( c1 -- c2 )  \ map in arrow keys etc
[ cpm? ] [if]
  $14F c@ of  5  end  $150 c@ of 24  end
  $151 c@ of  4  end  $152 c@ of 19  end
  127     of  7  end
[else]
  200     of  5  end  208     of 24  end
  205     of  4  end  203     of 19  end
  211     of  7  end
  210     of 22  end  201     of 18  end
  209     of  3  end  199     of 17  end
[then] ;

: CMD ( -- )  key kmap
   3 of  pd   ( ^C) end   4 of  rt   ( ^D) end
   5 of  up   ( ^E) end   7 of  del  ( ^G) end
   8 of  bs   ( ^H) end   9 of  tab  ( ^I) end
  12 of  rst  ( ^L) end  13 of  nln  ( ^M) end
  18 of  pu   ( ^R) end  19 of  lft  ( ^S) end
  20 of  deol ( ^T) end  21 of  done ( ^U) end
  24 of  dn   ( ^X) end  25 of  dln  ( ^Y) end
  26 of  fn   ( ^Z) end
  charok ;

\ Load & edit textfile addr len.  If len=0 don't load.
: (TED) ( line addr len -- )
  setup  page  .hd
  ?dup if
    rd ( line ) 1- dup 7 - swap sln
  else  2drop  then
  enter  xf off  begin  cmd  xf @ until
  0 YMAX at-xy  cr cr ;

( *) [if]

\ Turnkey version
-? : TED ( -- )  1 cmdtail (ted) ;  turnkey ted ted bye

[else]

\ Resident version
-? : TED ( "filename[.F]" -- )  token  dup if  1 -rot
  else  2drop  loadline @  lastfile  then  (ted) ;

\ aka TED EDIT

behead cpm? cmd

[then]

forth definitions application

