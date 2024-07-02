
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCMenu;
{ Turbo Pascal 6.0 object-oriented example command line menu system.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses Crt, TCUtil, TCScreen;

{ The menus in this unit are very simple.  Each menu points to a parent (so
  that ESC will take you back to the previous menu) and a list of items.
  Each item is either a pointer to a procedure that will be executed when
  you choose the item, or is a pointer to a new menu.
}

type
  MenuItemPtr = ^MenuItem;
  MenuPtr = ^Menu;
  Menu = object
    MenuString, CommandString : StringPtr;
    MenuItems, LastItem : MenuItemPtr;
    Parent : MenuPtr;
    constructor Init(InitMenuString : String; InitParent : MenuPtr);
    procedure AddItem(NewItem : MenuItemPtr);
    function AddItemProc(NewProc : ProcPtr) : Boolean;
    function AddItemMenu(NewMenu : MenuPtr) : Boolean;
    procedure RunMenu;
    destructor Done;
  end;
  MenuItem = object
    Next : MenuItemPtr;
    constructor Init;
    procedure RunItem(var CurrMenu : MenuPtr); virtual;
  end;
  MenuItemProcPtr = ^MenuItemProc;
  MenuItemProc = object(MenuItem)
    Proc : ProcPtr;
    constructor Init(InitProc : ProcPtr);
    procedure RunItem(var CurrMenu : MenuPtr); virtual;
  end;
  MenuItemMenuPtr = ^MenuItemMenu;
  MenuItemMenu = object(MenuItem)
    NewMenu : MenuPtr;
    constructor Init(InitMenu : MenuPtr);
    procedure RunItem(var CurrMenu : MenuPtr); virtual;
  end;

implementation

constructor Menu.Init(InitMenuString : String; InitParent : MenuPtr);
{ Initializes a new menu }
var
  S : String;
  Counter : Word;
begin
  MenuItems := nil;
  LastItem := nil;
  GetMem(MenuString, Succ(Length(InitMenuString)));
  if MenuString = nil then
    Fail;
  MenuString^ := InitMenuString;
  S := '';
  for Counter := 1 to Length(InitMenuString) do
  begin
    if (InitMenuString[Counter] in ['A'..'Z']) then   
         { Build command string based on upper case letters in mwenu string }
      S := S + InitMenuString[Counter];
  end;
  GetMem(CommandString, Succ(Length(S)));
  if CommandString = nil then
  begin
    Done;
    Fail;
  end;
  CommandString^ := S;
  Parent := InitParent;
end; { Menu.Init }

destructor Menu.Done;
{ Removes a menu from memory }
begin
  if MenuString <> nil then
    FreeMem(MenuString, Succ(Length(MenuString^)));
  if CommandString <> nil then
    FreeMem(CommandString, Succ(Length(CommandString^)));
  LastItem := MenuItems;
  while LastItem <> nil do
  begin
    MenuItems := LastItem;
    LastItem := LastItem^.Next;
    Dispose(MenuItems);
  end;
end; { Menu.Done }

procedure Menu.AddItem(NewItem : MenuItemPtr);
{ Adds a new item to a menu }
begin
  if MenuItems = nil then
  begin
    MenuItems := NewItem;
    LastItem := MenuItems;
  end
  else begin
    LastItem^.Next := NewItem;
    LastItem := LastItem^.Next;
  end;
end; { Menu.AddItem }

function Menu.AddItemProc(NewProc : ProcPtr) : Boolean;
{ Adds a procedure item to a menu }
var
  NewItem : MenuItemProcPtr;
begin
  NewItem := New(MenuItemProcPtr, Init(NewProc));
  if NewItem <> nil then
  begin
    AddItem(NewItem);
    AddItemProc := True;
  end
  else
    AddItemProc := False;
end; { Menu.AddItemProc }

function Menu.AddItemMenu(NewMenu : MenuPtr) : Boolean;
{ Adds a new menu item to a menu }
var
  NewItem : MenuItemMenuPtr;
begin
  NewItem := New(MenuItemMenuPtr, Init(NewMenu));
  if NewItem <> nil then
  begin
    AddItem(NewItem);
    AddItemMenu := True;
  end
  else
    AddItemMenu := False;
end; { Menu.AddItemMenu }

procedure Menu.RunMenu;
{ Run a menu system }
var
  Ch, Counter, P : Word;
  CurrMenu : MenuPtr;
  I : MenuItemPtr;
begin
  CurrMenu := @Self;
  repeat
    with CurrMenu^ do
    begin
      ClrEOLXY(1, Pred(Scr.CurrRows), Colors.MenuLoColor);  { Print the menu }
      for Counter := 1 to Length(MenuString^) do
      begin
        if MenuString^[Counter] in ['A'..'Z'] then
          WriteColor(MenuString^[Counter], Colors.MenuHiColor)
        else
          WriteColor(MenuString^[Counter], Colors.MenuLoColor);
      end;
      repeat
        Ch := GetKeyUpCase;
        case Ch of
          ESC : CurrMenu := Parent;
          Ord(' ')..Ord('~') : begin
            P := Pos(Chr(Lo(Ch)), CommandString^);
            if P <> 0 then              { A menu item has been chosen }
            begin
              I := MenuItems;
              for Counter := 2 to P do
              begin
                if I <> nil then
                  I := I^.Next;
              end;
              if I <> nil then
              begin
                I^.RunItem(CurrMenu);   { Run the procedure or switch menus }
                Ch := ESC;
              end;
            end;
          end;
        end; { case }
      until Ch = ESC;
    end; { with }
  until CurrMenu = nil;
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.MenuLoColor);
end; { Menu.RunMenu }

constructor MenuItem.Init;
{ Initializes a menu item }
begin
  Next := nil;
end; { MenuItem.Init }

procedure MenuItem.RunItem(var CurrMenu : MenuPtr);
begin
  Abstract('MenuItem.RunItem');
end; { MenuItem.RunItem }

constructor MenuItemProc.Init(InitProc : ProcPtr);
{ Initializes a procedure menu item }
begin
  MenuItem.Init;
  Proc := InitProc;
end; { MenuItemProc.Init }

procedure MenuItemProc.RunItem(var CurrMenu : MenuPtr);
{ Runs the procedure that a procedure menu item points to }
begin
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.MenuLoColor);
  if @Proc <> nil then
    Proc;
  CurrMenu := nil;
end; { MenuItemProc.RunItem }

constructor MenuItemMenu.Init(InitMenu : MenuPtr);
{ Initializes a new menu menu item }
begin
  MenuItem.Init;
  NewMenu := InitMenu;
end; { MenuItemMenu.Init }

procedure MenuItemMenu.RunItem(var CurrMenu : MenuPtr);
{ Changes CurrMenu so that the menu that the item points to becomes the new
  current menu }
begin
  CurrMenu := NewMenu;
end; { MenuItemMenu.RunItem }

end.
