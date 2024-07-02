
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

unit Drivers;
{ Sample unit to accompany GRLINK.PAS. This unit links all the BGI graphics
  driver into a single TPU file. This makes it easy to link the driver files
  directly into an .EXE file. See GRLINK.PAS for more information.
}
interface

procedure ATTDriverProc;
procedure CgaDriverProc;
procedure EgaVgaDriverProc;
procedure HercDriverProc;
procedure PC3270DriverProc;

implementation

procedure ATTDriverProc; external;
{$L ATT.OBJ }

procedure CgaDriverProc; external;
{$L CGA.OBJ }

procedure EgaVgaDriverProc; external;
{$L EGAVGA.OBJ }

procedure HercDriverProc; external;
{$L HERC.OBJ }

procedure PC3270DriverProc; external;
{$L PC3270.OBJ }

end.
