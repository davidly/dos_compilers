{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit FormCmds;

{$D-}

interface

uses Drivers;

const

  { Misc UI commands }
  cmAboutBox    = 2000;
  cmChangeDir   = 2001;
  cmVideoMode   = 2002;
  cmDosShell    = 2003;

  { List & form-oriented commands }
  { (Cannot be disabled)          }
  cmListOpen    = 3000;
  cmListSave    = 3001;
  cmFormEdit    = 3002;
  cmFormNew     = 3003;
  cmFormSave    = 3004;
  cmFormDel     = 3005;

  { Broadcast commands }
  cmTopForm      = 3050;
  cmRegisterForm = 3051;
  cmEditingForm  = 3052;
  cmCanCloseForm = 3053;
  cmCloseForm    = 3054;
  cmTopList      = 3055;
  cmEditingFile  = 3056;

  { History list IDs }
  hlChangeDir   = 1;
  hlOpenListDlg = 2;

implementation

end.
