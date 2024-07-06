BEGIN

INTEGER ARRAY board[0:8];

PROCEDURE winner;
BEGIN
    INTEGER t, p;
    text( 1, "hello from winner" );
  
    p := 0;
    t := board[ 0 ];
    IF 0 # t THEN BEGIN
        IF ( ( ( t = board[1] ) AND ( t = board[2] ) ) OR
             ( ( t = board[3] ) AND ( t = board[6] ) ) ) THEN
            p := t;
    END;

END winner;

    text( 1, "hello from algol, dave" );
    winner;
    ioc(22);

END
FINISH

