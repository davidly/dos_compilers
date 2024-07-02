{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit StrmErr;

interface

uses Objects;

type
  PMsgStream = ^TMsgStream;
  TMsgStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;


implementation

uses MsgBox;

const
  MsgString: array[-6..-1] of String =
    ('Put of unregistered type %d', 'Get of unregistered type %d',
    'Write error %d; cannot expand stream', '%d Read beyond end of stream',
    'Cannot initialize stream, code %d', 'Stream access error %d');

procedure TMsgStream.Error(Code, Info: Integer);
var
  LongInfo: Longint;
begin
  inherited Error(Code, Info);
  LongInfo := Longint(Info);
  MessageBox(MsgString[Code], @LongInfo, mfError or mfOKButton);
end;

end.
