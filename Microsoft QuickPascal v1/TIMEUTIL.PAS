type
  timetype = record h, m, s, l : integer; end;

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

procedure print_time_part( num : integer );
begin
  if ( num < 10 ) then write( '0' );
  write( num );
end;

procedure print_time( var t: timetype );

begin
  print_time_part( t.h );
  write( ':' );
  print_time_part( t.m );
  write( ':' );
  print_time_part( t.s );
  write( '.' );
  print_time_part( t.l );
end;

procedure print_elapsed_time( var timeStart, timeEnd: timetype );
var
  timeDiff: timetype;
begin
  time_difference( timeStart, timeEnd, timeDiff );
  write( 'elapsed time: ' );
  print_time( timeDiff );
  writeln;
end;
