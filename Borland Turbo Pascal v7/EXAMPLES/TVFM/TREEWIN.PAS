{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TreeWin;  { Tree window object }

{$X+,V-}

interface

uses Drivers, Objects, Views, FileView, DirView;

type
  PTreeWindow = ^TTreeWindow;
  TTreeWindow = object(TWindow)
    DirView: PDirectoryViewer;
    FileView: PFileView;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetTitle(Width: Integer): TTitleStr; virtual;
  end;

procedure InsertTreeWindow(Drive: Char);

implementation

uses Globals, Dos, Equ, Tools, Dialogs, App, Assoc, InfoView;

{ TTreeWindow }

procedure TTreeWindow.SizeLimits(var Min, Max: TPoint);
begin
  inherited SizeLimits(Min, Max);
  Min.X := 48;
end;

function TTreeWindow.GetTitle(Width: Integer): TTitleStr;
begin
  GetTitle := FileView^.Dir + '\' + ConfigRec.FileMask;
end;

procedure TTreeWindow.HandleEvent(var Event: TEvent);
var
  F: PFileRec;
  D: PDirectory;
  CurrentFile: PathStr;
begin
  inherited HandleEvent(Event);

  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmInvalidDir :
        begin
          D := DirView^.GetNode(DirView^.Foc);
          if PString( Event.InfoPtr )^ = D^.Dir^ then
            Message(FileView, evBroadcast, cmRescan, nil);
        end;
      cmTopWindow:
        ClearEvent(Event);
      cmFileListFocused :
        if (Current = PView(FileView)) and (FileView^.List^.Count > 0) then
          ClearEvent(Event);
      cmCloseAll :
        Close;
    end;
  end;

  if Event.What = evCommand then
  begin
    { Get the full filename of the current file }
    if (Current = PView(FileView)) and (FileView^.List^.Count > 0) then
    begin
      D := DirView^.GetNode(DirView^.Foc);
      F := FileView^.List^.At(FileView^.Focused);
      CurrentFile := D^.Dir^ + '\' + F^.Name + F^.Ext;

      case Event.Command of
        cmViewAsHex : ViewAsHex(CurrentFile);
        cmViewAsText : ViewAsText(CurrentFile);
        cmViewCustom : ViewCustom(CurrentFile);
        cmExecute : ExecuteFile(CurrentFile);
        cmAssociate: Associate(F^.Ext);
        cmCopy : HandleFileCopy(D^.Dir^, FileView^.List, FileView^.Focused);
        cmDelete : HandleFileDelete(D^.Dir^, FileView^.List, FileView^.Focused);
        cmRename : RenameFile(D^.Dir^, F);
        cmChangeAttr : ChangeAttr(D^.Dir^, F);
        else Exit;
      end; { case }
      ClearEvent(Event);
    end;
  end;


end;


procedure InsertTreeWindow(Drive: Char);
var
  Bounds, R: TRect;
  W, TopWin: PTreeWindow;
  vSB, hSB: PScrollBar;
  PRoot: PString;
  Root: String[2];
  S: string[40];
  D: PDialog;
  Width: Integer;
begin
  Root := Drive + ':';
  PRoot := @Root;

  FormatStr(S, RezStrings^.Get(sScanning), PRoot);
  D := WaitDialog(S);
  Desktop^.Insert(D);

  Bounds.Assign(0,0,75,16);
  W := New(PTreeWindow, Init(Bounds, Root, wnNoNumber));
  with W^ do
  begin
    Options := Options or ofTileable;
    GetExtent(Bounds);

    Width := Bounds.B.X - Bounds.A.X;
    Bounds.B.X := Width div 3;

    R.Assign(Bounds.B.X-1, Bounds.A.Y+1, Bounds.B.X, Bounds.B.Y-1);
    vSB := New(PScrollBar, Init(R));
    vSB^.Options := vSB^.Options or ofPostProcess;
    vSB^.GrowMode :=  gfGrowHiY;
    Insert(vSB);

    R.Assign(Bounds.A.X+2, Bounds.B.Y-1, Bounds.B.X-2, Bounds.B.Y);
    hSB := New(PScrollBar, Init(R));
    hSB^.Options := hSB^.Options or ofPostProcess;
    hSB^.GrowMode := gfGrowHiY + gfGrowLoY;
    Insert(hSB);

    Bounds.Grow(-1,-1);
    DirView := New(PDirectoryViewer, Init(Bounds, hSB, vSB,
      New(PDirectory, Init(Root))));

    with DirView^ do
    begin
      Options := Options or (ofFramed or ofFirstClick);
      Adjust(GetRoot, True);
      GrowMode := gfGrowHiY;
      Update;
    end;
    Insert(DirView);

    { Create the file viewer }
    GetExtent(Bounds);

    Bounds.A.X := Bounds.A.X + (Width div 3) - 1;
    Dec(Bounds.B.Y,3);

    R.Assign(Bounds.B.X-1, Bounds.A.Y+1, Bounds.B.X, Bounds.B.Y-1);
    vSB := New(PScrollBar, Init(R));
    vSB^.Options := vSB^.Options or ofPostProcess;
    vSB^.GrowMode :=  gfGrowHiY + gfGrowLoX + gfGrowHiX;
    Insert(vSB);

    R.Assign(Bounds.A.X+2, Bounds.B.Y-1, Bounds.B.X-2, Bounds.B.Y);
    hSB := New(PScrollBar, Init(R));
    hSB^.Options := hSB^.Options or ofPostProcess;
    hSB^.GrowMode := gfGrowHiY + gfGrowLoY + gfGrowHiX;
    hSB^.SetRange(0, 40);
    Insert(hSB);

    Bounds.Grow(-1,-1);
    FileView := New(PFileView, Init(Bounds, hSB, vSB));
    FileView^.GrowMode := gfGrowHiY + gfGrowHiX;
    FileView^.Options := FileView^.Options or ofFramed;
    Insert(FileView);

    Inc(Bounds.A.X, 2);
    Bounds.A.Y := Bounds.B.Y + 1;
    Bounds.B.Y := Bounds.A.Y + 1;
    Insert(New(PCntView, Init(Bounds)));

    Bounds.Move(0,1);
    Insert(New(PTagView, Init(Bounds)));

    SelectNext(False);
  end;

  { decide where to place this window }
  TopWin := Message(Desktop, evBroadcast, cmTopWindow, nil);
  if TopWin <> nil then
  begin
    W^.MoveTo(TopWin^.Origin.X + 1, TopWin^.Origin.Y + 1);
    W^.GrowTo(TopWin^.Size.X, TopWin^.Size.Y);
  end
  else
    W^.MoveTo(2,1);

  if Application^.ValidView(W) <> nil then
  begin
    Desktop^.Insert(W);
    Message(Desktop, evBroadcast, cmNewDir, PRoot);
  end;

  Dispose(D, Done);
end;

end.
