{****************************************************************************}
{*  PLAY.PAS: This file contains the computer thinking routines, the        *}
{*  human player move input routine, and the play game routines.            *}
{****************************************************************************}

{****************************************************************************}
{*  Get Computer Move:  Given whose turn, return the "best" move for that   *}
{*  player.  Also given is whether to display the best move found so far    *}
{*  information, and returned is a flag telling if the user typed escape    *}
{*  to terminate this routine.  A recursive depth-first tree search         *}
{*  algorithm is used, and enhancements like cutting off unnecessary        *}
{*  subtrees, pre-scanning to select the best candidate moves, and a        *}
{*  positional evaluation are also included.  The actual algorithm is very  *}
{*  simple, but it is burried in all kinds of special cases.                *}
{****************************************************************************}
  procedure GetComputerMove (Turn : PieceColorType; Display : boolean;
                             var HiMovement : MoveType; var Escape : boolean);
    var MoveList : MoveListType;
        i, MaxDepth, NegInfinity, L1CutOff: integer;
        HiScore, SubHiScore, InitialScore, SubEnemyMaxScore : integer;
        Movement : MoveType;
        Attacked, Protected : integer;
        PosStrength, HiPosStrength : integer;
        cstr : string10;
        key : char;
        PosEvalOn : boolean;

