
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCInput;
{ Turbo Pascal 6.0 object-oriented example input routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses Crt, TCUtil, TCScreen, TCLStr;

const
  LeftInputArrow = #17;
  RightInputArrow = #16;
  YesNo = 'Y/N';
  LegalYesNo = ['Y', 'N'];
  AllUpper = True;
  NotUpper = False;
  ErrNumberError1 = 'You must enter a number from ';
  ErrNumberError2 = ' to ';
  ErrColumnError1 = 'You must enter a column from ';
  ErrColumnError2 = ' to ';
  ErrCellError = 'You must enter a legal cell';

type
  InputField = object
    StartCol : ScreenColRange;
    StopCol : Integer;
    InputRow : Integer;
    MaxInputLen : Word;
    Quit : Boolean;
    InputData : LStringPtr;
    UCase : Boolean;
    InputArea : ScreenArea;
    constructor Init(C1 : ScreenColRange; C2 : Integer; R : Integer;
                     InitMaxInputLen : Word; InitUCase : Boolean);
    destructor Done;
    function GetQuit : Boolean;
    procedure Edit(StartCursor : Word);
    procedure ClearInput;
  end;

function ReadString(Prompt : String; Len : Word;
                    var ESCPressed : Boolean) : String;

function GetLegalChar(Prompt : String; Legal : CharSet;
                      var ESCPressed : Boolean) : Char;

function GetYesNo(Prompt : String; var ESCPressed : Boolean) : Boolean;

function GetNumber(Prompt : String; Low, High : Longint;
                   var Result : Boolean) : Longint;

implementation

constructor InputField.Init(C1 : ScreenColRange; C2 : Integer; R : Integer;
                            InitMaxInputLen : Word; InitUCase : Boolean);
{ Sets up an input field }
begin
  InputData := New(LStringPtr, Init);
  if InputData = nil then
    Fail;
  StartCol := C1;
  StopCol := C2;
  InputRow := R;
  if InitMaxInputLen = 0 then
    MaxInputLen := 65521      { Maximum area that a pointer can allocate }
  else
    MaxInputLen := InitMaxInputLen;
  UCase := InitUCase;
  Quit := False;
end; { InputField.Init }

destructor InputField.Done;
{ Remove memory used by an input field }
begin
  Dispose(InputData, Done);
end; { InputField.Done }

function InputField.GetQuit : Boolean;
{ Check to see if an input field has been exited with ESC }
begin
  GetQuit := Quit;
end; { InputField.GetQuit }

procedure InputField.Edit(StartCursor : Word);
{ Edits the input field }
var
  CursorPos, Start, Cursor : Word;
  Ch : Word;
  Good, InsMode, Finished : Boolean;
  R : ScreenRowRange;
  SCol, ECol, EndCol : ScreenColRange;
begin
  with InputData^ do
  begin
    Quit := False;
    SCol := StartCol;         { Figure out where the field starts and stops }
    if StopCol <= 0 then
      EndCol := Scr.CurrCols + StopCol
    else
      EndCol := StopCol;
    if InputRow <= 0 then
      R := Scr.CurrRows + InputRow
    else
      R := InputRow;
    if (R = Scr.CurrRows) and (ECol = Scr.CurrCols) then
      Dec(EndCol);
    ECol := EndCol;
    InputArea.Init(SCol, R, ECol, R, Colors.InputColor);
    InputArea.Clear;
    if StartCursor = 0 then
      CursorPos := Succ(Length)
    else
      CursorPos := StartCursor;
    Finished := False;
    InsMode := True;
    Cursor := Scr.InsCursor;
    Start := Max(Longint(CursorPos) - ECol - SCol + 2, 1);
    repeat
      if CursorPos > Length then
        ECol := EndCol;
      if (CursorPos < Start) or (CursorPos > Start + ECol - SCol) then
        Start := Max(Longint(CursorPos) - ECol + SCol, 1);
      if (Start = 2) and (SCol <> StartCol) then
      begin
        SCol := StartCol;
        Start := 1;
      end;
      if Start > 1 then
      begin
        if SCol = StartCol then
        begin
          Inc(Start);
          SCol := Succ(StartCol);    { Text is off left side of line }
        end;
      end
      else
        SCol := StartCol;
      if Length > Start + ECol - SCol then
      begin
        if ECol = EndCol then
        begin
          if SCol <> StartCol then
            Inc(Start);
          ECol := Pred(EndCol);       { Text is off right side of line }
        end;
      end
      else
        ECol := EndCol;
      GotoXY(StartCol, R);
      if SCol <> StartCol then        { Text is off left side of line }
        WriteColor(LeftInputArrow, Colors.InputArrowColor);
      WriteColor(LeftJustStr(InputData^.Copy(Start, Succ(ECol - SCol)),
                 Succ(ECol - SCol)), Colors.InputColor);
      if ECol <> EndCol then          { Text is off right side of line }
        WriteColor(RightInputArrow, Colors.InputArrowColor);
      GotoXY(CursorPos - Start + SCol, R);
      SetCursor(Cursor);
      Ch := GetKey;
      SetCursor(NoCursor);
      case Ch of
        Ord(' ')..Ord('~') : begin
          if not (InsMode and (Length = MaxInputLen)) then
          begin
            if UCase then
              Ch := Ord(UpCase(Chr(Ch)));
            if InsMode or (CursorPos > Length) then
              Good := Insert(Chr(Ch), CursorPos)
            else begin
              Good := True;
              Change(Chr(Ch), CursorPos);
            end;
            if Good then
              Inc(CursorPos);
          end;
        end;
        HomeKey : CursorPos := 1;
        EndKey : CursorPos := Succ(Length);
        BS : begin
          if CursorPos > 1 then
          begin
            Delete(Pred(CursorPos), 1);
            Dec(CursorPos);
          end;
        end;
        DelKey : begin
          if CursorPos <= Length then
            Delete(CursorPos, 1);
        end;
        LeftKey : begin
          if CursorPos > 1 then
            Dec(CursorPos);
        end;
        RightKey : begin
          if CursorPos <= Length then
            Inc(CursorPos);
        end;
        InsKey : begin
          InsMode := not InsMode;
          if InsMode then
            Cursor := Scr.InsCursor
          else
            Cursor := Scr.OldCursor;
        end;
        CtrlLeftKey : begin    { Move back one word }
          if (CursorPos > 1) and (Data^[CursorPos] <> ' ') then
            Dec(CursorPos);
          while (CursorPos > 1) and (Data^[CursorPos] = ' ') do
            Dec(CursorPos);
          while (CursorPos > 1) and (Data^[Pred(CursorPos)] <> ' ') do
            Dec(CursorPos);
        end;
        CtrlRightKey : begin   { Move forward one word }
          while (CursorPos <= Length) and (Data^[CursorPos] <> ' ') do
            Inc(CursorPos);
          while (CursorPos <= Length) and (Data^[CursorPos] = ' ') do
            Inc(CursorPos);
        end;
        ESC : begin
          ClearInput;
          Quit := True;
          Finished := True;
        end;
        CR : Finished := True;
      end; { case }
    until Finished;
  end; { with }
end; { InputField.Edit }

procedure InputField.ClearInput;
{ Makes the input field data a null long string }
var
  Good : Boolean;
begin
  Good := InputData^.FromString('');
end; { InputField.ClearInput }

function ReadString(Prompt : String; Len : Word;
                    var ESCPressed : Boolean) : String;
{ Read a string from the input area }
var
  I : InputField;
begin
  with I do
  begin
    if not Init(Length(Prompt) + 3, 0, -1, Len, NotUpper) then
    begin
      ESCPressed := True;
      ReadString := '';
    end;
    WriteXY(Prompt + ': ', 1, Pred(Scr.CurrRows), Colors.PromptColor);
    Edit(0);
    ReadString := InputData^.ToString;
    ESCPressed := GetQuit;
    Done;
  end; { with }
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
end; { ReadString }

function GetLegalChar(Prompt : String; Legal : CharSet;
                      var ESCPressed : Boolean) : Char;
{ Read a chanracter from the input area, only reading certain ones }
var
  Ch : Char;
begin
  WriteXY(Prompt + ': ', 1, Pred(Scr.CurrRows), Colors.PromptColor);
  Ch := GetKeyChar(Legal);
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
  GetLegalChar := Ch;
end; { GetLegalChar }

function GetYesNo(Prompt : String; var ESCPressed : Boolean) : Boolean;
{ Prints a "Yes/No" prompt, allowing the user to type Y or N to answer the
  question }
var
  Ch : Char;
begin
  WriteXY(Prompt + ' (' + YesNo + ')?', 1, Pred(Scr.CurrRows),
              Colors.PromptColor);
  Ch := GetKeyChar(LegalYesNo);
  ESCPressed := Ch = Chr(ESC);
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
  GetYesNo := Ch = 'Y';
end; { GetYesNo }

function GetNumber(Prompt : String; Low, High : Longint;
                   var Result : Boolean) : Longint;
{ Prompts for a numeric value within a certain range }
var
  I : InputField;
  S : String;
  Error : Integer;
  L : Longint;
begin
  with I do
  begin
    if not Init(Length(Prompt) + 3, 0, -1,
                Max(Length(NumToString(Low)),
                    Length(NumToString(High))), NotUpper) then
    begin
      Result := False;
      GetNumber := 0;
      Exit;
    end;
    WriteXY(Prompt + ': ', 1, Pred(Scr.CurrRows), Colors.PromptColor);
    repeat
      Edit(0);
      S := InputData^.ToString;
      if (not GetQuit) and (S <> '') then
      begin
        Val(S, L, Error);
        Result := (Error = 0) and (L >= Low) and (L <= High);
        if not Result then
          Scr.PrintError(ErrNumberError1 + NumToString(Low) +
                         ErrNumberError2 + NumToString(High));
      end
      else begin
        Result := False;
        L := 0;
      end;
    until Result or (S = '');
    Done;
  end; { with }
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
  GetNumber := L;
end; { GetNumber }

end.
