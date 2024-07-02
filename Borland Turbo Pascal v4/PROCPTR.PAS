
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

program ProcPtr;
{ This example program shows how to use a pointer and an inline
  directive to call 2 different procedures with the same parameters.
  CallProc is an inline directive (or macro) with the same parameters
  as both One and TheOther. A global pointer variable, ProcAddr,
  contains the address of the procedure to call. Then a call is made
  to CallProc, which in turn does a far call to the address stored
  in ProcAddr.

  Warning: This technique is recommended only for those programmers with
           assembly language programming experience.

  For more information about inline directives, refer to P-367 in the
  Owner's Handbook.
}

var
  ProcAddr : pointer;

procedure CallProc(var i : integer; w : word; s : string);
  Inline($FF/$1E/ProcAddr);

{$F+}
procedure One(var i : integer; w : word; s : string);
begin
  Writeln('First One,');
end;
{$F-}

{$F+}
procedure TheOther(var i : integer; w : word; s : string);
begin
  Writeln('then TheOther');
end;
{$F-}

var
  i : integer;
begin
  ProcAddr := @One;
  CallProc(i, 7, 'data');                  { first call one }
  ProcAddr := @TheOther;
  CallProc(i, 5, 'more data');             { then call the other }
end.
