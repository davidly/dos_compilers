{****************************************************************************}
{*  INIT.PAS:  this file contains the routines which initialize the global  *}
{*  variables.                                                              *}
{****************************************************************************}

{****************************************************************************}
{*  Init Possible Moves:  put the constant values into the data structure   *}
{*  which gives the possible moves for each piece, the point values for     *}
{*  capturing enemy pieces, and the opposite color to the given one.        *}
{****************************************************************************}
  procedure InitPossibleMoves;
    var index: integer;
    begin
        PossibleMoves [BISHOP].NumDirections := 4;
        PossibleMoves [BISHOP].MaxDistance := 7;
        PossibleMoves [BISHOP].UnitMove[1].DirRow := 1;
        PossibleMoves [BISHOP].UnitMove[1].DirCol := -1;
        PossibleMoves [BISHOP].UnitMove[2].DirRow := 1;
        PossibleMoves [BISHOP].UnitMove[2].DirCol := 1;
        PossibleMoves [BISHOP].UnitMove[3].DirRow := -1;
        PossibleMoves [BISHOP].UnitMove[3].DirCol := -1;
        PossibleMoves [BISHOP].UnitMove[4].DirRow := -1;
        PossibleMoves [BISHOP].UnitMove[4].DirCol := 1;
        PossibleMoves [KNIGHT].NumDirections := 8;
        PossibleMoves [KNIGHT].MaxDistance := 1;
        PossibleMoves [KNIGHT].UnitMove[1].DirRow := 1;
        PossibleMoves [KNIGHT].UnitMove[1].DirCol := -2;
        PossibleMoves [KNIGHT].UnitMove[2].DirRow := 2;
        PossibleMoves [KNIGHT].UnitMove[2].DirCol := -1;
        PossibleMoves [KNIGHT].UnitMove[3].DirRow := 2;
        PossibleMoves [KNIGHT].UnitMove[3].DirCol := 1;
        PossibleMoves [KNIGHT].UnitMove[4].DirRow := 1;
        PossibleMoves [KNIGHT].UnitMove[4].DirCol := 2;
        PossibleMoves [KNIGHT].UnitMove[5].DirRow := -1;
        PossibleMoves [KNIGHT].UnitMove[5].DirCol := 2;
        PossibleMoves [KNIGHT].UnitMove[6].DirRow := -2;
        PossibleMoves [KNIGHT].UnitMove[6].DirCol := 1;
        PossibleMoves [KNIGHT].UnitMove[7].DirRow := -2;
        PossibleMoves [KNIGHT].UnitMove[7].DirCol := -1;
        PossibleMoves [KNIGHT].UnitMove[8].DirRow := -1;
        PossibleMoves [KNIGHT].UnitMove[8].DirCol := -2;
        PossibleMoves [ROOK].NumDirections := 4;
        PossibleMoves [ROOK].MaxDistance := 7;
        PossibleMoves [ROOK].UnitMove[1].DirRow := 1;
        PossibleMoves [ROOK].UnitMove[1].DirCol := 0;
        PossibleMoves [ROOK].UnitMove[2].DirRow := 0;
        PossibleMoves [ROOK].UnitMove[2].DirCol := -1;
        PossibleMoves [ROOK].UnitMove[3].DirRow := 0;
        PossibleMoves [ROOK].UnitMove[3].DirCol := 1;
        PossibleMoves [ROOK].UnitMove[4].DirRow := -1;
        PossibleMoves [ROOK].UnitMove[4].DirCol := 0;
        PossibleMoves [QUEEN].NumDirections := 8;
        PossibleMoves [QUEEN].MaxDistance := 7;
        PossibleMoves [KING].NumDirections := 8;
        PossibleMoves [KING].MaxDistance := 1;
        for index := 1 to 4 do begin
            PossibleMoves [QUEEN].UnitMove[index] := PossibleMoves [BISHOP].UnitMove[index];
            PossibleMoves [KING].UnitMove[index] := PossibleMoves [BISHOP].UnitMove[index];
        end;
        for index := 1 to 4 do begin
            PossibleMoves [QUEEN].UnitMove[index + 4] := PossibleMoves [ROOK].UnitMove[index];
            PossibleMoves [KING].UnitMove[index + 4] := PossibleMoves [ROOK].UnitMove[index];
        end;

        CapturePoints[BLANK] := 0;
        CapturePoints[PAWN] := 10;
        CapturePoints[KNIGHT] := 35;
        CapturePoints[BISHOP] := 35;
        CapturePoints[ROOK] := 50;
        CapturePoints[QUEEN] := 90;
        CapturePoints[KING] := 2000;

        EnemyColor[C_WHITE] := C_BLACK;
        EnemyColor[C_BLACK] := C_WHITE;
    end;

{****************************************************************************}
{*  Startup Initialize:  set the default player info and options, and set   *}
{*  valid and invalid squares of the board.                                 *}
{****************************************************************************}
  procedure StartupInitialize;
    var row, col: RowColType;
    begin
      Randomize;
      InitPossibleMoves;
      DefaultFileName := 'EXAMPLE';

      {*** default options ***}
      Game.TimeLimit := 0;
      Game.EnPassentAllowed := true;
      Game.SoundFlag := true;
      Game.FlashCount := 2;
      Game.WatchDelay := 600;

      {*** default player attributes ***}
      with Player[C_WHITE] do begin
          Name := 'PERSON';
          IsHuman := true;
          LookAhead := 3;
          PosEval := false;
      end;
      with Player[C_BLACK] do begin
          Name := 'COMPUTER';
          IsHuman := false;
          LookAhead := 3;
          PosEval := false;
      end;

      {*** initialize board ***}
      for col := -1 to 10 do
          for row := -1 to 10 do
              with Board[row, col] do begin
                  image := BLANK;
                  color := C_WHITE;
                  HasMoved := false;
                  ValidSquare := false;
              end;
      for col := 1 to BOARD_SIZE do
          for row := 1 to BOARD_SIZE do
              Board[row, col].ValidSquare := true;
    end;

{*** end of INIT.PAS include file ***}
