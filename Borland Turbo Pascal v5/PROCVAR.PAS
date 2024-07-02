
{ Copyright (c) 1988 by Borland International, Inc. }

{$F+}
program ProcVar;
{ For an extensive discussion of procedural types, variables and
  parameters, refer to Chapter 8 in the Turbo Pascal 5.0 Reference
  Guide (or Chapter 7 in the Turbo Pascal 5.0 Update manual).
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
