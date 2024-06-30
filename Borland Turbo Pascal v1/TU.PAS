type
  timetype = record h, m, s, l : integer; end;
  regpac = record
           ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
           end;
  tustr = string[30];

procedure time_difference( var tStart, tEnd, tDiff : timetype );
var
  startSecond, startMinute, startHour : integer;

begin { time_difference }
  startSecond := tStart.s;
  startMinute := tStart.m;
  startHour := tStart.h;

  tDiff.l := tEnd.l - tStart.l;
  if ( tDiff.l < 0 ) then
  begin
    tDiff.l := tDiff.l + 100;
    startSecond := startSecond + 1;
  end;

  tDiff.s := tEnd.s - startSecond;
  if ( tDiff.s < 0 ) then
  begin
    tDiff.s := tDiff.s + 60;
    startMinute := startMinute + 1;
  end;

  tDiff.m := tEnd.m - startMinute;
  if ( tDiff.m < 0 ) then
  begin
    tDiff.m := tDiff.m + 60;
    startHour := startHour + 1;
  end;

  tDiff.h := tEnd.h - startHour;
  if ( tDiff.h < 0 ) then
    tDiff.h := tDiff.h + 12;
end;

procedure oc( var c : char );
var
  recpack: regpac;
  ah,al,ch,cl,dh: byte;

begin
  ah := $8;
  with recpack do
  begin
    ax := ah shl 8 + al;
    dx := ord( c );
  end;
  intr( $21, recpack );
end;

procedure ostr( var s: tustr );
var
  i, l : integer;
begin { ostr }
    l := Length( s );
    for i := 1 to l  do begin
      oc( s[ i ] );
    end;
end;

procedure onum( var n: integer );
var
  s : tustr;
begin { onum }
    Str( n, s );
    ostr( s );
end;

procedure print_time_part( num : integer );
var c : char;
begin
  c := '0';
  if ( num < 10 ) then oc( c );
  onum( num );
end;

procedure print_time( var t: timetype );
var c : char;
begin
  print_time_part( t.h );
  c := ':';
  oc( c );
  print_time_part( t.m );
  oc( c );
  print_time_part( t.s );
  c := '.';
  oc( c );
  print_time_part( t.l );
end;

procedure print_elapsed_time( var timeStart, timeEnd: timetype );
var
  timeDiff: timetype;
  s : tustr;
  c : char;
begin
  time_difference( timeStart, timeEnd, timeDiff );
  s := 'elapsed time: ';
  ostr( s );
  print_time( timeDiff );
  c := Chr( 10 );
  oc( c );
  c := Char( 13 );
  oc( c );
end;
