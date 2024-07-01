'			   TBWINDO
'		      MULTI-LEVEL WINDOWS
'			FOR TURBO BASIC
'			  Version 3.0
'
'PURPOSE:
'  This utility creates  incredibly quick multi-level windows
'  in Turbo Basic programs for IBM PC/XT/AT compatibles.
'
'TEST DRIVE:
'  Compile and run the tutoring program TBDEMO30.BAS to get a
'  feel for features and speed.
'
'
'FILES:
'  TBWINDO.INC    - Turbo Basic window include file
'  TBMENU.INC     - Menu include file
'  QPRINT.BIN     - Quick print inline subroutine
'  QPRINTC.BIN    - Quick print between columns
'  QATTR.BIN      - Re-attribute an area of the screen
'  QFILL.BIN      - Fill an area of the screen with a
'  		    specified character and attribute
'  QSAVE.BIN      - Save portion of screen
'  QREST.BIN      - Restore portion of screen
'  RECOLOR.BIN    - Screen area recoloring
'  TBDEMO30.BAS   - Demonstration program source code
'
'  Assembly  language  source  code  for  all  BIN  files  is
'  included for  all those  interested.  Any  Suggestions for
'  improvements to the code would be appreciated, as I do not
'  profess to be good at Assembly language.
'
'USING TBWINDO
'  Include the TBWINDO.INC  program in your  program with the
'  following statement:
'
'	  $INCLUDE "TBWINDO.INC"
'
'  Set MW%  variable equal to  the maximum  number of windows
'  you will have open at any one time.
'
'  Set the  ScrnArray variable  equal to  the estimated total
'  memory required to save your screens.  If you expreience a
'  subscript out of range error in the include file, increase
'  this variable.  As  a rough rule of  thumb, start out with
'  the variable equal to 250  times the maximum windows (mw%)
'  variable.
'
'  You invoke the routines by means  of a CALL with a list of
'  parameters, rather than a GOSUB.
'
'  Using the MAKEWINDOW procedure:
'
'	  CALL
'	  MAKEWINDOW(ROW%,COL%,ROWS%,COLS%,ATTR%,BRDRSEL%,SHADOW%,ZO
'	  OM%)
'
'  Where: ROW - the screen row of the upper left hand corner
'	       of your desired window.  Value should be
'	       between 2 and 23 (for reasons explained
'	       below).  WARNING - the subroutine does not
'	       check for proper values. You must check these
'	       yourself or accept the consequences.
'
'	 COL -  the screen column of the upper left hand
'	       corner.  Value should be between 2 and 79.
'
'	 ROWS - the number of rows long the window should be.
'
'	 COLS - the number of columns wide the window should
'	        be.
'
'	 ATTR - the attribute of the window colors.
'
'	 BRDRSEL - the border you desire  around the window.
'		   Valid selections in this release are:
'
'	      0 - No Frame (just a border of BACKground
'		  color.)
'	      1 - Single Line Frame
'	      2 - Double Line Frame
'	      3 - Single Horizontal Line, Double Vertical
'		  Line
'	      4 - Single Vertical Line, Double Horizontal
'		  Line
'
'	 SHADOW - Another "switch" to indicate  if the window
'		  should have a black "shadow" under it offset
'		  down.  This gives a three-dimensional effect
'		  that seems to "raise" the window away from the
'		  screen.  A value of 1 indicates a shadow is
'		  desired on the left side, a value of 2
'		  indicates the right side, while a value of 0
'		  means no shadow.
'
'	 ZOOM - A "switch" used to indicate to the subroutine
'	        if the window should "grow" from a small box
'	        at the midpoints of the coordinates to full
'	        size. A value of 1 indicates the window should
'	        grow. A value of 0 indicates it should not.
'
'
'
'  using the TITLEWINDOW procedure:
'
'	  CALL TITLEWINDOW(LOC%,TITLE$)
'
'  Where: LOC - Indicates where the title should be placed.
'	       Valid selections are:
'
'	       1 - Top left hand corner
'	       2 - Top center
'	       3 - Top right hand corner
'	       4 - Lower left hand corner
'	       5 - Lower center
'	       6 - Lower right hand corner
'
'	 TITLE - The string data you would like printed.
'
'  NOTE:  The TITLEWINDOW procedure uses the coordinates from
'	 the most recent use of MAKEWINDOW.  Use this
'	 procedure only after a call has been made to
'	 MAKEWINDOW.
'
'
'  Using the RemoveWindow procedure:
'
'	  CALL REMOVEWINDOW
'
'  There  are no  parameters passed  to this  procedure.  The
'  window created by  the last call  to MakeWindow is removed
'  from the screen.
'
'  Using the ClearWindow procedure:
'
'	  CALL CLEARWINDOW
'
'  There  are  no  parameters pass  to  this  procedure.  The
'  window created by  the last call  to MakeWindow is cleared
'  inside the frame.
'
'  Using the PrtWindow procedure:
'
'	  CALL PRTWINDOW(ROW%,COL%,STRDAT%)
'
'  Where:  ROW - Is the row within the window you want to
'	        print on.
'
'	  COL - Is the column within the  window where you
'	        want printing to start.
'
'	  NOTE:  The ROW and COL  coordinates are relative to the
'		 current window.  Row 1 Col 1 refers to the first
'		 character position inside the frame in the upper
'		 left corner.  No parameter checking is done so if
'		 the string data exceeds the  width of the window it
'		 will spill out the right side.
'
'	  STRDAT - Is the string  data you want printed inside
'		   the window.
'
'
'  Using the PrtCWindow procedure:
'
'	  CALL PRTCWINDOW(ROW%,STRDAT$)
'
'  Where:  ROW - Is the row  within  the window you to have
'	        your string data centered on.
'
'	  STRDAT - Is the string data  you want printed within
'		  the window.
'
'   NOTE:  This procedure uses the current window and will
'	  attempt to center the string data between the left
'	  border and the right border.  No parameter checking
'	  is done so if the string data exceeds the width of
'	  the window, it will spill out the sides.
'
'  Using the FNATTR% function:
'
'	  FNATTR%(FORE%,BACK%)
'
'  Where: FORE - is the foreground color.  Any Turbo Basic
'	        color number is valid.
'
'	 BACK - is the backgound color.  Any Turbo Basic
'	        background color is valid.
'
'  FNATTR% returns the attribute of the colors specified.
'
'
'  Using the RECOLOR procedure:
'
'	  CALL RECOLOR(OLDATTR%,NEWATTR%,SNOCHK%)
'
'  Where: OLDATTR - Is the attribute of the areas on the
'		   screen you wish to change.
'
'	 NEWATTR - Is the attribute of the color you want.
'
'	 X% = SCREEN(1,1,1)  ' RETURNS CURRENT SCREEN
'			     ' ATTRIBUTE
'	 CALL RECOLOR(X%,FNATTR%(14,4))
'
'	  This will recolor everything on the screen that
'	  has the same attribute a the upper left corner of
'	  the screen to a foreground of 14 and a background
'	  of 4.
'
'  Using the MAKEMENU procedure:
'
'	  CALL MAKEMENU
'
'  You  must  define  several variable  before  you  call the
'  MakeMenu procedure.  First define the selections available
'  to the user in a string  array named item$().  If you want
'  a title  on your menu  assign it to  the variable mtitle$.
'  Assign the  total selections  available to  itemcount% and
'  the starting selection number to startpos%.  The remaining
'  information  required  is  almost  identical  to  defining
'  window in the MakeWindow procedure.
'
'  Where: MROW - the screen row of the upper left hand corner
'	        of your desired menu.  Value should be
'	        between 2 and 23 (for reasons explained
'	        below).  WARNING - the subroutine does not
'	        check  for  proper  values.  You  must check
'	        these yourself or accept the consequences.
'
'        MCOL -  the screen column of the upper left hand
'	        corner.  Value should be between 2 and 79.
'
'      MWIDTH -  The  width of the menu.   Be sure this value
'	        is greater than  the longest string assigned
'	        to a selection.
'
'       MATTR -  the attribute of the menu colors.
'
'     MHIATTR -  the attribute of the moving selection bar.
'
'    MBRDRSEL -  the border you  desire around the menu. (See
'	        above)
'
'     MSHADOW -  Switch to indicate if the menu should have a
'	        shadow.
'
'       MZOOM -  Switch to indicate if the menu should grow.
'
'  When a selection has be made in the MakeMenu procedure the
'  item  number selected  will  be assigned  to  the variable
'  curntpos%.  You can now use this number to direct the flow
'  of you  main program.  Please  see the source  code of the
'  demo program for a better understanding.
'
'  All  of  the above  variables  with the  exception  of the
'  string variables  must either  be   declared  globally  as
'  integers by  means of  a DEFINT  statement early   in  the
'  program;  or  must  have  the  specific integer identifier
'  (%)  attached  wherever  they   appear in the program. The
'  BASIC  compiler  is picky  about  this; so   be   sure  to
'  verify that the type assignment is correct.
'
'  TBWINDO  requires no  special  handling when  it  comes to
'  compiling your program. Just make certain that all of
'  your variables passing parameters to the TBWINDO
'  subroutine  are identified  as integers,  and you  will be
'  able to  proceed with  the compile  operation as  with any
'  other program.
'
'
'  ACKNOWLEDGEMENTS
'
'  I  would  like   to  express  my   thanks  to  Dave  Evers
'  (BASWIN22),   Tom   Hanlin   (ADVBAS33)   and   Jim  LeMay
'  (WINDOW33).
'
'  These utilities  are released  into the  public domain for
'  anyone to  use as they  see fit however,  anyone who feels
'  inspired and would like to  contribute to my printer paper
'  and computer supplies fund may feel free to do so.
'
'  Rick Fothergill
'  141 Oak Hill Road
'  Pittsfield, MA 01201
'  (413) 442-2456
'
'  GEnie Address: R.FOTHERGILL
'     Compuserve: 76210,443
'
'
'			   TBWINDO QUICK REFERENCE
'
'	  MakeWindow(Row%,Col%,Rows%,Cols%,Attr%,BrdrSel%,Shadow%,Zoom%)
'
'			   TitleWindow(Loc%,Title$)
'
'				 RemoveWindow
'
'				 ClearWindow
'
'				   MakeMenu
'
'			 PrtWindow(Row%,Col%,StrDat$)
'
'			   PrtCWindow(Row%,StrDat$)
'
'			     FNAttr%(Fore%,Back%)
'
'		    Qsave(Row%,Col%,Rows%,Cols%,Scrn%(??))
'
'		    QRest(Row%,Col%,Rows%,Cols%,Scrn%(??))
'
'		      ReColor(OldAttr%,NewAttr%,SnoChk%)
'
'		       Qprint(Row%,Col%,StrDat$,Attr%)
'
'	        QprintC(Row%,ColLeft%,ColRight%,StrDat$,Attr%)
'
'		   QFill(Row%,Col%,Rows%,Cols%,Char%,Attr%)
'
'		      QAttr(Row%,Col%,Rows%,Cols%,Attr%)
'
'		  QBox(Row%,Col%,Rows%,Cols%,Attr%,BrdrSel%)
'
'


