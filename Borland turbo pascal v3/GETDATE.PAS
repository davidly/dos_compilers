{* WARNING WARNING WARNING WARNING WARNING WARNING WARNING

    Do not try to use the MsDos function call unless you are
    very familiar with the operating system and have technical
    information available to you!

   The following program uses the MsDos command in Turbo to
   retrieve the system date.  This is achieved via DOS function
   call 42 (or 2A hex).  The function call is placed in the AH
   register according to the technical reference manual.

   Type in the following code.  The only output is the date
   at the top of your screen.*}

program GetDate;
type
  DateStr = string[10];

function Date: DateStr;
type
  regpack = record
              ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
            end;

var
  recpack:       regpack;                {record for MsDos call}
  month,day:     string[2];
  year:          string[4];
  dx,cx:         integer;

begin
  with recpack do
  begin
    ax := $2a shl 8;
  end;
  MsDos(recpack);                        { call function }
  with recpack do
  begin
    str(cx,year);                        {convert to string}
    str(dx mod 256,day);                     { " }
    str(dx shr 8,month);                     { " }
  end;
  date := month+'/'+day+'/'+year;
end;

begin
  writeln(date);
end.