{$C-}
program test;
{
           TURBO-87 DEMONSTRATION PROGRAM  Version 1.00A

     This program demonstrates the speed and precision advantages
     of the TURBO-87 compiler.

     INSTRUCTIONS
     1.  Compile and run this program using the TURBO.COM compiler.
     2.  Compile and run this program using the TURBO-87.COM compiler
         and compare the results with (1) above.
}

var
  Terms : integer;
  Answer: char;

procedure GetTerms(var Count : integer);
begin
  ClrScr;
  Writeln('This program demonstrates the speed and precision advantages');
  Writeln('of the TURBO-87 compiler.');
  Writeln;
  Write('Please tell me how many terms you want to add: ');
  HighVideo;
  readln(Count);
  Writeln;
end; (* GetCount *)

procedure DisplayResults(Count : integer);
var
  Number,  Sum : real;
  Index        : integer;

  function InvSquare(arg: real): real;
  begin
    InvSquare := 1 / Sqr(arg)
  end; (* InvSquare *)

begin
  Write('Calculating: 1/1 + 1/4 +... + 1/',Count,'*',Count,' = ');
  Sum := 0;
  for Index := 1 to Count do
  begin
      Number := Index;
      Sum := Sum + InvSquare(Number)
  end;
  Writeln(Sum:1:20);
  Writeln;
  LowVideo;
end; (* DisplayResults *)

begin
  LowVideo;
  repeat
    GetTerms(Terms);
    DisplayResults(Terms);
    Write('Type <ESC> to quit, any other key to continue...');
    Read(KBD, Answer);
  until Answer in [#27, ^C];
end.
