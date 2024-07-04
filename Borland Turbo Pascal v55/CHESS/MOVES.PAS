{****************************************************************************}
{*  MOVES.PAS:  This file contains the routines which generate, move, and   *}
{*  otherwise have to do (on a low level) with moves.                       *}
{****************************************************************************}

{****************************************************************************}
{*  Attacked By:  Given the row and column of a square, this routine will   *}
{*  tally the number of other pieces which attack (enemy pieces) or protect *}
{*  (friendly pieces) the piece on that square.  This is accomplished by    *}
{*  looking around the piece to all other locations from which a piece      *}
{*  could protect or protect.  This routine does not count an attack by     *}
{*  en passent.  This routine is called to see if a king is in check and    *}
{*  as part of the position strength calculation.                           *}
{****************************************************************************}
  procedure AttackedBy (row, col : RowColType; var Attacked, Protected : integer);
    var dir, i, distance : integer;
        PosRow, PosCol, IncRow, IncCol : RowColType;
        FriendColor, EnemyColor : PieceColorType;
    begin
      {*** initialize ***}
      Attacked := 0;
      Protected := 0;
      FriendColor := Board[row, col].color;
      if (FriendColor = C_WHITE) then begin
          dir := 1; {*** row displacement from which an enemy pawn would attack ***}
          EnemyColor := C_BLACK;
      end else begin
          dir := -1;
          EnemyColor := C_WHITE;
      end;

      {*** count number of attacking pawns ***}
      with Board[row + dir, col - 1] do
          if (image = PAWN) and (color = EnemyColor) then Attacked := Attacked + 1;
      with Board[row + dir, col + 1] do
          if (image = PAWN) and (color = EnemyColor) then Attacked := Attacked + 1;

      {*** count number of protecting pawns ***}
      with Board[row - dir, col - 1] do
          if (image = PAWN) and (color = FriendColor) then Protected := Protected + 1;
      with Board[row - dir, col + 1] do
          if (image = PAWN) and (color = FriendColor) then Protected := Protected + 1;

      {*** check for a knight in all positions from which it could attack/protect ***}
      for i := 1 to PossibleMoves[KNIGHT].NumDirections do begin
          with PossibleMoves[KNIGHT].UnitMove[i] do begin
              PosRow := row + DirRow;
              PosCol := col + DirCol;
          end;
          if (Board[PosRow, PosCol].image = KNIGHT) then begin
              {*** color determines if knight is attacking or protecting ***}
              if (Board[PosRow, PosCol].color = FriendColor) then
                  Protected := Protected + 1
              else
                  Attacked := Attacked + 1;
          end;
      end;

      {*** check for king, queen, bishop, and rook attacking or protecting ***}
      for i := 1 to 8 do begin
          {*** get the current search direction ***}
          with PossibleMoves[QUEEN].UnitMove[i] do begin
              IncRow := DirRow;
              IncCol := DirCol;
          end;
          {*** set distance countdown and search position ***}
          distance := 7;
          PosRow := row;
          PosCol := col;

          {*** search until something is run into ***}
          while distance > 0 do begin
              {*** get new position and check it ***}
              PosRow := PosRow + IncRow;
              PosCol := PosCol + IncCol;
              with Board[PosRow, PosCol] do begin
                  if ValidSquare then begin
                      if image = BLANK then
                          {*** continue searching if search_square is blank ***}
                          distance := distance - 1
                      else begin
                          {*** separate cases of straight or diagonal attack/protect ***}
                          if (IncRow = 0) or (IncCol = 0) then begin
                              {*** straight: check for queen, rook, or one-away king ***}
                              if (image = QUEEN) or (image = ROOK) or
                                      ((image = KING) and (distance = 7)) then
                                  if (color = FriendColor) then
                                      Protected := Protected + 1
                                  else
                                      Attacked := Attacked + 1;
                          end else begin
                              {*** diagonal: check for queen, bishop, or one-away king ***}
                              if (image = QUEEN) or (image = BISHOP) or
                                      ((image = KING) and (distance = 7)) then
                                  if (color = FriendColor) then
                                      Protected := Protected + 1
                                  else
                                      Attacked := Attacked + 1;
                          end;
                          {*** force to stop searching if piece encountered ***}
                          distance := 0;
                      end;
                  end else
                      {*** force to stop searching if border of board encountered ***}
                      distance := 0;
              end;
          end;
      end;
    end; {AttackedBy}

{****************************************************************************}
{*  Gen Move List:  Returns the list of all possible moves for the given    *}
{*  player.  Searches the board for all pieces of the given color, and      *}
{*  adds all of the possible moves for that piece to the move list to be    *}
{*  returned.                                                               *}
{****************************************************************************}
  procedure GenMoveList (Turn : PieceColorType; var Movelist : MoveListType);
    var row, col : RowColType;

