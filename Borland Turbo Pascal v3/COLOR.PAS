program ColorDemo;

{            COLOR DEMONSTRATION PROGRAM  Version 1.00A

    This program demonstrates color graphics on the IBM PC and true
    compatibles with a color graphics adapter.

    INSTRUCTIONS
    1.  Compile and run the program using the TURBO.COM compiler.
    2.  Toggle between modifying the Palette and the Background by
        typing "P" and "B".
    3.  Change colors by using the up and down arrows on the numeric
        key pad.
}

{$I Graph.p  }

type
  AnyString = string[40];

procedure Check;     { Check to continue to run program }
var
  Ch: char;
begin
  Write('This program will only work if you have');
  WriteLn(' the color graphics adapter installed');
  Write('Continue Y/N ');
  repeat
    Read(Kbd,Ch)
  until UpCase(Ch) in ['Y','N', #27];
  if UpCase(Ch) in ['N', #27] then
    Halt;
end;

procedure PaletteDemo;
var
  Ch                        : char;
  PaletteNumber, Background : integer;
  PaletteChange             : boolean;

  procedure DrawBoxes;
  var
    Y : integer;
  begin
    FillPattern(10,81,320,104,1);
    FillPattern(10,104,320,128,2);
    FillPattern(10,129,320,154,3);
  end {DrawBoxes};

  procedure Msg(X,Y: integer; S: AnyString);
  { write the string S at X,Y }
  begin
    GotoXY(X,Y);
    Write(S);
  end {Msg};

  procedure Help;
  begin { write the help text}
    Msg(1,1,'           TURBO COLOR DEMO ');
    Msg(1,3,'Procedures used:');
    Msg(1,6,' To make  background: ');
    Msg(1,7,' To select a palette:  ');
    Msg(1,9,'Colors in selected palette are:');
    Msg(1,12,'1');
    Msg(1,15,'2');
    Msg(1,18,'3');
    Msg(1,21,'Use ' + #24 + ' ' + #25 + ' to change background number');
    Msg(1,22,'or press P to change Palette    ');
    GoToXY(1,25);
    Write('Press ESC to exit');
  end {Help};

  procedure Update;
  begin
    GoToXY(22,6); Write('GraphBackground(',Background,') ');
    GoToXY(22,7); Write('Palette(',PaletteNumber,')');
    GraphBackground(Background);
    Palette(PaletteNumber);
    if PaletteChange then
    begin
      Msg(1,21,'Use ' + #24 + ' ' + #25 + ' to change palette number   ');
      Msg(1,22,'Press B to change Background ');
    end
    else
    begin
      Msg(1,21,'Use ' + #24 + ' ' + #25 + ' to change background number');
      Msg(1,22,'or press P to change Palette    ');
    end;
  end {Update};

begin {PaletteDemo}
  GraphColorMode;
  BackGround:=0;
  PaletteNumber:=0;
  GraphBackground(BackGround);
  Palette(PaletteNumber);
  DrawBoxes;
  Help;
  Update;
  repeat
    repeat Read(Kbd,Ch) until Ch in ['P','p','B','b',#27];
    case Upcase(Ch) of
      'P': PaletteChange:=true;
      'B': PaletteChange:=false;
      #27: begin
             if KeyPressed then
               begin
                 Read(Kbd,Ch);
                 case Ch of
                   'P': begin
                          if PaletteChange then
                            begin
                              PaletteNumber:=PaletteNumber-1;
                              if PaletteNumber<0 then PaletteNumber:=0;
                            end
                            else
                            begin
                              Background:=BackGround-1;
                              if BackGround<0 then BackGround:=0;
                            end;
                        end;
                   'H': begin
                          if PaletteChange then
                          begin
                            PaletteNumber:=PaletteNumber+1;
                            if PaletteNumber>3 then PaletteNumber:=3;
                          end
                          else
                          begin
                            Background:=BackGround+1;
                            if BackGround>15 then BackGround:=15;
                          end;
                        end;
                 end;
               end;
           end;
    end;
    Update;
  until Ch=#27;
end {Palettedemo};

begin {Main program}
  ClrScr;
  Check;
  PaletteDemo;
  TextMode;
end.
