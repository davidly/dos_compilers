program SoundDemo;


type
  NoteRecord = record
                  C,CF,D,DF,E,F,FF,G,GF,A,AF,B: integer;
               end;

Const
  Notes: NoteRecord =
          (C:1;CF:2;D:3;DF:4;E:5;F:6;FF:7;G:8;GF:9;A:10;AF:11;B:12);


procedure Play(Octave,Note,Duration: integer);

{ Play Note in Octave Duration milliseconds  }
{ Frequency computed by first computing C in }
{ Octave then increasing frequency by Note-1 }
{ times the twelfth root of 2. (1.059463994) }
{                                            }
{ If Duration is zero  Note will be played   }
{ until you activate procedure NoSound       }

var
  Frequency: real;
  I: integer;
begin
  Frequency:=32.625;
  { Compute C in Octave }
  for I:=1 to Octave do Frequency:=Frequency*2;
  { Increase frequency Note-1 times }
  for I:=1 to Note-1 do Frequency:=Frequency*1.059463094;
  if Duration<>0 then
  begin
    Sound(Round(Frequency));
    Delay(Duration);
    NoSound;
  end else Sound(Round(Frequency));
end;


procedure SoftAlarm;
{ Play the notes G and D in octave three 7 times }
{ each with a duration of 70 milliseconds.       }
var
  I: integer;
begin
  for I:=1 to 7 do with Notes do
  begin
    Play(4,G,70);
    Play(4,D,70);
  end;
  Delay(1000);
end;


procedure Sirene;
var
  Frequency: integer;
begin
  for Frequency:= 500 to     2000 do begin Delay(1); Sound(Frequency); end;
  for Frequency:=2000 downto  500 do begin Delay(1); Sound(Frequency); end;
end;


begin
  writeln('Press any key to Stop');
  repeat SoftAlarm until KeyPressed;
  read(Kbd);
  writeln('Press any key to Stop');
  repeat Sirene until KeyPressed;
  NoSound;
end.


