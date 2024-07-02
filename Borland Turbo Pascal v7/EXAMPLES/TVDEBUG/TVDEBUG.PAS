{************************************************}
{                                                }
{   Turbo Vision Debuging Unit                   }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit TVDebug;  

interface

uses Objects, Drivers, Views, App, TextView;

const
  cmTextWinAppendLine = 30000;

  { Custom options flag so TextInterior will know whether to scroll
    its text as new lines are added or not.  Uses an unused bit of the
    TView options field.    Default is not to scroll on append. }

  ofScrollonAppend = $0400;

type

  { TApplication }
  {  A debugging version of APP's TApplication that will create a
     Event window and a Log window on the bottom of the desktop. }
  TApplication = object(App.TApplication)
    constructor Init;
    procedure GetEvent(var E: TEvent);  virtual;
  end;
  PApplication = ^TApplication;

  { TTextCollection }
  {  Used internally by TTextInterior to hold the text to display }
  PTextCollection = ^TTextCollection;
  TTextCollection = object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;

  { TTextInterior }
  {  A scrolling view of the text stored in Lines. If the view recieves
     a cmTextWinAppendLine as an evBroadcast the InfoPtr field is assumed
     to contain a PString containing a new line to add to Lines. }
  PTextInterior = ^TTextInterior;
  TTextInterior = object(TScroller)
    Lines: TTextCollection;
    constructor Init( R: TRect; MaxLines: Integer;
      AHScrollbar, AVScrollbar: PScrollbar);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var E: TEvent); virtual;
  end;

  { TTextWindow }
  {  A window designed to contain a TTextInterior }
  PTextWindow = ^TTextWindow;
  TTextWindow = object(TWindow)
    constructor Init(R: TRect; NewTitle: String; Num, MaxLines: Integer);
    procedure MakeInterior( MaxLines: integer);  virtual;
  end;

  { TEventWindow }
  {  A text window that will a list of the last MaxLines events
     sent to it by DisplayEvent.  TApplication above calls this
     method upon receiving an event in GetEvent.  If this unit
     is included after Views in a unit, all Message calls in that
     unit are also displayed. NOTE: only one of these windows is
     allowed.  If more than one is created the second will return
     False from Valid causing InsertWindow to refuse to insert the
     window in the desktop. }
  PEventWindow = ^TEventWindow;
  TEventWindow = object(TTextWindow)
    Filters: Word;
    constructor Init(var R: TRect; ATitle: String; Num, MaxLines: Integer);
    destructor Done; virtual;
    procedure DisplayEvent(var E: TEvent); virtual;
    procedure FiltersDialog;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure MakeInterior(Maxlines: Integer); virtual;
    function Valid(Command: Word): Boolean; virtual; 
  end;

  { TLogWindow }
  {  Creating a TLogWindow will redirect all Write and Writeln's to
     the window.  Only one of these windows should be created, if more
     than one is create Valid will return False and InsertWindow will
     refuse to insert the window into the desktop. }
  PLogWindow = ^TLogWindow;
  TLogWindow = object(TWindow)
    Interior: PTerminal;
    constructor Init(var Bounds: TRect; BufSize: Word);
    destructor Done; virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;

{ An alternate Message from View's that will log the message to the
  event window before sending it. }
function Message(Receiver: PView; What, Command: Word;
  InfoPtr: Pointer): Pointer;

implementation

uses Dos, Menus, Dialogs, KeyNamer, CmdNamer;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\DOS\TVDEBUG directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

var
  EventWindow: PEventWindow;

{ TApplication }

constructor TApplication.Init;
var
  R: TRect;
begin
  inherited Init;

  BuiltInCommandNames;

  Desktop^.GetExtent(R);
  R.Assign(R.A.X, R.B.Y-10, R.B.X div 2, R.B.Y);
  InsertWindow(New(PEventWindow, Init(R, 'Event Window', wnNoNumber, 100)));

  Desktop^.GetExtent(R);
  R.Assign(R.B.X div 2, R.B.Y-10, R.B.X, R.B.Y);
  InsertWindow(New(PLogWindow, Init(R, 1024)));
end;

procedure TApplication.GetEvent(var E: TEvent);
begin
  inherited GetEvent(E); 
  if EventWindow <> nil then
    EventWindow^.DisplayEvent(E);
end;

const
  CEWMenu = #9#10#11#12#13#14;

{ TEWMenubox }

type
  PEWMenubox = ^TEWMenubox;
  TEWMenubox = object(TMenubox)
    function GetPalette: PPalette; virtual;
  end;

function TEWMenubox.GetPalette: PPalette;
const
  P: String[length(CEWMenu)] = CEWMenu;
begin
  GetPalette:= @P;
end;

{ TEWMenubar }

type
  PEWMenubar = ^TEWMenubar;
  TEWMenubar = object(TMenubar)
    function GetPalette: PPalette; virtual;
    function NewSubView(var Bounds: TRect; AMenu: PMenu;
       AParentMenu: PMenuView): PMenuView; virtual;
  end;

