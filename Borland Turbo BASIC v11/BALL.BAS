'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
'³				BALL.BAS				     ³
'³                             VERSION 1.0                                   ³
'³									     ³
'³			       Turbo Basic				     ³
'³		(C) Copyright 1987 by Borland International		     ³
'³									     ³
'³ System Requirements:							     ³
'³   - DOS Version 2.0 or later						     ³
'³   - 320K								     ³
'³									     ³
'³   This  program is a simple demonstration of the graphics capabilities    ³
'³ of Turbo Basic.  It displays a "bouncing ball" that uses random numbers   ³
'³ to figure out which directions to bounce off to.                          ³
'³									     ³
'³	In order to run this program do the following:			     ³
'³	  1. Load Turbo Basic by typing TB at the DOS prompt. 		     ³
'³	  2. Load the file BALL.BAS from the Load option of the File	     ³
'³	     pulldown menu.						     ³
'³	  3. Select Run from the Main menu				     ³
'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


'  logic:
'    draw the ball
'    use GET to store pixels into an array
'    set CurrentPosition = OldPosition = StartPoint
'    DO
'      Erase (PUT with XOR) the object at the OldPosition
'      CurrentPosition = CurrentPosition + Increment
'      Display (PUT) the object at the CurrentPosition
'      DELAY a small amount of time
'      OldPosition = CurrentPosition
'    LOOP UNTIL any key is hit
'    end of program
'
DEFINT A-Z
RANDOMIZE TIMER
'
'  dimension the save buffer for the pixels
'
DIM GraphicsBuffer(1000)

SCREEN 1
'
'  set screen min and max based on screen number
'
Max.X = 319 : Min.X = 0
Max.Y = 199 : Min.Y = 0
'
'  set size of ball
'
SizeOfBall = 15
'
'  set up the starting center position for the ball
'
Start.X = 15
Start.Y = 15
'
'  build the ball on the screen
'
CIRCLE (Start.X,Start.Y),SizeOfBall,2
PAINT (Start.X,Start.Y),1,2
'
'  store the pixels in a graphics save buffer
'
GET (Start.X-SizeOfBall,Start.Y-SizeOfBall)-(Start.X+SizeOfBall,Start.Y+SizeOfBall),GraphicsBuffer
'
'  initialize the position of the ball
'
CurrentPosition.X = OldPosition.X = Start.X
CurrentPosition.Y = OldPosition.Y = Start.Y
'
'  set current X direction to Right, Y direction to Down
'
Direction.X = 1
Direction.Y = 1

DO
  '
  '  erase previous ball by doing a PUT at the old position
  '
  PUT (OldPosition.X,OldPosition.Y),GraphicsBuffer
  '
  '  calculate new X position,
  '  if at right edge set direction to Left
  '  if at left edge set direction to right
  '  if ball hits an edge, make a sound
  '
  Increment.X = RND*8
  IF CurrentPosition.X+Increment.X+30 > Max.X THEN Direction.X = -1 : sound 200+rnd*250,.5
  IF CurrentPosition.X-Increment.X < Min.Y THEN Direction.X = 1 : sound 200+rnd*300,.5
  CurrentPosition.X = CurrentPosition.X + (Increment.X*Direction.X)
  '
  '  calculate new Y position,
  '  if at bottom edge set direction to the up
  '  if at top edge set direction to the down
  '  if ball hits an edge, make a sound
  '
  Increment.Y = RND*8
  IF CurrentPosition.Y+Increment.Y+30 > Max.Y THEN Direction.Y = -1 : sound 200+rnd*275,.5
  IF CurrentPosition.Y-Increment.Y < Min.Y THEN Direction.Y = 1 : sound 200+rnd*325,.5
  CurrentPosition.Y = CurrentPosition.Y + (Increment.Y*Direction.Y)
  '
  '  display the ball at the new position
  '
  PUT (CurrentPosition.X,CurrentPosition.Y),GraphicsBuffer
  '
  '  wait some time for smoother animation
  '
  DELAY .03
  '
  '  save current position so the ball can be erased before next move
  '
  OldPosition.X = CurrentPosition.X
  OldPosition.Y = CurrentPosition.Y
  '
  '  keep looping until any key is hit
  '
LOOP UNTIL INSTAT
END
