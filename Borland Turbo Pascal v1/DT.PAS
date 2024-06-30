program dt;

var
  h, m, s, s100: word;

begin
    GetTime( h, m, s, s100 );
    Write( 'time: ' );
    Write( h, ':', m, s, s100 );
end.