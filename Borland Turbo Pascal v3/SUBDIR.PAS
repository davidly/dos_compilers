Program DirectoryExamples;

{
      DIRECTORY PROCEDURES DEMONSTRATION PROGRAM  Version 1.00A

  This program demonstrates the use of TURBO 3.0 directory procedures.

  PSEUDO CODE
  1.  Get the current drive and directory
  2.  Repeat
        Execute the selected TURBO directory procedure
      until the user types "Q" or "0"

 INSTRUCTIONS
 1.  Compile this program using the TURBO.COM compiler.
 2.  Manipulate the directory commands by selecting the menu options.
 3.  Type "Q" or "0" to exit the program.
}

Var
  Path: String[64];
  Ch: Char;

Begin
  ch := '1';   { initialize loop variable }
  Repeat
    if Upcase(ch) IN ['1', 'M', '2', 'R', '3', 'C', '0', 'Q'] then
      begin
         ClrScr;
         GetDir(0,Path); { Get the current directory of the current drive.
                           Note that 0 for the first variable means the current
                           drive, not A:.  1 means A: and so on.   This is contrary
                           to the manual }
         WriteLn('Current directory is ',Path);
         Writeln;
         WriteLn('Choose option: ');
         WriteLn('  1: Make a directory');
         WriteLn('  2: Remove a directory');
         WriteLn('  3: Change the current directory');
         WriteLn('  0: Quit');
         Writeln;
         Write('Option: ');
         Read(Kbd,Ch);

         {$I-}
         Case Upcase(Ch) Of
           '1','M': Begin
                      WriteLn('Make');
                      Write('Make what directory? ');
                      Readln(path);
                      MkDir(Path);
                    End;
           '2','R': Begin
                      WriteLn('Remove');
                      Write('Remove what directory? ');
                      Readln(path);
                      RmDir(Path);
                    End;
           '3','C': Begin
                      WriteLn('Change');
                      Writeln;
                      Write('Change to what directory? ');
                      Readln(path);
                      ChDir(Path); 
                    End;
           '0','Q': WriteLn('Quit');
           Else
          End; { case }

         {$I+}
         If IOResult<>0 Then
            begin
              Write('*** Error: ', path);
              delay(3000);
            end;
       end { if }
     else
       read(kbd, ch)
    Until Upcase(Ch) In ['0','Q', #27];
End.
