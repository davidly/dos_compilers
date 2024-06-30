

{ This program is hereby donated to the public domain                }
{ for non commercial use only                                        }

{Here is a note to the compiler:                                     }
{$R-,U-,V-,X-,C-}

program MicroCalc;

const
  FXMax: Char  = 'G';  { Maximum number of columns in spread sheet   }
  FYMax        = 21;   { Maximum number of lines in spread sheet     }

type
  Anystring   = string[70];
  SheetIndex  = 'A'..'G';
  Attributes  = (Constant,Formula,Txt,OverWritten,Locked,Calculated);

{ The spreadsheet is made out of Cells every Cell is defined as      }
{ the following record:}

  CellRec    = record
    CellStatus: set of Attributes; { Status of cell (see type def.)  }
    Contents:   String[70];        { Contains a formula or some text }
    Value:      Real;              { Last calculated cell value      }
    DEC,FW:     0..20;             { Decimals and Cell Whith         }
  end;

  Cells      =  array[SheetIndex,1..FYMax] of CellRec;

const
  XPOS: array[SheetIndex] of integer = (3,14,25,36,47,58,68);

var
  Sheet:         Cells;             { Definition of the spread sheet }
  FX:            SheetIndex;        { Culumn of current cell         }
  FY:            Integer;           { Line of current cell           }
  Ch:            Char;              { Last read character            }
  MCFile:        file of CellRec;   { File to store sheets in        }
  AutoCalc:      boolean;           { Recalculate after each entry?  }


 { For easy reference the procedures and functions are grouped in mo-}
 { dules called MC-MOD00 through MC-MOD05.                           }


 {.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD00                                   *}
{*  PURPOSE:            Micellaneous utilities and commands.        *}
{*******************************************************************}


procedure Msg(S: AnyString);
begin
  GotoXY(1,24);
  ClrEol;
  Write(S);
end;

procedure Flash(X: integer; S: AnyString;  Blink: boolean);
begin
  HighVideo;
  GotoXY(X,23);
  Write(S);
  if Blink then
  begin
    repeat
      GotoXY(X,23);
      Blink:=not Blink; if Blink then HighVideo else LowVideo;
      Write(S);
      Delay(175);
    until KeyPressed;
  end;
  LowVideo;
end;

procedure IBMCh(var Ch: Char);
begin
  case Ch of
    'H': Ch:=^E;
    'P': Ch:=^X;
    'M': Ch:=^D;
    'K': Ch:=^S;
    'S': Ch:=#127;
    'R': Ch:=^V;
    'G',
    'I',
    'O',
    'Q': Ch:=#00;
  end;
end;

procedure Auto;
begin
  AutoCalc:=not AutoCalc;
  if AutoCalc then  Flash(60,'AutoCalc: ON ',false)
  else Flash(60,'AutoCalc: OFF',false);
end;


{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD01                                   *}
{*  PURPOSE:            Display grid and initialize all cells      *}
{*                      in the spread sheet.                       *}
{*******************************************************************}



procedure Grid;
var I: integer;
    Count: Char;
begin
  HighVideo;
  For Count:='A' to FXMax do
  begin
    GotoXY(XPos[Count],1);
    Write(Count);
  end;
  GotoXY(1,2);
  for I:=1 to FYMax do writeln(I:2);
  LowVideo;
  if AutoCalc then  Flash(60,'AutoCalc: ON' ,false)
  else Flash(60,'AutoCalc: OFF',false);
  Flash(33,'  Type / for Commands',false);
end;


procedure Init;
var
  I: SheetIndex;
  J: Integer;
  LastName: string[2];
begin
  for I:='A' to FXMAX do
  begin
    for J:=1 to FYMAX do
    begin
      with Sheet[I,J] do
      begin
        CellStatus:=[Txt];
        Contents:='';
        Value:=0;
        DEC:=2;              { Default number of decimals        }
        FW:=10;              { Default field width               }
      end;
    end;
  end;
  AutoCalc:=True;
  FX:='A'; FY:=1;            { First field in upper left corner  }
end;

procedure Clear;
begin
  HighVideo;
  GotoXY(1,24); ClrEol;
  Write('Clear this worksheet? (Y/N) ');
  repeat Read(Kbd,Ch) until Upcase(Ch) in ['Y','N'];
  Write(Upcase(Ch));
  if UpCase(Ch)='Y' then
  begin
    ClrScr;
    Init;
    Grid;
  end;