'Demonstration of TBWINDO
$INCLUDE "TBWINDO.INC"
$INCLUDE "TBMENU.INC"
key off
out &H3d9,1
call qfill(1,1,25,80,32,fnattr%(7,1))
for m% = 1 to 3
  for i% = 1 to 29
    j% = rnd(1)*69
    k% = rnd(1)*19
    f% = rnd(1)*14
    b% = rnd(1)*6
    call makewindow(k%+1,j%+1,5,11,fnattr%(f%+1,b%+1),2,0,0)
    call prtcwindow(2,"WINDOW")
  next
  if (m = 3) then delay 3 else delay 1
  for x = LI to 1 step -1
  call removewindow
  next
next
'Put up opening screen
'4 windows of different colors and a Title Window
call makewindow(4,15,10,30,fnattr%(4,3),4,1,1)
call makewindow(3,36,13,40,fnattr%(15,2),3,1,1)
call makewindow(9,10,13,40,fnattr%(0,5),2,1,1)
call makewindow(12,42,11,36,fnattr%(3,4),1,1,1)

call makewindow(3,5,7,40,fnattr%(0,7),2,1,1)

call prtcwindow(3,"Presenting...")
delay 4
call makewindow(8,20,7,40,fnattr%(0,7),2,1,1)
call prtcwindow(1,"T B W I N D O")
call prtcwindow(2,"2.0")
call prtcwindow(4,"Windowing Routines for the")
call prtcwindow(5,"Borland Turbo BASIC Compiler")

