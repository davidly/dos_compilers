{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit FileView;  { File pane object }

{$X+}
{$V-}

interface

uses Drivers, Objects, Views, App, Dos, Dialogs, Memory,
  Globals, Equ, Tools, DragDrop;

type

  PFileView = ^TFileView;
  TFileView = object(TDDList)
    Foc: Integer;
    Dir: PathStr;
    List: PFileList;
    DoneScanning: Boolean;
    Search: SearchRec;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar);
    procedure HandleEvent(var Event: TEvent); virtual;
    destructor Done; virtual;
    function SearchForFiles(First: Boolean): Boolean;
    procedure ScanSingleFile(FileName: PathStr);
    function GetPalette : PPalette; virtual;
    procedure Draw; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure PickUpItem(Item: Integer; Where: TPoint); virtual;
  end;


implementation

uses MsgBox;

{ TFileView }
constructor TFileView.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  inherited Init(Bounds, 1, AHScrollBar, AVScrollBar);
  List := New(PFileList, Init(30,10));
  Dir := '';
  DoneScanning := True;
  EventMask := EventMask or evIdle;
  Foc := 0;
end;

function TFileView.GetPalette: PPalette;
const
  MyPal : String[length(CListViewer)] = #6#6#7#6#1;
begin
  GetPalette := @MyPal;
end;

procedure TFileView.Draw;
var
  B: TDrawBuffer;
  C: Word;
begin
  inherited Draw;
  if List^.Count = 0 then
  begin
    C := GetColor(1);
    MoveChar(B, ' ', C, Size.X);
    MoveStr(B, RezStrings^.Get(sNoFiles), C);
    WriteLine(0, 0, Size.X, 1, B);
  end;
end;

function TFileView.GetText(Item: Integer; MaxLen: Integer): String;
var
  F: PFileRec;
  S: String;
  Params: array[0..3] of Pointer;
  DOpt: Word;
begin
  if Item < List^.Count then
  begin
    F := List^.At(Item);
    Params[0] := @F^.Name;
    Params[1] := @F^.Ext;
    Params[2] := Pointer(F^.Size);

    with ConfigRec do
    begin
      if DisplayFields and $1 <> 0 then FormatStr(S, ' %-8s%-4s %7d', Params)
      else FormatStr(S, ' %-8s%-4s', Params);

      if F^.Tagged then S[1] := TagChar;

      DOpt := (DisplayFields and $6) shr 1;  { change 0xx0 -> 0,1,2,3 }

      { 0=none, 1=Date, 2=Time, 3=Date and Time }
      if DOpt > 0 then S := S + ' ' + FormatDateTime(F^.Time, DOpt);

      if (DisplayFields and $8) <> 0 then S := S + ' ' + FormatAttr(F^.Attr);
    end;

    if Length(S) > MaxLen then S[0] := Char(MaxLen);

    if ConfigRec.DisplayCase = 0 then LowerCase(S);
    GetText := S;

  end else GetText := '';
end;

function TFileView.SearchForFiles(First: Boolean): Boolean;
var
  F: PFileRec;
