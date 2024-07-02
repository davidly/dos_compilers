{************************************************}
{                                                }
{ Turbo List Demo                                }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

program SourceLister;
{
          SOURCE LISTER DEMONSTRATION PROGRAM

   This is a simple program to list your TURBO PASCAL source programs.

   PSEUDO CODE
   1.  Find Pascal source file to be listed
   2.  Initialize program variables
   3.  Open main source file
   4.  Process the file
       a.  Read a character into line buffer until linebuffer full or eoln;
       b.  Search line buffer for include file.
       c.  If line contains include file command:
             Then process include file and extract command from line buffer
             Else print out the line buffer.
       d.  Repeat step 4.a thru 4.c until Eof(main file);

   INSTRUCTIONS
   1. Compile and run the program:
       a. In the Development Environment load LISTER.PAS and
          press ALT-R R.
       b. From the command line type TPC LISTER.PAS (then type
          LISTER to run the program)
   2. Specify the file to print.
}

uses
  Printer;

const
  PageWidth = 80;
  PrintLength = 55;
  PathLength  = 65;
  FormFeed = #12;
  VerticalTabLength = 3;

type
  WorkString = string[126];
  FileName  = string[PathLength];

var
  CurRow : integer;
  MainFileName: FileName;
  MainFile: text;
  search1,
  search2,
  search3,
  search4: string[5];

  procedure Initialize;
  begin
    CurRow := 0;
    search1 := '{$'+'I';    { different forms that the include compiler }
    search2 := '{$'+'i';    { directive can take. }
    search3 := '(*$'+'I';
    search4 := '(*$'+'i';
  end {initialize};

  function Open(var fp:text; name: Filename): boolean;
  begin
    Assign(fp,Name);
    {$I-}
    Reset(fp);
    {$I+}
    Open := IOResult = 0;
  end { Open };

  procedure OpenMain;
  begin
    if ParamCount = 0 then
    begin
      Write('Enter filename: ');
      Readln(MainFileName);
    end
    else
      MainFileName := ParamStr(1);

    if (MainFileName = '') or not Open(MainFile,MainFileName) then
    begin
      Writeln('ERROR:  file not found (', MainFileName, ')');
      Halt(1);
    end;
  end {Open Main};

  procedure VerticalTab;
  var i: integer;
  begin
    for i := 1 to VerticalTabLength do Writeln(LST);
  end {vertical tab};

  procedure ProcessLine(PrintStr: WorkString);
  begin
    CurRow := Succ(CurRow);
    if Length(PrintStr) > PageWidth then Inc(CurRow);
    if CurRow > PrintLength then
    begin
      Write(LST,FormFeed);
      VerticalTab;
      CurRow := 1;
    end;
    Writeln(LST,PrintStr);
  end {Process line};

  procedure ProcessFile;
  { This procedure displays the contents of the Turbo Pascal program on the }
  { printer. It recursively processes include files if they are nested.     }

  var
    LineBuffer: WorkString;

     function IncludeIn(var CurStr: WorkString): boolean;
     var
       ChkChar: char;
       column: integer;
     begin
       ChkChar := '-';
       column := Pos(search1,CurStr);
       if column <> 0 then
         chkchar := CurStr[column+3]
       else
       begin
         column := Pos(search3,CurStr);
         if column <> 0 then
           chkchar := CurStr[column+4]
         else
         begin
           column := Pos(search2,CurStr);
           if column <> 0 then
             chkchar := CurStr[column+3]
           else
           begin
             column := Pos(search4,CurStr);
             if column <> 0 then
               chkchar := CurStr[column+4]
           end;
         end;
       end;
       if ChkChar in ['+','-'] then IncludeIn := False
       else IncludeIn := True;
     end { IncludeIn };

     procedure ProcessIncludeFile(var IncStr: WorkString);

     var NameStart, NameEnd: integer;
         IncludeFile: text;
         IncludeFileName: Filename;

       Function Parse(IncStr: WorkString): WorkString;
       begin
         NameStart := Pos('$I',IncStr)+2;
         while IncStr[NameStart] = ' ' do
           NameStart := Succ(NameStart);
         NameEnd := NameStart;
         while (not (IncStr[NameEnd] in [' ','}','*']))
              and ((NameEnd - NameStart) <= PathLength) do
           Inc(NameEnd);
         Dec(NameEnd);
         Parse := Copy(IncStr,NameStart,(NameEnd-NameStart+1));
       end {Parse};

     begin  {Process include file}
       IncludeFileName := Parse(IncStr);

       if not Open(IncludeFile,IncludeFileName) then
       begin
         LineBuffer := 'ERROR:  include file not found (' +
                       IncludeFileName + ')';
         ProcessLine(LineBuffer);
       end
       else
       begin
         while not EOF(IncludeFile) do
         begin
           Readln(IncludeFile,LineBuffer);
           { Turbo Pascal 6.0 allows nested include files so we must
             check for them and do a recursive call if necessary }
           if IncludeIn(LineBuffer) then
             ProcessIncludeFile(LineBuffer)
           else
             ProcessLine(LineBuffer);
         end;
         Close(IncludeFile);
       end;
     end {Process include file};

  begin  {Process File}
    VerticalTab;
    Writeln('Printing . . . ');
    while not EOF(mainfile) do
    begin
      Readln(MainFile,LineBuffer);
      if IncludeIn(LineBuffer) then
         ProcessIncludeFile(LineBuffer)
      else
         ProcessLine(LineBuffer);
    end;
    Close(MainFile);
    Write(LST,FormFeed); { move the printer to the beginning of the next }
                         { page }
  end {Process File};

begin
  Initialize;      { initialize some global variables }
  OpenMain;        { open the file to print }
  ProcessFile;     { print the program }
end.