function TEWMenubar.GetPalette: PPalette;
const
  P: string[length(CEWMenu)] = CEWMenu;
begin
  GetPalette:= @P;
end;

function TEWMenubar.NewSubView(var Bounds: TRect; AMenu: PMenu;
  AParentMenu: PMenuView): PMenuView;
begin
  NewSubView := New(PEWMenuBox, Init(Bounds, AMenu, AParentMenu));
end;

{ TTextCollection }

procedure TTextCollection.FreeItem(Item: Pointer);
begin
  DisposeStr(Item);
end;

{ TTextInterior }

constructor TTextInterior.Init( R: TRect; MaxLines: Integer;
  AHScrollbar, AVScrollbar: PScrollbar);
begin
  inherited Init(R, AHScrollbar, AVScrollbar);
  if MaxLines = 0 then
    Lines.Init(Size.X, 1)     { let it grow unchecked:  16K items max}
  else
    Lines.Init(Maxlines, 0);  { fix size and rollover when full }
  SetLimit(128,Size.X);
  GrowMode:= gfGrowHiX + gfGrowHiY;
end;

destructor TTextInterior.Done;
begin
  Lines.Done;
  inherited Done;
end;

procedure TTextInterior.Draw;
var
  color: byte;
  Y, I: Integer;
  B: TDrawBuffer;
begin                            { draw only what's visible }
  Color:= GetColor(1);
  for y:= 0 to Size.Y-1 do
  begin
    MoveChar(B,' ',Color,Size.X);
    I:= Delta.Y+Y;
    if (I < Lines.Count) and (Lines.At(I) <> nil) then
      MoveStr(B, Copy(PString(Lines.At(I))^,Delta.X+1, Size.X), Color);
    WriteLine(0,Y,Size.X,1,B);
  end;
end;

procedure TTextInterior.HandleEvent(var E: TEvent);
begin
  inherited HandleEvent(E);
  case E.What of
    evBroadcast:
      case E.Command of
        cmTextWinAppendLine:
          begin
            if Lines.Count < Lines.Limit then    { let it grow }
            begin
              Lines.Insert(E.Infoptr);
              if Lines.Count > Size.Y then
              begin
                SetLimit(128,Lines.Count);
                if (Owner <> nil) and
                    ((Owner^.Options and ofScrollonAppend) <> 0) then
                  VScrollbar^.SetValue(Lines.Count);
              end;
            end
            else
            begin
              Lines.AtFree(0);           { zap the first item }
              Lines.Insert(E.InfoPtr);   { before adding new one }
            end;
            DrawView;
            end                           { show the changes }
          else
            Exit;
         end;
    else
      Exit;
    end;
  ClearEvent(E);
end;

{ TTextWindow }

constructor TTextWindow.Init( R: TRect; NewTitle: String;
  Num, MaxLines: Integer);
begin
  inherited Init(R,NewTitle, Num);
  MakeInterior(MaxLines);
end;

procedure TTextWindow.MakeInterior( MaxLines: Integer);
var
  R: TRect;
begin
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PTextInterior, Init(R, MaxLines,
    StandardScrollBar(sbHorizontal),
    StandardScrollBar(sbVertical))));
end;

{ TEventWindow }

const
  cmEventFilters = 503;

constructor TEventWindow.Init(var R: TRect; ATitle: String; Num,
  Maxlines: Integer);