begin
  SearchForFiles := False;
  if First then FindFirst(Dir + '\' + ConfigRec.FileMask, AnyFile, Search)
  else FindNext(Search);
  if DosError = 0 then
  begin
    if Search.Attr and UnwantedFiles = 0 then
    begin
      F := New(PFileRec, Init(Search));
      List^.Insert(F);
    end;
  end else SearchForFiles := True;  { done searching }
end;

procedure TFileView.ScanSingleFile(FileName: PathStr);
var
  F: PFileRec;
begin
  FindFirst(FileName, AnyFile, Search);
  if DosError = 0 then
  begin
    if (Search.Attr and UnwantedFiles = 0) then
    begin
      F := New(PFileRec, Init(Search));
      List^.Insert(F);
      SetRange(List^.Count);
      DrawView;
    end;
  end;
end;

procedure TFileView.HandleEvent(var Event: TEvent);
var
  F: PFileRec;
  P: PFileNameRec;
  ScanInfo: TScanInfo;
  Where: TPoint;
  Mover: PFileMover;
  I: Integer;
  WildCard: string[12];
  R: TRect;

  procedure ReverseTags(F: PFileRec); far;
  begin
    F^.Toggle;
    Message(Owner, evBroadcast, cmTagChanged, F);
  end;

  procedure ClearTags(F: PFileRec); far;
  begin
    if F^.Tagged then
    begin
      F^.Toggle;
      Message(Owner, evBroadcast, cmTagChanged, F);
    end;
  end;

  procedure TagPerCard(F: PFileRec); far;
  begin
    if WildCardMatch(F^.Name + F^.Ext, WildCard) then
    begin
      F^.Tagged := True;
      Message(Owner, evBroadcast, cmTagChanged, F);
    end;
  end;

  function MatchFile(F: PFileRec): Boolean; far;
  begin
    P := Event.InfoPtr;
    MatchFile := (P^.Dir = Dir + '\') and (P^.Name = F^.Name) and
      (P^.Ext = F^.Ext);
  end;

  procedure CountBytes(F: PFileRec); far;
  begin
    Inc(ScanInfo.ScanBytes, F^.Size);
  end;

begin
  inherited HandleEvent(Event);

  if Event.What = evBroadcast then
  begin
    case Event.Command of

      { Scan a new directory, or rescan current directory }
      cmNewDir,
      cmRescan :
        begin
          if Event.Command = cmNewDir then Dir := PString(Event.InfoPtr)^;
          Owner^.Last^.DrawView; {Force the frame to redraw }
          DoneScanning := False;
          List^.FreeAll;
          DoneScanning := SearchForFiles(True); { search for the first file }
          if (not DoneScanning) and LowMemory then
          begin
            DoneScanning := True;
            Application^.OutOfMemory;
          end;
          if DoneScanning then
          begin
            SetRange(List^.Count);
            DrawView;
            ScanInfo.ScanCount := List^.Count;
            ScanInfo.ScanBytes := 0;
            List^.ForEach(@CountBytes);
            Message(Owner, evBroadcast, cmScanComplete, @ScanInfo);
          end;
          if Event.Command = cmNewDir then ClearEvent(Event);
        end;

      { Mark the current file as tagged }
      cmListItemSelected :
        begin
          if List^.Count > 0 then
          begin
            F := List^.At(Focused);
            F^.Toggle;
            Message(Owner, evBroadcast, cmTagChanged, F);
            DrawView;
            ClearEvent(Event);
          end;
        end;

      { Reorder and redraw the list since the sort order may have changed }
      cmRefreshDisplay :
        begin
          PFileList(List)^.Reorder;
          DrawView;
        end;

      cmItemDropped :
        begin
          Mover := Event.InfoPtr;
          Desktop^.MakeGlobal(Mover^.Origin, Where);
          if MouseInView(Where) then
          begin
            ClearEvent(Event);
            DragDropCopy(Mover, Dir);
          end;
        end;

    end; { case }
  end;

  if Event.What = evIdle then
  begin
    if not DoneScanning then
    begin
      DoneScanning := SearchForFiles(False);
      if DoneScanning then
      begin
        SetRange(List^.Count);
        DrawView;
        ScanInfo.ScanCount := List^.Count;
        ScanInfo.ScanBytes := 0;
        List^.ForEach(@CountBytes);
        Message(Owner, evBroadcast, cmScanComplete, @ScanInfo);
      end;
    end;
  end;

  if Event.What = evCommand then
  begin
    case Event.Command of
      cmReverseTags : List^.ForEach(@ReverseTags);
      cmClearTags: List^.ForEach(@ClearTags);
      cmTagPerCard:
        begin
          R.Assign(0,0,35,8);
          R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
          WildCard := '*.*';
          if InputBoxRect(R, 'Tag per wildcard', 'Wildcard', WildCard, 12) = cmOK then
          begin
            UpperCase(WildCard);
            List^.ForEach(@TagPerCard);
          end;
        end;
      else Exit;
    end;
    DrawView;
    ClearEvent(Event);
  end;
end;

procedure TFileView.PickUpItem(Item: Integer; Where: TPoint);
var
  R: TRect;
  Mover: PMover;
  E: TEvent;
  Min, Max: TPoint;
  F: PFileRec;
  NewList: PCollection;
  S: SearchRec;

  function CloneFileRec(Orig: PFileRec): PFileRec;
  begin
    S.Name := Orig^.Name + Orig^.Ext;
    S.Attr := Orig^.Attr;
    S.Size := Orig^.Size;
    S.Time := Orig^.Time;
    CloneFileRec := New(PFileRec, Init(S));
  end;

  procedure AddIfTagged(FileRec: PFileRec); far;
  begin
    if FileRec^.Tagged then
      NewList^.Insert(CloneFileRec(FileRec));
  end;

begin
  NewList := New(PCollection, Init(10, 5));

  F := List^.At(Item);  { are we dragging the tagged files? }
  if F^.Tagged then List^.ForEach(@AddIfTagged)
  else NewList^.Insert(CloneFileRec(F));

  Dec(Where.Y);
  Mover := New(PFileMover, Init(Where, Dir, NewList));
  Inc(Where.Y); 
  Desktop^.Insert(Mover);
  Desktop^.GetExtent(R);

  E.What := evMouseDown;
  E.Where := Where;
  Min := Mover^.Size;
  Max := Min;
  Mover^.DragView(E, dmDragMove, R, Min, Max);
  Message(Desktop, evBroadcast, cmItemDropped, Mover);
  Dispose(Mover, Done);
  Dispose(NewList, Done);
end;

procedure TFileView.SetState(AState: Word; Enable: Boolean);

  procedure ShowScrollBar(SBar: PScrollBar);
  begin
    if (SBar <> nil) then
      if GetState(sfActive + sfSelected) then SBar^.Show
      else SBar^.Hide;
  end;

begin
  inherited SetState(AState, Enable);
  if AState and (sfActive + sfSelected) <> 0 then
  begin
    ShowScrollBar(HScrollBar);
    ShowScrollBar(VScrollBar);
  end;
end;

destructor TFileView.Done;
begin
  if List <> nil then Dispose(List, Done);
  inherited Done;
end;



end. { unit }
