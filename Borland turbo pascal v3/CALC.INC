{*************************************************************************}
{                    MicroCalc Module 000                                 }
{                    Last Modified : 7-22-85                              }
{                                                                         }
{  Purpose : Miscellaneous utilities and commands.                        }
{                                                                         }
{*************************************************************************}

procedure Help; forward; { procedure Help is forward declared in the int- }
                         { erest of keeping all miscellaneous routines    }
                         { grouped in one module.                         }


{ procedure Center centers the string passed as the paramater on the      }
{ screen. NOTE : This routine assumes an 80 column screen.                }

procedure Center(S : AnyString);
var
  I : Integer;
begin
  for I := 1 to ((80-Length(S)) div 2) do
    Write(' '); {Fill beginning of line with spaces based on the length(S)}
  writeln(S);
end; { end Sub-procedure Center }

{ procedure Welcome says Welcome and activates the help procedure if the  }
{ user presses any key other than Carriage Return.                        }

procedure Welcome;
begin { procedure Welcome }
  ClrScr;
  GotoXY(1,9);
  Center('Welcome to MicroCalc.  A Turbo Pascal demonstration program');
  Center('Press any key for help or <RETURN> to start');
  GotoXY(40,12);
  Read(Kbd,Ch);
  { If Ch entered does not equal a carriage return then call Help routine.}
  if Ch <> ^M then Help;
end;  { end procedure Welcome }

{ procedure Msg outputs the string, passed in as a paramater, to the      }
{ screen.                                                                 }

procedure Msg(S : AnyString);
begin
  GotoXY(1,24);
  ClrEol;
  Write(S);
  ClrEol;
end;     { End procedure Msg }

{ The procedure Flash causes the string input as a paramater to flash by  }
{ alternately writeing it to the screen in LowVideo and NormVideo.        }

{ NOTES :
    1. procedure Flash allows you to specify the column in which
       the string will be written. A possible extension of the
       routine could be to allow the user to specify the row also.
    2. By setting the blink paramater to true or false the string
       will flash or not flash. If Blink is true the string will
       Flash until a key is pressed.
    3. Upon exit of the procedure, the string will be written in
       LowVideo regardless of the value of Blink                          }