end;



{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD02                                   *}
{*  PURPOSE:            Display values in cells and move between   *}
{*                      cells in the spread sheet.                 *}
{*******************************************************************}


procedure FlashType;
begin
  with Sheet[FX,FY] do
  begin
    GotoXY(1,23);
    Write(FX,FY:2,' ');
    if Formula in CellStatus  then write('Formula:')  else
    if Constant in CellStatus then Write('Numeric ') else
    if Txt in CellStatus then Write('Text    ');
    GotoXY(1,24); ClrEol;
    if Formula in CellStatus then Write(Contents);
  end;
end;


{ The following procedures move between the Cells on the calc sheet.}
{ Each Cell has an associated record containing its X,Y coordinates }
{ and data. See the type definition for "Cell".                     }

procedure GotoCell(GX: SheetIndex; GY: integer);
begin
  with Sheet[GX,GY] do
  begin
    HighVideo;
    GotoXY(XPos[GX],GY+1);
    Write('           ');
    GotoXY(XPos[GX],GY+1);
    if Txt in CellStatus then Write(Contents)
    else
    begin
      if DEC>=0 then Write(Value:FW:DEC)
      else Write(Value:FW);
    end;
    FlashType;
    GotoXY(XPos[GX],GY+1);
  end;
  LowVideo;
end;

{.CP20}

procedure LeaveCell(FX:SheetIndex;FY: integer);
begin
  with Sheet[FX,FY] do
  begin
    GotoXY(XPos[FX],FY+1);
    LowVideo;
    if Txt in CellStatus then Write(Contents)
    else
    begin
      if DEC>=0 then Write(Value:FW:DEC)
      else Write(Value:FW);
    end;
  end;
end;


{.CP20}

procedure Update;
var
  UFX: SheetIndex;
  UFY: integer;
begin
  ClrScr;
  Grid;
  for UFX:='A' to FXMax do for UFY:=1 to FYMax do
  if Sheet[UFX,UFY].Contents<>'' then LeaveCell(UFX,UFY);
  GotoCell(FX,FY);
end;

{.CP20}

procedure MoveDown;
var Start: integer;
begin
  LeaveCell(FX,FY);
  Start:=FY;
  repeat
    FY:=FY+1;
    if FY>FYMax then FY:=1;
  until (Sheet[FX,FY].CellStatus*[OverWritten,Locked]=[]) or (FY=Start);
  if FY<>Start then GotoCell(FX,FY);
end;

{.CP20}

procedure MoveUp;
var Start: integer;
begin
  LeaveCell(FX,FY);
  Start:=FY;
  repeat
    FY:=FY-1;
    if FY<1 then FY:=FYMax;
  until (Sheet[FX,FY].CellStatus*[OverWritten,Locked]=[]) or (FY=Start);
  if FY<>Start then GotoCell(FX,FY);
end;

{.CP20}

procedure MoveRight;
var Start: SheetIndex;
begin
  LeaveCell(FX,FY);
  Start:=FX;
  repeat
    FX:=Succ(FX);
    if FX>FXMax then
    begin
      FX:='A';
      FY:=FY+1;
      if FY>FYMax then FY:=1;
    end;
  until (Sheet[FX,FY].CellStatus*[OverWritten,Locked]=[]) or (FX=Start);
  if FX<>Start then GotoCell(FX,FY);
end;

{.CP20}

procedure MoveLeft;
var Start: SheetIndex;
begin
  LeaveCell(FX,FY);
  Start:=FX;
  repeat
    FX:=Pred(FX);
    if FX<'A' then
    begin
      FX:=FXMax;
      FY:=FY-1;
      if FY<1 then FY:=FYMax;
    end;
  until (Sheet[FX,FY].CellStatus*[OverWritten,Locked]=[]) or (FX=Start);
  if FX<>Start then GotoCell(FX,FY);
end;


{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD03                                   *}
{*  PURPOSE:            Read, Save and Print a spread sheet.       *}
{*                      Display on-line manual.                    *}
{*******************************************************************}

type
  String3 = string[3];

var
  FileName: string[14];
  Line: string[100];

function Exist(FileN: AnyString): boolean;
var F: file;
begin
   {$I-}
   assign(F,FileN);
   reset(F);
   {$I+}
   if IOResult<>0 then Exist:=false
   else Exist:=true;
end;


