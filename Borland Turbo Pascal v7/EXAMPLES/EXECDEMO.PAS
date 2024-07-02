{************************************************}
{                                                }
{ Turbo Exec Demo                                }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

program ExecDemo;

(*
  Demonstration program that shows how to use the Dos
  unit's Exec procedure to execute DOS commands (including
  running other programs or batch files).

  This program keeps prompting you for a DOS command until
  you enter a blank line.

  When using Exec, make sure you specify a {$M} directive
  so the heap leaves some memory available for the child
  process.
*)

{$M 8192,0,0}           { Leave memory for child process }

uses Dos;

var
  Command: string[127];

begin
  repeat
    Write('Enter DOS command: ');
    ReadLn(Command);
    if Command <> '' then
    begin
      SwapVectors;
      Exec(GetEnv('COMSPEC'), '/C ' + Command);
      SwapVectors;
      if DosError <> 0 then
        WriteLn('Could not execute COMMAND.COM');
      WriteLn;
    end;
  until Command = '';
end.
