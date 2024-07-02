
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

Program MCalc;

uses Crt, Dos, MCVars, MCUtil, MCDisply, MCParser, MCLib, MCInput, MCommand;

var
  Ch : Char;

procedure Run;
{ The main program loop }
var
  Input : Char;
begin
  Stop := False;
  ClearInput;
  repeat
    DisplayCell(CurCol, CurRow, HIGHLIGHT, NOUPDATE);
    CurCell := Cell[CurCol, CurRow];
    ShowCellType;
    GotoXY(1, 25);
    Input := GetKey;
    case Input of
      '/' : MainMenu;
      F1 : Recalc;
      F2 : EditCell(CurCell);
      DELKEY : begin
        DeleteCell(CurCol, CurRow, UPDATE);
        PrintFreeMem;
        if AutoCalc then
          Recalc;
      end; { DELKEY }
      PGUPKEY : begin
        if CurRow <= SCREENROWS then
        begin
          CurRow := 1;
          TopRow := 1;
        end
        else if TopRow <= SCREENROWS then
        begin
          CurRow := Succ(CurRow - TopRow);
          TopRow := 1;
        end
        else begin
          Dec(TopRow, SCREENROWS);
          Dec(CurRow, SCREENROWS);
        end;
        SetBottomRow;
        DisplayScreen(NOUPDATE);
      end; {PGUPKEY }
      PGDNKEY : begin
        Inc(TopRow, SCREENROWS);
        Inc(CurRow, SCREENROWS);
        if (CurRow > MAXROWS) and (TopRow > MAXROWS) then
        begin
          CurRow := MAXROWS;
          TopRow := Succ(MAXROWS - SCREENROWS);
        end
        else if TopRow > Succ(MAXROWS - SCREENROWS) then
        begin
          CurRow := Succ(CurRow) - (TopRow + SCREENROWS - MAXROWS);
          TopRow := Succ(MAXROWS - SCREENROWS);
        end;
        SetBottomRow;
        DisplayScreen(NOUPDATE);
      end; { PGDNKEY }
      CTRLLEFTKEY : begin
        DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
        if LeftCol = 1 then
          CurCol := 1
        else begin
          CurCol := Pred(LeftCol);
          RightCol := CurCol;
          SetLeftCol;
          SetRightCol;
          DisplayScreen(NOUPDATE);
        end;
      end; { CTRLLEFTKEY }
      CTRLRIGHTKEY : begin
        DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
        if RightCol = MAXCOLS then
          CurCol := RightCol
        else begin
          CurCol := Succ(RightCol);
          LeftCol := CurCol;
          SetRightCol;
          SetLeftCol;
          DisplayScreen(NOUPDATE);
        end;
      end; { CTRLRIGHTKEY }
      HOMEKEY : begin
        CurRow := 1;
        CurCol := 1;
        LeftCol := 1;
        TopRow := 1;
        SetRightCol;
        SetBottomRow;
        DisplayScreen(NOUPDATE);
      end; { HOMEKEY }
      ENDKEY : begin
        CurCol := LastCol;
        RightCol := CurCol;
        BottomRow := LastRow;
        CurRow := BottomRow;
        SetTopRow;
        SetLeftCol;
        SetRightCol;
        DisplayScreen(NOUPDATE);
      end; { ENDKEY }
      UPKEY : MoveRowUp;
      DOWNKEY : MoveRowDown;
      LEFTKEY : MoveColLeft;
      RIGHTKEY : MoveColRight;
      else if Input in [' '..'~'] then
        GetInput(Input);
    end; { case }
  until Stop;
end; { Run }

begin
  CheckBreak := False;
  SetColor(TXTCOLOR);
  ClrScr;
  SetColor(MSGHEADERCOLOR);
  WriteXY(MSGHEADER, (80 - Length(MSGHEADER)) shr 1, 10);
  SetColor(PROMPTCOLOR);
  WriteXY(MSGKEYPRESS, (80 - Length(MSGKEYPRESS)) shr 1, 12);
  GotoXY(80, 25);
  Ch := GetKey;
  ClrScr;
  InitVars;
  Changed := False;
  RedrawScreen;
  if (ParamCount > 0) then
    LoadSheet(ParamStr(1));
  ClearInput;
  Run;
  SetColor(LightGray);
  TextMode(OldMode);
  SetCursor(OldCursor);
end.