procedure GetFileName(var Line: AnyString; FileType:String3);
begin
  Line:='';
  repeat
    Read(Kbd,Ch);
    if Upcase(Ch) in ['A'..'Z',^M] then
    begin
      write(Upcase(Ch));
      Line:=Line+Ch;
    end;
  until (Ch=^M) or (length(Line)=8);
  if Ch=^M then Delete(Line,Length(Line),1);
  if Line<>'' then Line:=Line+'.'+FileType;
end;

{.CP20}

procedure Save;
var I: SheetIndex;
J: integer;
begin
  HighVideo;
  Msg('Save: Enter filename  ');
  GetFileName(Filename,'MCS');
  if FileName<>'' then
  begin
    Assign(MCFile,FileName);
    Rewrite(MCFile);
    for I:='A' to FXmax do
    begin
      for J:=1 to FYmax do
      write(MCfile,Sheet[I,J]);
    end;
    Grid;
    Close(MCFile);
    LowVideo;
    GotoCell(FX,FY);
  end;
end;

{.CP30}

procedure Load;
begin
  HighVideo;
  Msg('Load: Enter filename  ');
  GetFileName(Filename,'MCS');
  if (Filename<>'') then if (not exist(FileName)) then
  repeat
    Msg('File not Found: Enter another filename  ');
    GetFileName(Filename,'MCS');
  until exist(FileName) or (FileName='');
  if FileName<>'' then
  begin
    ClrScr;
    Msg('Please Wait. Loading definition...');
    Assign(MCFile,FileName);
    Reset(MCFile);
    for FX:='A' to FXmax do
     for FY:=1 to FYmax do read(MCFile,Sheet[FX,FY]);
    FX:='A'; FY:=1;
    LowVideo;
    UpDate;
  end;
  GotoCell(FX,FY);
end;


{.PA}

procedure Print;
var
  I:      SheetIndex;
  J,Count,
  LeftMargin: Integer;
  P:          string[20];
  MCFile:     Text;
begin
  HighVideo;
  Msg('Print: Enter filename "P" for Printer> ');
  GetFileName(Filename,'LST');
  Msg('Left margin > ');  Read(LeftMargin);
  if FileName='P.LST' then FileName:='Printer';
  Msg('Printing to: ' + FileName + '....');
  Assign(MCFile,FileName);
  Rewrite(MCFile);
  For Count:=1 to 5 do Writeln(MCFile);
  for J:=1 to FYmax do
  begin
    Line:='';
    for I:='A' to FXmax do
    begin
      with Sheet[I,J] do
      begin
        while (Length(Line)<XPOS[I]-4) do Line:=Line+' ';
        if (Constant in CellStatus) or (Formula in CellStatus) then
        begin
          if not (Locked in CellStatus) then
          begin
            if DEC>0 then Str(Value:FW:DEC,P) else Str(Value:FW,P);
            Line:=Line+P;
          end;
        end else Line:=Line+Contents;
      end; { With }
    end; { One line }
    For Count:=1 to LeftMargin do Write(MCFile,' ');
    writeln(MCFile,Line);
  end; { End Column }
  Grid;
  Close(MCFile);
  LowVideo;
  GotoCell(FX,FY);
end;

{.PA}

procedure Help;
var
  H: text;
  Line: string[80];
  J: integer;
  Bold: boolean;

begin
  if Exist('CALC.HLP') then
  begin
    Assign(H,'CALC.HLP');
    Reset(H);
    while not Eof(H) do
    begin
      ClrScr; Bold:=false; LowVideo;
      Readln(H,Line);
      repeat
        Write('     ');
        For J:=1 to Length(Line) do
        begin
          if Line[J]=^B then
          begin
            Bold:=not Bold;
            if Bold then HighVideo else LowVideo;
          end else write(Line[J]);
        end;
        Writeln;
        Readln(H,Line);
      until  Eof(H) or (Copy(Line,1,3)='.PA');
      GotoXY(26,24); HighVideo;
      write('<<< Please press any key to continue >>>');
      LowVideo;
      read(Kbd,Ch);
    end;
    GotoXY(20,24); HighVideo;
    write('<<< Please press <RETURN> to start MicroCalc >>>');
    LowVideo;
    Readln(Ch);
    UpDate;
  end else { Help file did not exist }
  begin
    Msg('To get help the file CALC.HLP must be on your disk. Press <RETURN>');
    repeat Read(kbd,Ch) until Ch=^M;
    GotoCell(FX,FY);
  end;
