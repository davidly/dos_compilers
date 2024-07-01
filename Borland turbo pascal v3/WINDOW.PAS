program TestWindow;
{$C-}
{
              WINDOW DEMONSTRATION PROGRAM  Version 1.00A

       This program demonstrates the use of windows on the IBM PC
       and true compatibles.

       PSEUDO CODE
       1.  MakeWindow        - draws window boxes on the screen
       2.  repeat
             UpdateWindow 1  - scrolls the window contents up or
                               down for each window.
             UpdateWindow 2
             UpdateWindow 3
           until a key is pressed
       3.  Reset to full screen window

       INSTRUCTIONS
       1.  Compile this program using the TURBO.COM compiler.
       2.  Type any key to exit the program.
}


const  Windows    = 3;
       Wtab       : array [1..Windows,1..5] of Integer  { X0,Y0,X1,Y1,LineNo }
                  = ( ( 5,  2,  35, 11,  1),
                      (45,  2,  75, 11,  1),
                      ( 5, 15,  75, 23,  1) );
       Up         = true;
       Down       = false;

type   MaxString  = string [255];

var    I          : Integer;
       Ch         : char;


procedure Frame(UpperLeftX, UpperLeftY, LowerRightX, LowerRightY: Integer);
var  I : Integer;

begin {Frame}
  GotoXY(UpperLeftX, UpperLeftY);
  Write(chr(218));
  for I := (UpperLeftX + 1) to (LowerRightX - 1) do
  begin
    Write(chr(196));
  end;
  Write(chr(191));
  for I := (UpperLeftY + 1) to (LowerRightY - 1) do
  begin
    GotoXY(UpperLeftX , I);  Write(chr(179));
    GotoXY(LowerRightX, I);  Write(chr(179));
  end;
  GotoXY(UpperLeftX, LowerRightY);
  Write(chr(192));
  for I := (UpperLeftX + 1) to (LowerRightX - 1) do
  begin
    Write(chr(196));
  end;
  Write(chr(217));
end; {Frame}


procedure MakeScreen;

begin
  ClrScr;
  GotoXY(15,25);
  Write('TURBO PASCAL Window Demo  -  Press any key to stop');
  for I := 1 to Windows do
  begin
    Frame(Wtab[I,1] - 1, Wtab[I,2] - 1, Wtab[I,3] + 1, Wtab[I,4] + 1);
  end;
end; {MakeScreen}


function RandomStr(Len: Integer): MaxString;
var   S: MaxString;
      I: integer;

begin
  S[0] := Chr(Len);
  for Len := 1 to Len do
  begin
    repeat
      I := Random(255)
    until not (Chr(I) in[^@,^G,^H,^J,^M]);
    S[Len] := Chr(I);
  end;
  RandomStr := S;
end;  {RandomStr}


procedure SelectWindow(Win: Integer);

begin
  Window(Wtab[Win,1], Wtab[Win,2], Wtab[Win,3], Wtab[Win,4])
end; {SelectWindow}


procedure UpdateWindow (Win,StringLen: integer;Scroll: boolean);

begin
  LowVideo;
  SelectWindow(Win);
  GotoXY(1,1);
  if Scroll then
  begin
    DelLine;
    GotoXY(1, Wtab[Win,4] - Wtab[Win,2] + 1);
  end
  else
    InsLine;
  Write('Line ', Wtab[Win,5]:5,' ',chr(219),' ',RandomStr(StringLen));
  Wtab[Win,5] := Succ(Wtab[Win,5]);
  NormVideo;
end; {UpdateWindow}


procedure DrawWindows;
begin
  repeat
    UpdateWindow(1,15,Up);
    UpdateWindow(2,15,Up);
    UpdateWindow(3,55,Down);
  until KeyPressed;
  Window(1,1,80,25);
  GotoXY(1,24);
end; {DrawWindows}


begin { Program body }
  MakeScreen;
  DrawWindows;
end.
