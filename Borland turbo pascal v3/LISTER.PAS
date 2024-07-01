program SourceLister;

{
          SOURCE LISTER DEMONSTRATION PROGRAM  Version 1.00A

   This is a simple program to list your TURBO PASCAL source programs.

   INSTRUCTIONS
   1. Execute Turbo Pascal
   2. Load this file as the work file
   3. Select the .COM option from the compiler Options menu
   4. Compile this program
   5. Quit Turbo Pascal
   6. Execute the program LISTER by typing LISTER at the operating
      system command line

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
       d.  Repeat step 4.a thru 4.c until eof(main file);


}

Const
  PageWidth         = 80;
  PrintLength       = 55;
  PathLength        = 65;
  FormFeed          = #12;
  VerticalTabLength = 3;

Type
  WorkString = String[126];
  FileName   = String[PathLength];

Var
  CurRow       : integer;
  MainFileName : FileName;
  MainFile     : text;
  search1      : string[5];
  search2      : string[5];
  search3      : string[5];
  search4      : string[5];

  Procedure Initialize;
  begin
    CurRow := 0;
    clrscr;
    search1 := '{$'+'I';  { So LISTER can list itself! }
    search2 := '{$'+'i';
    search3 := '(*$'+'I';
    search4 := '(*$'+'i';
  end {initialize};

  Function Open(var fp:text; name: Filename): boolean;
  begin
    Assign(fp,Name);
    {$I-}
    reset(fp);
    {$I+}
    If IOresult <> 0 then
     begin
      Open := False;
      close(fp);
     end
    else
      Open := True;
  end { Open };

  Procedure OpenMain;
  begin
    If ParamCount = 0 then
    begin
      Write('Enter filename: ');
      readln(MainFileName);
    end
    else
    begin
      MainFileName := ParamStr(1);
    end;
    If Not Open(MainFile,MainFileName) Then
    begin
      Writeln('ERROR -- File not found:  ',MainFileName);
      Halt;
    end;
  end {Open Main};

  Procedure VerticalTab;
  var i: integer;
  begin
    for i := 1 to VerticalTabLength do writeln(lst);
  end {vertical tab};

  Procedure ProcessLine(PrintStr: WorkString);
  begin
    CurRow := Succ(CurRow);
    if length(PrintStr) > PageWidth then CurRow := Succ(CurRow);
    if CurRow > PrintLength Then
    begin
      Write(lst,FormFeed);
      VerticalTab;
      CurRow := 1;
    end;
    Writeln(lst,PrintStr);
  end {Process line};

  Procedure ProcessFile;

  var
    LineBuffer : WorkString;

     Function IncludeIn(VAR CurStr: WorkString): Boolean;

     Var
       ChkChar : char;
       column  : integer;

     begin
       ChkChar := '-';
       column := pos(search1,CurStr);
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
       Else IncludeIn := True;
     end { IncludeIn };


     Procedure ProcessIncludeFile(VAR IncStr: WorkString);

     var
       NameStart       : integer;
       NameEnd         : integer;
       IncludeFile     : text;
       IncludeFileName : Filename;

       Function Parse(IncStr: WorkString): WorkString;
       begin
         NameStart := pos('$I',IncStr)+2;
         while IncStr[NameStart] = ' ' do
           NameStart := Succ(NameStart);
         NameEnd := NameStart;
         while (not (IncStr[NameEnd] in [' ','}','*']))
              AND ((NameEnd - NameStart) <= PathLength)
              do NameEnd := Succ(NameEnd);
         NameEnd := Pred(NameEnd);
         Parse := copy(IncStr,NameStart,(NameEnd-NameStart+1));
       end {Parse};

     begin  {Process include file}
       IncludeFileName := Parse(IncStr);

       If not Open(IncludeFile,IncludeFileName) then
       begin
         LineBuffer := 'ERROR -- Include file not found:  ' + IncludeFileName;
         ProcessLine(LineBuffer);
       end
       Else
       begin
         while not eof(IncludeFile) do
         begin
           Readln(IncludeFile,LineBuffer);
           ProcessLine(LineBuffer);
         end;
         close(IncludeFile);
       end;
     end {Process include file};

  begin  {Process File}
    VerticalTab;
    Writeln('Printing . . . ');
    while not eof(mainfile) do
    begin
      Readln(MainFile,LineBuffer);
      if IncludeIn(LineBuffer) then
         ProcessIncludeFile(LineBuffer)
      else
         ProcessLine(LineBuffer);
    end;
    close(MainFile);
    write(lst,FormFeed);
  end {Process File};


BEGIN
  Initialize;
  OpenMain;
  ProcessFile;
END.
