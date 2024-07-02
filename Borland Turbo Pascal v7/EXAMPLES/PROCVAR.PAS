{************************************************}
{                                                }
{ Procedural Types Demo                          }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

{$F+}
program ProcVar;
{ For an extensive discussion of procedural types, variables and
  parameters, refer to the Programmer's Guide.
}

type
  IntFuncType = function (x, y : integer) : integer; { No func. identifier }

var
  IntFuncVar : IntFuncType;

procedure DoSomething(Func : IntFuncType; x, y : integer);
begin
  Writeln(Func(x, y):5);      { call the function parameter }
end;

function AddEm(x, y : integer) : integer;
begin
  AddEm := x + y;
end;

function SubEm(x, y : integer) : integer;
begin
  SubEm := x - y;
end;

begin
  { Directly: }
  DoSomething(AddEm, 1, 2);
  DoSomething(SubEm, 1, 2);

  { Indirectly: }
  IntFuncVar := AddEm;              { an assignment, not a call }
  DoSomething(IntFuncVar, 3, 4);    { a call }
  IntFuncVar := SubEm;              { an assignment, not a call }
  DoSomething(IntFuncVar, 3, 4);    { a call }
end.
