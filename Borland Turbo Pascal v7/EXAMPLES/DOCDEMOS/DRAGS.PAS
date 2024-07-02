{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Drags;

uses Objects, Views, App, Drivers, Dialogs, Menus;

type
  PDragDialog = ^TDragDialog;
  TDragDialog = object(TDialog)
    constructor Init;
  end;
  TFlagRecord = record
    DragFlags, GrowFlags: Word;
  end;
  PDragBlock = ^TDragBlock;
  TDragBlock = object(TView)
    Flags: TFlagRecord;
    constructor Init;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;
  PDragWindow = ^TDragWindow;
  TDragWindow = object(TWindow)
    constructor Init;
  end;
  TDragApp = object(TApplication)
    constructor Init;
    procedure InitStatusLine; virtual;
  end;

constructor TDragDialog.Init;
var
  R: TRect;
  DragFlags, GrowFlags: PCheckBoxes;
begin
  R.Assign(0, 0, 41, 11);
  inherited Init(R, 'Set drag/grow flags');
  Options := Options or ofCentered;
  R.Assign(2, 3, 19, 7);
  DragFlags := New(PCheckBoxes, Init(R,
    NewSItem('dmLimitLoX',
    NewSItem('dmLimitLoY',
    NewSItem('dmLimitHiX',
    NewSItem('dmLimitHiY', nil))))));
  Insert(DragFlags);
  R.Assign(1, 2, 12, 3);
  Insert(New(PLabel, Init(R, '~D~rag mode', DragFlags)));
  R.Assign(22, 3, 39, 7);
  GrowFlags := New(PCheckBoxes, Init(R,
    NewSItem('gfGrowLoX',
    NewSItem('gfGrowLoY',
    NewSItem('gfGrowHiX',
    NewSItem('gfGrowHiY', nil))))));
  Insert(GrowFlags);
  R.Assign(21, 2, 32, 3);
  Insert(New(PLabel, Init(R, '~G~row mode', GrowFlags)));
  R.Assign(5, 8, 15, 10);
  Insert(New(PButton, Init(R, 'O~k~', cmOK, bfDefault)));
  R.Assign(24, 8, 34, 10);
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  SelectNext(False);
end;

constructor TDragBlock.Init;
var
  R: TRect;
begin
  R.Assign(5, 5, 25, 10);
  inherited Init(R);
  DragMode := dmLimitAll;
  Flags.DragFlags := (DragMode shr 4) and $0F;
  Flags.GrowFlags := GrowMode and gfGrowAll;
end;

procedure TDragBlock.Draw;
var
  B: TDrawBuffer;
begin
  MoveChar(B, ' ', GetColor(4), Size.X);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

procedure TDragBlock.HandleEvent(var Event: TEvent);
var
  R: TRect;
  Min, Max: TPoint;
begin
  inherited HandleEvent(Event);
  if Event.What and evMouseDown = evMouseDown then
  begin
    if Event.Double then
    begin
      if Application^.ExecuteDialog(New(PDragDialog, Init), @Flags) <> cmCancel then
      begin
        DragMode := Flags.DragFlags shl 4;
        GrowMode := Flags.GrowFlags;
      end;
    end
    else
    begin
      Owner^.GetExtent(R);
      R.Grow(-1, -1);
      SizeLimits(Min, Max);
      case Event.Buttons of
        mbLeftButton:
          begin
            DragView(Event, dmDragMove or DragMode, R, Min, Max);
            ClearEvent(Event);
          end;
        mbRightButton:
          begin
            DragView(Event, dmDragGrow or DragMode, R, Min, Max);
            ClearEvent(Event);
          end;
      end;
    end;
  end;
end;

constructor TDragWindow.Init;
var
  R: TRect;
  DragBlock: PDragBlock;
begin
  Desktop^.GetExtent(R);
  inherited Init(R, 'Drag Window', wnNoNumber);
  DragBlock := New(PDragBlock, Init);
  if Application^.ValidView(DragBlock) <> nil then Insert(DragBlock);
end;

constructor TDragApp.Init;
var
  DragWindow: PDragWindow;
begin
  inherited Init;
  DragWindow := New(PDragWindow, Init);
  InsertWindow(DragWindow);
end;

procedure TDragApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R, NewStatusDef(0, $FFFF,
    NewStatusKey('Drag block, double-click to change flags, or ~Alt+X~ to exit', kbAltX, cmQuit,
    StdStatusKeys(nil)), nil)));
end;

var
  DragApp: TDragApp;
begin
  DragApp.Init;
  DragApp.Run;
  DragApp.Done;
end.
