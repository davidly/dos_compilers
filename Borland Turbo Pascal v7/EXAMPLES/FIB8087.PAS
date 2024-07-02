{************************************************}
{                                                }
{ 8087 Stack Overflow Demo                       }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

{$N+,E+}

program Fib8087;
{
  Sample program from the Progammer's Guide that
  demonstrates how to avoid 8087 stack overflow in recursive
  functions that use the 8087 math co-processor. Local variables
  are used to store temporary results on the 8086 stack.
}

var
  i : integer;

function Fib(N : integer) : extended;
{ calculate the fibonacci sequence for N }
var
  F1, F2 : extended;
begin
  if N = 0 then
    Fib := 0.0
  else
    if N = 1 then
      Fib := 1.0
    else
    begin
      (* Use this line instead of the 3 lines that follow this
         comment to cause an 8087 stack overflow for values of
         N >= 8:
      Fib := Fib(N - 1) + Fib(N - 2);  { will cause overflow for N > 8 }
      *)

      F1 := Fib(N - 1);         { store results in temporaries on 8086 }
      F2 := Fib(N - 2);         { stack to avoid 8087 stack overflow }
      Fib := F1 + F2;
    end;
end; { Fib }

begin
  for i := 0 to 15 do
    Writeln(i, '. ', Fib(i));
end.
