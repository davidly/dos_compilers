{****************************************************************************}
{*  DISPLAY.PAS:  This file contains the display-oriented routines.         *}
{****************************************************************************}

{****************************************************************************}
{*  Display Init: initialize the Turbo Pascal VGA high resolution graphics  *}
{*  driver and load in the character fonts.  Displays error messages and    *}
{*  aborts the program if something goes wrong.                             *}
{****************************************************************************}
  procedure DisplayInit;
    begin
      ClrScr;
      write ('Starting KC Chess...');
      NoSound;
      GraphDriver := VGA;
      GraphMode := VGAHi;
      InitGraph (GraphDriver, GraphMode, '');
      if GraphResult <> grOk then begin
          writeln;
          writeln;
          writeln ('Error using graphics driver file "EGAVGA.BGI" <<or>> this computer does');
          writeln ('not have a VGA graphics card.  Aborting');
          Halt (1);
      end;
      SetTextStyle (TriplexFont, HorizDir, 1);
      if GraphResult <> grOk then begin
          CloseGraph;
          writeln ('Error in accessing font file "TRIP.CHR".  Aborting!');
          Halt (1);
      end;
    end;

{****************************************************************************}
{*  Load Piece Images:  from the file "PIECES.IMG".  These are the pixel    *}
{*  images of all of the pieces, including the 'piece' BLANK.  Checks for   *}
{*  I/O errors and aborts the program if there are any.                     *}
{****************************************************************************}
  procedure LoadPieceImages;
    var ImageFile : file of ImageType;
        IOerror : boolean;
    begin
      new (ImageStore);
      assign (ImageFile, 'PIECES.IMG');
      reset (ImageFile);
      IOerror := IOResult <> 0;
      if not IOerror then begin
          read (ImageFile, ImageStore^);
          IOerror := IOResult <> 0;
          if not IOerror then
              close (ImageFile);
      end;
      if IOerror then begin
          CloseGraph;
          writeln ('IO error trying to access images file "PIECES.IMG".  Aborting!');
          Halt (1);
      end;
    end;