begin
  inherited Init(R, ATitle, Num, MaxLines);

  { custom option flag for TextWindow's interior}
  Options:= Options or (ofScrollOnAppend + ofFirstClick);
  Filters := evMouse or evKeyBoard or evMessage;

  EventWindow := @Self; 
end;

destructor TEventWindow.Done;
begin
  inherited Done;
  EventWindow := nil;
end;

procedure TEventWindow.DisplayEvent(var E: TEvent);
var
  st,xs,ys: String;
  Event: Word;
begin
  st:='';
  if State and sfSelected = 0 then
  begin
    Event := E.What and Filters;
    case Event of
      evNothing: Exit;
      evMouseDown,
      evMouseUp,
      evMouseMove,
      evMouseAuto:
        begin
          st := 'Mouse ';
          case E.What of
            evMouseDown: st := st + 'Down, ';
            evMouseUp:   st := st + 'Up, ';
            evMouseMove: st := st + 'Move, ';
            evMouseAuto: st := st + 'Auto, ';
          end;
          case E.Buttons of
            mbLeftButton:  st := st + 'Left Button, ';
            mbRightButton: st := st + 'Right Button, ';
            $04:           st := st + 'Center Button, ';
          end;
          if (E.Buttons <> 0) and E.Double then
            st := st +'Double Click ';
          Str(E.Where.X:0, xs);
          Str(E.Where.Y:0, ys);
          st := st + 'X:' + xs + ' Y:' + ys;
        end;
      evKeyDown:
        begin
          st := KeyName(E.KeyCode);
          if st = '' then
            st := KeyName(Word(E.CharCode));
          st := 'Keyboard ' + st;
        end;
      evCommand,
      evBroadcast:
        begin
          if E.What = evCommand then
            st := 'Command '
          else
            st := 'Broadcast ';
          St := Concat(St, CommandName(E.Command));
        end;
      else
        Str(E.What:0, xs);
        st := 'Unknown Event.What: ' + xs;
      end;  {case}

      Views.Message(@Self, evBroadcast, cmTextWinAppendLine, NewStr(st));
  end;  { if }
end;

procedure TEventWindow.FiltersDialog;
var
  D: PDialog;
  R: TRect;
  DataRec: Word;
begin
  R.Assign(10,6,40,20);
  D := New(PDialog, Init(R, 'Message Filters'));

  with D^ do
  begin
    R.Assign(7,2,22,10);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('Mouse ~D~own',
      NewSItem('Mouse ~U~p',
      NewSItem('Mouse ~M~ove',
      NewSItem('Mouse ~A~uto',
      NewSItem('~K~eyboard',
      NewSItem('~C~ommand',
      NewSItem('~B~roadcast',
      NewSItem('~O~ther', nil)))))))))));

    R.Assign(5,11,13,13);
    Insert(New(PButton, Init(R, 'Ok', cmOk, bfDefault)));

    R.Assign(14,11,24,13);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  { transfer data from filters to a more linear datarec }
  DataRec := 0;
  DataRec := Filters and (evMouse or evKeyDown);
  DataRec := DataRec or ((Filters - DataRec) shr 3);

  if Application^.ExecuteDialog(D, @DataRec) <> cmCancel then
  begin
    Filters := 0;
    Filters := DataRec and (evMouse or evKeyDown);
    Filters := Filters or ((DataRec - Filters) shl 3);
  end;
end;

function TEventWindow.GetPalette: PPalette;
const
  P: String[length(CBlueWindow)+ length(CMenuView)] = CBlueWindow + CMenuView;
begin
  GetPalette := @P;
end;

procedure TEventWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmEventFilters) then
  begin
    FiltersDialog;
    ClearEvent(Event);
  end;
end;

procedure TEventWindow.MakeInterior(Maxlines: Integer);
var
  R: TRect;
  M: PMenubar;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  R.B.Y:= R.A.Y+1;
  Insert(New(PEWMenubar, Init(R, NewMenu(
    NewSubMenu('~O~ptions', hcNoContext, NewMenu(
      NewItem('~F~ilters', '', 0, cmEventFilters, hcNoContext, nil)),
    nil)))));

  GetExtent(R);
  R.Grow(-1, -1);
  Inc(R.A.Y);
  Insert(New(PTextInterior, Init(R, MaxLines,
    StandardScrollBar(sbHorizontal+sbHandleKeyboard),
    StandardScrollBar(sbVertical+sbHandleKeyboard))));
end;

function TEventWindow.Valid(Command: Word): Boolean;
begin
  if inherited Valid(Command) then
    Valid := EventWindow = @Self
  else
    Valid := False;
end;

{ TLogWindow }

function AssignedTo(var T: Text; View: PTextDevice): Boolean;
begin
  AssignedTo :=  Pointer((@TextRec(T).UserData)^) = View;
end;

constructor TLogWindow.Init(var Bounds: TRect; BufSize: Word);
var
  R: TRect;
  vSB, hSB: PScrollBar;
begin
  inherited Init(Bounds, 'Messages Log', wnNoNumber);
  vSB := StandardScrollBar(sbVertical + sbHandleKeyboard);
  Insert(vSB);
  hsb := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  Insert(hSB);
  GetExtent(R);
  R.Grow(-1, -1);
  Interior := New(PTerminal, Init(R, hSB, vSB, BufSize));
  Insert(Interior);
  AssignDevice(Output, Interior);
  Rewrite(Output);
end;

destructor TLogWindow.Done;
begin
  if AssignedTo(Output, Interior) then
  begin
    Assign(Output, '');
    Rewrite(Output);
  end;
  inherited Done;
end;

function TLogWindow.Valid(Command: Word): Boolean;
begin
  Valid := AssignedTo(Output, Interior);
end;

{ Message }

function Message(Receiver: PView; What, Command: Word;
  InfoPtr: Pointer): Pointer;
var
  E: TEvent;
begin
  E.What := What;
  E.Command := Command;
  E.Infoptr := Infoptr;

  { no point in displaying our own message to display an event...}

  if (EventWindow <> nil) and (Command <> cmTextWinAppendLine) then
    EventWindow^.DisplayEvent(E);

  { pass the intercepted data on to the Message function it was intended for }
  Message:= Views.Message(Receiver, What, Command, InfoPtr);
end;

end.