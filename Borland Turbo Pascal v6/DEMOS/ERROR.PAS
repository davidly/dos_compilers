
{ Copyright (c) 1985,90 by Borland International, Inc. }

unit Error;
{ Sample unit for CIRCULAR.PAS }

interface

procedure ShowError(Msg : string);

implementation

uses
  Crt, Display;

procedure ShowError(Msg : string);
begin
  WriteXY(1, 25, 'Error: ' + Msg);
end;

end.