delay 3
call makewindow(17,55,7,24,fnattr%(0,6),1,1,1)
call prtwindow(1,2,"By:")
call prtcwindow(3,"Rick Fothergill")
call prtcwindow(4,"141 Oak Hill Road")
call prtcwindow(5,"Pittsfield, MA 01201")


delay 4

call makewindow(5,5,10,32,fnattr%(15,1),2,1,0)

call prtcwindow(1,"Including ...")
call prtcwindow(3,"*** Window Tools ***")
call prtcwindow(5,"A collection of routines")
call prtcwindow(6,"for integration into your")
call prtcwindow(7,"own programs.")

delay 4
call makewindow(8,25,10,32,fnattr%(15,1),2,1,0)

call prtwindow(1,2," * * * * * * * * * * * * * ")
call prtwindow(3,2,"Stand by for a guided tour")
call prtwindow(5,2,"through the many facets of")
call prtwindow(7,2,"this exciting program.")
delay 2
for x = 1 to 9
call removewindow
next
call makewindow(9,16,8,52,fnattr%(0,7),2,0,0)


call prtwindow(1,2,"The basic  purpose of TBWINDO is to provide")
call prtwindow(2,2,"the  fundamental  routines for  implementing")
call prtwindow(3,2,"simple 'windowing' into your Turbo BASIC pro-")
call prtwindow(4,2,"grams.   With  just a few simple statements,")
call prtwindow(5,2,"you can 'pop-up'  a colored  window onto the")
call prtwindow(6,2,"screen; just like this ...")

