program TimeDifference;

{$I timeutil.pas}

var
  ta, tb, tdiff: timetype;
  i, j, x: integer;

begin
  get_time( ta );

  write( 'start time: ' );
  print_time( ta );
  writeln;

  for j := 1 to 3000 do
    for i := 1 to 30000 do
       x := i * 4 * 4 + x;

  get_time( tb );
  write( 'end time: ' );
  print_time( tb );
  writeln;

  time_difference( ta, tb, tdiff );
  write( 'elapsed time: ' );
  print_time( tdiff );
  writeln;

  writeln( 'done' );
end.
