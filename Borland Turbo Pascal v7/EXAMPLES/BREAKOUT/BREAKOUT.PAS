{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Breakout;

{

  This is a version of the classic arcade game, Breakout.

    SCREEN.PAS
    COUNT.PAS
    BRICKS.PAS
    BOUNDS.PAS
    WALLS.PAS
    BREAKOUT.PAS

  To build an executable file, compile from the command line with:

    tpc /m breakout

  or load BREAKOUT.PAS into the integrated development
  environment and press F9.

  When testing the program, you may want to force the paddle to
  follow the ball, so you'll never miss. The program contains
  conditional compilation directives to produce this version, and
  you can build it from the command line with:

    tpc /DTest breakout

  or load BREAKOUT.PAS into the integrated development
  environment, select Alt-O/C/Alt-C, type 'Test' (without the quotes,
  of course) followed by the Enter key, then select Alt-C/B to
  rebuild the executable file.
}

uses Screen, Count, Bricks, Bounds, Walls, Crt, Dos;

var
  ss        : SaveScreen;
  w         : Wall;
  b         : Ball;
  p         : Paddle;
  Speed     : LimitCounter;
  Left      : LeftBound;
  Top       : UpperBound;
  Right     : RightBound;
  Bottom    : LowerBound;
  Obstacles : ObstacleList;
  PaddleMsg,
  SpeedMsg,
  StartMsg,
  QuitMsg,
  PauseMsg1,
  PauseMsg2,
  TypeMsg   : TextString;
  Score     : Counter;
  Highest   : Counter;
  Balls     : DownCounter;
  X         : Integer;
  Finished  : Boolean;
  FirstGame : Boolean;
  TypeInc,
  ch        : Char;

procedure Startup;
begin
  { First set up the screen and the cursor }
  ss.Init;
  TextBackground(BLACK);
  ClrScr;

  { Create the boundaries of the playfield }
  Left.Init(0, 0, 27, False);
  Top.Init(0, 0, 82, False);
  Right.Init(81, 0, 27, False);
  Bottom.Init(0, 24, 82, True);

  { Initialize the score displays }
  Score.Init(0, 65, 24, 'Score', 15);
  Score.Show;
  Highest.Init(0, 60, 25, 'High Score', 14);
  Highest.Show;

  { Set up the various menu messages }
  PauseMsg1.Init(31, 18, 'Paused.  Press any', 15);
  PauseMsg2.Init(31, 19, ' key to continue.', 15);
  SpeedMsg.Init(5, 23, #24 + #25  + ' to change speed', 14);
  StartMsg.Init(5, 24, #17 + #196 + #217 + ' to begin game', 14);
  PaddleMsg.Init(5, 24, #27 + #26 + ' to move paddle', 14);
  QuitMsg.Init(5, 25, 'ESC to quit', 14);
  QuitMsg.Show;

  { Set up the information messages }
  Balls.Init(5, 40, 24, -1, 'Balls', 15);
  Balls.Show;
  Speed.Init(1, 40, 25, 1, 10, 'Speed', 14);
  Speed.Show;

  { Build the wall }
  w.Init(1, 1, 16, 10);
  w.Show;

  { Need to initialize these, even though we're going to move them later }
  b.Init(10, 22, 1, -1, YELLOW);
  p.Init(8, 23, WHITE);

  { Put the various obstacles into a list.  We don't really need
    to do this, but it makes changing things around much easier }
  Obstacles.Init;
  Obstacles.Append(@p);
  Obstacles.Append(@w);
  Obstacles.Append(@Left);
  Obstacles.Append(@Top);
  Obstacles.Append(@Right);
  Obstacles.Append(@Bottom);

  TypeMsg.Init(22, 12, 'Increase typematic rate? (y/n) ', WHITE);
  TypeMsg.Show;
  repeat
    TypeInc := UpCase(ReadKey);
  until (TypeInc = 'Y') or (TypeInc = 'N');
  TypeMsg.Hide;

  if TypeInc = 'Y' then
    ss.Speedup;

  ss.SetCursor($2000);
  Randomize;
  FirstGame := True;
end;

procedure NewGame;
begin
  Balls.Reset;
  Score.Reset;
  if not FirstGame then
    w.Reset;
  X := Random(78) + 3;
  b.MoveTo(X, 22);
  p.MoveTo(X-2, 23);
  b.Show;
  p.Show;
  Balls.Decrement;
  FirstGame := False;
end;

{ This procedure handles keystrokes between games.
  It returns False if the user presses ESC, otherwise it returns True. }
function MainMenu : Boolean;
var
  Done : Boolean;
begin
  MainMenu := True;
  Done := False;
  SpeedMsg.Show;
  StartMsg.Show;
  while not Done do
  begin
    ch := ReadKey;
    case ch of
      Chr(27) :
        begin
          MainMenu := False;
          Done := True;
        end;
      #13 : Done := True;
      #0  :
        begin
          ch := ReadKey;
          if Ord(ch) = 72 then
            Speed.Increment
          else if Ord(ch) = 80 then
            Speed.Decrement;
        end;
      end;
  end;
  SpeedMsg.Hide;
  StartMsg.Hide;
end;

{ This procedure handles keystrokes while the game is in progress }
procedure ProcessKeyStroke;

{ Pause the game }
procedure Pause;
begin
  PauseMsg1.Show;
  PauseMsg2.Show;
  ch := ReadKey;
  if KeyPressed then
    ch := ReadKey;  { Swallow extended keystrokes }
  PauseMsg1.Hide;
  PauseMsg2.Hide;
  b.Show;
end;

begin
  ch := ReadKey;
  case ch of
    Chr(27) : Finished := True;
    Chr(0)    :
      begin
        ch := ReadKey;
{$IFNDEF Test}
        case Ord(ch) of
          75: p.MoveTo(p.GetX - 1, p.GetY);  { Left Arrow }
          77: p.MoveTo(p.GetX + 1, p.GetY);  { Right Arrow }
        else
          Pause;
        end;
{$ELSE}
        Pause;
{$ENDIF}
      end
    else
      Pause;
  end;
end;

{ This procedure checks for collisions with any of the obstacles
  and updates the screen accordingly. }
procedure Update;
var
  Offset : Integer;
begin
  if Obstacles.CheckCollisions(b, Score) then
  begin
    b.MoveY;
    p.MoveTo(b.GetX - 2, p.GetY);
    sound(150);
    Delay(300);
    nosound;
    Balls.Decrement;
    while KeyPressed do
      ch := ReadKey;
  end;

  b.MoveX;
  b.MoveY;

{$IFDEF Test}
  p.MoveTo(b.NextX -2, p.GetY);
{$ENDIF}
end;

{ This procedure cleans up when we're exiting from the program }
procedure ShutDown;
begin
 b.Hide;
 Obstacles.Hide;
 Balls.Hide;
 Score.Hide;

 Obstacles.Done;

 ss.Restore;
 if TypeInc = 'Y' then
   ss.Slowdown;
 ClrScr;
end;

{ This procedure plays a game.  The main loop allows up to ten keystrokes,
 then moves the ball and checks for collisions }
procedure Play;
var
 KeyLoops : Integer;
begin
 NewGame;
{$IFNDEF Test}
  PaddleMsg.Show;
{$ENDIF}
  Finished := False;
  KeyLoops := 0;
  repeat
    if KeyPressed then
      ProcessKeyStroke;
    Inc(KeyLoops);
    if (KeyLoops = 10) and not Finished then
    begin
      KeyLoops := 0;
      UpDate;
    end;
    Delay(12 - Speed.GetValue);
  until Finished or Balls.Last;
  PaddleMsg.Hide;
end;

begin
  Startup;
  while MainMenu do
  begin
    Play;
    Balls.Reset;
    b.Hide;
    p.Hide;
    if Score.GetValue > Highest.GetValue then
      Highest.SetValue(Score.GetValue);
  end;
  ShutDown;
end.