{----------------------------------------------------------------------------}
{  Search:  This routine handles all of the tree searching except the first  }
{  level which of the tree which is handled by the main routine.  Given the  }
{  player, all of his moves are generated, and then each one is made.  The   }
{  enemy's maximum countermove score is subtracted from the move score, and  }
{  this gives the net value for the player making the move.  The maximum     }
{  net score is remembered and returned by this function.  The player's move }
{  is then taken back, and all of his other possible moves are tried in this }
{  same way.  If the score of any move exceeds the given cutoff value, then  }
{  no other of the player's moves are checked, and the score that exceeded   }
{  (or matched) the cutoff value is returned.  If the given depth is one or  }
{  less, then the enemy's countermoves are not checked, only the points for  }
{  taking the pieces, minus the points of the player's piece if the enemy's  }
{  piece is protected.  However, if the current player's move being          }
{  considered is a take and it is given that all of moves to that point      }
{  have been AllTakes, then enemy countermoves will be checked down to a     }
{  given depth of -1.  To calculate the enemy's best score in retaliation    }
{  to the given player's move, this routine is called recursively with the   }
{  enemy as the player to move, and a depth of the one originally given, -1. }
{  The new cutoff value is the score of the move that was just made, minus   }
{  the the best score that was found so far.  If the enemy's countermoves    }
{  score exceeds or matches this countermove value, then the net score of    }
{  the original player's move cannot exceed the best found so far, and the   }
{  move will be thrown out.  The new value for AllTakes is passed on as true }
{  if all moves heretofor have been takes, and the current player's move is  }
{  a take.  This routine is the core of the computer's 'thinking'.           }
{----------------------------------------------------------------------------}
  function Search (Turn: PieceColorType; CutOff, Depth: integer; AllTakes : boolean) : integer;
    var MoveList: MoveListType;
        j, LineScore, Score, BestScore, STCutOff: integer;
        Movement: MoveType;
        Attacked, Protected: integer;
        NoMoves, TakingPiece: boolean;
    begin
      {*** get the player's move list ***}
      GenMoveList (Turn, MoveList);
      NoMoves := true;
      BestScore := NegInfinity;
      j := MoveList.NumMoves;

      {*** go through all of the possible moves ***}
      while (j > 0) do begin
          Movement := MoveList.Move[j];
          {*** make the move ***}
          MakeMove (Movement, false, Score);
          {*** make sure it is legal (not moving into check) ***}
          AttackedBy (Player[Turn].KingRow, Player[Turn].KingCol, Attacked, Protected);
          if (Attacked = 0) then begin
              NoMoves := false;
              if (Score = STALE_SCORE) then
                  {*** end the search on a stalemate ***}
                  LineScore := Score
              else begin
                  TakingPiece := Movement.PieceTaken.image <> BLANK;
                  if (Depth <= 1) and not (AllTakes and TakingPiece and (Depth >= PLUNGE_DEPTH)) then begin
                      {*** have reached horizon node of tree: score points for piece taken ***}
                      {*** but assume own piece will be taken if enemy's piece is protected ***}
                      if Movement.PieceTaken.image <> BLANK then begin
                          AttackedBy (Movement.ToRow, Movement.ToCol, Attacked, Protected);
                          if Attacked > 0 then
                              LineScore := Score - CapturePoints[Movement.PieceMoved.image]
                          else
                              LineScore := Score;
                      end else
                          LineScore := Score;
                  end else begin
                      {*** new cutoff value ***}
                      STCutOff := Score - BestScore;
                      {*** recursive call for enemy's best countermoves score ***}
                      LineScore := Score - Search (EnemyColor[Turn], STCutOff,
                                                   Depth - 1, AllTakes and TakingPiece);
                  end;
              end;
              {*** remember player's maximum net score ***}
              if (LineScore > BestScore) then BestScore := LineScore;
          end;
          {*** un-do the move and check for cutoff ***}
          UnMakeMove (Movement);
          if BestScore >= CutOff then j := 0 else j := j - 1;
      end;
      if (BestScore = STALE_SCORE) then
          BestScore := -STALE_SCORE;   {stalemate means both players lose}
      if NoMoves then
          {*** player cannot move ***}
          if Player[Turn].InCheck then
              {*** if he is in check and cannot move, he loses ***}
              BestScore := - CapturePoints[KING]
          else
              {*** if he is not in check, then both players lose ***}
              BestScore := -STALE_SCORE; {prefer stalemate to checkmate}
      Search := BestScore;
    end; {Search}

{----------------------------------------------------------------------------}
{  Pre Search:  Returns the given move list of the given player, sorted into }
{  the order of ascending score for the given depth to look ahead.  The      }
{  main computer move routine calls this routine to sort the move list such  }
{  that it will probably find a good move early in a greater depth search.   }
{----------------------------------------------------------------------------}
    procedure PreSearch (Turn : PieceColorType; Depth : integer; var MoveList : MoveListType);
      var i, j, Attacked, Protected : integer;
          Score : integer;
          Movement : MoveType;
          TempScore : integer;
          Temp : string80;
          PreScanScore : array [1..MOVE_LIST_LEN] of integer;
          BestScore : integer;
      begin

        {*** display message ***}
        if Display then begin
            DisplayClearLines (MSG_HINT, 21);
            SetTextStyle (TriplexFont, HorizDir, 1);
            SetColor (LightGreen);
            CenterText (MSG_HINT, 'Pre Scanning...');
        end;
        BestScore := NegInfinity;

        {*** scan each move in same order as main routine ***}
        for i := MoveList.NumMoves downto 1 do begin
            {*** get points for move as in Search routine ***}
            Movement := MoveList.Move[i];
            MakeMove (Movement, false, Score);
            AttackedBy (Player[Turn].KingRow, Player[Turn].KingCol, Attacked, Protected);
            if (Attacked = 0) then begin
                Score := Score - Search (EnemyColor[Turn], Score - BestScore, Depth - 1, false);
                {*** remember the score of the move ***}
                PreScanScore[i] := Score;
            end else
                {*** invalid moves get lowest score ***}
                PreScanScore[i] := NegInfinity;
            UnMakeMove (Movement);
            {*** remember best score for purpose of making cutoffs ***}
            if (Score > BestScore) then BestScore := Score;
        end;

        {*** sort the movelist by score: O(n^2) selection sort used ***}
        for i := 1 to MoveList.NumMoves do
            for j := i + 1 to MoveList.NumMoves do
                if PreScanScore[i] > PreScanScore[j] then begin
                    Movement := MoveList.Move[i];
                    MoveList.Move[i] := MoveList.Move[j];
                    MoveList.Move[j] := Movement;
                    TempScore := PreScanScore[i];
                    PreScanScore[i] := PreScanScore[j];
                    PreScanScore[j] := TempScore;
                end;
      end; {PreSearch}

{----------------------------------------------------------------------------}
{  Eval Pos Strength:  Use a number of ad-hoc rules to evaluate the          }
{  positional content (rather than material content) of the given move,      }
{  considering the current board configuration.  Generally important         }
{  considerations are friendly piece protection and enemy piece threatening, }
{  as well as number of possible future moves allowed for the player.        }
{----------------------------------------------------------------------------}
      function EvalPosStrength (Turn : PieceColorType; Movement : MoveType) : integer;
        var PosMoveList : MoveListType;
            PosStrength : integer;
            row, col, KingRow, KingCol : RowColType;
            Attacked, Protected : integer;
            CumOwnAttacked, CumOwnProtected : integer;
            CumEnemyAttacked, CumEnemyProtected : integer;
            PawnDir, KingProtection, KingFront : integer;
            CheckCol : RowColType;
            CastlePossible, IsDevMove : boolean;
            NoDevCount : integer;

        begin
          {*** points for putting enemy in check ***}
          NoDevCount := Game.NonDevMoveCount[Game.MovesPointer];
          if Player[EnemyColor[Turn]].InCheck then begin
              if NoDevCount < 9 then
                  PosStrength := 40
              else begin
                  if NoDevCount < 12 then
                      PosStrength := 4
                  else
                      PosStrength := 0;
              end;
          end else
              PosStrength := 0;

          {*** points for pieces in front of king if he is (probably) in castled position ***}
          KingProtection := 0;
          KingRow := Player[Turn].KingRow;
          KingCol := Player[Turn].KingCol;
          if ((KingRow = 1) or (KingRow = 8)) and (KingCol <> 5) then begin
              if KingRow = 1 then KingFront := 2 else KingFront := 7;
              for CheckCol := KingCol - 1 to KingCol + 1 do
                  with Board[KingFront, CheckCol] do begin
                      if ValidSquare and (image <> BLANK) and (color = Turn) then
                          KingProtection := KingProtection + 1;
                  end;
          end;
          PosStrength := PosStrength + KingProtection * 3;

          {*** determine if castling is still possible ***}
          with Board[KingRow, 1] do
              CastlePossible := (image = ROOK) and (not HasMoved);
          with Board[KingRow, 8] do
              CastlePossible := CastlePossible or ((image = ROOK) and (not HasMoved));
          CastlePossible := CastlePossible and (not Board[KingRow, KingCol].HasMoved);

          {*** points for castling or not moving king/rook if castling still possible ***}
          if Movement.PieceMoved.image = KING then begin
              if (abs(Movement.FromCol - Movement.ToCol) > 1)
                                        and (KingProtection >= 2) then
                  PosStrength := PosStrength + 140
              else
                  if CastlePossible then PosStrength := PosStrength - 80;
          end;

          {*** points for pushing a pawn; avoids pushing potential castling protection ***}
          IsDevMove := false;
          if Movement.PieceMoved.image = PAWN then begin
              if ((Movement.FromCol <= 3) or (Movement.FromCol >= 6))
                       and ((Movement.FromRow = 1) or (Movement.FromRow = 8))
                       and CastlePossible then
                  PosStrength := PosStrength - 12
              else
                  PosStrength := PosStrength + 1;
              IsDevMove := true;
          end;

          {*** points for developmental move if one has not happened in a while ***}
          IsDevMove := IsDevMove or (Movement.PieceTaken.image <> BLANK);
          if IsDevMove then begin
              if NoDevCount >= 9 then
                  PosStrength := PosStrength + NoDevCount;
          end;

          {*** points for number of positions that can be moved to ***}
          GenMoveList (Turn, PosMoveList);
          PosStrength := PosStrength + PosMoveList.NumMoves;

          {*** points for pieces attacked / protected ***}
          CumOwnAttacked := 0;
          CumOwnProtected := 0;
          CumEnemyAttacked := 0;
          CumEnemyProtected := 0;
          for row := 1 to BOARD_SIZE do
              for col := 1 to BOARD_SIZE do
                  if (Board[row, col].image <> BLANK) then begin
                      AttackedBy (row, col, Attacked, Protected);
                      if (Board[row, col].color = Turn) then begin
                          CumOwnAttacked := CumOwnAttacked + Attacked;
                          CumOwnProtected := CumOwnProtected + Protected;
                      end else begin
                          CumEnemyAttacked := CumEnemyAttacked + Attacked;
                          CumEnemyProtected := CumEnemyProtected + Protected;
                      end;
                  end;
          PosStrength := PosStrength + 2 * CumOwnProtected
                         - 2 * CumOwnAttacked + 2 * CumEnemyAttacked;
          EvalPosStrength := PosStrength;
      end; {EvalPosStrength}

{----------------------------------------------------------------------------}
    begin {GetComputerMove}
      {*** initialize ***}
      PosEvalOn := Player[Turn].PosEval;
      MaxDepth := Player[Turn].LookAhead;
      NegInfinity := - CapturePoints[KING] * 5;
      Escape := false;
      HiScore := NegInfinity;
      HiPosStrength := -maxint;
      HiMovement.FromRow := NULL_MOVE;

      {*** get the move list and scramble it (to randomly choose between ties) ***}
      GenMoveList (Turn, MoveList);
      RandomizeMoveList (MoveList);
      key := GetKey;  {*** check for user pressing ESCape ***}
      if key <> 'x' then begin
          {*** perform pre-scan of two or three-ply if feasible ***}
          if MaxDepth >= 3 then begin
              if MaxDepth = 3 then
                  PreSearch (Turn, 2, MoveList)
              else
                  PreSearch (Turn, 3, MoveList);
          end;
          i := MoveList.NumMoves;
          key := GetKey;
      end;
      {*** check for user pressing ESCape after pre-scan ***}
      if key = 'x' then begin
          Escape := true;
          i := 0;
      end;

      {*** check each possible move - same method as in Search ***}
      while (i > 0) do begin
          UpDateTime (Turn);  {*** player's elapsed time ***}
          Movement := MoveList.Move[i];
          MakeMove (Movement, false, InitialScore);
          AttackedBy (Player[Turn].KingRow, Player[Turn].KingCol, Attacked, Protected);
          if (Attacked = 0) then begin
              if (InitialScore = STALE_SCORE) then
                  SubHiScore := STALE_SCORE
              else begin
                  {*** display scan count-down ***}
                  if Display and (MaxDepth >= 3) then begin
                      DisplayClearLines (MSG_HINT, 21);
                      SetTextStyle (TriplexFont, HorizDir, 1);
                      SetColor (LightGreen);
                      Str (i, cstr);
                      CenterText (MSG_HINT, 'Scan=' + cstr);
                  end;

                  {*** calculate one-ply score ***}
                  if (MaxDepth <= 1) then begin
                      if Movement.PieceTaken.image <> BLANK then begin
                          AttackedBy (Movement.ToRow, Movement.ToCol, Attacked, Protected);
                          if Attacked > 0 then
                              SubEnemyMaxScore := CapturePoints[Movement.PieceMoved.image]
                          else
                              SubEnemyMaxScore := 0;
                      end else
                          SubEnemyMaxScore := 0;
                  end else begin
                      {*** get net score ***}
                      if PosEvalOn then
                          {*** position evaluation needs to check all scores tying for best ***}
                          L1CutOff := InitialScore - HiScore + 1
                      else
                          L1CutOff := InitialScore - HiScore;
                      SubEnemyMaxScore := Search (EnemyColor[Turn], L1CutOff, MaxDepth - 1,
                                                  Movement.PieceTaken.image <> BLANK);
                  end;
                  {*** subtree score ***}
                  SubHiScore := InitialScore - SubEnemyMaxScore;
              end;

              {*** check if new score is highest ***}
              if (SubHiScore > HiScore) or (PosEvalOn and (SubHiScore = HiScore)) then begin
                  if PosEvalOn then
                      PosStrength := EvalPosStrength (Turn, Movement)
                  else
                      PosStrength := 0;
                  if (SubHiScore > HiScore) or (PosStrength > HiPosStrength) then begin
                      {*** remember new high score ***}
                      HiMovement := Movement;
                      HiScore := SubHiScore;
                      HiPosStrength := PosStrength;
                      {*** display new best movement ***}
                      if Display then begin
                          DisplayClearLines (MSG_MOVE, 15);
                          SetTextStyle (DefaultFont, HorizDir, 2);
                          SetColor (White);
                          CenterText (MSG_MOVE, MoveStr (HiMovement));
                          DisplayClearLines (MSG_SCORE, MSG_POS_EVAL+8-MSG_SCORE);
                          SetTextStyle (DefaultFont, HorizDir, 1);
                          SetColor (LightCyan);
                          Str (HiScore, cstr);
                          CenterText (MSG_SCORE, 'Score=' + cstr);
                          Str (SubEnemyMaxScore, cstr);
                          CenterText (MSG_ENEMY_SCORE, 'EnemyScore=' + cstr);
                          Str (HiPosStrength, cstr);
                          CenterText (MSG_POS_EVAL, 'Pos=' + cstr);
                      end;
                      {*** for zero-ply lookahead, take first move looked at ***}
                      if MaxDepth = 0 then i := 1;
                  end;
              end;
          end;
          UnMakeMove (Movement);
          i := i - 1;

          {*** check for escape or forced move by user ***}
          key := GetKey;
          if key = 'x' then begin
              Escape := true;
              i := 0;
          end else
              if (key = 'M') and (HiScore <> NegInfinity) then i := 0;
      end;
      {*** beep when done thinking ***}
      MakeSound (true);
    end; {GetComputerMove}

{****************************************************************************}
{*  Get Human Move:  Returns the movement as input by the user.  Invalid    *}
{*  moves are screened by this routine.  The user moves the cursor to the   *}
{*  piece to pick up and presses RETURN, and then moves the cursor to the   *}
{*  location to which the piece is to be moved and presses RETURN.          *}
{*  Pressing ESCape will exit this routine and return a flag indicating     *}
{*  escape; pressing H will make the computer suggest a move (hint); and    *}
{*  pressing A will report the attack/protect count of the cursor square.   *}
{*  BACKSPACE will delete the from-square and allow the user to select a    *}
{*  different piece.                                                        *}
{****************************************************************************}
  procedure GetHumanMove (Turn : PieceColorType; var Movement : MoveType;
                          var Escape : boolean);
    const MSG1X = 510;
    var key : char;
        HumanMoveList : MoveListType;
        ValidMove, BadFromSq, PickingUp : boolean;
        i : integer;

{----------------------------------------------------------------------------}
{  Move Cursor With Hint:  Moves the cursor around until the player presses  }
{  RETURN or SPACE.  Also handles keys A (Attack/protect) and H (Hint).      }
{----------------------------------------------------------------------------}
    procedure MoveCursorWithHint;
      var HintMove : MoveType;
          Att, Pro, i : integer;
          cstr : string10;
          bstr : string80;

      begin
        repeat
            {*** position cursor ***}
            MoveCursor(Player[Turn].CursorRow, Player[Turn].CursorCol, Turn, true, key);
            if key = ' ' then key := 'e';

            {*** check your move list ***}
            if key = 'C' then begin
                RestoreCrtMode;
                writeln ('Your list of possible moves:');
                writeln;
                for i := 1 to HumanMoveList.NumMoves do
                    write (i:2, '.', copy(MoveStr(HumanMoveList.Move[i]) + '       ',1,7));
                writeln;
                writeln;
                write ('Press any key to continue...');
                key := ReadKey;
                SetGraphMode (GraphMode);
                DisplayGameScreen;
                if not PickingUp then begin
                    SetTextStyle (DefaultFont, HorizDir, 2);
                    SetColor (White);
                    OutTextXY (MSG1X, MSG_MOVE, SqStr(Movement.FromRow, Movement.FromCol) + '-');
                end;
                DisplayInstructions (INS_GAME);
            end;

            {*** attack / protect count ***}
            if key = 'A' then begin
                DisplayClearLines (MSG_HINT, 17);
                SetTextStyle (TriplexFont, HorizDir, 1);
                SetColor (LightRed);
                with Player[Turn] do begin
                    if Board[CursorRow, CursorCol].image = BLANK then
                        Board[CursorRow, CursorCol].color := Turn;
                    AttackedBy (CursorRow, CursorCol, Att, Pro);
                end;
                Str (Att, cstr);
                bstr := 'Attk=' + cstr;
                Str (Pro, cstr);
                bstr := bstr + ' Prot=' + cstr;
                CenterText (MSG_HINT, bstr);
            end;

            {*** ask computer for hint ***}
            if key = 'H' then begin
                DisplayClearLines (MSG_HINT, 17);
                SetTextStyle (TriplexFont, HorizDir, 1);
                SetColor (LightRed);
                CenterText (MSG_HINT, 'Thinking...');
                GetComputerMove (Turn, false, HintMove, Escape);
                if not Escape then begin
                    SetTextStyle (TriplexFont, HorizDir, 1);
                    SetColor (LightRed);
                    DisplayClearLines (MSG_HINT, 21);
                    CenterText (MSG_HINT, 'Hint: ' + MoveStr (HintMove));
                end;
            end else begin
                Escape := key = 'x';
            end;
        until (key = 'e') or (key = 'b') or Escape;
      end; {MoveCursorWithHint}

{----------------------------------------------------------------------------}
{  Sq Move:  Returns whether the given two moves are equal on the basis of   }
{  the from/to squares.                                                      }
{----------------------------------------------------------------------------}
    function EqMove (M1, M2 : MoveType) : boolean;
      begin
        EqMove := (M1.FromRow = M2.FromRow) and (M1.FromCol = M2.FromCol)
                  and (M1.ToRow = M2.ToRow) and (M1.ToCol = M2.ToCol);
      end; {EqMove}

{----------------------------------------------------------------------------}
    begin {GetHumanMove}
      Escape := false;

      {*** make sure the human has a move to make ***}
      GenMoveList (Turn, HumanMoveList);
      TrimChecks (Turn, HumanMoveList);
      if HumanMoveList.NumMoves = 0 then
          Movement.FromRow := NULL_MOVE
      else begin
          repeat
              repeat
                  {*** get the from-square ***}
                  DisplayClearLines (MSG_MOVE, 15);
                  PickingUp := true;
                  MoveCursorWithHint;
                  DisplayClearLines (MSG_HINT, 21);
                  if not Escape then begin
                      {*** make sure there is a piece of player's color on from-square ***}
                      with Player[Turn] do
                          BadFromSq := (Board[CursorRow, CursorCol].image = BLANK)
                                       or (Board[CursorRow, CursorCol].color <> Turn);
                      if (BadFromSq) then
                          MakeSound (false);
                  end;
                  if (not Escape) and (key <> 'b') and (not BadFromSq) then begin
                      {*** if all is well, display the from square ***}
                      Movement.FromRow := Player[Turn].CursorRow;
                      Movement.FromCol := Player[Turn].CursorCol;
                      SetTextStyle (DefaultFont, HorizDir, 2);
                      SetColor (White);
                      OutTextXY (MSG1X, MSG_MOVE, SqStr(Movement.FromRow, Movement.FromCol) + '-');
                      {*** get the to-square ***}
                      PickingUp := false;
                      MoveCursorWithHint;
                  end;
                  {*** if user typed Backspace, go back to getting the from-square ***}
              until ((key = 'e') and (not BadFromSq)) or Escape;
              ValidMove := false;
              if not Escape then begin
                  {*** store rest of move attributes ***}
                  Movement.ToRow := Player[Turn].CursorRow;
                  Movement.ToCol := Player[Turn].CursorCol;
                  Movement.PieceMoved := Board[Movement.FromRow, Movement.FromCol];
                  Movement.MovedImage := Board[Movement.FromRow, Movement.FromCol].image;
                  Movement.PieceTaken := Board[Movement.ToRow, Movement.ToCol];
                  {*** display the move ***}
                  DisplayClearLines (MSG_MOVE, 15);
                  SetTextStyle (DefaultFont, HorizDir, 2);
                  SetColor (White);
                  CenterText (MSG_MOVE, MoveStr (Movement));

                  {*** search for the move in the move list ***}
                  ValidMove := false;
                  for i := 1 to HumanMoveList.NumMoves do
                      if EqMove(HumanMoveList.Move[i], Movement) then ValidMove := true;
                  DisplayClearLines (MSG_HINT, 17);
                  {*** if not found then move is not valid: give message ***}
                  if not ValidMove then begin
                      SetTextStyle (TriplexFont, HorizDir, 1);
                      SetColor (LightRed);
                      CenterText (MSG_HINT, 'Invalid Move');
                      MakeSound (false);
                  end;
              end;
              {*** keep trying until the user gets it right ***}
          until ValidMove or Escape;
      end;
    end; {GetHumanMove}

{****************************************************************************}
{*  Get Player Move:  Updates the display, starts the timer, figures out    *}
{*  whose turn it is, calls either GetHumanMove or GetComputerMove, stops   *}
{*  the timer, and returns the move selected by the player.                 *}
{****************************************************************************}
  procedure GetPlayerMove (var Movement : MoveType; var Escape : boolean);
    var Turn : PieceColorType;
        Dummy: longint;
    begin
      DisplayWhoseMove;
      {*** start timer ***}
      Dummy := ElapsedTime;
      {*** which color is to move ***}
      if Game.MoveNum mod 2 = 1 then
          Turn := C_WHITE
      else
          Turn := C_BLACK;
      {*** human or computer ***}
      if Player[Turn].IsHuman then
          GetHumanMove (Turn, Movement, Escape)
      else
          GetComputerMove (Turn, true, Movement, Escape);
      {*** stop timer ***}
      UpDateTime (Turn);
    end; {GetPlayerMove}

{****************************************************************************}
{*  Play Game:  Call for the move of the current player, make it, and go on *}
{*  to the next move and the next player.  Continue until the game is over  *}
{*  (for whatever reason) or the user wishes to escape back to the main     *}
{*  menu.  When making the move, this routine checks if it is a pawn        *}
{*  promotion of a human player.  This routine is called from the main menu.*}
{****************************************************************************}
  procedure PlayGame;
    var Movement : MoveType;
        DummyScore : integer;
        NoMoves, Escape : boolean;
        TimeOutWhite, TimeOutBlack, Stalemate, NoStorage : boolean;

{----------------------------------------------------------------------------}
{  Check Finish Status:  Updates the global variables which tell if the      }
{  game is over and for what reason.  This routine checks for a player       }
{  exceeding the set time limit, the 50-move stalemate rule occuring, or     }
{  the game being too long and there being not enough room to store it.      }
{----------------------------------------------------------------------------}
  procedure CheckFinishStatus;
    begin
      Game.TimeOutWhite := (Game.TimeLimit > 0) and (Player[C_WHITE].ElapsedTime >= Game.TimeLimit);
      Game.TimeOutBlack := (Game.TimeLimit > 0) and (Player[C_BLACK].ElapsedTime >= Game.TimeLimit);
      Game.Stalemate := Game.NonDevMoveCount[Game.MovesPointer] >= NON_DEV_MOVE_LIMIT;
      Game.NoStorage := Game.MovesStored >= GAME_MOVE_LEN - MAX_LOOKAHEAD + PLUNGE_DEPTH - 2;
    end; {CheckFinishStatus}

{----------------------------------------------------------------------------}
{  Check Human Pawn Promotion:  Checks if the given pawn move is a promotion }
{  by a human player.  If not, the move is displayed.  If so, the move is    }
{  displayed as usual, but then the player is asked what piece he wants to   }
{  promote the pawn to.  The possible responses are: Q = Queen, R = Rook,    }
{  B = Bishop, and N = kNight.  Then, the piece is promoted.  Note that the  }
{  computer will always promote to a queen.                                  }
{----------------------------------------------------------------------------}
    procedure CheckHumanPawnPromotion (var Movement : MoveType);
      var Turn : PieceColorType;
          LegalPiece : boolean;
          key : char;
          NewImage : PieceImageType;
          row, col : RowColType;

      begin
        {*** check if the destination row is an end row ***}
        row := Movement.ToRow;
        col := Movement.ToCol;
        if (row = 1) or (row = 8) then begin
            {*** see if the player is a human ***}
            Turn := Movement.PieceMoved.color;
            if Player[Turn].IsHuman then begin
                {*** show the pawn trotting up to be promoted ***}
                Board[row, col].image := PAWN;
                DisplayMove (Movement);
                DisplaySquare (row, col, true);
                DisplayInstructions (INS_PAWN_PROMOTE);

                {*** wait for the user to indicate what to promote to ***}
                repeat
                    repeat key := GetKey until key <> 'n';
                    LegalPiece := true;
                    case key of
                        'Q': NewImage := QUEEN;
                        'R': NewImage := ROOK;
                        'B': NewImage := BISHOP;
                        'N': NewImage := KNIGHT;
                        else begin
                            {*** buzz at user for pressing wrong key ***}
                            LegalPiece := false;
                            MakeSound (false);
                        end;
                    end;
                until LegalPiece;

                {*** put in the new piece image ***}
                Board[row, col].image := NewImage;
                Game.Move[Game.MovesPointer].MovedImage := NewImage;
                DisplaySquare (row, col, false);
                DisplayInstructions (INS_GAME);
            end else
                DisplayMove (Movement);
        end else
            DisplayMove (Movement);
    end; {CheckHumanPawnPromotion}

{----------------------------------------------------------------------------}
    begin {PlayGame}
      Game.GameFinished := false;
      DisplayInstructions (INS_GAME);
      Escape := false;
      NoMoves := false;
      CheckFinishStatus;

      {*** play until escape or game over ***}
      while not (NoMoves or Escape or Game.TimeOutWhite or Game.TimeOutBlack
                        or Game.Stalemate or Game.NoStorage) do begin
          GetPlayerMove (Movement, Escape);
          CheckFinishStatus;
          NoMoves := Movement.FromRow = NULL_MOVE;
          if not (NoMoves or Escape or Game.TimeOutWhite or Game.TimeOutBlack) then begin
              {*** display the move if everything is ok ***}
              MakeMove (Movement, true, DummyScore);
              if (Movement.PieceMoved.image = PAWN) then
                  CheckHumanPawnPromotion (Movement)
              else
                  DisplayMove (Movement);
          end;
          CheckFinishStatus;
      end;

      {*** game is over unless the exit reason is the user pressing ESCape ***}
      if not Escape then Game.GameFinished := true;
  end; {PlayGame}

{*** end of PLAY.PAS include file ***}