{****************************************************************************}
{*  Display Title Screen:  Display the title, authors and notes on the      *}
{*  screen when the program starts, in a variety of fonts, sizes, and       *}
{*  colors.  Then wait for user to type a key.  The internal subroutine     *}
{*  CenterTitle will display its string argument, centered on the screen,   *}
{*  on the given pixel row.                                                 *}
{****************************************************************************}
  procedure DisplayTitleScreen;
    var key : char;

    procedure CenterTitle (row : integer; str : string80);
      begin
        OutTextXY (320 - TextWidth(str) div 2, row, str);
      end;

    begin
      ClearDevice;
      SetColor (LightCyan);
      SetTextStyle (TriplexFont, HorizDir, 26);
      CenterTitle (0, 'KC CHESS');
      SetColor (LightGreen);
      SetTextStyle (TriplexFont, HorizDir, 3);
      CenterTitle (200, 'by Craig Bruce and Kevin Phillips, 06-Apr-90.');
      SetTextStyle (TriplexFont, HorizDir, 1);
      CenterTitle (240, 'This program is Public Domain software.'); {*** that's right ***}
      SetColor (LightGray);
      SetTextStyle (TriplexFont, HorizDir, 1);
      CenterTitle (300, 'This program was written using');
      CenterTitle (330, 'Turbo Pascal 5.5 (c) Borland International, Inc.');  {*** required message ***}
      CenterTitle (360, 'as the undergraduate final project for Dr. J. D. Horton');
      CenterTitle (390, 'at the University of New Brunswick.');
      LoadPieceImages;  {*** while user is reading title screen ***}
      SetTextStyle (DefaultFont, HorizDir, 2);
      {*** display some piece images on the title screen ***}
      PutImage (320-WIDE*2, 135, ImageStore^[PAWN, C_WHITE, S_DARK], 0);
      PutImage (320-WIDE*1, 135, ImageStore^[KING, C_BLACK, S_LIGHT], 0);
      PutImage (320+WIDE*0, 135, ImageStore^[QUEEN, C_WHITE, S_DARK], 0);
      PutImage (320+WIDE*1, 135, ImageStore^[KNIGHT, C_BLACK, S_LIGHT], 0);
      SetColor (Yellow);
      CenterTitle (450, 'Press any key to begin');
      key := ReadKey;
    end;

{****************************************************************************}
{*  Make Sound:  Will make either the "good" sound (a beep), or the "bad"   *}
{*  sound (a buzz), if the sound option is on.                              *}
{****************************************************************************}
  procedure MakeSound (Good : boolean);
    begin
      if (Game.SoundFlag) then begin
          if (Good) then begin
              Sound (650);    {*** beep = 650 Hz ***}
              Delay (100);
          end else begin
              Sound (110);    {*** buzz = 110 Hz ***}
              Delay (350);
          end;
          NoSound;
      end;
    end;

{****************************************************************************}
{*  Display Square: and the piece on it on the main game screen, given the  *}
{*  row and column and whether to display it in the square's natural shade  *}
{*  or the cursor color.                                                    *}
{****************************************************************************}
  procedure DisplaySquare (Row, Col : RowColType; cursor : boolean);
    var x, y        : integer;
        SquareColor : SquareColorType;
        Piece       : PieceType;
    begin
      Piece := Board[Row, Col];
      {*** get the starting pixel location ***}
      x := BOARD_X1 + (Col - 1) * WIDE;
      y := BOARD_Y1 + (BOARD_SIZE - Row) * HIGH;
      {*** get the square color ***}
      if cursor then begin
          SquareColor := S_CURSOR;
      end else begin
          if (Row + Col) mod 2 = 0 then
              SquareColor := S_DARK
          else
              SquareColor := S_LIGHT;
      end;
      {*** put image onto the screen ***}
      PutImage (x, y, ImageStore^ [Piece.image, Piece.color, SquareColor], 0);
    end;

{****************************************************************************}
{*  Display Clear Lines:  Erase all text from the given pixel row for the   *}
{*  given number of pixel rows, on the conversation area.                   *}
{****************************************************************************}
  procedure DisplayClearLines (from, count : integer);
    begin
      SetFillStyle (SolidFill, DarkGray);
      Bar (MSG_BOXX1 + 1, from, MSG_BOXX2 - 1, from + count - 1);
    end;

{****************************************************************************}
{*  Center Text: Display the given string, centered, on the given pixel row *}
{*  of the conversation area.                                               *}
{****************************************************************************}
  procedure CenterText (row : integer; str : string80);
    begin
      OutTextXY (MSG_MIDX - TextWidth(str) div 2, row, str);
    end;

{****************************************************************************}
{*  Display Player Info:  Display the name, elapsed time, player type and   *}
{*  skill level, last move, and whether in check or not, for the given      *}
{*  player starting at the given pixel row on the conversation area (in     *}
{*  the player status box).                                                 *}
{****************************************************************************}
  procedure DisplayPlayerInfo (row : integer; color : PieceColorType);
    var cstr : string10;
        bstr : string80;
    begin
      SetTextStyle (TriplexFont, HorizDir, 1);
      SetColor (Yellow);
      with Player[color] do begin
          CenterText (row, Name);
          CenterText (row + MSG_CHI, TimeString (ElapsedTime));
          if IsHuman then
              bstr := 'Human'
          else begin
              Str (LookAhead, cstr);
              bstr := 'Machine Level ' + cstr;
              if PosEval then bstr := bstr + '+';
          end;
          CenterText (row + MSG_CHI * 2, bstr);
          CenterText (row + MSG_CHI * 3, 'Last: ' + MoveStr (LastMove));
          if InCheck then
              bstr := 'In Check'
          else
              bstr := 'Ok';
          CenterText (row + MSG_CHI * 4, bstr);
      end;
    end;

{****************************************************************************}
{*  Display Instructions:  display the given set of instructions at the     *}
{*  bottom of the screen in the instruction area.  OutLine will display the *}
{*  given instructions on the given instruction line number.                *}
{****************************************************************************}
  procedure DisplayInstructions (InstrSet : InstructionType);
    const CHI = 11;  {*** character height ***}

    procedure OutLine (LineNum : integer; OutText : string80);
      begin
        OutTextXY (0, INSTR_LINE + CHI * LineNum, OutText);
      end;

    begin
      SetFillStyle (SolidFill, Black);
      Bar (0, INSTR_LINE, GetMaxX, GetMaxY);
      SetTextStyle (DefaultFont, HorizDir, 1);
      SetColor (LightRed);
      case InstrSet of
          INS_MAIN: begin
              OutLine (0, 'MAIN MENU                                   RETURN = play,       F = File System');
              OutLine (1, 'H = Help,  G = Goto move, W = Watch game,   O = Options,         P = Player info');
              OutLine (2, 'Q = Quit,  N = New game,  S = Setup board,  T = Take-Back Move,  U = Un-takeback');
              end;
          INS_GAME : begin
              OutLine (0, 'GAME MENU');
              OutLine (1, 'Human Player: use Cursor Keys, BACKSPACE, and RETURN/SPACE.  ESC = main menu');
              OutLine (2, 'M = force computer to Move,  H = Hint,  A = Attack/protect,  C = Check moves');
              end;
          INS_SETUP : begin
              OutLine (0, 'SETUP MENU');
              OutLine (1, 'Use cursor keys.  Then type K, Q, R, B, N or P to set piece or SPACE to remove.');
              OutLine (2, 'RETURN = exit,  ESC = exit recalling old setup;  D = default,  C = clear board.');
              end;
          INS_SETUP_COLOR : begin
              OutLine (0, 'SETUP MENU - PIECE COLOR SET');
              OutLine (1, 'Type B to create a BLACK piece');
              OutLine (2, 'Type W to create a WHITE piece');
              end;
          INS_SETUP_MOVED : begin
              OutLine (0, 'SETUP MENU - PIECE MOVED SET');
              OutLine (1, 'Has this piece been moved from its starting position at any time since the');
              OutLine (2, 'start of the game (Y/N)?');
              end;
          INS_SETUP_MOVENUM : begin
              OutLine (0, 'SETUP MENU - SET MOVE NUMBER and COLOR');
              OutLine (1, 'Enter the number then whose turn the next move of the game will be.');
              OutLine (2, 'Use BACKSPACE to edit value, and RETURN to enter it.');
              end;
          INS_PLAYER : begin
              OutLine (0, 'SET PLAYER INFO');
              OutLine (1, 'Type value, use BACKSPACE to edit and press RETURN after each field.');
              OutLine (2, 'For the player type: H = Human and M = Machine. Pos Eval is part of skill level.');
              end;
          INS_OPTIONS : begin
              OutLine (0, 'SET OPTIONS');
              OutLine (1, 'Type value, use BACKSPACE to edit and press RETURN after each field.');
              OutLine (2, 'Press RETURN only to preserve current setting.');
              end;
          INS_FILE : begin
              OutLine (0, 'FILE MENU');
              OutLine (1, 'L = Load Game,  S = Save Game,  D = Directory,  P = Print Game');
              OutLine (2, 'ESC = return to Main Menu');
              end;
          INS_FILE_INPUT: begin
              OutLine (0, 'FILE NAME INPUT');
              OutLine (1, 'Please enter the name of the file you wish to use.');
              OutLine (2, 'Press RETURN only for default file name.');
              end;
          INS_WATCH : begin
              OutLine (0, 'WATCH MODE');
              OutLine (1, 'Press any key to return to Main Menu.');
              end;
          INS_GOTO : begin
              OutLine (0, 'GOTO MOVE NUMBER');
              OutLine (1, 'Please enter the move number and then the color to move.');
              OutLine (2, 'to use.  Press RETURN only for default file.');
              end;
          INS_PAWN_PROMOTE : begin
              OutLine (0, 'HUMAN PLAYER PAWN PROMOTION');
              OutLine (1, 'Press the letter of the piece you wish to promote the pawn to:');
              OutLine (2, 'Q = Queen,  R = Rook,  B = Bishop,  N = kNight.');
              end;
      end;
    end;

{****************************************************************************}
{*  Display Board:  call DisplaySquare for each square on the board.  A     *}
{*  small dot is displayed on the screen immediately before the square      *}
{*  image is displayed to show that the screen is being updated, even if    *}
{*  the board is being displayed over itself with no changes.               *}
{****************************************************************************}
  procedure DisplayBoard;
    var row, col : RowColType;
        x,y : integer;
    begin
      SetFillStyle (SolidFill, LightCyan);
      for row := 1 to BOARD_SIZE do
          for col := 1 to BOARD_SIZE do begin
              x := BOARD_X1 + (Col-1) * WIDE;
              y := BOARD_Y1 + (BOARD_SIZE - Row) * HIGH;
              Bar (x + 23, y + 23, x + 26, y + 26);
              DisplaySquare (row, col, false);
          end;
    end;

{****************************************************************************}
{*  Get Finish Reason:  given the completion status variables in the Game   *}
{*  global data structure, this routine returns the reason and the winner   *}
{*  (if any) of the game.  The reason can be that a player exceeded the     *}
{*  time limit, there are more moves than can be stored in the game,        *}
{*  stalemate (fifty non-developmental moves or player cannot move, or      *}
{*  last but not least, checkmate.                                          *}
{****************************************************************************}
  procedure GetFinishReason (var Reason : string80; var IsWinner : boolean;
                             var Winner : PieceColorType);
    var KingInCheck : boolean;
    begin
      if Game.TimeOutWhite or Game.TimeOutBlack then begin
          Reason := 'Time-Out';
          if Game.TimeOutWhite and Game.TimeOutBlack then
              IsWinner := false
          else begin
              IsWinner := true;
              if Game.TimeOutWhite then
                  Winner := C_BLACK
              else
                  Winner := C_WHITE;
          end;
      end else begin
          if Game.NoStorage then begin
              Reason := 'Game Too Long';
              IsWinner := false;
          end else begin
              KingInCheck := Player[C_WHITE].InCheck or Player[C_BLACK].InCheck;
              if Game.Stalemate or not KingInCheck then begin
                  Reason := 'Stalemate';
                  IsWinner := false;
              end else begin
                  Reason := 'Checkmate';
                  IsWinner := true;
                  if Player[C_WHITE].InCheck then
                      Winner := C_BLACK
                  else
                      Winner := C_WHITE;
              end;
          end;
      end;
    end;

{****************************************************************************}
{*  Display Whose Move:  displays the move number and color of the current  *}
{*  move in the conversation area.  If the game is finished, display the    *}
{*  reason, and if the fifty move stalemate is close, displays a warning.   *}
{****************************************************************************}
  procedure DisplayWhoseMove;
    var cstr : string10;
        mstr : string80;
        Reason : string80;
        Winner : PieceColorType;
        IsWinner : boolean;
        Turn : PieceColorType;
        OutMove : integer;
        NoDevCount : integer;
    begin
      {*** move number and color ***}
      if Game.GameFinished then
          OutMove := Game.MoveNum - 1
      else
          OutMove := Game.MoveNum;
      Str ((OutMove + 1) div 2, cstr);
      mstr := 'Move ' + cstr + '-';
      if OutMove mod 2 = 1 then begin
          mstr := mstr + 'White';
          Turn := C_WHITE;
      end else begin
          mstr := mstr + 'Black';
          Turn := C_BLACK;
      end;
      SetTextStyle (TriplexFont, HorizDir, 1);
      SetColor (Yellow);
      DisplayClearLines (MSG_SCORE, MSG_POS_EVAL+8-MSG_SCORE);
      DisplayClearLines (MSG_MOVENUM, 80);
      CenterText (MSG_MOVENUM, mstr);

      {*** if game is over, display reason ***}
      if Game.GameFinished then begin
          GetFinishReason (Reason, IsWinner, Winner);
          SetColor (White);
          CenterText (MSG_TURN + 3, Reason + ':');
          SetColor (LightGreen);
          if IsWinner then
              CenterText (MSG_MOVE - 1, Player[Winner].Name)
          else
              CenterText (MSG_MOVE, 'Neither Player');
          CenterText (MSG_HINT, 'Wins');
      end else begin
          CenterText (MSG_TURN, Player[Turn].Name);
      end;

      {*** warn if fifty move stalemate is close ***}
      NoDevCount := Game.NonDevMoveCount[Game.MovesPointer];
      DisplayClearLines (MSG_WARN50, 17);
      if (NoDevCount >= NON_DEV_MOVE_LIMIT - 10) then begin
          SetColor (LightRed);
          if (NoDevCount = NON_DEV_MOVE_LIMIT) then
              CenterText (MSG_WARN50, '50 Move Limit')
          else begin
              Str(NON_DEV_MOVE_LIMIT - NoDevCount, cstr);
              CenterText (MSG_WARN50, 'Stalemate in ' + cstr);
          end;
      end;
    end;

{****************************************************************************}
{*  Display Conversation Area:  display player status for black and white,  *}
{*  move status, and time limit, all in the conversation area.              *}
{****************************************************************************}
  procedure DisplayConversationArea;
    var tempstr : string80;
    begin
      SetFillStyle (SolidFill, DarkGray);
      Bar (MESSAGE_X, MSG_CONV, GetMaxX, INSTR_LINE - 8);
      SetColor (White);
      Rectangle (MSG_BOXX1, MSG_WHITE-2, MSG_BOXX2, MSG_WHITE + MSG_PLHI);
      SetTextStyle (DefaultFont, HorizDir, 1);
      OutTextXY (MSG_BOXX1 + 4, MSG_WHITE - 10, 'White');
      DisplayPlayerInfo (MSG_WHITE, C_WHITE);
      SetColor (Black);
      Rectangle (MSG_BOXX1, MSG_BLACK-2, MSG_BOXX2, MSG_BLACK + MSG_PLHI);
      SetTextStyle (DefaultFont, HorizDir, 1);
      OutTextXY (MSG_BOXX1 + 4, MSG_BLACK - 10, 'Black');
      DisplayPlayerInfo (MSG_BLACK, C_BLACK);
      SetColor (Cyan);
      Rectangle (MSG_BOXX1, 356, MSG_BOXX2, 438);
      SetTextStyle (TriplexFont, HorizDir, 1);
      SetColor (LightGreen);
      if (Game.TimeLimit = 0) then
          tempstr := '<none>'
      else
          tempstr := TimeString (Game.TimeLimit);
      CenterText (MSG_TIME_LIMIT, 'T.Limit = ' + tempstr);
      DisplayWhoseMove;
    end;

{****************************************************************************}
{*  Display Game Screen:  clear the hires screen, display the board,        *}
{*  conversation area, and instructions.                                    *}
{****************************************************************************}
  procedure DisplayGameScreen;
    var i : integer;
    begin
      ClearDevice;
      {*** display board ***}
      SetFillStyle (SolidFill, Blue);
      Bar (BOARD_X1-4, BOARD_Y1-4, BOARD_X2+3, BOARD_Y2+3);
      DisplayBoard;

      {*** display row and column letters and numbers around board ***}
      SetColor (LightGreen);
      SetTextStyle (TriplexFont, HorizDir, 2);
      for i := 1 to 8 do begin
          OutTextXY (0, BOARD_Y1+HIGH*i-8-HIGH div 2,
                     Copy (ROW_NAMES, BOARD_SIZE - i + 1, 1));
          OutTextXY (BOARD_X2 + 10, BOARD_Y1+HIGH*i-8-HIGH div 2,
                     Copy (ROW_NAMES, BOARD_SIZE - i + 1, 1));
          OutTextXY (BOARD_X1+WIDE*i-8-WIDE div 2, BOARD_Y2+4,
                     Copy (COL_NAMES, i, 1));
      end;

      {*** display title and conversation area ***}
      SetFillStyle (SolidFill, DarkGray);
      Bar (MESSAGE_X, 0, GetMaxX, MSG_CONV - 1);
      SetTextStyle (TriplexFont, HorizDir, 4);
      SetColor (LightCyan);
      CenterText (2, 'KC CHESS');
      DisplayConversationArea;
    end;

{****************************************************************************}
{*  Update Time:  get the elapsed time since last call, and if there was a  *}
{*  change in the time, the amount of change is added to the current        *}
{*  player's elapsed time and the new time is displayed.                    *}
{****************************************************************************}
  procedure UpdateTime (Turn : PieceColorType);
    var Elapsed : longint;
        Row     : integer;
    begin
      Elapsed := ElapsedTime;
      if (Elapsed > 0) then begin
          Player[Turn].ElapsedTime := Player[Turn].ElapsedTime + Elapsed;
          if (Turn = C_WHITE) then
              Row := MSG_WHITE + MSG_CHI
          else
              Row := MSG_BLACK + MSG_CHI;
          DisplayClearLines (Row, 17);
          SetTextStyle (TriplexFont, HorizDir, 1);
          SetColor (Yellow);
          CenterText (Row, TimeString(Player[Turn].ElapsedTime));
      end;
    end;

{****************************************************************************}
{*  Flash Piece:  will flash the piece at the given location on the Board   *}
{*  alternately against the other given piece image and color.  This        *}
{*  routine is called to highlight the piece that is moving and what it     *}
{*  takes when a move is being displayed.                                   *}
{****************************************************************************}
  procedure FlashPiece (row, col : RowColType; OldImage : PieceImageType;
                        OldColor : PieceColorType);
    var NewImage : PieceImageType;
        NewColor : PieceColorType;
        i : integer;
    begin
      NewImage := Board[row, col].image;
      NewColor := Board[row, col].color;
      for i := 1 to Game.FlashCount do begin
          Board[row,col].image := NewImage;  {*** show new image ***}
          Board[row,col].color := NewColor;
          DisplaySquare (row, col, false);
          Delay (80);
          Board[row,col].image := OldImage;  {*** show old image ***}
          Board[row,col].color := OldColor;
          DisplaySquare (row, col, false);
          Delay (80);
      end;
      Board[row, col].image := NewImage;     {*** store new image ***}
      Board[row, col].color := NewColor;
      DisplaySquare (row, col, false);
    end;

{****************************************************************************}
{*  Display Move:  displays the given move on the screen after it has       *}
{*  already been made to the internal data structures.  The special cases   *}
{*  of castling and en passent are taken care of.  No special case is       *}
{*  required for pawn promotion, since it is taken care of elsewhere.       *}
{****************************************************************************}
  procedure DisplayMove (Movement : MoveType);
    var row, EnemyRow : integer;
        cstr : string10;
    begin
      {*** for all moves, show the piece leaving old square and taking new square ***}
      with Movement do begin
          FlashPiece (FromRow, FromCol, PieceMoved.image, PieceMoved.color);
          FlashPiece (ToRow, ToCol, PieceTaken.image, PieceTaken.color);
      end;
      case Movement.PieceMoved.image of

          {*** castling to left or right: must show rook moving ***}
          KING: begin
              if abs (Movement.FromCol - Movement.ToCol) > 1 then begin
                  if (Movement.ToCol < Movement.FromCol) then begin
                      FlashPiece (Movement.FromRow, 1, ROOK, Movement.PieceMoved.color);
                      FlashPiece (Movement.FromRow, 4, BLANK, Movement.PieceMoved.color);
                  end else begin
                      FlashPiece (Movement.FromRow, 8, ROOK, Movement.PieceMoved.color);
                      FlashPiece (Movement.FromRow, 6, BLANK, Movement.PieceMoved.color);
                  end;
              end;
          end;

          {*** en passent: must show the pawn being taken ***}
          PAWN: if (Movement.FromCol <> Movement.ToCol) and (Movement.PieceTaken.image = BLANK) then
                      FlashPiece (Movement.FromRow, Movement.ToCol, PAWN, EnemyColor[Movement.PieceMoved.color]);
      end;

      {*** locate and display the new last move and in-check status ***}
      if Movement.PieceMoved.color = C_WHITE then begin
          row := MSG_WHITE;
          EnemyRow := MSG_BLACK;
      end else begin
          row := MSG_BLACK;
          EnemyRow := MSG_WHITE;
      end;
      DisplayClearLines (row + MSG_CHI * 3, 34);
      SetTextStyle (TriplexFont, HorizDir, 1);
      SetColor (Yellow);
      CenterText (row + MSG_CHI * 3, 'Last: ' + MoveStr(Player[Movement.PieceMoved.color].LastMove));
      CenterText (row + MSG_CHI * 4, 'Ok');
      if Player[EnemyColor[Movement.PieceMoved.color]].InCheck then cstr := 'In Check' else cstr := 'Ok';
      DisplayClearLines (EnemyRow + MSG_CHI * 4, 17);
      CenterText (EnemyRow + MSG_CHI * 4, cstr);
    end;

{****************************************************************************}
{*  Display UnMade Move:  display a move being retracted after the internal *}
{*  data structures have been modified.  Special cases are un-castle and    *}
{*  un-en passent.                                                          *}
{****************************************************************************}
  procedure DisplayUnMadeMove (Movement : MoveType);
    var row, EnemyRow : integer;
        cstr : string10;
    begin
      if (Movement.FromRow <> NULL_MOVE) then begin
          with Movement do begin
              {*** retract for all pieces ***}
              FlashPiece (ToRow, ToCol, MovedImage, PieceMoved.color);
              FlashPiece (FromRow, FromCol, BLANK, C_WHITE);
          end;
          case Movement.PieceMoved.image of

              {*** un-castle ***}
              KING: begin
                  if abs (Movement.FromCol - Movement.ToCol) > 1 then begin
                      if (Movement.ToCol < Movement.FromCol) then begin
                          FlashPiece (Movement.FromRow, 4, ROOK, Movement.PieceMoved.color);
                          FlashPiece (Movement.FromRow, 1, BLANK, Movement.PieceMoved.color);
                      end else begin
                          FlashPiece (Movement.FromRow, 6, ROOK, Movement.PieceMoved.color);
                          FlashPiece (Movement.FromRow, 8, BLANK, Movement.PieceMoved.color);
                      end;
                  end;
              end;

              {*** un-en passent ***}
              PAWN: if (Movement.FromCol <> Movement.ToCol) and (Movement.PieceTaken.image = BLANK) then
                          FlashPiece (Movement.FromRow, Movement.ToCol, BLANK, EnemyColor[Movement.PieceMoved.color]);
          end;

          {*** update status for both players ***}
          if Movement.PieceMoved.color = C_WHITE then begin
              row := MSG_WHITE;
              EnemyRow := MSG_BLACK;
          end else begin
              row := MSG_BLACK;
              EnemyRow := MSG_WHITE;
          end;
          DisplayClearLines (row + MSG_CHI * 3, 34);
          SetTextStyle (TriplexFont, HorizDir, 1);
          SetColor (Yellow);
          CenterText (row + MSG_CHI * 3, 'Last: ' + MoveStr(Player[Movement.PieceMoved.color].LastMove));
          if Player[Movement.PieceMoved.color].InCheck then cstr := 'In Check' else cstr := 'Ok';
          CenterText (row + MSG_CHI * 4, cstr);
          DisplayClearLines (EnemyRow + MSG_CHI * 4, 17);
          CenterText (EnemyRow + MSG_CHI * 4, 'Ok');
          DisplayWhoseMove;
      end;
    end;

{*** end of DISPLAY.PAS include file ***}