delay 3
call clearwindow

call prtwindow(2,2,"The window can be a solid panel of any of")
call prtwindow(4,2,"the BASIC background colors; such as ...")

delay 4

call makewindow(2,2,7,35,fnattr%(1,2),0,0,0)

delay 3
call removewindow
call clearwindow

call prtwindow(2,2,"or it can be surrounded by a 'frame' in any")
call prtwindow(4,2,"of five styles...")

delay 3

call makewindow(5,5,8,35,fnattr%(9,5),1,0,0)
call titlewindow(1,"[ Frame Style 1 ]")
call makewindow(8,8,8,35,fnattr%(12,3),2,0,0)
call titlewindow(2,"[ Frame Style 2 ]")
call makewindow(11,11,8,35,fnattr%(15,4),3,0,0)
call titlewindow(3,"[ Frame Style 3 ]")
call makewindow(14,14,8,35,fnattr%(0,6),4,0,0)
call titlewindow(1,"[ Frame Style 4 ]")
call makewindow(17,17,8,35,fnattr%(0,2),5,0,0)
call titlewindow(3,"[ Frame Style 5 ]")

delay 4
for x = 1 to 5
call removewindow
next
call clearwindow

call prtwindow(1,2,"The frame itself can be in any one of the")
call prtwindow(2,2,"BASIC foreground colors. It can even blink")
call prtwindow(3,2,"if you want...")

