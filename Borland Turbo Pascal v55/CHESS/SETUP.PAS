{****************************************************************************}
{*  SETUP.PAS:  This file contains the routines to either put the board in  *}
{*  its normal start of game setup or a custom user defined setup.          *}
{****************************************************************************}

{****************************************************************************}
{*  Default Board Set Pieces:  Puts the pieces on the board for the normal  *}
{*  initial configuration.                                                  *}
{****************************************************************************}
  procedure DefaultBoardSetPieces;
    var row, col : RowColType;
    begin
      {*** put in the row of pawns for each player ***}
      for col := 1 to BOARD_SIZE do begin
          Board[2,col].image := PAWN;
          Board[7,col].image := PAWN;
      end;

      {*** blank out the middle of the board ***}
      for row := 3 to 6 do
          for col := 1 to BOARD_SIZE do
              Board[row,col].image := BLANK;

      {*** put in white's major pieces and then copy for black ***}
      Board[1,1].image := ROOK;
      Board[1,2].image := KNIGHT;
      Board[1,3].image := BISHOP;
      Board[1,4].image := QUEEN;
      Board[1,5].image := KING;
      Board[1,6].image := BISHOP;
      Board[1,7].image := KNIGHT;
      Board[1,8].image := ROOK;
      for col := 1 to BOARD_SIZE do
          Board[8,col] := Board[1,col];

      {*** set the piece colors for each side ***}
      for row := 1 to 4 do
          for col := 1 to BOARD_SIZE do begin
              Board[row,col].color := C_WHITE;
              Board[row,col].HasMoved := false;
              Board[row+4,col].color := C_BLACK;
              Board[row+4,col].HasMoved := false;
          end;
    end; {DefaultBoardSetPieces}

{****************************************************************************}
{*  Default Board:  Sets the pieces in their default positions and sets     *}
{*  some of the player attributes to their defaults.  Some of the           *}
{*  attributes of the game are also set to their startup values.            *}
{****************************************************************************}
  procedure DefaultBoard;
    var row,col : RowColType;
    begin
      DefaultBoardSetPieces;

      {*** player attributes ***}
      with Player[C_WHITE] do begin
          CursorRow := 2;
          CursorCol := 4;
          InCheck := false;
          KingRow := 1;
          KingCol := 5;
          ElapsedTime := 0;
          LastMove.FromRow := NULL_MOVE;
      end;

      with Player[C_BLACK] do begin
          CursorRow := 7;
          CursorCol := 4;
          InCheck := false;
          KingRow := 8;
          KingCol := 5;
          ElapsedTime := 0;
          LastMove.FromRow := NULL_MOVE;
      end;

      {*** game attributes ***}
      Game.MoveNum := 1;
      Game.MovesStored := 0;
      Game.GameFinished := false;
      Game.MovesPointer := 0;
      Game.InCheck[0] := false;
      Game.NonDevMoveCount[0] := 0;
    end; {DefaultBoard}

{****************************************************************************}
{*  Setup Board:  Input a custom configuration of the pieces on the board   *}
{*  from the user.  Will anyone actually read these comments.  The user     *}
{*  moves the cursor to the square to be changed, and presses the key to    *}
{*  select the piece to put there.  The standards K Q R B N P select a      *}
{*  piece and SPACE blanks out the square.  The user can also clear the     *}
{*  board or ask for the default setup.  RETURN saves the changes and asks  *}
{*  the user for the move number to continue the game from.  ESCAPE         *}
{*  restores the setup upon entry to this routine and exits back to the     *}
{*  main menu.  This routine is called from the main menu.                  *}
{****************************************************************************}
  procedure SetupBoard;
    var row, col, ClearRow, ClearCol : RowColType;
        key : char;
        image : PieceImageType;
        LegalKey, InvalidSetup : boolean;
        KingCount, Attacked, Protected, Error, NewMoveNum : integer;
        TempStr : string80;
        SaveGame : GameType;

{----------------------------------------------------------------------------}
{  Put Piece On Board:  Puts the global Image onto the board at the cursor   }
{  position.  If the image is not a blank, then the user is asked for the    }
{  color (B or W).  If the piece is a rook or king being placed in the       }
{  piece's startup position, the user is asked if the piece has been moved   }
{  since the start of the game.                                              }
{----------------------------------------------------------------------------}
    procedure PutPieceOnBoard;
      var KingHomeRow, PawnHomeRow : RowColType;
      begin
        Board[row,col].image := image;
        if (image = BLANK) then begin
            Board[row,col].color := C_WHITE;
            Board[row,col].HasMoved := false;
        end else begin
            {*** get color ***}
            DisplayInstructions (INS_SETUP_COLOR);
            repeat
                key := GetKey;
            until (key = 'B') or (key = 'W');

            {*** check if piece has moved ***}
            if key = 'W' then begin
                Board[row,col].color := C_WHITE;
                KingHomeRow := 1;
                PawnHomeRow := 2;
            end else begin
                Board[row,col].color := C_BLACK;
                KingHomeRow := 8;
                PawnHomeRow := 7;
            end;
            {*** may have to ask if piece has been moved ***}
            if ((image = KING) and (row = KingHomeRow) and (col = 5))
                    or ((image = ROOK) and (row = KingHomeRow) and ((col = 1) or (col = 8))) then begin
                DisplayInstructions (INS_SETUP_MOVED);
                repeat
                    key := GetKey;
                until (key = 'Y') or (key = 'N');
                Board[row,col].HasMoved := key = 'Y';
            end else
                Board[row, col].HasMoved := not ((image = PAWN) and (row = PawnHomeRow));
            DisplaySquare (row, col, false);
            DisplayInstructions (INS_SETUP);
        end;
      end; {PutPieceOnBoard}

{----------------------------------------------------------------------------}
{  Check Valid Setup:  Makes sure that each player has exactly one king on   }
{  the board and updates the Player's King location attributes.  Both kings  }
{  cannot be in check.  The other relevant player attributes are set to.     }
{----------------------------------------------------------------------------}
    procedure CheckValidSetup;
      const NULL_ROW = NULL_MOVE;
      var row, col : RowColType;
      begin
        {*** locate kings ***}
        Player[C_WHITE].KingRow := NULL_ROW;
        Player[C_BLACK].KingRow := NULL_ROW;
        KingCount := 0;
        for row := 1 to BOARD_SIZE do
            for col := 1 to BOARD_SIZE do
                if (Board[row, col].image = KING) then begin
                    KingCount := KingCount + 1;
                    Player[Board[row, col].color].KingRow := row;
                    Player[Board[row, col].color].KingCol := col;
                end;
        InvalidSetup := (KingCount <> 2) or (Player[C_WHITE].KingRow = NULL_ROW)
                                         or (Player[C_BLACK].KingRow = NULL_ROW);

        {*** make sure both kings are not in check ***}
        if not InvalidSetup then begin
            AttackedBy (Player[C_WHITE].KingRow, Player[C_WHITE].KingCol, Attacked, Protected);
            Player[C_WHITE].InCheck := (Attacked <> 0);
            AttackedBy (Player[C_BLACK].KingRow, Player[C_BLACK].KingCol, Attacked, Protected);
            Player[C_BLACK].InCheck := (Attacked <> 0);
            InvalidSetup := (Player[C_WHITE].InCheck) and (Player[C_BLACK].InCheck);
        end;

        {*** set other player attributes ***}
        Game.GameFinished := false;
        with Player[C_WHITE] do begin
            CursorRow := 2;
            CursorCol := 4;
            LastMove.FromRow := NULL_MOVE;
        end;
        with Player[C_BLACK] do begin
            CursorRow := 7;
            CursorCol := 4;
            LastMove.FromRow := NULL_MOVE;
        end;
        DisplayConversationArea;

        {*** report invalid setup ***}
        if InvalidSetup then begin
            SetColor (White);
            SetFillStyle (SolidFill, Black);
            Bar (0,INSTR_LINE, GetMaxX, GetMaxY);
            SetTextStyle (TriplexFont, HorizDir, 3);
            OutTextXY (0,INSTR_LINE, 'Illegal Setup - King(s) not set correctly.  Press Key.');
            MakeSound (false);
            while GetKey = 'n' do ;
            DisplayInstructions (INS_SETUP);
        end;
      end; {CheckValidSetup}

{----------------------------------------------------------------------------}
{  Get Move Num:  Asks the user for the next move number of the game and     }
{  whose turn it is to move next.  If one of the players is in check, then   }
{  that player is the one who must move next and the latter question is not  }
{  asked.                                                                    }
{----------------------------------------------------------------------------}
    procedure GetMoveNum;
      const ex = 190; ey = 40;
      var cx, cy : integer;
      begin
        DisplayInstructions (INS_SETUP_MOVENUM);
        Game.MovesStored := 0;
        Game.MovesPointer := 0;
        Game.InCheck[0] := (Player[C_WHITE].InCheck) or (Player[C_BLACK].InCheck);

        {*** open up 'window' ***}
        cx := (BOARD_X1 + BOARD_X2) div 2;
        cy := (BOARD_Y1 + BOARD_Y2) div 2;
        SetFillStyle (SolidFill, DarkGray);
        Bar (cx - ex, cy - ey, cx + ex, cy + ey);

        {*** ask for move number ***}
        SetTextStyle (DefaultFont, HorizDir, 2);
        SetColor (Yellow);
        Str ((Game.MoveNum + 1) div 2, TempStr);
        UserInput (67, cy - 18, 4, 'Move Number: ', TempStr);
        Val (TempStr, NewMoveNum, Error);
        if Error <> 0 then
            NewMoveNum := 1
        else
            NewMoveNum := NewMoveNum * 2 - 1;

        {*** ask for whose turn to move next if not in check ***}
        if Game.InCheck[0] then begin
            if Player[C_BLACK].InCheck then NewMoveNum := NewMoveNum + 1
        end else begin
            if Game.MoveNum mod 2 = 1 then
                TempStr := 'W'
            else
                TempStr := 'B';
            UserInput (67, cy + 4, 1, 'Next Player (B/W): ', TempStr);
            if TempStr = 'B' then NewMoveNum := NewMoveNum + 1;
        end;

        Game.MoveNum := NewMoveNum;
        Game.NonDevMoveCount[0] := 0;
        DisplayWhoseMove;
      end; {GetMoveNum}

{----------------------------------------------------------------------------}
    begin {SetupBoard}
      DisplayInstructions (INS_SETUP);
      {*** remember old setup incase of escape ***}
      SaveGame := Game;
      SaveGame.Player := Player;
      SaveGame.FinalBoard := Board;
      row := 4;
      col := 4;
      repeat
          repeat
              {*** move cursor and get key ***}
              MoveCursor (row, col, C_WHITE, false, key);
              LegalKey := true;
              {*** interpret key ***}
              case key of
                  'K': image := KING;
                  'Q': image := QUEEN;
                  'R': image := ROOK;
                  'B': image := BISHOP;
                  'N': image := KNIGHT;
                  'P': begin
                         image := PAWN;
                         if (row = 1) or (row = 8) then begin
                             LegalKey := false;
                             MakeSound (false);
                         end;
                       end;
                  ' ': image := BLANK;
                  {*** clear board ***}
                  'C': begin
                         for ClearRow := 1 to BOARD_SIZE do
                             for ClearCol := 1 to BOARD_SIZE do
                                 Board[ClearRow, ClearCol].image := BLANK;
                         DisplayBoard;
                         LegalKey := false;
                       end;
                  {*** default setup of pieces ***}
                  'D': begin
                         DefaultBoardSetPieces;
                         DisplayBoard;
                         LegalKey := false;
                       end;
                  else LegalKey := false;
              end;
              if LegalKey then PutPieceOnBoard;
          until (key = 'e') or (key = 'x');

          {*** make sure setup is valid and repeat above if not ***}
          if (key = 'x') then
              InvalidSetup := false
          else
              CheckValidSetup;
      until not InvalidSetup;

      if (key = 'x') then begin
          {*** restore the old setup if user presses escape ***}
          Game := SaveGame;
          Player := SaveGame.Player;
          Board := SaveGame.FinalBoard;
      end else
          GetMoveNum;
      DisplayBoard;
    end; {SetupBoard}

{*** end of SETUP.PAS include file ***}
