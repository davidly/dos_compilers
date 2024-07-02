{************************************************}
{                                                }
{   Demo unit                                    }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Workers;

interface

const
  PayPeriods        =  26;       { per annum }
  OvertimeThreshold =  80;       { per pay period }
  OvertimeFactor    = 1.5;       { times normal hourly rate }

type
  PEmployee = ^TEmployee;
  TEmployee = object
    Name: string[25];
    Title: string[25];
    Rate: Real;
    constructor Init(AName, ATitle: String; ARate: Real);
    destructor Done; virtual;
    function GetName: String;
    function GetPayAmount: Real; virtual;
    function GetRate: Real;
    function GetTitle: String;
    procedure Show; virtual;
  end;

  PHourly = ^THourly;
  THourly = object(TEmployee)
    Time: Integer;
    constructor Init(AName, ATitle: String; ARate: Real; ATime: Integer);
    function GetPayAmount: Real; virtual;
    function GetTime: Integer;
  end;

  PSalaried = ^TSalaried;
  TSalaried = object(TEmployee)
    function GetPayAmount: Real; virtual;
  end;

  PCommissioned = ^TCommissioned;
  TCommissioned = object(TSalaried)
    Commission: Real;
    SalesAmount: Real;
    constructor Init(AName, ATitle: String;
      ARate, ACommission, ASalesAmount: Real);
    function GetPayAmount: Real; virtual;
  end;


implementation

function RoundPay(Wages: Real): Real;
{ Round pay amount to ignore any pay less than 1 penny }
begin
  RoundPay := Trunc(Wages * 100) / 100;
end;


{ TEmployee }
constructor TEmployee.Init(AName, ATitle: String; ARate: Real);
begin
  Name := AName;
  Title := ATitle;
  Rate := ARate;
end;

destructor TEmployee.Done;
begin
end;

function TEmployee.GetPayAmount: Real;
begin
  RunError(211);         { Give runtime error }
end;

function TEmployee.GetName: String;
begin
  GetName := Name;
end;

function TEmployee.GetRate: Real;
begin
  GetRate := Rate;
end;

function TEmployee.GetTitle: String;
begin
  GetTitle := Title;
end;

procedure TEmployee.Show;
var
  S: string[25];
begin
  S := GetName;
  Write(S, ' ':30 - Length(S));
  S := GetTitle;
  Write(S, ' ':30 - Length(S));
  Writeln(GetPayAmount:10:2);
end;

{ THourly }
constructor THourly.Init(AName, ATitle: String; ARate: Real; ATime: Integer);
begin
  TEmployee.Init(AName, ATitle, ARate);
  Time := ATime;
end;

function THourly.GetPayAmount: Real;
var
  OverTime: Integer;
begin
  Overtime := Time - OvertimeThreshold;
  if Overtime > 0 then
    GetPayAmount := RoundPay(OvertimeThreshold * Rate +
      OverTime * OvertimeFactor * Rate)
  else
    GetPayAmount := RoundPay(Time * Rate);
end;

function THourly.GetTime: Integer;
begin
  GetTime := Time;
end;


{ TSalaried }
function TSalaried.GetPayAmount: Real;
begin
  GetPayAmount := RoundPay(Rate / PayPeriods);
end;


{ TCommissioned }
constructor TCommissioned.Init(AName, ATitle: String;
  ARate, ACommission, ASalesAmount: Real);
begin
  TSalaried.Init(AName, ATitle, ARate);
  Commission := ACommission;
  SalesAmount := ASalesAmount;
end;

function TCommissioned.GetPayAmount: Real;
begin
  GetPayAmount := RoundPay(TSalaried.GetPayAmount + Commission * SalesAmount);
end;

end.
