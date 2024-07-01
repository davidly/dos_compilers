{ App to prove you can't win at Tic-Tac-Toe }
{ coded for Microsoft Pascal. Tested on v1.0, v3.3, and v4.0. }
{ requires djldos.obj, built from djldos.asm }
(*$DEBUG-   *)

program ttt( output );

function getticks : word; External;
function pspbyte( offset : word ) : integer; External;

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

var
  evaluated: integer;
  board: boardType;

procedure dumpBoard;
var
  i : integer;
begin
  Write( '{' );
  for i := 0 to 8 do
    Write( board[i] );
  Write( '}' );
end;

function lookForWinner : integer;
var
  t, p : integer;
begin
  {  dumpBoard; }
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

function minmax( alpha: integer; beta: integer; depth: integer; move: integer ): integer;
var
  p, val, pieceMove, score : integer;
begin
  evaluated := evaluated + 1;
  val := scoreInvalid;
  if depth >= 4 then
  begin
    p := winner2( move ); { lookForWinner; }
    if p <> pieceBlank then
    begin
      if p = pieceX then
        val := scoreWin
      else
        val := scoreLose
    end
    else if depth = 8 then
      val := scoreTie;
  end;

  if val = scoreInvalid then
  begin
    if Odd( depth ) then
    begin
      val := scoreMin;
      pieceMove := pieceX;
    end
    else
    begin
      val := scoreMax;
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
          if ( score > val ) then
          begin
            val := score;
            if ( val = scoreWin ) or ( val >= beta ) then p := 10
            else if ( val > alpha ) then alpha := val;
          end;
        end
        else
        begin
          if ( score < val ) then
          begin
            val := score;
            if ( val = scoreLose ) or ( val <= alpha ) then p := 10
            else if ( val < beta ) then beta := val;
          end;
        end;
      end;
      p := p + 1;
    until p > 8;
  end;

  minmax := val;
end;

function firstArgAsInt : integer;
var
  psp, offset : word;
  c, result : integer;
  location : ads of byte;
begin
  result := 0;

  offset := 128;
  c := pspbyte( offset );
  if c > 0 then begin
    offset := offset + 2; { past length and space }
    c := pspbyte( offset );
    while ( ( c >= 48 ) and ( c <= 57 ) ) do
    begin
      result := result * 10;
      result := result + c - 48;
      offset := offset + 1;
      c := pspbyte( offset );
    end;
  end;

  firstArgAsInt := result;
end;

procedure runit( move : integer );
var
  score: integer;
begin
  board[move] := pieceX;
  score := minmax( scoreMin, scoreMax, 0, move );
  board[move] := pieceBlank;
end;

var
  i, loops : integer;
  startTicks, endTicks: word;
begin
  i := firstArgAsInt;
  if 0 <> i then loops := i
  else loops := Iterations;

  for i := 0 to 8 do
    board[i] := pieceBlank;

  WriteLn( 'begin' );
  startTicks := getticks;

  for i := 1 to loops do
  begin
    evaluated := 0;  { once per loop to prevent overflow }
    runit( 0 );
    runit( 1 );
    runit( 4 );
  end;

  endTicks := getticks;
  WriteLn( 'end ticks:        ', endTicks );
  WriteLn( 'start ticks:      ', startTicks );
  WriteLn( 'difference in hs: ', endTicks - startTicks );

  if startTicks > endTicks then begin  { passed a 10 minute mark }
    endTicks := endTicks + 60000;
    WriteLn( 'corrected in hs:  ', endTicks - startTicks );
  end;

  WriteLn( 'moves evaluated:  ', evaluated );
  WriteLn( 'iterations:       ', loops );
end.
