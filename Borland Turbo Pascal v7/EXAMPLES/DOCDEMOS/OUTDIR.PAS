{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program OutDir;

uses Drivers, App, Dialogs, Outline, Objects, Views, Dos;

type
  PDirDlg = ^TDirDlg;
  TDirDlg = object(TWindow)
    constructor Init(ADirTree: PNode);
  end;

  TDirApp = object(TApplication)
    DirTree: PNode;
    constructor Init;
  end;

function GetDirs(const Path: PathStr): PNode;
var
  S: PathStr;

  function GetChildren(const Path: PathStr): PNode;
  var
    Cur: PNode;
    S: SearchRec;
  begin
    Cur := nil;
    FindFirst(Path + '\*.*', Directory, S);
    while DosError = 0 do
    begin
      if (S.Attr and Directory <> 0) and (S.Name[1] <> '.') then
        Cur := NewNode(S.Name, GetChildren(Path + '\' + S.Name), Cur);
      FindNext(S);
    end;
    GetChildren := Cur;
  end;

begin
  S := Path;
  if S[Length(S)] = '\' then Dec(S[0]);
  GetDirs := NewNode(Path, GetChildren(S), nil);
end;

constructor TDirDlg.Init(ADirTree: PNode);
var
  R: TRect;
  HScrollBar, VScrollBar: PScrollBar;
  Outline: POutline;
begin
  R.Assign(0, 0, 50, 20);
  inherited Init(R, 'Directory Tree', wnNoNumber);
  Options := Options or ofCentered;
  VScrollBar := StandardScrollBar(sbVertical or sbHandleKeyboard);
  HScrollBar := StandardScrollBar(sbHorizontal or sbHandleKeyboard);
  Insert(VScrollBar);
  Insert(HScrollBar);
  R.Grow(-1, -1);
  Outline := New(POutline, Init(R, HScrollBar, VScrollBar, ADirTree));
  Insert(Outline);
end;

constructor TDirApp.Init;
begin
  inherited Init;
  DirTree := GetDirs('C:\');
  InsertWindow(New(PDirDlg, Init(DirTree)));
end;

var
  DirApp: TDirApp;
begin
  DirApp.Init;
  DirApp.Run;
  DirApp.Done;
end.