procedure Flash(X : Integer; S : AnyString; Blink : boolean);
begin
  NormVideo;
  GotoXY(X,23);
  Write(S);
  if Blink then   { Check value of Blink, if true then execute the repeat }
  begin           { until loop.                                           }
    repeat
      GotoXY(X,23);
      Blink := not Blink;      { By modifying the value of Blink after    }
      if Blink then            { each iteration of the loop, we can use   }
        NormVideo              { Blink's value as a test for the appro-   }
      else                     { priate Video attribute value.            }
        LowVideo;
      Write(S);
      Delay(175);
    until KeyPressed;
  end;
  LowVideo;
end;    { End procedure Flash }

{ procedure IBMCh  determines the extended scan code read in and returns  }
{ a one character interpolation of the characters read in.                }

procedure IBMCh(var Ch: Char);
begin
  case Ch of
    'H': Ch := ^E;
    'P': Ch := ^X;
    'M': Ch := ^D;
    'K': Ch := ^S;
    'S': Ch := #127;
    'R': Ch := ^V;
    'G', 'I', 'O',
    'Q': Ch := #00;
  end;
end;   { End procedure IBMCh }

procedure Auto;  { Toggles automatic calculation mode on and off          }
begin
  AutoCalc:=not AutoCalc;
  if AutoCalc then  Flash(60,'AutoCalc: ON ',false)
  else Flash(60,'AutoCalc: OFF',false);
end;

{*************************************************************************}
{                     MicroCalc Module 001                                }
{                     Last Modified 7-22-85                               }
{                                                                         }
{  Purpose : initialize Spread sheet, redraw screen, and clear current    }
{            spread sheet                                                 }
{                                                                         }
{*************************************************************************}

{ procedure Grid Displays the entire spread sheet grid and command line.  }

procedure Grid;
var
  I     : Integer;
  Count : Char;

begin
  NormVideo;
  For Count := 'A' to FXMax do          { Display Column Names (A..FXMax) }
  begin
    GotoXY(XPos[Count],1);
    Write(Count);
  end;
  GotoXY(1,2);
  for I := 1 to FYMax do                 { Display Row numbers (1..FYMax) }
    writeln(I:2);
  LowVideo;
  if AutoCalc then                                  { Display Status line }
    Flash(60,'AutoCalc: ON' ,false)
  else
    Flash(60,'AutoCalc: OFF',false);
  Flash(33,'  Type / for Commands',false);
end;  { End procedure Grid }

{ procedure Init initializes the values of each of the cells in the grid. }
{      NOTE : Initializing variables in TURBO PASCAL is very important.   }

procedure Init;
var
  I        : ColumnName;
  J        : Integer;
  LastName : string[2];

begin
  for I := 'A' to FXMAX do        { Traverse grid Column by Column - Row  }
  begin                           { by Row, initializing each cell        }
    for J := 1 to FYMAX do
    begin
      with Sheet[I,J] do          { Access record representing this cell  }
      begin
        CellStatus := [Txt];          { Default cell attribute            }
        Contents   := '';             { Value of default cell attribute   }
        Value := 0;                   { Default value of numeric field    }
        DEC := 2;                     { Default number of decimals        }
        FW := 10;                     { Default field width               }
      end;
    end;
  end;
  AutoCalc := True;                   { AutoCalc defaults to True or ON   }
  FX:='A'; FY:=1;                     { Field A1 is default current field }
end;  { End procedure Init }

{ procedure Clear clears the current worksheet.                           }

procedure Clear;
begin
  NormVideo;
  GotoXY(1,24); ClrEol;
  Write('Clear this worksheet? (Y/N) ');
  repeat
    Read(Kbd,Ch)
  until Upcase(Ch) in ['Y','N'];
  Write(Upcase(Ch));
  if UpCase(Ch)='Y' then
  begin
    ClrScr;
    Init;
    Grid;
  end;
end;  { End procedure Clear }

{*************************************************************************}
{                         MicroCalc Module 002                            }
{                         Last Modified 7-22-85                           }
{                                                                         }
{  Purpose : Cursor movement whithin the spread sheet                     }
{                                                                         }
{*************************************************************************}

{ procedure DisplayType outputs the current cell it's type and if the     }
{ cell's type is a formula the formula is also output.                    }

procedure DisplayType;
begin
  with Sheet[FX,FY] do
  begin
    GotoXY(1,23);
    Write(FX,FY:2,' ');
    if Formula in CellStatus  then  { Determine Type of Cell }
      write('Formula ')
    else
      if Constant in CellStatus then
        Write('Numeric ')
      else
        if Txt in CellStatus then
          Write('Text    ');
    GotoXY(1,24); ClrEol;
    if Formula in CellStatus
      then Write(Contents);
  end;
end;  { End procedure DisplayType }

{*************************************************************************}
{ The following procedures move between the Cells on the calc sheet. Each }
{ Cell has an associated record containing its X,Y coordinates and data.  }
{ See the type definition for "Cell".                                     }
{*************************************************************************}

{ procedure GotoCell goes to the cell indicated by the procedures         }
{ paramaters and outputs it's current value.                              }

procedure GotoCell(GX: ColumnName; GY: Integer);
begin
  with Sheet[GX,GY] do         { Get specified record (i.e. cell)         }
  begin
    NormVideo;
    GotoXY(XPos[GX],GY+1);     { Go to leftmost column of specified cell  }
    Write('           ');      { Clear the cell                           }
    GotoXY(XPos[GX],GY+1);
    if Txt in CellStatus then
      Write(Contents)
    else  { cell does not contain text }
    begin
      if DEC >= 0 then             { check if number of decimal spaces is }
        Write(Value:FW:DEC)        { specified else output in scientific  }
      else                         { notation.                            }
        Write(Value:FW);
    end;
    DisplayType;
    GotoXY(XPos[GX],GY+1);
  end;
  LowVideo;
end;

{ procedure LeaveCell simply writes the current cell's contents in        }
{ LowVideo.                                                               }

procedure LeaveCell(FX : ColumnName; FY : Integer);
begin
  with Sheet[FX,FY] do             { Get record representing current cell }
  begin
    GotoXY(XPos[FX],FY + 1);
    LowVideo;
    if Txt in CellStatus then
      Write(Contents)
    else
    begin
      if DEC >= 0 then
        Write(Value:FW:DEC)
      else
        Write(Value:FW);
    end;
  end;
end;   { End procedure LeaveCell }

procedure Update;
var
  UFX : ColumnName;
  UFY : Integer;

begin
  ClrScr;
  Grid;
  for UFX := 'A' to FXMax do
    for UFY := 1 to FYMax do
  if Sheet[UFX,UFY].Contents <> '' then
    LeaveCell(UFX,UFY);
  GotoCell(FX,FY);
end;

{ procedure MoveDown updates the current cell by calling procedure        }
{ LeaveCell. It then moves the cursor down on position. Note : The repeat }
{ loop in this routine does the actuall moving of the cursor. A valid cell}
{ must be found before the cursor can be moved. The cell is valid if it's }
{ CellStatus is not in [OverWritten,Locked] .                             }

procedure MoveDown;
var
  Start : Integer;

begin
  LeaveCell(FX,FY);
  Start := FY;
  repeat
    FY := FY + 1;
    if FY > FYMax then
      FY := 1;
  until (Sheet[FX,FY].CellStatus * [OverWritten,Locked] = []) or (FY = Start);
  if FY <> Start then
    GotoCell(FX,FY);
end;    { End procedure MoveDown }

{ procedure MoveUp updates the current cell, then moves the cursor up one }
{ position. The note for the last procedure applies here also.            }

procedure MoveUp;
var
  Start : Integer;

begin
  LeaveCell(FX,FY);
  Start := FY;
  repeat
    FY := FY - 1;
    if FY < 1 then
    FY := FYMax;
  until (Sheet[FX,FY].CellStatus * [OverWritten,Locked] = []) or (FY = Start);
  if FY <> Start then
    GotoCell(FX,FY);
end;  { End procedure MoveUp }

{ procedure MoveRight acts the same as the previous two procedures with   }
{ the exception of the direction it moves the cursor.                     }

procedure MoveRight;
var
  Start : ColumnName;

begin
  LeaveCell(FX,FY);
  Start := FX;
  repeat
    FX := Succ(FX);
    if FX > FXMax then
    begin
      FX := 'A';
      FY := FY + 1;
      if FY > FYMax then
        FY := 1;
    end;
  until (Sheet[FX,FY].CellStatus * [OverWritten,Locked] = []) or (FX = Start);
  if FX <> Start then
    GotoCell(FX,FY);
end;  { End procedure MoveRight }

{ procedure MoveLeft acts the same as the previous three procedures with  }
{ the exception of the direction it moves the cursor.                     }

procedure MoveLeft;
var
  Start : ColumnName;

begin
  LeaveCell(FX,FY);
  Start := FX;
  repeat
    FX := Pred(FX);
    if FX < 'A' then
    begin
      FX := FXMax;
      FY := FY - 1;
      if FY < 1 then
        FY := FYMax;
    end;
  until (Sheet[FX,FY].CellStatus * [OverWritten,Locked] = []) or (FX = Start);
  if FX <> Start then
    GotoCell(FX,FY);
end;  { End procedure MoveLeft }

{*************************************************************************}
{                        MicroCalc Module 003                             }
{                        Last Modified : 7-22-85                          }
{                                                                         }
{  PURPOSE:            Load, Save and Print a spread sheet.               }
{                      Display on-line manual.                            }
{*************************************************************************}

{ function Exist returns a boolean value indicating the existence of
  the file passed in as a paramater.                                 }

function Exist(FileN : AnyString): boolean;

var
  F : file;

begin
   {$I-}
   assign(F,FileN);
   reset(F);
   {$I+}
   if IOResult <> 0 then
     Exist := false
   else
   begin
     Exist := true;
     close(F);
   end;
end; { End function Exist }


{ Procedure GetFileName reads a filename input by the user. The
  filename's extension is passed in as the second paramater of the
  procedure.
  Note : As the procedure stands, the user can not use path names.   }

Procedure GetFileName(var Line : AnyString; FileType : String3);

var
  i : Integer;

begin
  Line := '';
  Read(Line);
  clreol;
  if Length(Line) > 8 then
  begin
    clreol;
    Line[0] := chr(8);
    Msg('Filename Truncated to : ' + Line);
  end;
  for i := 1 to Length(Line) do
  begin
    Line[i] := UpCase(Line[i]);
    if not (Line[i] in ['A'..'Z','0'..'9'
                       (*,'!','#'..')','-',',','/','@','\','_','`','{','}'*)
                       ]) then
      Msg('Invalid Filename');
  end;
  if Line <> '' then
    Line := Line + '.' + FileType;
end;  { End Procedure GetFileName }




{ Procedure Save saves the current spreadsheet to a file.
  Note : this routine attaches the extension 'MCS' to the filename.  }

Procedure Save;

var
  I : ColumnName;
  J : Integer;

begin
  NormVideo;
  Msg('Save: Enter filename  ');
  GetFileName(Filename,'MCS');
  if FileName <> '' then
  begin
    Assign(MCFile,FileName);
    Rewrite(MCFile);
    for I := 'A' to FXmax do
      for J := 1 to FYmax do
        write(MCfile,Sheet[I,J]);
    Grid;
    Close(MCFile);
    LowVideo;
    GotoCell(FX,FY);
  end;
end;  { End Procedure Save }



{ Procedure Load loads a spreadsheet from a file.
  Note : the procedure gives the user two chances to enter the
         correct filename.                                           }

Procedure Load;

begin
  NormVideo;
  Msg('Load: Enter filename  ');
  GetFileName(Filename,'MCS');    { Get filename                     }
  if (Filename <> '') then        { Check if filename is legal       }
    if (not exist(FileName)) then { if filename not legal then       }
      repeat                      { prompt the user again.           }
        Msg('File not Found: Enter another filename  ');
        GetFileName(Filename,'MCS');
      until exist(FileName) or (FileName = '');
  if FileName <> '' then
  begin
    ClrScr;
    Msg('Please Wait. Loading definition...');
    Assign(MCFile,FileName);
    Reset(MCFile);
    for FX := 'A' to FXmax do     { Read records from file }
      for FY := 1 to FYmax do
        read(MCFile,Sheet[FX,FY]);
    FX := 'A';
    FY := 1;
    LowVideo;
    UpDate;
  end;
  GotoCell(FX,FY);
end;  { End Procedure Load }



{ Procedure Print prints the current spreadsheet to a file.
  Note : a possible improvement might be to allow the user to specify
         not only the left margin of the paper, but also the width
         of the paper. Also allowing output to go directly to the
         printer.                                                    }

Procedure Print;

var
  I          : ColumnName;
  J, Count,
  LeftMargin : Integer;
  P          : string[20];
  MCFile     : Text;

begin
  NormVideo;
  Msg('Print: Enter filename "P" for Printer> ');
  GetFileName(Filename,'LST');
  Msg('Left margin > ');
  Read(LeftMargin);
  if FileName = 'P.LST' then
    FileName := 'LST';
  Msg('Printing to: ' + FileName + '....');
  Assign(MCFile,FileName);
  Rewrite(MCFile);
  For Count := 1 to 5 do
    Writeln(MCFile);
  for J := 1 to FYmax do
  begin
    Line := '';
    for I := 'A' to FXmax do
    begin
      with Sheet[I,J] do
      begin
        while (Length(Line) < XPOS[I] - 4) do
          Line := Line + ' ';
        if (Constant in CellStatus) or (Formula in CellStatus) then
        begin
          if not (Locked in CellStatus) then
          begin
            if DEC > 0 then
              Str(Value:FW:DEC,P)
            else
              Str(Value:FW,P);
            Line := Line + P;
          end;  { End if not (Locked in CellStatus) then }
        end  { End if or then }
        else
          Line := Line + Contents;
      end; { End With Statement }
    end; { End For Loop - have gotten one line }
    For Count := 1 to LeftMargin do  { Insert left margin  }
      Write(MCFile,' ');
    writeln(MCFile,Line);
  end; { End for loop -  move to next line }
  Grid;
  Close(MCFile);
  LowVideo;
  GotoCell(FX,FY);
end;  { End Procedure Print }



{ Procedure Help dislpays the help file CALC.HLP for the user.            }

Procedure Help;

type
  str80 = string[80];
  Pages = array[0..200] of str80;

var
  H    : text;
  Line : string[80];
  LineCounter, EndOfFile, ErrorResult, BeginPage,
  J    : Integer;
  Bold : boolean;
  Buffer : ^Pages;

  Procedure DisplayMessage;

  begin
    GotoXY(6,24);
    NormVideo;
    write('Press ');
    LowVideo;
    Write('`P`');
    NormVideo;
    Write(' for previous page ');
    LowVideo;
    Write('`N`');
    NormVideo;
    Write(' for next,');
    LowVideo;
    Write('`Esc`');
    NormVideo;
    Write(' to exit Help file.');
  end;

  { Procedure GetPages reads the help file from disk into an array of a   }
  { dynamicly allocated array. NOTE : the number of lines read in is kept }
  { in the zero'th index of the array.                                    }

  Procedure GetPages;

  var
    st : string[10];
    count : integer;

  begin
    count := 1;
    Assign(H,'CALC.HLP');
    Reset(H);
    while not Eof(H) do
    begin
      Readln(H,Buffer^[count]);
      count := count + 1;
    end;
    close(H);
    Str(count,st);
    Buffer^[0] := st;
  end;



begin
  LineCounter := 1;                              { Initialize line counter}
  if Exist('CALC.HLP') then
  begin
    New(Buffer);                                 { Allocate dynamic array }
    GetPages;                                    { Read in Help File      }
    Val(Buffer^[0],EndOfFile,ErrorResult);       { EndOfFile := # of Lines}
    while LineCounter < EndOfFile do
    begin
      BeginPage := LineCounter - 1;
      if BeginPage < 1 then         { If Previous page is called while on }
        BeginPage := 1;             { first page, Beginpage is off by 1.  }
      ClrScr;
      Bold := false;
      LowVideo;
      Line := Buffer^[LineCounter];     { Get first line of current page. }

      { This while loop steps through the array looking for the end of    }
      { page indicator '.PA', writing out each line as it goes.           }

      while (LineCounter < EndOfFile) and (Line <> '.PA') do
      begin
        Write('     ');
        For J := 1 to Length(Line) do
        begin
          if Line[J] = ^B then { Check for bold face type }
          begin
            Bold := not Bold;  { Toggle Bold type }
            if Bold then
              NormVideo
            else
              LowVideo;
          end
          else
            write(Line[J]);
        end;  { End for loop - have written entire line }
        Writeln;
        LineCounter := LineCounter + 1;
        Line := Buffer^[LineCounter];                     { Get next line }
      end; { end while }
      DisplayMessage;
      repeat
        read(Kbd,Ch);
      until Upcase(Ch) in ['P','N',#27];
      case UpCase(Ch) of
        'P' : begin                          { Get start of previous page }
                repeat
                  BeginPage := BeginPage - 1;
                until (Buffer^[BeginPage] = '.PA') or (BeginPage < 1);
                LineCounter := BeginPage + 1;
              end;
        'N' : LineCounter := LineCounter + 1;    { Get start of next page }
        #27 : LineCounter := EndOfFile;    { force counter to end of file }
      end;
    end;   { end while }
    Dispose(Buffer);                           { Deallocate dynamic array }
    UpDate;                                    { Return to Spread Sheet   }
  end  { End if then statement }
  else { Help file did not exist }
  begin
    Msg('To get help the file CALC.HLP must be on your disk. Press <RETURN>');
    repeat Read(kbd,Ch) until Ch=^M;
    GotoCell(FX,FY);
  end;
end;  { End procedure Help }


{*************************************************************************}
{                          MicroCalc Module 004                           }
{                          Last Modified 7-22-85                          }
{                                                                         }
{  PURPOSE:            Evaluate formulas.                                 }
{                      Recalculate spread sheet.                          }
{                                                                         }
{  NOTE:               This module contains recursive procedures          }
{*************************************************************************}

{$A-}

{ procedure NextCh returns the next Character in the formula of the cell  }
{ currently being evaluated.                                              }

procedure NextCh(var Position : Integer;
                 var NextChar : Char;
                     Formula  : AnyString);
begin
  repeat
    Position := Position + 1;
    if Position <= Length(Formula) then
      NextChar := Formula[Position]
    else
      NextChar := eofline;
  until NextChar <> ' ';
end;  { End procedure NextCh }

{ procedure Evaluate evaluates a string passed to it, the string          }
{ represents an expression or formula.                                    }

procedure Evaluate(var IsFormula : Boolean;
                   var Formula   : AnyString;
                   var Value     : Real;
                   var ErrorPosition    : Integer);
var
  Position : Integer;    { Current position in formula                    }
  EvalCh   : Char;       { Current Character being scanned                }
  EXY      : string[3];  { Intermediate string for conversion             }

  function Expression(var ExpressionCh : Char):Real;forward;

  { Sub-function Fact returns the factorial value of the integer passed in}
  { as it's paramater.                                                    }

  function Fact(I : Real): Real;

  {WARNING: This program will not compile using TURBO-87.COM unless you
   have an 8087 math coprocessor installed in your computer.  Use TURBO.
   COM to compile}
  begin
    if ((I > 0.0) and (I < 34.0)) then { check if value is in legal range.}
      Fact := I * Fact(I - 1)          { Fact(34) is out of range.        }
    else
      Fact := 1.0;
  end; { End sub-function Fact }

  { function Factor is the meat of procedure Evaluate. Within this pro-   }
  { -cedure the current subexpression is actualy evaluated. Using nested  }
  { If-Then-Else statements, the function determines if the sub-expression}
  { is a number, the sum of a subrange of cells (i.e A1>A5), or a         }
  { function(i.e.ABS(X) ).                                                }

  function Factor(var FactorCh : Char): Real;

  type
    { Declare a set of the standard functions }
    Standardfunction =
     (fabs,fsqrt,fsqr,fsin,fcos,farctan,fln,flog,fexp,ffact);

    { Declare array with indices being the Standard function names.       }
    StandardfunctionList = array[Standardfunction] of string[6];

  const
    { Declare Typed Constant array initializing it with function names    }
    StandardfunctionNames : StandardfunctionList =
     ('ABS','SQRT','SQR','SIN','COS','ARCTAN','LN','LOG','EXP','FACT');

  var
    E, EE, L   : Integer;       { temporary variables                     }
    Found      : Boolean;       { boolean value - expression found or not }
    CellSum, F : Real;          { F holds value returned by recursive     }
                                { calls to Factor                         }
    Sf         : Standardfunction;
    OldExpFY,                   { ExpEFX and ExpFY hold the positions of  }
    ExpFY,                      { the cells referenced to in any formulas }
    SumFY,                      { SumFX and SumFY hold the sum to be      }
    Start      : Integer;       { calculated at the fromula's position    }
    OldExpFX, ExpFX, SumFX  : ColumnName;

  begin { begin main block of function Factor }
    F := -1;
    if FactorCh in Numbers then   { Get integer or real number            }
    begin
      Start := Position;        { Save first position of number in string }
      repeat                    { Skip to non number character            }
        NextCh(Position,FactorCh,Formula);
      until not (FactorCh in Numbers);
      if FactorCh = '.' then    { is decimal point                        }
        repeat
          NextCh(Position,FactorCh,Formula);
        until not (FactorCh in Numbers);
      if FactorCh = 'E' then    { is Exponent symbol                      }
      begin
        NextCh(Position,FactorCh,Formula);
        repeat
          NextCh(Position,FactorCh,Formula)
        until not (FactorCh in Numbers);
      end;
      { Get value of number }
      Val(Copy(Formula,Start,Position - Start),F,ErrorPosition);
      if FactorCh = ')' then
        NextCh(Position,FactorCh,Formula);
    end   { end if FactorCh in Numbers }
    else  { FactorCh not a number      }
    if FactorCh = '(' then
    begin
      NextCh(Position,FactorCh,Formula);
      F := Expression(FactorCh);
      if FactorCh = ')' then   {if matching paren is found then read next }
        NextCh(Position,FactorCh,Formula)
      else                   { else there is an error in the expression.  }
        ErrorPosition := Position;
    end  { End if FactorCh = '(' }
    else                 { else FactorCh <> Number or '('}
    {FactorCh may be a cell reference or function name or a function name }
    if FactorCh in ['A'..'G','L','S'] then
    begin
      ExpFX := FactorCh;
      NextCh(Position,FactorCh,Formula);
      if FactorCh in Numbers then
      begin
        F := 0;
        EXY := FactorCh;
        NextCh(Position,FactorCh,Formula);
        if FactorCh in Numbers then
        begin
          EXY := EXY + FactorCh;
        NextCh(Position,FactorCh,Formula);
        end;
        Val(EXY,ExpFY,ErrorPosition);
        IsFormula := true;     { the expression is a formula              }

        { Check if content of the cell referenced in the formula is a     }
        { constant. If so then verify that it has been calculated. If the }
        { constant has been calculated then make a recursive call to the  }
        { procedure Evaluate to evaluate the contents of the cell.        }

        if (Constant in Sheet[ExpFX,ExpFY].CellStatus) and
                        not (Calculated in Sheet[ExpFX,ExpFY].CellStatus) then
        begin
          Evaluate(Form,Sheet[ExpFX,ExpFY].contents,f,ErrorPosition);
          { Update CellStatus to indicate that the cells value has been   }
          { calculated.                                                   }

          Sheet[ExpFX,ExpFY].CellStatus :=
                                Sheet[ExpFX,ExpFY].CellStatus + [Calculated]
        end  { End if ... and not ... Statement }

        { The cell refered to either didn't contain a constant or the     }
        { constants value was already calculated.                         }

        else { If the contents of the cell are not text then they must be }
             { a constant.                                                }
          if not (Txt in Sheet[ExpFX,ExpFY].CellStatus) then
            F := Sheet[ExpFX,ExpFY].Value;
        if FactorCh = '>' then  { Check for formula range designator      }
        begin
          OldExpFX  := ExpFX;
          OldExpFY := ExpFY;
          NextCh(Position,FactorCh,Formula);
          ExpFX := FactorCh;
          NextCh(Position,FactorCh,Formula);
          if FactorCh in Numbers then
          begin
            EXY := FactorCh;
            NextCh(Position,FactorCh,Formula);
            if FactorCh in Numbers then
            begin
              EXY := EXY + FactorCh;
              NextCh(Position,FactorCh,Formula);
            end;
            if FactorCh = ')' then
              NextCh(Position,FactorCh,Formula);
            val(EXY,ExpFY,ErrorPosition);
            Cellsum := 0;

            { visit each cell specified in sub-range of formula }

            for SumFY := OldExpFY to ExpFY do
            begin
              for SumFX := OldExpFX to ExpFX do
              begin
                F := 0;
                { Note that the next few statements are identical to the  }
                { statements about fifty lines back.                      }
                if (Constant in Sheet[SumFX,SumFY].CellStatus) and
                        not (Calculated in Sheet[SumFX,SumFY].CellStatus) then
                begin
                  Evaluate(Form,Sheet[SumFX,SumFY].contents,f,ErrorPosition);
                  Sheet[SumFX,SumFY].CellStatus :=
                                 Sheet[SumFX,SumFY].CellStatus+[Calculated];
                end
                else
                if not (Txt in Sheet[SumFX,SumFY].CellStatus) then
                  F := Sheet[SumFX,SumFY].Value;
                Cellsum := Cellsum + f;
                f := Cellsum;
              end;  {  for SumFX := OldExpFX to ExpFX do }
            end;  {  for SumFY := OldExpFY to ExpFY do }
          end;  {  if FactorCh in Numbers then }
        end  {  if FactorCh = '>' then }
        else { FactorCh = ')' }
        if FactorCh = ')' then
        begin
          NextCh(Position,FactorCh,Formula);
          found := true;
        end;
      end  {  if FactorCh in Numbers then }
      else   {FactorCh is second letter in function name (i.e. ABS or LN )}
      begin
        found := false;
        for sf := fabs to ffact do     { step through all possible func's }
        if not found then
        begin
          l := Length(StandardfunctionNames[sf]);
          if copy(Formula,Position - 1,l) = StandardfunctionNames[sf] then
          begin
            Position := Position + l - 1;
            NextCh(Position,FactorCh,Formula);
            F := Expression(FactorCh);
            case sf of
              fabs    : f := abs(f);
              fsqrt   : begin
                          if f > 0 then
                            f := sqrt(f) { WARNING: This progam will not
                                           compile with TURBOBCD.COM. (Sqrt,
                                           Sin, and similar operations are
                                           not implemented in the BCD
                                           version.) Use TURBO.COM to
                                           compile. }
                          else
                            F := -1;
                        end;
              fsqr    : begin
                          if Abs(f) < Sqrt(exp(38) * ln(1)) then
                            f := sqr(f)
                          else
                            F := -1;
                        end;
              fsin    : f := sin(f);
              fcos    : f := cos(f);
              farctan : f := arctan(f);
              fln     : f := ln(f);
              flog    : f := ln(f)/ln(10);
              fexp    : begin
                          if abs(f) < 89 then { Exp(+/-89) will cause     }
                            f := exp(f)       { floating point Overflow.  }
                          else
                            f := -1;
                        end;
              ffact   : f := fact(int(f));
            end;   { end case }
            Found := true;
          end; { if  then Statement }
        end; { if not found Statement }
        if not Found then
          ErrorPosition := Position;
      end;   { else statement }
    end;  {  if FactorCh in ['A'..'G'] then }
    Factor := F;
  end;  { End Sub-function Factor}

  { Sub-function Signed Factor first determines the sign of the exp-      }
  { -ression. It then calls the function Factor to get the value of the   }
  { expression.                                                           }

  function SignedFactor(var SignedCh : Char):Real;

  begin { begin main block of procedure SignedFactor }
    if SignedCh = '-' then
    begin
      NextCh(Position,SignedCh,Formula);
      SignedFactor := -Factor(SignedCh);
    end
    else
      SignedFactor := Factor(SignedCh);
  end; { End Sub-function SignedFactor }

  { Sub-function Term returns the value of the sub-expression being eval- }
  { -uated. If the expression contains an exponent expression Term eval-  }
  { -uates it.                                                            }

  function Term(var TermCh : Char):Real;

  var
    T : Real;

  begin { begin main block of procedure Term }
    T := SignedFactor(TermCh);
    while TermCh = '^' do
    begin
      NextCh(Position,TermCh,Formula);
      T := exp(ln(t) * SignedFactor(TermCh));
    end;
    Term := T;
  end; { End Sub-function Term }

  { Sub-function SimpleExpression calls the function term and evaluates   }
  { the simple expression returned.                                       }

  function SimpleExpression(var SimpleExpCh : Char):Real;

  var
    SimpExp   : Real;
    Opr : Char;

  begin { begin main block of procedure SimpleExpression }
    SimpExp := Term(SimpleExpCh);
    while SimpleExpCh in ['*','/'] do
    begin
      Opr := SimpleExpCh;
      NextCh(Position,SimpleExpCh,Formula);
      case Opr of
        '*' : SimpExp := SimpExp * term(SimpleExpCh);
        '/' : SimpExp := SimpExp / term(SimpleExpCh);
      end;
    end;
    SimpleExpression := SimpExp;
  end; { End Sub-function SimpleExpression }

  { Sub-function Expression evaluates the expression contained in the     }
  { current cell.                                                         }

  function Expression{(var ExpressionCh : Char):Real;forward};

  var
    E   : Real;
    Opr : Char;

  begin { begin main block of function Expression }
    E := SimpleExpression(ExpressionCh);
    while ExpressionCh in ['+','-'] do
    begin
      Opr := ExpressionCh;
      NextCh(Position,ExpressionCh,Formula);
      case Opr of
        '+' : E := E +
            SimpleExpression(ExpressionCh);
        '-' : E := E -
            SimpleExpression(ExpressionCh);
      end;
    end;
    Expression := E;
  end; { End Sub-function Expression }

begin { main body of procedure Evaluate }
  if Formula[1] = '.' then
    Formula := '0' + Formula;
  if Formula[1] = '+' then
    delete(Formula,1,1);
  IsFormula := false;
  Position := 0;
  NextCh(Position,EvalCh,Formula);
  Value := Expression(EvalCh);
  if EvalCh = EofLine then
    ErrorPosition := 0
  else
    ErrorPosition := Position;
end; { End procedure Evaluate }

{ procedure Recalculate steps through the entire spreadsheet recalculating}
{ each cell.                                                              }

procedure Recalculate;
var
  RFX      : ColumnName;
  RFY      : Integer;
  OldValue : Real;
  Err      : Integer;

begin
  LowVideo;
  GotoXY(1,24);
  ClrEol;
  Write('Calculating..');
  for RFY := 1 to FYMax do    { Reevaluate each cell updating it's        }
  begin                       { contents when appropriate.                }
    for RFX := 'A' to FXMax do
    begin
      with Sheet[RFX,RFY] do
      begin
        if (Formula in CellStatus) then
        begin
          CellStatus := CellStatus + [Calculated];
          OldValue := Value;
          Evaluate(Form,Contents,Value,Err);
          if OldValue <> Value then
          begin
            GotoXY(XPos[RFX],RFY + 1);
            if (DEC >= 0) then
              Write(Value:FW:DEC)
            else
              Write(Value:FW);
          end;
        end;
      end;
    end;
  end;
  GotoCell(FX,FY);
end;  { End procedure Recalculate }

{*************************************************************************}
{                          MicroCalc Module 005                           }
{                          Last Modified 7-22-85                          }
{                                                                         }
{   PURPOSE:            Read the contents of a cell and update            }
{                       associated cells.                                 }
{                                                                         }
{*************************************************************************}

{ procedure GetCell gets the contents of a cell from the user. This       }
{ routine gets all input entered by the user. procedure GetCell           }
{ initializes the temporary variable "S" with the last read Character.    }
{ Depending on this character, it then  calls GetFormula, GetText, or     }
{ EditCell.                                                               }

procedure  GetCell(FX : ColumnName; FY : Integer);
var
  S             : AnyString;
  NewStatus     : SetofAttri;
  ErrorPosition : Integer;
  EvalResult    : Real;
  I             : ColumnName;
  Abort,
  IsForm        : Boolean;

  { Sub-procedure ClearCells clears the current cell and its associated   }
  { cells. An associated cell is a cell overwritten by data from the cur- }
  { -rent cell. The data can be text in which case the cell has the attri-}
  { -bute "OverWritten". If the data is a result  from an expression and  }
  { the field width is larger than 11 then the associated  cell is        }
  { "Locked."                                                             }

  procedure ClearCells(FX : ColumnName; FY : Integer);
  var
    I : ColumnName;

  begin
    I := FX;
    repeat
      with Sheet[I,FY] do
      begin
        GotoXY(XPos[I],FY + 1);
        write('           ');
        I := Succ(I);
      end;
        { Cell is not OverWritten not Locked }
    until ([OverWritten,Locked] * Sheet[I,FY].CellStatus = []);
  end;  { End Sub-procedure ClearCells }

  { Sub-procedure GetLine is the routine used to get input from the user. }
  { The procedure allows editing of input and checks that the input con-  }
  { -tains legal characters.                                              }

  procedure GetLine(ColNO, LineNO,       { Where to start line  }
                    MAX : Integer;       { Max length           }
                    UpperCase : Boolean);{ True if auto Upcase  }
  var
    X        : Integer;
    InsertOn : boolean;
    OkChars  : set of Char;

    procedure GotoX;
    begin
      GotoXY(X + ColNo - 1,LineNo);
    end;

  begin
    OkChars := [' '..'}'];
    InsertOn := true;
    X := 1;
    GotoX;
    Write(S);
    if Length(S) = 1 then
      X := 2;
    if ErrorPosition <> 0 then  { there was an error found }
      X := ErrorPosition;
    GotoX;
    repeat
      Read(Kbd,Ch);
      if KeyPressed then
      begin
        Read(kbd,Ch);
        IBMCh(Ch);
      end;
      if UpperCase then
        Ch := UpCase(Ch);
      case Ch of
         ^[ : begin
                S := chr($FF);             { abort editing }
                Ch := ^M;
              end;
         ^D : begin                        { Move cursor right }
                X := X + 1;
                if (X > length(S) + 1) or (X > MAX) then
                  X := X - 1;
                GotoX;
              end;
         ^G : begin                        { Delete Char under cursor }
                if X <= Length(S) then
                begin
                  Delete(S,X,1);
                  Write(copy(S,X,Length(S) - X + 1),' ');
                  GotoX;
                end;
              end;
      ^S,^H : begin                        { Move cursor left }
                X := X - 1;
                if X < 1 then
                  X := 1;
                GotoX;
              end;
         ^F : begin                        { Move cursor to end of line }
                 X := Length(S) + 1;
                 GotoX;
              end;
         ^A : begin                        { Move cursor to beginning of line }
                X := 1;
                GotoX;
              end;
       #127 : begin                        { Delete left Char }
                X := X - 1;
                if (Length(S) > 0) and (X > 0)  then
                begin
                  Delete(S,X,1);
                  Write(copy(S,X,Length(S) - X + 1),' ');
                  GotoX;
                  if X < 1 then
                    X := 1;
                end
                else
                  X := 1;
              end;
         ^V : InsertOn := not InsertOn;    { Toggle Insert/Overwrite }
      else  { Not Upcase }
        begin
          if Ch in OkChars  then
          begin
            if InsertOn then
            begin
              insert(Ch,S,X);
              Write(copy(S,X,Length(S) - X + 1),' ');
            end
            else
            begin
              write(Ch);
              if X = length(S) then
                S := S + Ch
              else
                S[X] := Ch;
            end;
            if Length(S) + 1 <= MAX then
              X := X + 1
            else
              OkChars := []; { Line too Long }
            GotoX;
          end  { end if Ch in OkChars }
          else
            if Length(S) + 1 <= Max then
              OkChars:= [' '..'}']; { Line ok again }
        end;  { end case statement's else }
      end;  { end case statement }
    until CH = ^M;
  end;  { End Sub-procedure GetLine }

  { Sub-procedure GetText calls the procedure GetLine with the current    }
  { cells X,Y position as parameters. This means that text entering takes }
  { place direcly at the cells position on the Sheet.                     }

  procedure GetText;
  var
    LineLength : Integer;

  begin
    GotoXY(5,23);
    LowVideo;
    if FX = 'G' then
      LineLength := 10
    else
      LineLength := 70;
    with Sheet[FX,FY] do
      GetLine(XPos[FX],FY+1,LineLength,False);
  end;  { End Sub-procedure GetText }

  { Sub-procedure GetFormula calls the routine GetLine to get a line from }
  { the user. It then calls the routine Evaluate to evaluate the Formula  }
  { input by the user.                                                    }

  procedure GetFormula;

  begin
    GotoXY(5,23);
    LowVideo;
    repeat
      GetLine(1,24,70,True);
      if S <> Chr($FF) then
      begin
        Evaluate(IsForm,S,EvalResult ,ErrorPosition);
        if ErrorPosition <> 0 then
          Flash(15,'GetFormula Error at cursor' + ^G,false)
        else
          Flash(15,'get formula ok',false);
      end;
    until (ErrorPosition = 0) or (S = Chr($FF));
    if IsForm then
      NewStatus := NewStatus + [Formula];
  end;  { End Sub-procedure GetFormula }

  { Sub-procedure EditCell loads a copy of the current cell's contents    }
  { into the variable S before calling either GetText or GetFormula. In   }
  { this way no changes are actually made to the current cell.            }

  procedure EditCell;
  begin
    GotoXY(5,23);
    with Sheet[FX,FY] do
    begin
      S := Contents;
      if Txt in CellStatus then
        GetText
      else
        GetFormula;
    end;
  end;  { End procedure EditCell }

  { Sub-procedure UpdateCells is a little more complicated. Basically it  }
  { makes sure to tag and untag cells which have been overwritten or      }
  { cleared by data from  another cell. It also updates the current cell  }
  { with the new type and contents which are still in the temporary       }
  { variable "S".                                                         }

  procedure UpdateCells;
  var
    I       : ColumnName;
    Flength : Integer;

  begin
    Sheet[FX,FY].Contents := S;
    if Txt in NewStatus then
    begin
      I := FX;
      FLength := Length(S);
      repeat  { this repeat loop checks the status of adjoining cells to  }
              { verify that they have or have not been overwritten.       }
        I := Succ(I);
        with Sheet[I,FY] do
        begin
          FLength := Flength - 11;
          if (Flength > 0) then
          begin
            CellStatus := [Overwritten,Txt];
            Contents := '';
          end
          else
          begin
            if OverWritten in CellStatus then
            begin
              CellStatus := [Txt];
              GotoCell(I,FY);
              LeaveCell(I,FY);
            end; { if OverWritten in CellStatus }
          end;  { else }
        end;  { with Sheet[I,FY] do }
      until (I = FXMax)  or (Sheet[I,FY].Contents <> '');
      Sheet[FX,FY].CellStatus := [Txt];
    end
    else { string changed to formula or constant }
    begin
      I := FX;
      repeat   { this repeat loop checks whether or not the cell is       }
               { overwritten.                                             }
        with Sheet[I,FY] do
        begin
          if OverWritten in CellStatus then
          begin
            CellStatus := [Txt];
            Contents := '';
          end;
          I := Succ(I);
        end;
      until not (OverWritten in Sheet[I,FY].CellStatus);
      with Sheet[FX,FY] do
      begin
        CellStatus := [Constant];
        if IsForm then
          CellStatus := CellStatus + [Formula];
        Value := EvalResult ;
      end;  { with }
    end;  { else }
  end;  { End Sub-procedure UpdateCells }

begin { begin main block of procedure GetCell }
  S             := Ch;
  ErrorPosition := 0;
  Abort         := false;
  NewStatus     := [];
  EvalResult    := -1;
  if Ch in ['0'..'9','+','-','.','(',')'] then
  begin
    NewStatus := [Constant];
    if not (Formula in Sheet[FX,FY].CellStatus) then
    begin
      GotoXY(11,24);
      ClrEol;
      ClearCells(FX,FY);
      GetFormula;
    end
    else  { Formula in Sheet[FX,FY].CellStatus }
    begin
      Flash(15,'Edit formula Y/N?',true);
      repeat
        read(Kbd,Ch)
      until UpCase(CH) in ['Y','N'];
      Flash(15,'                 ',false);
      if UpCase(Ch) = 'Y' then
      begin
        EditCell;
      end
      Else
        Abort := true;
    end;
  end
  else  {  Ch not in ['0'..'9','+','-','.','(',')'] }
  begin
    if Ch = ^[ then
    begin
      NewStatus := (Sheet[FX,FY].CellStatus) * [Txt,Constant];
      EditCell;
    end
    else  { Ch <> '^[' and not in ['0'..'9','+','-','.','(',')'] }
    begin
      if formula in Sheet[FX,FY].CellStatus then
      begin
        Flash(15,'Edit formula Y/N?',true);
        repeat
          read(Kbd,Ch)
        until UpCase(CH) in ['Y','N'];
        Flash(15,'                 ',false);
        if UpCase(Ch) = 'Y' then
        begin
          EditCell;
        end
        Else
          Abort := true;
      end
      else  { formula not in Sheet[FX,FY].CellStatus }
      begin
        NewStatus := [Txt];
        ClearCells(FX,FY);
        GetText;
      end;  { End else }
    end;  { end else }
  end;  { end else }
  if not Abort then   { do neccesary bookkeeping }
  begin
    if S <> Chr($FF) then
       UpDateCells;
    GotoCell(FX,FY);
    if AutoCalc and (Constant in Sheet[FX,FY].CellStatus) then
      Recalculate;
    if Txt in NewStatus then
    begin
      GotoXY(3,FY + 1);
      Clreol;
      For I := 'A' to FXMax do
        LeaveCell(I,FY);
    end;
  end;  { end if not abort }
  Flash(15,'                ',False);
  GotoCell(FX,FY);
end;  { End procedure GetCell }

{ procedure Format is used to modify the numeric format of a range of     }
{ cells in the current column.                                            }

procedure Format;
var
  J, FW, DEC,
  FromLine, ToLine : Integer;
  Lock             : Boolean;

  { procedure GetInt reads an integer from the keyboard screening it for  }
  { illegal characters.                                                   }

  procedure GetInt(var I: Integer; Max: Integer);
  var
    S      : String[8];
    Result : Integer;
    Ch     : Char;

  begin
    S := '';
    repeat
      repeat Read( Kbd,Ch) until Ch in ['0'..'9','-',^M];
      if Ch <> ^M then
      begin
        Write(Ch);
        S := S + Ch;
        Val(S,I,Result);
      end;
    until (I >= Max) or (Ch = ^M);
    if I > Max then I := Max;
  end;  { End Subprocedure GetInt }

begin
  NormVideo;
  Msg('Format: Enter number of places beyond decimal point (Max 11) :  ');
  GetInt(DEC,11);
  Msg('Enter Cell width (if larger than 10 next column will be locked) : ');
  GetInt(FW,20);
  Msg('From which line in column '+ FX +' : ');
  GetInt(FromLine,FYMax);
  Msg('To which line in column '+ FX +' : ');
  GetInt(ToLine,FYMax);
  if FW > 10 then
    Lock := true
  else
    Lock := False;
  for J := FromLine to ToLine do   { Format specified cells within        }
  begin                            { current column.                      }
    Sheet[FX,J].DEC := DEC;
    Sheet[FX,J].FW := FW;
    with Sheet[Succ(FX),J] do
    begin
      if Lock then
      begin
        CellStatus := CellStatus + [Locked,Txt];
        Contents := '';
      end
      else
        CellStatus :=CellStatus - [Locked];
    end;  { End With Statement }
  end;  { End For Loop }
  NormVideo;
  UpDate;
  GotoCell(FX,FY);
end;  { End procedure Format }

{ Procedure Commands is called from the program's main loop when the user }
{ types a slash '/'. The procedure in turn calls the appropriate procedure}
{ based on the users response to the menu displayed.                      }
{                                                                         }
{ For easy reference the source code module number is shown in a comment  }
{ on the right following the procedure call.                              }

Procedure Commands;

begin
  GotoXY(1,24);
  NormVideo;
  Write('Update, Quit, Load, Save, Recalculate, Print, Format, AutoCalc, Help ');
  ClrEol;
  Read(KBD,Ch);
  Ch := UpCase(Ch);
  case Ch of          {                                         module # }
    'Q': Halt;        { Halt execution of program                        }
    'F': Format;      { Format a range of cells                      005 }
    'S': Save;        { Save the current spreadsheet to a file       003 }
    'L': Load;        { Load a spreadsheet from a file               003 }
    'H': Help;        { Call the Help procedure                      003 }
    'R': Recalculate; { Recalculate spreadsheet                      005 }
    'A': Auto;        { Toggle AutoCalc On or Off                    000 }
    'U': Update;      { Redraw the screen                            001 }
    'C': Clear;       { Clear screen of spreadsheet                  001 }
    'P': Print;       { Print spreadsheet to a file                  003 }
  end;
  Grid;               {                                              001 }
  GotoCell(FX,FY);    {                                              002 }
end;   { End Procedure Commands }
