-- Note: this code passes "board" as an arguments instead of using a global variable because
-- while the AI interpreter produces correct results both ways, the A86 compiler produces
-- inconsistent offsets for accessing "board" as a global variable and ttt fails to run properly.
-- Ada (well, this version) prohibits in+out arguments to functions, so procedures are used instead.

with TEXT_IO; use TEXT_IO;

procedure TTT is

ScoreWin : Constant := 6;
ScoreTie : Constant := 5;
ScoreLose : Constant :=  4;
ScoreMax : Constant := 9;
ScoreMin : Constant := 2;
DefaultIterations : Constant := 10;

PieceX : Constant := 1;
PieceO : Constant := 2;
PieceBlank : Constant := 0;

moves : integer;

type TTTBoardType is array (integer range 0..8) of integer;
    
procedure LookForWinner( board : in TTTBoardType; p : in out integer ) is
begin
    p := board(0);
    if ( PieceBlank /= p ) then 
        if ( p = board(1) and p = board(2) ) then return; end if;
        if ( p = board(3) and p = board(6) ) then return; end if;
    end if;

    p := board(3);
    if ( ( PieceBlank /= p ) and ( p = board(4) ) and ( p = board(5) ) ) then return; end if;

    p := board(6);
    if ( ( PieceBlank /= p ) and ( p = board(7) ) and ( p = board(8) ) ) then return; end if;

    p := board(1);
    if ( PieceBlank /= p and p = board(4) and p = board(7) ) then return; end if;

    p := board(2);
    if ( PieceBlank /= p and p = board(5) and p = board(8) ) then return; end if;

    p := board(4);
    if ( PieceBlank /= p ) then 
        if ( p = board(0) and p = board(8) ) then return; end if;
        if ( p = board(2) and p = board(6) ) then return; end if;
    end if;

    p := PieceBlank;
end LookForWinner;

procedure pos0func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 0 );
    if ( ( p = board(1) and p = board(2) ) or
         ( p = board(3) and p = board(6) ) or
         ( p = board(4) and p = board(8) ) ) then return; end if;
    p := PieceBlank;
end pos0func;

procedure pos1func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 1 );
    if ( ( p = board(0) and p = board(2) ) or
         ( p = board(4) and p = board(7) ) ) then return; end if;
    p := PieceBlank;
end pos1func;

procedure pos2func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 2 );
    if ( ( p = board(0) and p = board(1) ) or
         ( p = board(5) and p = board(8) ) or
         ( p = board(4) and p = board(6) ) ) then return; end if;
    p := PieceBlank;
end pos2func;

procedure pos3func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 3 );
    if ( ( p = board(4) and p = board(5) ) or
         ( p = board(0) and p = board(6) ) ) then return; end if;
    p := PieceBlank;
end pos3func;

procedure pos4func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 4 );
    if ( ( p = board(0) and p = board(8) ) or
         ( p = board(2) and p = board(6) ) or
         ( p = board(1) and p = board(7) ) or
         ( p = board(3) and p = board(5) ) ) then return; end if;
    p := PieceBlank;
end pos4func;

procedure pos5func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 5 );
    if ( ( p = board(3) and p = board(4) ) or
         ( p = board(2) and p = board(8) ) ) then return; end if;
    p := PieceBlank;
end pos5func;

procedure pos6func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 6 );
    if ( ( p = board(7) and p = board(8) ) or
         ( p = board(0) and p = board(3) ) or
         ( p = board(4) and p = board(2) ) ) then return; end if;
    p := PieceBlank;
end pos6func;

procedure pos7func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 7 );
    if ( ( p = board(6) and p = board(8) ) or
         ( p = board(1) and p = board(4) ) ) then return; end if;
    p := PieceBlank;
end pos7func;

procedure pos8func( board : in TTTBoardType; p : in out integer ) is
begin
    p := board( 8 );
    if ( ( p = board(6) and p = board(7) ) or
         ( p = board(2) and p = board(5) ) or
         ( p = board(0) and p = board(4) ) ) then return; end if;
    p := PieceBlank;
end pos8func;

procedure MinMax( alphaarg : in integer; betaarg : in integer;
                  depth : in integer; move : in integer;
                  board : in out TTTBoardType; score : out integer ) is
sc, alpha, beta, p, value, pieceMove : integer;
begin
    moves := moves + 1;

    if ( depth >= 4 ) then
        --LookForWinner( board, p );  -- this is much slower than the posXfunc solution

        case move is
            when 0 => pos0func( board, p );
            when 1 => pos1func( board, p );
            when 2 => pos2func( board, p );
            when 3 => pos3func( board, p );
            when 4 => pos4func( board, p );
            when 5 => pos5func( board, p );
            when 6 => pos6func( board, p );
            when 7 => pos7func( board, p );
            when 8 => pos8func( board, p );
            when others => Put( "invalid move!" ); -- the compiler needs a when others
        end case;

        if ( PieceBlank /= p ) then
            if ( PieceX = p ) then score := ScoreWin; return; end if;
            score := ScoreLose;
            return;
        end if;

        if ( 8 = depth ) then score := ScoreTie; return; end if;
    end if;

    alpha := alphaarg;
    beta := betaarg;

    if ( pieceO = board( move ) ) then -- a bitwise operator on depth would be faster
        value := ScoreMin;
        pieceMove := PieceX;
    else
        value := ScoreMax;
        pieceMove := PieceO;
    end if;

    for p in 0..8 loop
        if ( PieceBlank = board( p ) ) then
            board( p ) := pieceMove;
            MinMax( alpha, beta, depth + 1, p, board, sc );
            board( p ) := pieceBlank;

            if ( PieceX = pieceMove ) then
                if ( sc = ScoreWin ) then score := ScoreWin; return; end if;
                if ( sc > value ) then
                    if ( sc >= beta ) then score := sc; return; end if;
                    value := sc;
                    if ( value > alpha ) then alpha := value; end if;
                end if;
            else
                if ( sc = ScoreLose ) then score := ScoreLose; return; end if;
                if ( sc < value ) then
                    if ( sc <= alpha ) then score := sc; return; end if;
                    value := sc;
                    if ( value < beta ) then beta := value; end if;
                end if;
            end if;
        end if;
    end loop;

    score := value;
end MinMax;

procedure FindSolution( move : in integer ) is
board : TTTBoardType;
score : integer;
begin
    board := ( others => PieceBlank );
    board( move ) := PieceX;

    MinMax( ScoreMin, ScoreMax, 0, move, board, score );
end FindSolution;

i, iterations : integer;
begin
    iterations := DefaultIterations;

    for i in 1..iterations loop -- iterations loop
        moves := 0;
        FindSolution( 0 );
        FindSolution( 1 );
        FindSolution( 4 );
    end loop;

    Put( "Moves:      " ); Put( INTEGER'IMAGE( moves ) ); New_line;
    Put( "Iterations: " ); Put( INTEGER'IMAGE( iterations ) ); New_line;
end TTT;