delay 3
for i%=0 to 15
  label$="[ Color:"+str$(i%)+" ]"
  j%=rnd(1)*50
  k%=rnd(1)*12
  call makewindow(k%+1,j%+1,7,25,fnattr%(i%,5),4,2,0)
  call titlewindow(2,label$)
  delay .5
next
call makewindow(7,20,7,25,fnattr%(31,5),4,2,0)
call titlewindow(2,"[ Color: 31 ]")

delay 4
for x = 1 to 17
call removewindow
next

call clearwindow
call prtcwindow(5,"The window itself can be presented in many")
call prtcwindow(6,"different ways. It can be flat...")

delay 3

call makewindow(1,2,11,30,fnattr%(15,4),1,0,0)

delay 3
call removewindow
call clearwindow
call prtcwindow(5,"or it can have a black shadow underneath; giving")
call prtcwindow(6,"a three-dimensional effect...")
delay 3
call makewindow(5,5,10,30,fnattr%(14,5),2,1,0)
call qprintc(7,5,35,"Left Shadow",fnattr%(15,5))
delay 2
call makewindow(5,40,10,30,fnattr%(0,2),2,2,0)
call qprintc(7,40,70,"Right Shadow",fnattr%(15,2))
delay 2
call removewindow
call removewindow
call clearwindow
call prtcwindow(2,"Titles may be placed in any")
call prtcwindow(3,"of six different locations,")
call prtcwindow(4,"or any combination.")
delay 2
call makewindow(2,5,10,70,fnattr%(15,5),2,1,0)
for x% = 1 to 6
  title$ = "[ Location"+str$(x%)+" ]"
  call titlewindow(x%,title$)
  delay 1
next
delay 3
call removewindow
call clearwindow
call prtcwindow(3,"Windows can be zoomed")
call prtcwindow(4,"onto the screen.")
delay 2
call makewindow(2,2,15,60,fnattr%(0,2),2,0,1)
delay 2
call makewindow(13,10,10,60,fnattr%(1,3),3,0,1)
delay 2
call makewindow(7,33,10,45,fnattr%(14,5),1,0,1)
delay 2
call makewindow(7,10,12,63,fnattr%(15,4),2,1,1)
call prtcwindow(5,"W O W !!!")
delay 3
for x = 1 to 4
call removewindow
next
call clearwindow
call prtwindow(1,2,"Once you have your window on the screen, simply")
call prtwindow(2,2,"use calls to PrtWindow or PrtCWindow to put text")
call prtwindow(3,2,"in them.  A call to ClearWindow will erase the")
call prtwindow(4,2,"contents of the window ...   ")
delay 3


call clearwindow
call prtwindow(1,2,"Just as easily as you can create the window!")
call prtwindow(2,2,"In fact, all of the commands of TBWINDO are")
call prtwindow(3,2,"very  easy to use.  Here is a call to create")
call prtwindow(4,2,"this window ...")
call prtwindow(5,2,"   CALL MAKEWINDOW(8,14,8,52,fnattr%(0,7),2,0,1)")
delay 5

call clearwindow

call prtwindow(1,2,"Each window is stored as a result of a call to")
call prtwindow(2,2,"MakeWindow.  To restore the screen to it's")
call prtwindow(3,2,"original contents, simply call RemoveWindow.")
call prtwindow(4,2,"Here is a good example . . .")
delay 5
call makewindow(3,5,15,45,fnattr%(0,2),4,1,1)
call prtcwindow(6,"This is the first level ...")
delay 2
call makewindow(6,29,17,50,fnattr%(15,4),4,1,1)
call prtcwindow(6,"This is the second level ...")
delay 2
call makewindow(9,22,15,35,fnattr%(0,3),4,1,1)
call prtcwindow(7,"This is the third level ...")
delay 2
call prtcwindow(7,"Now to go back ...           ")
delay 1
call removewindow
delay 1
call removewindow
delay 1
call removewindow
delay 2
call clearwindow
call prtwindow(2,2,"Next is a demonstration of the MakeMenu")
call prtwindow(3,2,"procedure which will create a point and")
call prtwindow(4,2,"shoot type menu.")
delay 3
call removewindow