end;


{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD04                                   *}
{*  PURPOSE:            Evaluate formulas.                         *}
{*                      Recalculate spread sheet.                  *}
{*                                                                 *}
{*  NOTE:               This module contains recursive procedures  *}
{*******************************************************************}

var
  Form: Boolean;

{$A-}
procedure Evaluate(var IsFormula: Boolean; { True if formula}
                   var Formula: AnyString; { Fomula to evaluate}
                   var Value: Real;  { Result of formula }
                   var ErrPos: Integer);{ Position of error }
const
  Numbers: set of Char = ['0'..'9'];
  EofLine  = ^M;

var
  Pos: Integer;    { Current position in formula                     }
  Ch: Char;        { Current character being scanned                 }
  EXY: string[3];  { Intermidiate string for conversion              }

{ Procedure NextCh returns the next character in the formula         }
{ The variable Pos contains the position ann Ch the character        }

  procedure NextCh;
  begin
    repeat
      Pos:=Pos+1;
      if Pos<=Length(Formula) then
      Ch:=Formula[Pos] else Ch:=eofline;
    until Ch<>' ';
  end  { NextCh };


  function Expression: Real;
  var
    E: Real;
    Opr: Char;

    function SimpleExpression: Real;
    var
      S: Real;
      Opr: Char;

      function Term: Real;
      var
        T: Real;

        function SignedFactor: Real;

          function Factor: Real;
          type
            StandardFunction = (fabs,fsqrt,fsqr,fsin,fcos,
            farctan,fln,flog,fexp,ffact);
            StandardFunctionList = array[StandardFunction] of string[6];

          const
            StandardFunctionNames: StandardFunctionList =('ABS','SQRT','SQR','SIN','COS',
                                                          'ARCTAN','LN','LOG','EXP','FACT');
          var
            E,EE,L:  Integer;       { intermidiate variables }
            Found:Boolean;
            F: Real;
            Sf:StandardFunction;
            OldEFY,                 { Current cell  }
            EFY,
            SumFY,
            Start:Integer;
            OldEFX,
            EFX,
            SumFX:SheetIndex;
            CellSum: Real;

              function Fact(I: Integer): Real;
              begin
                if I > 0 then begin Fact:=I*Fact(I-1); end
                else Fact:=1;
              end  { Fact };

