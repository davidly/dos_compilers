{ App to prove you can't win at Tic-Tac-Toe }
{ use of byte instead of integer should be faster, but it's not }

program ttt;

uses Dos;

{$I timeutil.pas}
{$I dos_gt.pas}

type TScoreFunc = function : integer;

const
    scoreWin = 6;
    scoreTie = 5;
    scoreLose = 4;
    scoreMax = 9;
    scoreMin = 2;
    scoreInvalid = 0;
  
    pieceBlank = 0;
    pieceX = 1;
    pieceO = 2;
  
    iterations = 1;

type
    boardType = array[ 0..8 ] of integer;
    funcArrayType = array[ 0..8 ] of pointer;

var
    { update evaluated after each run because longint operations are slow }
    evaluated: longint;
    moves: integer;
    board: boardType;
    timeStart, timeEnd: timetype;
    scoreFuncs : funcArrayType;

procedure dumpBoard;
var
    i : integer;
begin
    Write( '{' );
    for i := 0 to 8 do
        Write( board[i] );
    Write( '}' );
end;

function func0 : integer;
var x : integer;
begin
    x := board[0];
    if ( ( ( x = board[1] ) and ( x = board[2] )  ) or
         ( ( x = board[3] ) and ( x = board[6] ) ) or
         ( ( x = board[4] ) and ( x = board[8] ) ) ) then
        func0 := x
    else
        func0 := pieceBlank;
end;

function func1 : integer;
var x : integer;
begin
    x := board[1];
    if ( ( ( x = board[0] ) and ( x = board[2] )  ) or
         ( ( x = board[4] ) and ( x = board[7] ) ) ) then
        func1 := x
    else
        func1 := pieceBlank;
end;

function func2 : integer;
var x : integer;
begin
    x := board[2];
    if ( ( ( x = board[0] ) and ( x = board[1] )  ) or
         ( ( x = board[5] ) and ( x = board[8] ) ) or
         ( ( x = board[4] ) and ( x = board[6] ) ) ) then
        func2 := x
    else
        func2 := pieceBlank;
end;

function func3 : integer;
var x : integer;
begin
    x := board[3];
    if ( ( ( x = board[4] ) and ( x = board[5] )  ) or
         ( ( x = board[0] ) and ( x = board[6] ) ) ) then
        func3 := x
    else
        func3 := pieceBlank;
end;

function func4 : integer;
var x : integer;
begin
    x := board[4];
    if ( ( ( x = board[0] ) and ( x = board[8] )  ) or
         ( ( x = board[2] ) and ( x = board[6] ) ) or
         ( ( x = board[1] ) and ( x = board[7] ) ) or
         ( ( x = board[3] ) and ( x = board[5] ) ) ) then
        func4 := x
    else
        func4 := pieceBlank;
end;

function func5 : integer;
var x : integer;
begin
    x := board[5];
    if ( ( ( x = board[3] ) and ( x = board[4] )  ) or
         ( ( x = board[2] ) and ( x = board[8] ) ) ) then
        func5 := x
    else
        func5 := pieceBlank;
end;

function func6 : integer;
var x : integer;
begin
    x := board[6];
    if ( ( ( x = board[7] ) and ( x = board[8] )  ) or
         ( ( x = board[0] ) and ( x = board[3] ) ) or
         ( ( x = board[4] ) and ( x = board[2] ) ) ) then
        func6 := x
    else
        func6 := pieceBlank;
end;

function func7 : integer;
var x : integer;
begin
    x := board[7];
    if ( ( ( x = board[6] ) and ( x = board[8] )  ) or
         ( ( x = board[1] ) and ( x = board[4] ) ) ) then
        func7 := x
    else
        func7 := pieceBlank;
end;

function func8 : integer;
var x : integer;
begin
    x := board[8];
    if ( ( ( x = board[6] ) and ( x = board[7] )  ) or
         ( ( x = board[2] ) and ( x = board[5] ) ) or
         ( ( x = board[0] ) and ( x = board[4] ) ) ) then
        func8 := x
    else
        func8 := pieceBlank;
end;

function lookForWinner : integer;
var
    t, p : integer;
begin
    {dumpBoard;}
    p := pieceBlank;
    t := board[ 0 ];
    if pieceBlank <> t then
    begin
        if ( ( ( t = board[1] ) and ( t = board[2] ) ) or
             ( ( t = board[3] ) and ( t = board[6] ) ) ) then
            p := t;
    end;
  
    if pieceBlank = p then
    begin
        t := board[1];
        if ( t = board[4] ) and ( t = board[7] ) then
            p := t
        else
        begin
            t := board[2];
            if ( t = board[5] ) and ( t = board[8] ) then
                p := t
            else
            begin
                t := board[3];
                if ( t = board[4] ) and ( t = board[5] ) then
                    p := t
                else
                begin
                    t := board[6];
                    if ( t = board[7] ) and ( t = board[8] ) then
                        p := t
                    else
                    begin
                        t := board[4];
                        if ( ( ( t = board[0] ) and ( t = board[8] ) ) or
                             ( ( t = board[2] ) and ( t = board[6] ) ) ) then
                            p := t
                    end;
                end;
            end;
        end;
    end;
  
    lookForWinner := p;
end;

function winner2( move: integer ) : integer;
var
    x : integer;
begin
    case move of
        0:  begin
            x := board[ 0 ];
            if not ( ( ( x = board[1] ) and ( x = board[2] ) ) or
                     ( ( x = board[3] ) and ( x = board[6] ) ) or
                     ( ( x = board[4] ) and ( x = board[8] ) ) )
                then x := PieceBlank;
            end;
        1:  begin
            x := board[ 1 ];
            if not ( ( ( x = board[0] ) and ( x = board[2] ) ) or
                     ( ( x = board[4] ) and ( x = board[7] ) ) )
                then x := PieceBlank;
            end;
        2:  begin
            x := board[ 2 ];
            if not ( ( ( x = board[0] ) and ( x = board[1] ) ) or
                     ( ( x = board[5] ) and ( x = board[8] ) ) or
                     ( ( x = board[4] ) and ( x = board[6] ) ) )
                then x := PieceBlank;
            end;
        3:  begin
            x := board[ 3 ];
            if not ( ( ( x = board[4] ) and ( x = board[5] ) ) or
                     ( ( x = board[0] ) and ( x = board[6] ) ) )
                then x := PieceBlank;
            end;
        4:  begin
            x := board[ 4 ];
            if not ( ( ( x = board[0] ) and ( x = board[8] ) ) or
                     ( ( x = board[2] ) and ( x = board[6] ) ) or
                     ( ( x = board[1] ) and ( x = board[7] ) ) or
                     ( ( x = board[3] ) and ( x = board[5] ) ) )
                then x := PieceBlank;
            end;
        5:  begin
            x := board[ 5 ];
            if not ( ( ( x = board[3] ) and ( x = board[4] ) ) or
                     ( ( x = board[2] ) and ( x = board[8] ) ) )
                then x := PieceBlank;
            end;
        6:  begin
            x := board[ 6 ];
            if not ( ( ( x = board[7] ) and ( x = board[8] ) ) or
                     ( ( x = board[0] ) and ( x = board[3] ) ) or
                     ( ( x = board[4] ) and ( x = board[2] ) ) )
                then x := PieceBlank;
            end;
        7:  begin
            x := board[ 7 ];
            if not ( ( ( x = board[6] ) and ( x = board[8] ) ) or
                     ( ( x = board[1] ) and ( x = board[4] ) ) )
                then x := PieceBlank;
            end;
        8:  begin
            x := board[ 8 ];
            if not ( ( ( x = board[6] ) and ( x = board[7] ) ) or
                     ( ( x = board[2] ) and ( x = board[5] ) ) or
                     ( ( x = board[0] ) and ( x = board[4] ) ) )
                then x := PieceBlank;
            end;
    end;

    winner2 := x;
end;

function minmax( alpha: integer; beta: integer; depth: integer; move : integer ): integer;
var
    p, value, pieceMove, score : integer;
begin
    moves := moves + 1;
    value := scoreInvalid;
    if depth >= 4 then
    begin
        { p := winner2( move ); }
        p := TScoreFunc( scoreFuncs[ move ] );
        { p := LookForWinner;  this is 10% slower than using function pointers }
    
        if p <> pieceBlank then
        begin
            if p = pieceX then
                value := scoreWin
            else
                value := scoreLose
        end
        else if depth = 8 then
            value := scoreTie;
    end;
  
    if value = scoreInvalid then
    begin
        if Odd( depth ) then
        begin
            value := scoreMin;
            pieceMove := pieceX;
        end
        else
        begin
            value := scoreMax;
            pieceMove := pieceO;
        end;
    
        p := 0;
        repeat
            if board[ p ] = pieceBlank then
            begin
                board[ p ] := pieceMove;
                score := minmax( alpha, beta, depth + 1, p );
                board[ p ] := pieceBlank;
        
                if Odd( depth ) then
                begin
                    if ( score > value ) then
                    begin
                        value := score;
                        if ( value = scoreWin ) or ( value >= beta ) then p := 10
                        else if ( value > alpha ) then alpha := value;
                    end;
                end
                else
                begin
                    if ( score < value ) then
                    begin
                        value := score;
                        if ( value = scoreLose ) or ( value <= alpha ) then p := 10
                        else if ( value < beta ) then beta := value;
                    end;
                end;
            end;
            p := p + 1;
      until p > 8;
    end;
  
    minmax := value;
end;

procedure runit( move : integer );
var score : integer;
begin
    board[move] := pieceX;
    score := minmax( scoreMin, scoreMax, 0, move );
    board[move] := pieceBlank;
end;

var
    i, errpos, loops: integer;
begin
    loops := Iterations;

    if 0 <> Length( ParamStr( 1 ) ) then
        Val( ParamStr( 1 ), loops, errpos );

    for i := 0 to 8 do
        board[i] := pieceBlank;

    scoreFuncs[0] := @func0;
    scoreFuncs[1] := @func1;
    scoreFuncs[2] := @func2;
    scoreFuncs[3] := @func3;
    scoreFuncs[4] := @func4;
    scoreFuncs[5] := @func5;
    scoreFuncs[6] := @func6;
    scoreFuncs[7] := @func7;
    scoreFuncs[8] := @func8;

    evaluated := 0;
    get_time( timeStart );

    for i := 1 to loops do
    begin
        moves := 0;
        runit( 0 );
        runit( 1 );
        runit( 4 );
        evaluated := evaluated + moves;
    end;

    get_time( timeEnd );
    print_elapsed_time( timeStart, timeEnd );

    WriteLn( 'moves evaluated: ', evaluated );
    WriteLn( 'iterations: ', loops );
end.
