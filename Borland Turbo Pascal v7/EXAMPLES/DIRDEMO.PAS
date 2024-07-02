{************************************************}
{                                                }
{ Turbo Directory Demo                           }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

program DirDemo;
{ Demonstration program that shows how to use:

    o Directory routines from DOS unit
    o Procedural types (used by QuickSort)

  Usage:

    dirdemo [options] [directory mask]

  Options:

    -W      Wide display
    -N      Sort by file name
    -S      Sort by file size
    -T      Sort by file date and time

  Directory mask:

    Path, Filename, wildcards, etc.

}

{$I-,S-}
{$M 8192,8192,655360}

uses Dos;

const
  MaxDirSize = 512;
  MonthStr: array[1..12] of string[3] = (
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

type
  DirPtr   = ^DirRec;
  DirRec   = record
               Attr: Byte;
               Time: Longint;
               Size: Longint;
               Name: string[12];
             end;
  DirList  = array[0..MaxDirSize - 1] of DirPtr;
  LessFunc = function(X, Y: DirPtr): Boolean;

var
  WideDir: Boolean;
  Count: Integer;
  Less: LessFunc;
  Path: PathStr;
  Dir: DirList;

function NumStr(N, D: Integer): String;
begin
  NumStr[0] := Chr(D);
  while D > 0 do
  begin
    NumStr[D] := Chr(N mod 10 + Ord('0'));
    N := N div 10;
    Dec(D);
  end;
end;

{$F+}

function LessName(X, Y: DirPtr): Boolean;
begin
  LessName := X^.Name < Y^.Name;
end;

function LessSize(X, Y: DirPtr): Boolean;
begin
  LessSize := X^.Size < Y^.Size;
end;

function LessTime(X, Y: DirPtr): Boolean;
begin
  LessTime := X^.Time > Y^.Time;
end;

{$F-}

procedure QuickSort(L, R: Integer);
var
  I, J: Integer;
  X, Y: DirPtr;
begin
  I := L;
  J := R;
  X := Dir[(L + R) div 2];
  repeat
    while Less(Dir[I], X) do Inc(I);
    while Less(X, Dir[J]) do Dec(J);
    if I <= J then
    begin
      Y := Dir[I];
      Dir[I] := Dir[J];
      Dir[J] := Y;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSort(L, J);
  if I < R then QuickSort(I, R);
end;

procedure GetCommand;
var
  I,J: Integer;
  Attr: Word;
  S: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  F: File;
begin
  WideDir := False;
  @Less := nil;
  Path := '';
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if S[1] = '-' then
      for J := 2 to Length(S) do
        case UpCase(S[J]) of
          'N': Less := LessName;
          'S': Less := LessSize;
          'T': Less := LessTime;
          'W': WideDir := True;
        else
          WriteLn('Invalid option: ', S[J]);
          Halt(1);
        end
    else
      Path := S;
  end;
  Path := FExpand(Path);
  if Path[Length(Path)] <> '\' then
  begin
    Assign(F, Path);
    GetFAttr(F, Attr);
    if (DosError = 0) and (Attr and Directory <> 0) then
      Path := Path + '\';
  end;
  FSplit(Path, D, N, E);
  if N = '' then N := '*';
  if E = '' then E := '.*';
  Path := D + N + E;
end;

procedure FindFiles;
var
  F: SearchRec;
begin
  Count := 0;
  FindFirst(Path, ReadOnly + Directory + Archive, F);
  while (DosError = 0) and (Count < MaxDirSize) do
  begin
    GetMem(Dir[Count], Length(F.Name) + 10);
    Move(F.Attr, Dir[Count]^, Length(F.Name) + 10);
    Inc(Count);
    FindNext(F);
  end;
end;

procedure SortFiles;
begin
  if (Count <> 0) and (@Less <> nil) then
    QuickSort(0, Count - 1);
end;

procedure PrintFiles;
var
  I, P: Integer;
  Total: Longint;
  T: DateTime;
  N: NameStr;
  E: ExtStr;
begin
  WriteLn('Directory of ', Path);
  if Count = 0 then
  begin
    WriteLn('No matching files');
    Exit;
  end;
  Total := 0;
  for I := 0 to Count-1 do
  with Dir[I]^ do
  begin
    P := Pos('.', Name);
    if P > 1 then
    begin
      N := Copy(Name, 1, P - 1);
      E := Copy(Name, P + 1, 3);
    end else
    begin
      N := Name;
      E := '';
    end;
    Write(N, ' ': 9 - Length(N), E, ' ': 4 - Length(E));
    if WideDir then
    begin
      if Attr and Directory <> 0 then
        Write(' DIR')
      else
        Write((Size + 1023) shr 10: 3, 'k');
      if I and 3 <> 3 then
        Write(' ': 3)
      else
        WriteLn;
    end else
    begin
      if Attr and Directory <> 0 then
        Write('<DIR>   ')
      else
        Write(Size: 8);
      UnpackTime(Time, T);
      WriteLn(T.Day: 4, '-',
        MonthStr[T.Month], '-',
        NumStr(T.Year mod 100, 2),
        T.Hour: 4, ':',
        NumStr(T.Min, 2));
    end;
    Inc(Total, Size);
  end;
  if WideDir and (Count and 3 <> 0) then WriteLn;
  WriteLn(Count, ' files, ', Total, ' bytes, ',
    DiskFree(Ord(Path[1])-64), ' bytes free');
end;

begin
  GetCommand;
  FindFiles;
  SortFiles;
  PrintFiles;
end.
