{****************************************************************************}
{*  Conv Help: this is not part of the main chess program.  It reads the    *}
{*  text file "HELPTEXT.PAS" which contains the information to be displayed *}
{*  in the online help mode of the chess program.  The output file          *}
{*  "CHESS.HLP" is in the format expected by the chess program.  To change  *}
{*  the help information, edit the HELPTEXT.PAS file and then execute this  *}
{*  program.                                                                *}
{****************************************************************************}

program ConvHelp;
  type string80 = string[80];
       PageType = array[1..22] of string80;
  var Line : string80;
      InFile : Text;
      OutFile : file of PageType;
      key : char;
      LineNum : integer;
      Page : PageType;
      i : integer;
  begin
    writeln ('====Beginning====');
    assign (InFile, 'HELPTEXT.TXT');
    assign (OutFile, 'CHESS.HLP');
    reset (InFile);
    rewrite (OutFile);
    LineNum := 1;
    for i := 1 to 22 do Page[i] := '';
    while not Eof(InFile) do begin
        readln (Infile, Line);
        Line := Copy (Line, 1, 79);
        writeln (Line);
        Page[LineNum] := Line;
        LineNum := LineNum + 1;
        if LineNum > 22 then begin
            write (OutFile, Page);
            writeln ('----New Page----');
            LineNum := 1;
            for i := 1 to 22 do Page[i] := '';
        end;
    end;
    if LineNum <> 1 then write (OutFile, Page);
    writeln ('====Ending====');
    close (OutFile);
  end.
