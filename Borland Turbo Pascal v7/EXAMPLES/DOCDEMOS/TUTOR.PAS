{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Tutorial;

uses Drivers, Memory, TutConst, Objects, Views, Menus, App, Editors, 
  Orders, Stocks, StdDlg, TutTypes, Count, Dialogs, Supplier, Validate;

var
  ResFile: TResourceFile;

type
  TTutorApp = object(TApplication)
    ClipboardWindow: PEditWindow;
    OrderWindow: POrderDialog;
    constructor Init;
    destructor Done; virtual;
    procedure CancelOrder;
    procedure DoAboutBox;
    procedure EnterNewOrder;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure LoadDesktop;
    procedure NewWindow;
    procedure OpenOrderWindow;
    procedure OpenWindow;
    procedure SaveDesktop;
    procedure SaveOrderData;
    procedure ShowOrder(AOrderNum: Integer);
  end;

procedure TutorStreamError(var S: TStream); far;
var
  ErrorMessage: String;
begin
  case S.Status of
    stError: ErrorMessage := 'Stream access error';
    stInitError: ErrorMessage := 'Cannot initialize stream';
    stReadError: ErrorMessage := 'Read beyond end of stream';
    stWriteError: ErrorMessage := 'Cannot expand stream';
    stGetError: ErrorMessage := 'Unregistered type read from stream';
    stPutError: ErrorMessage := 'Unregistered type written to stream';
    end;
  DoneVideo;
  PrintStr('Error: ' + ErrorMessage);
  Halt(Abs(S.Status));
end;

constructor TTutorApp.Init;
var
  R: TRect;
begin
  MaxHeapSize := 8192;
  EditorDialog := StdEditorDialog;
  StreamError := @TutorStreamError;
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterEditors;
  RegisterApp;
  RegisterDialogs;
  RegisterValidate;
  RegisterGlobals;
  RegisterOrders;
  RegisterCount;
  RegisterStocks;
  ResFile.Init(New(PBufStream, Init('TUTORIAL.TVR', stOpen, 1024)));
  inherited Init;
  Desktop^.GetExtent(R);
  ClipBoardWindow := New(PEditWindow, Init(R, '', wnNoNumber));
  if Application^.ValidView(ClipboardWindow) <> nil then
  begin
    ClipboardWindow^.Hide;
    InsertWindow(ClipboardWindow);
    Clipboard := ClipboardWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
  LoadOrders;
  CurrentOrder := 0;
  OrderInfo := POrderObj(OrderColl^.At(CurrentOrder))^.TransferRecord;
  LoadStock;
  LoadSuppliers;
  DisableCommands([cmOrderNext, cmOrderPrev, cmOrderCancel, cmOrderSave]);
end;

destructor TTutorApp.Done;
begin
  if Assigned(OrderColl) then Dispose(OrderColl, Done);
  inherited Done;
  ResFile.Done;
end;

procedure TTutorApp.CancelOrder;
begin
  if CurrentOrder < OrderColl^.Count then
    ShowOrder(CurrentOrder)
  else
  begin
    Dispose(TempOrder, Done);
    ShowOrder(CurrentOrder - 1);
  end;
  EnableCommands([cmOrderNew]);
end;

procedure TTutorApp.DoAboutBox;
begin
  ExecuteDialog(PDialog(ResFile.Get('ABOUTBOX')), nil);
end;

procedure TTutorApp.EnterNewOrder;
begin
  OpenOrderWindow;
  CurrentOrder := OrderColl^.Count;
  TempOrder := New(POrderObj, Init);
  OrderInfo := TempOrder^.TransferRecord;
  with OrderWindow^ do
  begin
    SetData(OrderInfo);
    Counter^.SetCurrent(CurrentOrder + 1);
  end;
  DisableCommands([cmOrderNext, cmOrderPrev, cmOrderNew]);
  EnableCommands([cmOrderCancel, cmOrderSave]);
end;

procedure TTutorApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmOpen:
        begin
          OpenWindow;
          ClearEvent(Event);
        end;
      cmNew:
        begin
          NewWindow;
          ClearEvent(Event);
        end;
      cmClipShow:
        with ClipBoardWindow^ do
        begin
          Select;
          Show;
          ClearEvent(Event);
        end;
      cmAbout:
        begin
          DoAboutBox;
          ClearEvent(Event);
        end;

      cmOrderWin:
        begin
          OpenOrderWindow;
          ClearEvent(Event);
        end;
      cmStockWin:
        begin
          ExecuteDialog(New(PStockDialog, Init), StockInfo);
          ClearEvent(Event);
        end;
      cmSupplierWin:
        begin
          ExecuteDialog(New(PSupplierDialog, Init), SupplierInfo);
          ClearEvent(Event);
        end;

      cmOrderNew:
        begin
          EnterNewOrder;
          ClearEvent(Event);
        end;
      cmOrderSave:
        begin
          SaveOrderData;
          ClearEvent(Event);
        end;
      cmOrderCancel:
        begin
          CancelOrder;
          ClearEvent(Event);
        end;
      cmOrderNext:
        begin
          ShowOrder(CurrentOrder + 1);
          ClearEvent(Event);
        end;
      cmOrderPrev:
        begin
          ShowOrder(CurrentOrder - 1);
          ClearEvent(Event);
        end;

      cmOptionsVideo:
        begin
          SetScreenMode(ScreenMode xor smFont8x8);
          ClearEvent(Event);
        end;
      cmOptionsSave:
        begin
          SaveDesktop;
          ClearEvent(Event);
        end;
      cmOptionsLoad:
        begin
         LoadDesktop;
         ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TTutorApp.InitMenuBar;
begin
  MenuBar := PMenuBar(ResFile.Get('MAINMENU'));
end;

procedure TTutorApp.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PStatusLine(ResFile.Get('STATUS'));
  GetExtent(R);
  StatusLine^.MoveTo(0, R.B.Y - 1);
end;

procedure TTutorApp.LoadDesktop;
var
  DesktopFile: TBufStream;
  TempDesktop: PDesktop;
  R: TRect;
begin
  DesktopFile.Init('DESKTOP.TUT', stOpenRead, 1024);
  TempDesktop := PDesktop(DesktopFile.Get);
  DesktopFile.Done;
  if ValidView(TempDesktop) <> nil then
  begin
    Desktop^.Delete(ClipboardWindow);
    Delete(Desktop);
    Dispose(Desktop, Done);
    Desktop := TempDesktop;
    Insert(Desktop);
    GetExtent(R);
    R.Grow(0, -1);
    Desktop^.Locate(R);
    InsertWindow(ClipboardWindow);
  end;
end;

procedure TTutorApp.NewWindow;
var
  R: TRect;
begin
  R.Assign(0, 0, 75, 20);
  InsertWindow(New(PEditWindow, Init(R, '', wnNoNumber)));
end;

procedure TTutorApp.OpenOrderWindow;
var
  R: TRect;
begin
  if Message(Desktop, evBroadcast, cmFindOrderWindow, nil) = nil then
  begin
    OrderWindow := New(POrderDialog, Init);
    InsertWindow(OrderWindow);
  end
  else
    if PView(OrderWindow) <> Desktop^.TopView then OrderWindow^.Select;
  ShowOrder(CurrentOrder);
end;

procedure TTutorApp.OpenWindow;
var
  R: TRect;
  FileDialog: PFileDialog;
  TheFile: FNameStr;
const
  FDOptions: Word = fdOKButton + fdOpenButton;
begin
  TheFile := '*.*';
  FileDialog := New(PFileDialog, Init(TheFile, 'Open file', '~F~ile name',
    FDOptions, 1));
  if ExecuteDialog(FileDialog, @TheFile) <> cmCancel then
  begin
    R.Assign(0, 0, 75, 20);
    InsertWindow(New(PEditWindow, Init(R, TheFile, 0)));
  end;
end;

procedure TTutorApp.SaveDesktop;
var
  DesktopFile: TBufStream;
begin
  Desktop^.Delete(ClipboardWindow);
  DesktopFile.Init('DESKTOP.TUT', stCreate, 1024);
  DesktopFile.Put(Desktop);
  DesktopFile.Done;
  InsertWindow(ClipboardWindow);
end;

procedure TTutorApp.SaveOrderData;
begin
  if OrderWindow^.Valid(cmClose) then
  begin
    OrderWindow^.GetData(OrderInfo);
    if CurrentOrder = OrderColl^.Count then
    begin
      OrderColl^.Insert(TempOrder);
      OrderWindow^.Counter^.IncCount;
    end
    else POrderObj(OrderColl^.At(CurrentOrder))^.TransferRecord := OrderInfo;
    SaveOrders;
    ShowOrder(CurrentOrder);
  end;
end;

procedure TTutorApp.ShowOrder(AOrderNum: Integer);
begin
  CurrentOrder := AOrderNum;
  OrderInfo := POrderObj(OrderColl^.At(CurrentOrder))^.TransferRecord;
  with OrderWindow^ do
  begin
    SetData(OrderInfo);
    Counter^.SetCurrent(CurrentOrder + 1);
  end;
  if CurrentOrder > 0 then EnableCommands([cmOrderPrev])
  else DisableCommands([cmOrderPrev]);
  if OrderColl^.Count > 0 then EnableCommands([cmOrderNext]);
  if CurrentOrder >= OrderColl^.Count - 1 then DisableCommands([cmOrderNext]);
  EnableCommands([cmOrderNew, cmOrderSave]);
end;

var
  TutorApp: TTutorApp;

begin
  TutorApp.Init;
  TutorApp.Run;
  TutorApp.Done;
end.