{.PA}
          begin { Function Factor }
            if Ch in Numbers then
            begin
              Start:=Pos;
              repeat NextCh until not (Ch in Numbers);
              if Ch='.' then repeat NextCh until not (Ch in Numbers);
              if Ch='E' then
              begin
                NextCh;
                repeat NextCh until not (Ch in Numbers);
              end;
              Val(Copy(Formula,Start,Pos-Start),F,ErrPos);
            end else
            if Ch='(' then
            begin
              NextCh;
              F:=Expression;
              if Ch=')' then NextCh else ErrPos:=Pos;
            end else
            if Ch in ['A'..'G'] then { Maybe a cell reference }
            begin
              EFX:=Ch;
              NextCh;
              if Ch in Numbers then
              begin
                F:=0;
                EXY:=Ch; NextCh;
                if Ch in Numbers then
                begin
                  EXY:=EXY+Ch;
                  NextCh;
                end;
                Val(EXY,EFY,ErrPos);
                IsFormula:=true;
                if (Constant in Sheet[EFX,EFY].CellStatus) and
                not (Calculated in Sheet[EFX,EFY].CellStatus) then
                begin
                  Evaluate(Form,Sheet[EFX,EFY].contents,f,ErrPos);
                  Sheet[EFX,EFY].CellStatus:=Sheet[EFX,EFY].CellStatus+[Calculated]
                end else if not (Txt in Sheet[EFX,EFY].CellStatus) then
                F:=Sheet[EFX,EFY].Value;
                if Ch='>' then
                begin
                  OldEFX:=EFX; OldEFY:=EFY;
                  NextCh;
                  EFX:=Ch;
                  NextCh;
                  if Ch in Numbers then
                  begin
                    EXY:=Ch;
                    NextCh;
                    if Ch in Numbers then
                    begin
                      EXY:=EXY+Ch;
                      NextCh;
                    end;
                    val(EXY,EFY,ErrPos);
                    Cellsum:=0;
                    for SumFY:=OldEFY to EFY do
                    begin
                      for SumFX:=OldEFX to EFX do
                      begin
                        F:=0;
                        if (Constant in Sheet[SumFX,SumFY].CellStatus) and
                        not (Calculated in Sheet[SumFX,SumFY].CellStatus) then
                        begin
                          Evaluate(Form,Sheet[SumFX,SumFY].contents,f,errPos);
                          Sheet[SumFX,SumFY].CellStatus:=
                          Sheet[SumFX,SumFY].CellStatus+[Calculated];
                        end else if not (Txt in Sheet[SumFX,SumFY].CellStatus) then
                        F:=Sheet[SumFX,SumFY].Value;
                        Cellsum:=Cellsum+f;
                        f:=Cellsum;
                      end;
                    end;
                  end;
                end;
              end;
            end else
            begin
              found:=false;
              for sf:=fabs to ffact do
              if not found then
              begin
                l:=Length(StandardFunctionNames[sf]);
                if copy(Formula,Pos,l)=StandardFunctionNames[sf] then
                begin
                  Pos:=Pos+l-1; NextCh;
                  F:=Factor;
                  case sf of
                    fabs:     f:=abs(f);
                    fsqrt:    f:=sqrt(f);
                    fsqr:     f:=sqr(f);
                    fsin:     f:=sin(f);
                    fcos:     f:=cos(f);
                    farctan:  f:=arctan(f);
                    fln :     f:=ln(f);
                    flog:     f:=ln(f)/ln(10);
                    fexp:     f:=exp(f);
                    ffact:    f:=fact(trunc(f));
                  end;
                  Found:=true;
                end;
              end;
              if not Found then ErrPos:=Pos;
            end;
            Factor:=F;
          end { function Factor};
{.PA}

        begin { SignedFactor }
          if Ch='-' then
          begin
            NextCh; SignedFactor:=-Factor;
          end else SignedFactor:=Factor;
        end { SignedFactor };

      begin { Term }
        T:=SignedFactor;
        while Ch='^' do
        begin
          NextCh; t:=exp(ln(t)*SignedFactor);
        end;
        Term:=t;
      end { Term };


    begin { SimpleExpression }
      s:=term;
      while Ch in ['*','/'] do
      begin
        Opr:=Ch; NextCh;
        case Opr of
          '*': s:=s*term;
          '/': s:=s/term;
        end;
      end;
      SimpleExpression:=s;
    end { SimpleExpression };

  begin { Expression }
    E:=SimpleExpression;
    while Ch in ['+','-'] do
    begin
      Opr:=Ch; NextCh;
      case Opr of
        '+': e:=e+SimpleExpression;
        '-': e:=e-SimpleExpression;
      end;
    end;
    Expression:=E;
  end { Expression };


begin { procedure Evaluate }
  if Formula[1]='.' then Formula:='0'+Formula;
  if Formula[1]='+' then delete(Formula,1,1);
  IsFormula:=false;
  Pos:=0; NextCh;
  Value:=Expression;
  if Ch=EofLine then ErrPos:=0 else ErrPos:=Pos;
end { Evaluate };

{.PA}

procedure Recalculate;
var
  RFX: SheetIndex;
  RFY:integer;
  OldValue: real;
  Err: integer;

begin
  LowVideo;
  GotoXY(1,24); ClrEol;
  Write('Calculating..');
  for RFY:=1 to FYMax do
  begin
    for RFX:='A' to FXMax do
    begin
      with Sheet[RFX,RFY] do
      begin
        if (Formula in CellStatus) then
        begin
          CellStatus:=CellStatus+[Calculated];
          OldValue:=Value;
          Evaluate(Form,Contents,Value,Err);
          if OldValue<>Value then
          begin
            GotoXY(XPos[RFX],RFY+1);
            if (DEC>=0) then Write(Value:FW:DEC)
            else Write(Value:FW);
          end;
        end;
      end;
    end;
  end;
  GotoCell(FX,FY);
end;

{.PA}
{*******************************************************************}
{*  SOURCE CODE MODULE: MC-MOD05                                   *}
{*  PURPOSE:            Read the contents of a cell and update     *}
{*                      associated cells.                          *}
{*******************************************************************}


procedure GetLine(var S: AnyString;           { String to edit       }
                         ColNO,LineNO,        { Where start line     }
                         MAX,                 { Max length           }
                         ErrPos: integer;     { Where to begin       }
                         UpperCase:Boolean);  { True if auto Upcase  }
