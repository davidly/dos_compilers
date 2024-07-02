{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{$M 16384,8192,655360}

{ This program uses GENPHONE and GENPARTS to generate forms data
  files for use by TVFORMS.PAS. Run the batch file, GENFORMS.BAT
  to make data files for TVFORMS.PAS.
}

program GenForm;

uses
  Objects, Drivers, Views, Menus, Dialogs, App,
  DataColl, Forms, Fields, Editors,
{$IFDEF PHONENUM}
  GenPhone;
{$ELSE}
{$IFDEF PARTS}
  GenParts;
{$ELSE}
  Error: Specify PHONENUM or PARTS as a conditional define, compile and then run.
{$ENDIF}
{$ENDIF}

type
  PReportStream = ^TReportStream;
  TReportStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

procedure TReportStream.Error(Code, Info: Integer);
begin
  Writeln('Stream error: ', Code, ' (',Info,')');
  Halt(1);
end;

var
  Collection: PSortedCollection;
  i: Integer;
  F: PForm;
  P: Pointer;
  R: TResourceFile;
  S: PBufStream;

begin
  Writeln('Creating ', RezFileName);

  { Stream registration }
  RegisterObjects;
  RegisterViews;
  RegisterDialogs;
  RegisterDataColl;
  RegisterForms;
  RegisterFields;
  RegisterEditors;

  { Init stream and resource }
  S := New(PReportStream, Init(RezFileName, stCreate, 1024));
  R.Init(S);

  { Form }
  F := MakeForm;
  R.Put(F, 'FormDialog');

  { Data }
  Collection := New(PDataCollection,
    Init(DataCount + 10, 5, SizeOf(TDataRec), DataKeyType));
  Collection^.Duplicates := AllowDuplicates;
  for i := 1 to DataCount do
  begin
    GetMem(P, SizeOf(TDataRec));       { allocate }
    F^.SetData(Data[i]);               { move into object }
    F^.GetData(P^);                    { move onto heap }
    Collection^.Insert(P);             { insert in sorted order }
  end;
  R.Put(Collection, 'FormData');

  { Done }
  Dispose(F, Done);
  Dispose(Collection, Done);
  R.Done;
end.
