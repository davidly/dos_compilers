{************************************************}
{                                                }
{ 286 Detection Demo                             }
{ Copyright (c) 1985,90 by Borland International }
{                                                }
{************************************************}

(*
  Programs compiled with {$G} compiler directive enabled do not
  check the processor at runtime to determine whether it is
  286-compatible. Trying to execute 80286 instructions on an 8086
  or an 8088 will lock up the computer. This program shows how to
  check for the presence of a 286-compatible chip at runtime.

  If you want to put code like this in a program with {$G+}
  enabled, put the test and halt code in the initialization
  section of the first unit in the main program's USES clause.
*)

program Test286;

function Is286Able: Boolean; assembler;
asm
        PUSHF
        POP     BX
        AND     BX,0FFFH
        PUSH    BX
        POPF
        PUSHF
        POP     BX
        AND     BX,0F000H
        CMP     BX,0F000H
        MOV     AX,0
        JZ      @@1
        MOV     AX,1
@@1:
end;

begin
  if not Is286Able then
  begin
    Writeln('Need an 80286-compatible system to run this program');
    Halt(1);
   end;
end.