var
  X: integer;
  InsertOn: boolean;
  OkChars: set of Char;


  procedure GotoX;
  begin
    GotoXY(X+ColNo-1,LineNo);
  end;

begin
  OkChars:=[' '..'}'];
  InsertOn:=true;
  X:=1; GotoX;
  Write(S);
  if Length(S)=1 then X:=2;
  if ErrPos<>0 then X:=ErrPos;
  GotoX;
  repeat
    Read(Kbd,Ch);
    if KeyPressed then
    begin
      Read(kbd,Ch);
      IBMCh(Ch);
    end;
    if UpperCase then Ch:=UpCase(Ch);
    case Ch of
       ^[: begin
             S:=chr($FF); { abort editing }
             Ch:=^M;
           end;
       ^D: begin { Move cursor right }
             X:=X+1;
             if (X>length(S)+1) or (X>MAX) then X:=X-1;
             GotoX;
           end;
       ^G: begin { Delete right char }
             if X<=Length(S) then
             begin
               Delete(S,X,1);
               Write(copy(S,X,Length(S)-X+1),' ');
               GotoX;
             end;
           end;
    ^S,^H: begin { Move cursor left }
             X:=X-1;
             if X<1 then X:=1;
             GotoX;
           end;
       ^F: begin { Move cursor to end of line }
              X:=Length(S)+1;
              GotoX;
           end;
       ^A: begin { Move cursor to beginning of line }
             X:=1;
             GotoX;
           end;
     #127: begin { Delete left char }
             X:=X-1;
             if (Length(S)>0) and (X>0)  then
             begin
               Delete(S,X,1);
               Write(copy(S,X,Length(S)-X+1),' ');
               GotoX;
               if X<1 then X:=1;
             end else X:=1;
           end;
       ^V: InsertOn:= not InsertOn;

{.PA}

    else
      begin
        if Ch in OkChars  then
        begin
          if InsertOn then
          begin
            insert(Ch,S,X);
            Write(copy(S,X,Length(S)-X+1),' ');
          end else
          begin
            write(Ch);
            if X=length(S) then S:=S+Ch
              else S[X]:=Ch;
          end;
          if Length(S)+1<=MAX then X:=X+1
          else OkChars:=[]; { Line too Long }
          GotoX;
        end else
        if Length(S)+1<=Max then
          OkChars:= [' '..'}']; { Line ok again }
      end;
    end;
  until CH=^M;
end;


{.PA}


procedure  GetCell(FX: SheetIndex;FY: Integer);
var
  S:             AnyString;
  NewStat:       Set of Attributes;
  ErrorPosition: Integer;
  I:             SheetIndex;
  Result:        Real;
  Abort:         Boolean;
  IsForm:        Boolean;

{ Procedure ClearCells clears the current cell and its associated    }
{ cells. An associated cell is a cell overwritten by data from the   }
{ current cell. The data can be text in which case the cell has the  }
{ attribute "OverWritten". If the data is a result from an expression}
{ and the field with is larger tahn 11 then the cell is "Locked"     }

  procedure ClearCells;
  begin
    I:=FX;
    repeat
      with Sheet[I,FY] do
      begin
        GotoXY(XPos[I],FY+1);
        write('           '); I:=Succ(I);
      end;
    until ([OverWritten,Locked]*Sheet[I,FY].CellStatus=[]);
    { Cell is not OVerWritten not Locked }
  end;

{.CP20}
{ The new type of the cell is flashed at the bottom of the Sheet     }
{ Notice that a constant of type array is used to indicate the type  }

  procedure FlashType;
  begin
    HighVideo;
    GotoXY(5,23);
    LowVideo;
  end;

{.CP20}
  procedure GetFormula;
  begin
    FlashType;
    repeat
      GetLine(S,1,24,70,ErrorPosition,True);
      if S<>Chr($FF) then
      begin
        Evaluate(IsForm,S,Result,ErrorPosition);
        if ErrorPosition<>0 then
          Flash(15,'Error at cursor'+^G,false)
        else Flash(15,'               ',false);
      end;
    until (ErrorPosition=0) or (S=Chr($FF));
    if IsForm then NewStat:=NewStat+[Formula];
  end;

{.CP20}
{ Procedure GetText calls the procedure GetLine with the current     }
{ cells X,Y position as parameters. This means that text entering    }
{ takes place direcly at the cells position on the Sheet.            }

  procedure GetText;
  begin
    FlashType;
    with Sheet[FX,FY] do GetLine(S,XPos[FX],FY+1,70,ErrorPosition,False);
  end;

{.CP20}
{ Procedure EditCell loads a copy of the current cells contents in   }
{ in the variable S before calling either GetText or GetFormula. In  }
{ this way no changes are made to the current cell.                  }

  procedure EditCell;
  begin
    with Sheet[FX,FY] do
    begin
      S:=Contents;
      if Txt in CellStatus then GetText else GetFormula;
    end;
  end;

{.PA}
{ Procedure UpdateCells is a little more complicated. Basically it   }
{ makes sure to tag and untag cells which has been overwritten or    }
{ cleared from data from  another cell. It also updates the current  }
{ with the new type and the contents which still is in the temporaly }
{ variable "S".                                                      }


  procedure UpdateCells;
  var
    Flength: Integer;
  begin
    Sheet[FX,FY].Contents:=S;
    if Txt in NewStat {Sheet[FX,FY].CellStatus} then
    begin
      I:=FX; FLength:=Length(S);
      repeat
        I:=Succ(I);
        with Sheet[I,FY] do
        begin
          FLength:=Flength-11;
          if (Flength>0) then
          begin
            CellStatus:=[Overwritten,Txt];
            Contents:='';
          end else
          begin
            if OverWritten in CellStatus then
            begin
              CellStatus:=[Txt];
              GotoCell(I,FY);LeaveCell(I,FY);
            end;
          end;
        end;
      until (I=FXMax)  or (Sheet[I,FY].Contents<>'');
      Sheet[FX,FY].CellStatus:=[Txt];
    end else { string changed to formula or constant }
    begin { Event number two }
      I:=FX;
      repeat
        with Sheet[I,FY] do
        begin
          if OverWritten in CellStatus then
          begin
            CellStatus:=[Txt];
            Contents:='';
          end;
          I:=Succ(I);
        end;
      until not (OverWritten in Sheet[I,FY].CellStatus);
      with Sheet[FX,FY] do
      begin
        CellStatus:=[Constant];
        if IsForm then CellStatus:=CellStatus+[Formula];
        Value:=Result;
      end;
    end;
  end;


{.PA}
{ Procedure GetCell finnaly starts here. This procedure uses all     }
{ all the above local procedures. First it initializes the temporaly }
{ variable "S" with the last read character. It then depending on    }
{ this character calls GetFormula, GetText, or EditCell.             }

begin { procedure GetCell }
  S:=Ch; ErrorPosition:=0; Abort:=false;
  NewStat:=[];
  if Ch in ['0'..'9','+','-','.','(',')'] then
  begin
    NewStat:=[Constant];
    if not (Formula in Sheet[FX,FY].CellStatus) then
    begin
      GotoXY(11,24); ClrEol;
      ClearCells;
      GetFormula;
    end else
    begin
      Flash(15,'Edit formula Y/N?',true);
      repeat read(Kbd,Ch) until UpCase(CH) in ['Y','N'];
      Flash(15,'                 ',false);
      if UpCase(Ch)='Y' then EditCell Else Abort:=true;
    end;
  end else
  begin
    if Ch=^[ then
    begin
      NewStat:=(Sheet[FX,FY].CellStatus)*[Txt,Constant];
      EditCell;
    end else
    begin
      if formula in Sheet[FX,FY].CellStatus then
      begin
        Flash(15,'Edit formula Y/N?',true);
        repeat read(Kbd,Ch) until UpCase(CH) in ['Y','N'];
        Flash(15,'                 ',false);
        if UpCase(Ch)='Y' then EditCell Else Abort:=true;
      end else
      begin
        NewStat:=[Txt];
        ClearCells;
        GetText;
      end;
    end;
  end;
  if not Abort then
  begin
    if S<>Chr($FF) then UpDateCells;
    GotoCell(FX,FY);
    if AutoCalc and (Constant in Sheet[FX,FY].CellStatus) then Recalculate;
    if Txt in NewStat then
    begin
      GotoXY(3,FY+1); Clreol;
      For I:='A' to FXMax do
      LeaveCell(I,FY);
    end;
  end;
  Flash(15,'                ',False);
  GotoCell(FX,FY);
end;

{.PA}
{ Procedure Format is used to }


procedure Format;
var
  J,FW,DEC,
  FromLine,ToLine: integer;
  Lock:            Boolean;


  procedure GetInt(var I: integer; Max: Integer);
  var
    S: string[8];
    Err: Integer;
    Ch: Char;
  begin
    S:='';
    repeat
      repeat Read(Kbd,Ch) until Ch in ['0'..'9','-',^M];
      if Ch<>^M then
      begin
        Write(Ch); S:=S+Ch;
        Val(S,I,Err);
      end;
    until (I>=Max) or (Ch=^M);
    if I>Max then I:=Max;
  end;

begin
  HighVideo;
  Msg('Format: Enter number of decimals (Max 11):  ');
  GetInt(DEC,11);
  Msg('Enter Cell whith remember if larger than 10 next column will lock: ');
  GetInt(FW,20);
  Msg('From which line in column '+FX+': ');
  GetInt(FromLine,FYMax);
  Msg('To which line in column '+FX+': ');
  GetInt(ToLine,FYMax);
  if FW>10 then Lock:=true else Lock:=False;
  for J:=FromLine to ToLine do
  begin
    Sheet[FX,J].DEC:=DEC;
    Sheet[FX,J].FW:=FW;
    with Sheet[Succ(FX),J] do
    begin
      if Lock then
      begin
        CellStatus:=CellStatus+[Locked,Txt];
        Contents:='';
      end else CellStatus:=CellStatus-[Locked];
    end;
  end;
  NormVideo;
  UpDate;
  GotoCell(FX,FY);
end;


{.PA}
{*********************************************************************}
{*                START OF MAIN PROGRAM PROCEDURES                   *}
{*********************************************************************}


{ Procedure Commands is activated from the main loop in this program }
{ when the user types a slash (/). a procedure activates a procedure}
{ which will execute the command. These procedures are located in the}
{ above modules.                                                     }

{ For easy reference the source code module number is shown in a     }
{ comment on the right following the procedure call.                 }

procedure Commands;
begin
  GotoXY(1,24);
  HighVideo;
  Write('/ restore Quit, Load, Save, Recalculate, Print, Format, AutoCalc, Help ');
  Read(Kbd,Ch);
  Ch:=UpCase(Ch);
  case Ch of                                             { In module }
    'Q': Halt;
    'F': Format;                                               {  04 }
    'S': Save;                                                 {  03 }
    'L': Load;                                                 {  03 }
    'H': Help;                                                 {  03 }
    'R': Recalculate;                                          {  05 }
    'A': Auto;                                                 {  00 }
    '/': Update;                                               {  01 }
    'C': Clear;                                                {  01 }
    'P': Print;                                                {  03 }
  end;
  Grid;                                                        {  01 }
  GotoCell(FX,FY);                                             {  02 }
end;

{ Procedure Hello says hello and activates the help procedure if the }
{ user presses anything but Return                                   }

procedure Welcome;

  procedure Center(S: AnyString);
  var I: integer;
  begin
    for I:=1 to (80-Length(S)) div 2 do Write(' ');
    writeln(S);
  end;

begin { procedure Wellcome }
  ClrScr; GotoXY(1,9);
  Center('Welcome to MicroCalc.  A Turbo demonstation program');
  Center('Press any key for help or <RETURN> to start');
  GotoXY(40,12);
  Read(Kbd,Ch);
  if Ch<>^M then Help;
end;

{.PA}
{*********************************************************************}
{*          THIS IS WHERE THE PROGRAM STARTS EXECUTING               *}
{*********************************************************************}

begin
  Init;                                                        {  01 }
  Welcome;
  ClrScr; Grid;                                                {  01 }
  GotoCell(FX,FY);
  repeat
    Read(Kbd,Ch);
    if KeyPressed then
    begin
      read(kbd,Ch);
      IBMCh(Ch);
    end;
    case Ch of
      ^E:       MoveUp;                                        {  02 }
      ^X,^J:    MoveDown;                                      {  02 }
      ^D,^M,^F: MoveRight;                                     {  02 }
      ^S,^A:    MoveLeft;                                      {  02 }
      '/':      Commands;
      ^[:       GetCell(FX,FY);                                {  04 }
    else
      if Ch in [' '..'~'] then
      GetCell(FX,FY);                                          {  04 }
    end;
  until true=false;          { (program stops in procedure Commands) }
end.

