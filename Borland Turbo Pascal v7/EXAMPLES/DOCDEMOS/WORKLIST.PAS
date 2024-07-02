{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program WorkList;

{$IFDEF Windows}
uses WinCrt, Workers;
{$ELSE}
uses Workers;
{$ENDIF}

const
  CompanyName = 'Sand Tech, Inc.';

type
  { Linked list management objects }
  PNode = ^TNode;
  TNode = record
    Item: PEmployee;
    Next: PNode;
  end;

  PStaffList = ^TStaffList;
  TStaffList = object
    Nodes: PNode;
    constructor Init;
    destructor Done; virtual;
    procedure Add(Item: PEmployee);
    procedure Report;
  end;

{ TStaffList }
constructor TStaffList.Init;
begin
  Nodes := nil;
end;

destructor TStaffList.Done;
var
  N: PNode;
begin
  while Nodes <> nil do
  begin
    N := Nodes;
    Nodes := N^.Next;
    Dispose(N^.Item, Done);
    Dispose(N);
  end;
end;

procedure TStaffList.Add(Item: PEmployee);
var
  N: PNode;
begin
  New(N);
  N^.Item := Item;
  N^.Next := Nodes;
  Nodes := N;
end;

procedure TStaffList.Report;

procedure PadString(S: String; PadLen: Integer);
begin
  Write(S, ' ':PadLen - Length(S));
end;

var
  Current: PNode;
  TotalPayAmount: Real;
  StaffCount: LongInt;
begin
  { Report header }
  TotalPayAmount := 0;
  StaffCount := 0;
  Writeln;
  Writeln(' ':35 - Length(CompanyName), CompanyName, ' Payroll Report');
  Writeln;
  PadString('Name', 30);
  PadString('Title', 30);
  Writeln('Pay amount');
  PadString('----', 30);
  PadString('-----', 30);
  Writeln('----------');

  { Traverse linked list, dump payroll report for each worker }
  Current := Nodes;
  while Current <> nil do
    with Current^.Item^ do
    begin
      Inc(StaffCount);
      TotalPayAmount := TotalPayAmount + GetPayAmount;
      Show;
      Current := Current^.Next;
    end;

  { Report summary }
  Writeln;
  Writeln('Number of employees:     ', StaffCount:15);
  Writeln('Total payroll amount:    ', TotalPayAmount:15:2);
  Writeln('Estimated annual payroll:', TotalPayAmount * PayPeriods:15:2);
  Writeln;
end;

var
  TotalPayAmount: Real;
  Staff: TStaffList;

begin
  { Create an empty list }
  Staff.Init;

  { Now create and add several workers to the staff list }
  Staff.Add(New(PHourly, Init('Von Staadt, Alfred',
    'Word processor', 8.35, 80)));
  Staff.Add(New(PHourly, Init('Karlon, Allison',
    'Fork lift operator', 12.95, 80)));
  Staff.Add(New(PCommissioned, Init('Smith, Sam "Snake oil"',
    'Direct Sales', 30000, 0.03, 89743)));
  Staff.Add(New(PSalaried, Init('Gomez, Rosa',
    'Managing Editor', 56000)));
  Staff.Add(New(PSalaried, Init('Carter, Cynthia', 'CEO', 110000)));

  { Traverse the list and produce a payroll report }
  Staff.Report;

  { Deallocate list and its contents with one destructor call }
  Staff.Done;
end.