{----------------------------------------------------------------------------}
{  Gen Piece Move List:  Generates all of the moves for the given piece at   }
{  the given board position, and adds them to the move list for the player.  }
{  If the piece is a pawn then all of the moves are checked by brute force.  }
{  If the piece is a king, then the castling move is checked by brute force. }
{  For all other moves, each allowed direction for the piece is checked, and }
{  each square off in that direction from the piece, up to the piece's move  }
{  distance limit, is added to the list, until the edge of the board is      }
{  encountered or another piece is encountered.  If the piece encountered    }
{  is an enemy piece, then taking that enemy piece is added to the player's  }
{  move list as well.                                                        }
{----------------------------------------------------------------------------}
  procedure GenPieceMoveList (Piece : PieceType; row, col : integer);
    var dir : integer;
        PosRow, PosCol : RowColType;    {*** current scanning position ***}
        OrigRow, OrigCol : RowColType;  {*** location to search from ***}
        IncRow, IncCol : integer;       {*** displacement to add to scanning position ***}
        DirectionNum : 1..8;
        distance : 0..7;
        EPPossible : boolean;
        EnemyColor : PieceColorType;
        Attacked, Protected : integer;

{----------------------------------------------------------------------------}
{  Gen Add Move:  Adds the move to be generated to the player's move list.   }
{  Given the location and displacement to move the piece, takes PieceTaken   }
{  and PieceMoved from the current board configuration.                      }
{----------------------------------------------------------------------------}
  procedure GenAddMove (row, col : RowColType; drow, dcol : integer);
    begin
      MoveList.NumMoves := MoveList.NumMoves + 1;
      with MoveList.Move[MoveList.NumMoves] do begin
          FromRow := row;
          FromCol := col;
          ToRow := row + drow;
          ToCol := col + dcol;
          PieceTaken := Board [ToRow, ToCol];
          PieceMoved := Board [FromRow, FromCol];
          {*** get image of piece after it is moved... ***}
          {*** same as before the movement except in the case of pawn promotion ***}
          MovedImage := Board [FromRow, FromCol].image;
      end;
    end; {GenAddMove}

{----------------------------------------------------------------------------}
{  Gen Add Pawn Move: Adds the move to be generated for a pawn to the        }
{  player's move list and checks for pawn promotion.                         }
{----------------------------------------------------------------------------}
  procedure GenAddPawnMove (row, col : RowColType; drow, dcol : integer);
    begin
      GenAddMove (row, col, drow, dcol);
      {*** if pawn will move to an end row ***}
      if (row + drow = 1) or (row + drow = 8) then
          {*** assume the pawn will be promoted to a queen ***}
          MoveList.Move[MoveList.NumMoves].MovedImage := QUEEN;
    end; {GenAddPawnMove}

{----------------------------------------------------------------------------}
    begin {GenPieceMoveList}
      OrigRow := row;
      OrigCol := col;

      {*** pawn movement is a special case ***}
      if Piece.image = PAWN then begin
          {*** check for En Passent ***}
          if Piece.color = C_WHITE then begin
              dir := 1;
              EPPossible := (row = 5);
              EnemyColor := C_BLACK;
          end else begin
              dir := -1;
              EPPossible := (row = 4);
              EnemyColor := C_WHITE;
          end;
          {*** make sure enemy's last move was push pawn two, beside player's pawn ***}
          with Player[EnemyColor].LastMove do begin
              if EPPossible and Game.EnPassentAllowed and (FromRow <> NULL_MOVE) then
                  if (abs (FromRow - ToRow) = 2) then
                      if (abs (ToCol - col) = 1) and (PieceMoved.image = PAWN) then
                          GenAddPawnMove (row, col, dir, ToCol - col);
          end;

          {*** square pawn is moving to (1 or 2 ahead) is guaranteed to be valid ***}
          if (Board [row + dir, col].image = BLANK) then begin
              GenAddPawnMove (row, col, dir, 0);
              {*** see if pawn can move two ***}
              if (not Piece.HasMoved) and (Board [row + 2*dir, col].image = BLANK) then
                  GenAddPawnMove (row, col, 2*dir, 0);
          end;

          {*** check for pawn takes to left ***}
          with Board[row + dir, col - 1] do begin
              if (image <> BLANK) and (color = EnemyColor) and ValidSquare then
                  GenAddPawnMove (row, col, dir, -1);
          end;

          {*** check for pawn takes to right ***}
          with Board[row + dir, col + 1] do begin
              if (image <> BLANK) and (color = EnemyColor) and ValidSquare then
                  GenAddPawnMove (row, col, dir, +1);
          end;
      end else begin
          {*** check for the king castling ***}
          if (Piece.image = KING) and (not Piece.HasMoved) and (not Player[Turn].InCheck) then begin
              {*** check for castling to left ***}
              if (Board [row, 1].image = ROOK) and (not Board [row, 1].HasMoved) then
                  if (Board [row, 2].image = BLANK) and (Board [row, 3].image = BLANK)
                            and (Board [row, 4].image = BLANK) then begin
                      {*** make sure not moving through check ***}
                      Board [row, 4].color := Turn;
                      AttackedBy (row, 4, Attacked, Protected);
                      if (Attacked = 0) then
                          GenAddMove (row, 5, 0, -2);
                  end;

              {*** check for castling to right ***}
              if (Board [row, 8].image = ROOK) and (not Board [row, 8].HasMoved) then
                  if (Board [row, 6].image = BLANK) and (Board [row, 7].image = BLANK) then begin
                      {*** make sure not moving through check ***}
                      Board [row, 6].color := Turn;
                      AttackedBy (row, 6, Attacked, Protected);
                      if (Attacked = 0) then
                          GenAddMove (row, 5, 0, 2);
                  end;
          end;

          {*** Normal moves: for each allowed direction of the piece... ***}
          for DirectionNum := 1 to PossibleMoves [Piece.image].NumDirections do begin
              {*** initialize search ***}
              distance := PossibleMoves [Piece.image].MaxDistance;
              PosRow := OrigRow;
              PosCol := OrigCol;
              with PossibleMoves[Piece.image].UnitMove[DirectionNum] do begin
                  IncRow := DirRow;
                  IncCol := DirCol;
              end;

              {*** search until something is run into ***}
              while distance > 0 do begin
                  PosRow := PosRow + IncRow;
                  PosCol := PosCol + IncCol;
                  with Board [PosRow, PosCol] do begin
                      if (not ValidSquare) then
                          distance := 0
                      else begin
                          if image = BLANK then begin
                              {*** sqaure is empty: can move there; keep searching ***}
                              GenAddMove (OrigRow, OrigCol, PosRow - OrigRow, PosCol - OrigCol);
                              distance := distance - 1;
                          end else begin
                              {*** piece is there: can take if enemy; stop searching ***}
                              distance := 0;
                              if color <> Turn then
                                  GenAddMove (OrigRow, OrigCol, PosRow - OrigRow, PosCol - OrigCol);
                          end;
                      end;
                  end;
              end;
          end;
      end;
    end; {GenPieceMoveList}

{----------------------------------------------------------------------------}
    begin {GenMoveList}
      {*** empty out player's move list ***}
      MoveList.NumMoves := 0;

      {*** search for player's pieces on board ***}
      for row := 1 to BOARD_SIZE do
          for col := 1 to BOARD_SIZE do
              with Board [row, col] do begin
                  {*** if player's piece, add its moves ***}
                  if (image <> BLANK) and (color = Turn) then
                      GenPieceMoveList (Board [row, col], row, col);
              end;
    end; {GenMoveList}

{****************************************************************************}
{*  Make Move:  Update the Board to reflect making the given movement.  If  *}
{*  given is a PermanentMove, then the end of game pointers is set to the   *}
{*  current move.  Returns the score for the move, which is given by the    *}
{*  number of points for the piece taken.                                   *}
{****************************************************************************}
  procedure MakeMove (Movement : MoveType; PermanentMove : boolean; var Score : integer);
    var Row: RowColType;
        Attacked, Protected : integer;

    begin
      Score := 0;
      {*** update board for most moves ***}
      with Movement do begin
          {*** pick piece up ***}
          Board[FromRow, FromCol].image := BLANK;
          {*** put piece down ***}
          Board[ToRow, ToCol] := PieceMoved;
      end;

      {*** check for en passent, pawn promotion, and castling ***}
      case Movement.PieceMoved.image of
          PAWN: begin
              {*** en passent: blank out square taken; get points ***}
              if (Movement.FromCol <> Movement.ToCol) and (Movement.PieceTaken.image = BLANK) then begin
                  Board[Movement.FromRow, Movement.ToCol].image := BLANK;
                  Score := Score + CapturePoints[PAWN];
              end;

              {*** pawn promotion: use the after-moved image; get trade-up points ***}
              if Movement.PieceMoved.color = C_WHITE then Row := 8 else Row := 1;
              if Movement.ToRow = Row then begin
                  Board[Movement.ToRow, Movement.ToCol].image := Movement.MovedImage;
                  Score := Score + CapturePoints[Movement.MovedImage] - CapturePoints[PAWN];
              end;
          end;

          KING: begin
              {*** update king position in player record ***}
              with Player[Movement.PieceMoved.color] do begin
                  KingRow := Movement.ToRow;
                  KingCol := Movement.ToCol;
              end;

              {*** castling left/right: move the rook too ***}
              if abs (Movement.FromCol - Movement.ToCol) > 1 then begin
                  if (Movement.ToCol < Movement.FromCol) then begin
                      Board[Movement.FromRow, 4] := Board[Movement.FromRow, 1];
                      Board[Movement.FromRow, 4].HasMoved := true;
                      Board[Movement.FromRow, 1].image := BLANK;
                  end else begin
                      Board[Movement.FromRow, 6] := Board[Movement.FromRow, 8];
                      Board[Movement.FromRow, 6].HasMoved := true;
                      Board[Movement.FromRow, 8].image := BLANK;
                  end;
              end;
          end;
      end;

      {*** update player attributes ***}
      Player[Movement.PieceMoved.color].LastMove := Movement;
      Player[Movement.PieceMoved.color].InCheck := false;
      with Player[EnemyColor[Movement.PieceMoved.color]] do begin
          AttackedBy (KingRow, KingCol, Attacked, Protected);
          InCheck := Attacked <> 0;
      end;

      {*** remember that piece has been moved, get score ***}
      Board[Movement.ToRow, Movement.ToCol].HasMoved := true;
      Score := Score + CapturePoints[Movement.PieceTaken.image];

      {*** update game attributes ***}
      Game.MoveNum := Game.MoveNum + 1;
      Game.MovesPointer := Game.MovesPointer + 1;
      Game.Move[Game.MovesPointer] := Movement;
      if PermanentMove then
          Game.MovesStored := Game.MovesPointer;
      Game.InCheck[Game.MovesPointer] := Attacked <> 0;

      {*** update nondevelopmental moves counter ***}
      if (Movement.PieceMoved.image = PAWN) or (Movement.PieceTaken.image <> BLANK) then begin
          Game.NonDevMoveCount[Game.MovesPointer] := 0;
      end else begin
          {*** if 50 nondevelopmental moves in a row: stalemate ***}
          Game.NonDevMoveCount[Game.MovesPointer] := Game.NonDevMoveCount[Game.MovesPointer-1] + 1;
          if (Game.NonDevMoveCount[Game.MovesPointer] >= NON_DEV_MOVE_LIMIT) then
              Score := STALE_SCORE;
      end;
    end; {MakeMove}

{****************************************************************************}
{*  Un Make Move:  Updates the board for taking back the last made move.    *}
{*  This routine returns (is not given) the last made movement (so it may   *}
{*  be passed to DisplayUnMadeMove).                                        *}
{****************************************************************************}
  procedure UnMakeMove (var Movement: Movetype);
    begin
      {*** make sure there is a move to un-make ***}
      if (Game.MovesPointer > 0) then begin
          Movement := Game.Move[Game.MovesPointer];
          {*** restore whether player who made move was in check ***}
          Player[Movement.PieceMoved.color].InCheck := Game.InCheck[Game.MovesPointer - 1];
          {*** the enemy could not have been in check ***}
          Player[EnemyColor[Movement.PieceMoved.color]].InCheck := false;
          {*** restore the From and To squares ***}
          Board[Movement.FromRow, Movement.FromCol] := Movement.PieceMoved;
          Board[Movement.ToRow, Movement.ToCol] := Movement.PieceTaken;

          {*** special cases ***}
          case Movement.PieceMoved.image of
              KING: begin
                  {*** restore position of king in player attributes ***}
                  with Player[Movement.PieceMoved.color] do begin
                      KingRow := Movement.FromRow;
                      KingCol := Movement.FromCol;
                  end;
                  {*** un-castle left/right if applicable ***}
                  if abs (Movement.FromCol - Movement.ToCol) > 1 then begin
                      if (Movement.FromCol < Movement.ToCol) then begin
                          Board[Movement.FromRow, 8] := Board[Movement.FromRow, 6];
                          Board[Movement.FromRow, 6].image := BLANK;
                          Board[Movement.FromRow, 8].HasMoved := false;
                      end else begin
                          Board[Movement.FromRow, 1] := Board[Movement.FromRow, 4];
                          Board[Movement.FromRow, 4].image := BLANK;
                          Board[Movement.FromRow, 1].HasMoved := false;
                      end;
                  end;
              end;

              PAWN:
                  {*** un-en passent: restore the pawn that was taken ***}
                  if (Movement.FromCol <> Movement.ToCol) and (Movement.PieceTaken.image = BLANK) then
                      with Board[Movement.FromRow, Movement.ToCol] do begin
                          image := PAWN;
                          if Movement.PieceMoved.color = C_WHITE then
                              color := C_BLACK
                          else
                              color := C_WHITE;
                          HasMoved := true;
                      end;
          end;

          {*** roll back move number and pointer ***}
          Game.MoveNum := Game.MoveNum - 1;
          Game.MovesPointer := Game.MovesPointer - 1;

          {*** restore player previous move attributes ***}
          if (Game.MovesPointer > 1) then
              Player[Movement.PieceMoved.color].LastMove := Game.Move[Game.MovesPointer - 1]
          else
              Player[Movement.PieceMoved.color].LastMove.FromRow := NULL_MOVE;
      end else
          {*** indicate no move to take back ***}
          Movement.FromRow := NULL_MOVE;
    end; {UnMakeMove}

{****************************************************************************}
{*  Trim Checks:  Given a move list, remove all of the moves which would    *}
{*  result in the given player moving into check.  This is not done         *}
{*  directly by GenMoveList because it is an expensive operation, since     *}
{*  each move will have to be made and then unmade.  This routine is called *}
{*  by the Human Movement routine.  The Computer Movement routine           *}
{*  incorporates this code into its code, since the moves have to be made   *}
{*  and unmade there anyway.                                                *}
{****************************************************************************}
  procedure TrimChecks (Turn : PieceColorType; var MoveList : MoveListType);
    var DummyMove : MoveType;
        DummyScore, Attacked, Protected : integer;
        ValidMoves, i : integer;

    begin
      ValidMoves := 0;
      for i := 1 to MoveList.NumMoves do begin
          MakeMove (MoveList.Move[i], false, DummyScore);
          {*** check if the king is attacked (in check) ***}
          AttackedBy (Player[Turn].KingRow, Player[Turn].KingCol, Attacked, Protected);
          if Attacked = 0 then begin
              {*** if not in check, then re-put valid move ***}
              ValidMoves := ValidMoves + 1;
              MoveList.Move[ValidMoves] := MoveList.Move[i];
          end;
          UnMakeMove (DummyMove);
      end;
      MoveList.NumMoves := ValidMoves;
    end; {TrimChecks}

{****************************************************************************}
{*  Randomize Move List:  Scrambles the order of the given move list.  This *}
{*  is done to make choosing between tie scores random.  It is necassary    *}
{*  to scramble the moves here because the move list will always be         *}
{*  generated in the same order.                                            *}
{****************************************************************************}
  procedure RandomizeMoveList (var MoveList : MoveListType);
    var i, Exch : integer;
        ExchMove : MoveType;
    begin
      for i := 1 to MoveList.NumMoves do begin
          {*** swap the current move with some random other one ***}
          Exch := Random (MoveList.NumMoves) + 1;
          ExchMove := MoveList.Move[Exch];
          MoveList.Move[Exch] := MoveList.Move[i];
          MoveList.Move[i] := ExchMove;
      end;
    end; {RandomizeMoveList}

{****************************************************************************}
{*  Goto Move:  Rolls back/forth the game to the given move number.  Each   *}
{*  move between the current move and the destination is made/retracted to  *}
{*  update the board and other game status information.  If the given move  *}
{*  number is too small or too large, the game is rolled to the first/last  *}
{*  move.                                                                   *}
{****************************************************************************}
  procedure GotoMove (GivenMoveTo : integer);
    var Movement : MoveType;
        DummyScore : integer;
        MoveTo, BeginMoveNum, EndMoveNum : integer;
    begin
      {*** check the bounds of given move number ***}
      MoveTo := GivenMoveTo;
      BeginMoveNum := Game.MoveNum - Game.MovesPointer;
      EndMoveNum := Game.MoveNum + (Game.MovesStored - Game.MovesPointer);
      if (MoveTo < BeginMoveNum) then MoveTo := BeginMoveNum;
      if (MoveTo > EndMoveNum) then MoveTo := EndMoveNum;

      {*** make / retract moves of the game until the destination is reached ***}
      while (Game.MoveNum <> MoveTo) do begin
          if MoveTo > Game.MoveNum then begin
              Movement := Game.Move[Game.MovesPointer + 1];
              MakeMove (Movement, false, DummyScore);
          end else
              UnMakeMove (Movement);
      end;
      Game.GameFinished := false;
    end;

{*** end of the MOVES.PAS include file ***}