item$(1) = "Pop Screen 1"
item$(2) = "Pop Screen 2"
item$(3) = "Pop Screen 3"
item$(4) = "Exit"
itemcount% = 4
mtitle$ = "[ MENU DEMO ]"
mrow% = 5
mcol% = 20
mwidth% = 40
mattr% = fnattr%(15,1)
mhiattr% = fnattr%(0,7)
mbrdrsel% = 2
mshadow% = 2
mzoom% = 0
startpos% = 1

restart1:
out &H03d9,7
call qfill(1,1,25,80,32,fnattr%(0,7))

call makemenu

select case curntpos%
  case 1 'screen 1
    gosub popscreen1
    goto restart1
  case 2 ' screen 2
    gosub popscreen2
    goto restart1
  case 3 ' screen 3
    gosub popscreen3
    goto restart1
  case else
   out &H03d9,1
   call qfill(1,1,25,80,32,fnattr%(15,1))
   color 0,7
   call makewindow(9,16,8,52,fnattr%(0,7),2,0,0)
   locate 10,18:print "Please see the source code and documentation"
   locate 11,18:print "for how to create and use menu windows in"
   locate 12,18:print "your programs...."
   delay 5
end select


call makewindow(4,15,10,30,fnattr%(4,3),4,1,1)
call makewindow(3,36,13,40,fnattr%(15,2),3,1,1)
call makewindow(9,10,13,40,fnattr%(0,5),2,1,1)
call makewindow(12,42,11,36,fnattr%(3,4),1,1,1)

call makewindow(9,16,8,52,fnattr%(0,7),2,1,1)
call prtwindow(2,2,"The basic routines in the  TBWINDO  package")
call prtwindow(3,2,"give you all you  need to create some power-")
call prtwindow(4,2,"ful 'toolbox' modules to integrate into your")
call prtwindow(5,2,"programs.")
delay 5
out &H3d9,0
end

popscreen1:
out &H03d9 ,6
call qfill(1,1,25,80,32,fnattr%(7,6))
call makewindow(8,10,7,60,fnattr(0,2),2,1,1)
call titlewindow(2,"[ SELECTION 1 ]")
call qprintc(10,10,70,"This is selection no. 1",fnattr(14,2))
call qprintc(11,10,70,"Press enter to return to main menu...",fnattr%(14,2))
while not instat
wend
a$=inkey$
call removewindow
return

popscreen2:
out &H03d9 ,3
call qfill(1,1,25,80,32,fnattr%(7,3))
call makewindow(8,10,7,60,fnattr(15,1),2,1,1)
call titlewindow(2,"[ SELECTION 2 ]")
call qprintc(10,10,70,"This is selection no. 2",fnattr(15,1))
call qprintc(11,10,70,"Press enter to return to main menu...",fnattr%(15,1))
while not instat
wend
a$=inkey$
call removewindow
return

popscreen3:
out &H03d9 ,5
call qfill(1,1,25,80,32,fnattr%(7,5))
call makewindow(8,10,7,60,fnattr(0,7),2,1,1)
call titlewindow(2,"[ SELECTION 3 ]")
call qprintc(10,10,70,"This is selection no. 3",fnattr(0,7))
call qprintc(11,10,70,"Press enter to return to main menu...",fnattr%(0,7))
while not instat
wend
a$=inkey$
call removewindow
return
