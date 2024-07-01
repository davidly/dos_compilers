{* WARNING WARNING WARNING WARNING WARNING WARNING WARNING
    In order to use the Intr procedure in Turbo Pascal you
    must be familiar with interrupts and have access to a
    technical reference manual.

    The following program uses the Intr function in Turbo to
    get the time.  Registers have to be set correctly according
    to the DOS technical reference manual before the function
    is called.

    The program simply returns the time in a string at the top
    of the screen.*}

program TimeInterrupt;
type
  TimeString = string[8];

function time: TimeString;
type
  regpack = record
              ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
            end;

var
  recpack:          regpack;             {assign record}
  ah,al,ch,cl,dh:   byte;
  hour,min,sec:     string[2];

begin
  ah := $2c;                             {initialize correct registers}
  with recpack do
  begin
    ax := ah shl 8 + al;
  end;
  intr($21,recpack);                     {call interrupt}
  with recpack do
  begin
    str(cx shr 8,hour);                  {convert to string}
    str(cx mod 256,min);                       { " }
    str(dx shr 8,sec);                         { " }
  end;
  time := hour+':'+min+':'+sec;
end;

begin
  writeln(time);
end.