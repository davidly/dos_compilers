{$C-}
program PlayWithTurtle;
{
                TURTLEGRAPHICS DEMO PROGRAM  Version 1.00A

        This programs demonstrates the use of Turtlegraphics with
        TURBO PASCAL Version 3.0.  NOTE:  You must have a color
        graphics adapter to use this program.

        PSEUDO CODE

        1.  Initialize program variables.
        2.  Play with the turtle routines.
            a.  Start with medium resolution graphics.
            b.  Read a character and manipulate the turtle until
                the user pressed <ESC> or ^C.
        3.  Reset screen to text mode and quit.


        Here is a list of the commands that this program uses:

          Function Keys:
            F1           Turns turtle to the left.
            F2           Turns turtle to the right.

          Cursor Keys:

            They point the turtle:
              Up arrow,    north
              Down arrow,  south
              Right arrow, east
              Left arrow:  west
              Home,        northwest
              PgUp,        northeast
              PgDn,        southeast
              End:         southwest

          Alpha keys:
            0 thru 9:    Set the magnitude for speed.
                         (i.e. 0 is stop, 1 is slow, 9 is fast)
            H:           Sets video mode to High resolution.
            M:           Sets video mode to Medium resolution.
            W:           TOGGLE: Wrap on / off
            P:           TOGGLE: PenUp / PenDown.
            T:           TOGGLE: Hide / show the turtle.
            C:           Changes the color (or intensity) of the lines.
            +:           Homes the turtle.
            <ESC>:       Quits the turtle demo.
}

 {$I Graph.p  }
 const
   TurtleSpeed = 50;

 type
   ToggleCommands = (PenOn, WrapOn, TurtleOn);

 var
   ToggleRay    : array[PenOn..TurtleOn] of boolean;
   Magnitude,               { Sets speed: 0 = stopped, 9 = fast        }
   Color,                   { Current palette color                    }
   CurentPalette: Integer;  { Current Palette                          }

 Procedure Init;
 var  Toggle: ToggleCommands;

   procedure VerifyGraphicsCard;
   var ch : char;
   begin
     ClrScr;
     Writeln('You must have a color graphics adapter to use this program.');
     write('CONTINUE?  (Y/N): ');
     repeat
       read(kbd, ch);
       if upcase(ch) in ['N', #27, ^C] then
       begin
         TextMode;
         Halt;
       end;
     until upcase(ch) = 'Y';
   end; { VerifyGraphicsCard }

 begin
   VerifyGraphicsCard;
   Magnitude := 0;  { Stopped }
   Color     := 0;
   for Toggle := PenOn to TurtleOn do
     ToggleRay[Toggle]  := true;      { Start with all commands toggled on }
 end;

 Procedure PlayWithTurtle;

 var
   InKey:     Char;
   FunctionKey:  Boolean;    { TRUE if a function key was pressed       }

   procedure NewScreen(SetRes : char);

     procedure DrawBox(x, y, w, h : integer);
     begin
       Draw(x, y, x + w, y, 1);                     { top        }
       Draw(x, y, x, y + h, 1);                     { left side  }
       Draw(x, y + h, x + w, y + h, 1);             { bottom     }
       Draw(x + w, y + h, x + w, y, 1);             { right side }
     end; (* DrawBox *)

     procedure HiResOn;
     const
       CharHeight = 10;
     begin
       HiRes;
       HiResColor(Yellow);
       DrawBox(0, 0, 639, 199-CharHeight);
       TurtleWindow(319, 99-(CharHeight DIV 2), 638, 198-CharHeight);
     end; { HiResOn }

     procedure MediumResOn;
     const
       CharHeight = 20;
     begin
       Graphics;
       DrawBox(0, 0, 319, 199-CharHeight);
       TurtleWindow(159, 99-(CharHeight DIV 2), 318, 198-CharHeight);
     end; { MediumResOn }

   begin
     case SetRes of
       'M'   : begin
                 MediumResOn;
                 GoToXY(1, 24);
                 writeln('SPEED:0-9 TOGGLES:Pen,Wrap,Turtle,Color');
                 write('   TURN: F1,F2, HOME: +, RES: Hi,Med');
               end;
       'H'   : begin
                 HiResOn;
                 GoToXY(1, 25);
                 write(' SPEED: 0-9  TOGGLES: Pen,Wrap,Turtle,Color');
                 write('  TURN: F1,F2  HOME: +  RES: Hi,Med');
               end;
     end; (* case *)
     Showturtle;
     home;
     Wrap;
     Magnitude := 0;
   end; { NewScreen }

   Function GetKey(var FunctionKey: Boolean): char;
   var ch: char;
   begin
     read(kbd,Ch);
     If (Ch = #27) AND KeyPressed Then  { it must be a function key }
     begin
       read(kbd,Ch);
       FunctionKey := true;
     end
     else FunctionKey := false;
     GetKey := Ch;
   end;


   Procedure TurtleDo(InKey : char; FunctionKey : boolean);
   const
     NorthEast = 45;
     SouthEast = 135;
     SouthWest = 225;
     NorthWest = 315;

     procedure DoFunctionCommand(FunctionKey: char);
     begin
       case FunctionKey of
         'H': SetHeading(North);      { Up arrow Key    }
         'P': SetHeading(South);      { Down arrow Key  }
         'M': SetHeading(East);       { Left arrow Key  }
         'K': SetHeading(West);       { Right arrow Key }
         'I': SetHeading(NorthEast);  { PgUp            }
         'Q': SetHeading(SouthEast);  { PgDn            }
         'G': SetHeading(NorthWest);  { Home            }
         'O': SetHeading(SouthWest);  { End             }
         '<': SetHeading(Heading+5);  { F1              }
         ';': SetHeading(Heading-5);  { F2              }
       end
     end { Do function command };

   begin
     If FunctionKey then DoFunctionCommand(Upcase(InKey))
     else
     case upcase(InKey) of
       'P': begin
              ToggleRay[PenOn] := NOT ToggleRay[PenOn];
              case ToggleRay[PenOn] of
                true  : PenUp;
                false : PenDown;
              end; (* case *)
            end;
       'W': begin
              ToggleRay[WrapOn] := NOT ToggleRay[WrapOn];
              case ToggleRay[WrapOn] of
                true  : Wrap;
                false : NoWrap;
              end; (* case *)
            end;
       'T': begin
              ToggleRay[TurtleOn] := NOT ToggleRay[TurtleOn];
              case ToggleRay[TurtleOn] of
                true  : ShowTurtle;
                false : HideTurtle;
              end; (* case *)
            end;
       '+': Home;
       'C': begin
              Color := succ(color) mod 4;
              SetPenColor(Color);
            end;
       '0'..'9': Magnitude := Sqr(ord(inkey) - ord('0'));
       'M': begin
              NewScreen('M');     { medium resolution graphics }
            end;
       'H': begin
              NewScreen('H');     { HiRes graphics }
            end;
     end;   { case }
   end; (* TurtleDo *)

 begin
  NewScreen('M');     { start with medium resolution graphics }
  repeat
    TurtleDelay(TurtleSpeed);
    repeat
      if Magnitude <> 0 then forwd(Magnitude);
    until KeyPressed;
    Inkey := GetKey(FunctionKey);
    TurtleDo(InKey, FunctionKey);
  until UpCase(Inkey) in [#27, ^C];
 end;  { PlayWithTurtle }

begin
  Init;
  PlayWithTurtle;
  ClearScreen;
  TextMode;
end.
