{****************************************************************************}
{*   KC CHESS ver 1.00.00 - by Craig Bruce and Kevin Phillips, 06-Apr-90.   *}
{*        Language: Turbo Pascal 5.5 (c) Borland International, Inc.        *}
{****************************************************************************}
{*  CHESS.PAS: This file contains all of the global constants, data         *}
{*  structures, and global variables.  All of the other source files which  *}
{*  comprise the game are "included" here, and the very high level code     *}
{*  for the main routine is at the bottom of this file.                     *}
{****************************************************************************}
{*  Executing this program requires a 100% IBM-PC or PS/2 compatible        *}
{*  computer with 640K of RAM and a VGA graphics card.                      *}
{****************************************************************************}

{$M 45000, 80000, 80000}  {*** memory parameters - stack size, heap size ***}

program ChessMain;
  uses graph, crt, dos;  {*** use Turbo Pascal subroutine packages ***}

        {*** miscellaneous program constants ***}
  const HIGH = 52;  WIDE = 52;  SINGLE_IMAGE_SIZE = 1500;
        BOARD_SIZE = 8;  ROW_NAMES = '12345678';  COL_NAMES = 'ABCDEFGH';
        BOARD_X1 = 19;  BOARD_Y1 = 4;  BOARD_X2 = 434;  BOARD_Y2 = 419;
        INSTR_LINE = 450;  MESSAGE_X = 460;
        NULL_MOVE = -1;  STALE_SCORE = -1000;
        MOVE_LIST_LEN = 300;  GAME_MOVE_LEN = 500;
        MAX_LOOKAHEAD = 9;  PLUNGE_DEPTH = -1;  NON_DEV_MOVE_LIMIT = 50;

        {*** pixel rows to print various messages in the conversation area ***}
        MSG_MOVE = 399;  MSG_BOXX1 = 464;    MSG_BOXX2 = 635;   MSG_MIDX = 550;
        MSG_WHITE = 165; MSG_BLACK = 54;     MSG_MOVENUM = 358; MSG_PLHI = 90;
        MSG_TURN = 375;  MSG_SCAN = 416;     MSG_CHI = 17;      MSG_HINT = 416;
        MSG_CONV = 40;   MSG_WARN50 = 277;   MSG_TIME_LIMIT = 258;
        MSG_SCORE = 318; MSG_POS_EVAL = 344; MSG_ENEMY_SCORE = 331;

  type PieceImageType = (BLANK, PAWN, BISHOP, KNIGHT, ROOK, QUEEN, KING);
       PieceColorType = (C_WHITE, C_BLACK);
       {*** the color of the actual square ***}
       SquareColorType = (S_LIGHT, S_DARK, S_CURSOR);
       {*** which instructions to print at bottom of screen ***}
       InstructionType = (INS_MAIN, INS_GAME, INS_SETUP, INS_PLAYER, INS_SETUP_COLOR,
                          INS_SETUP_MOVED, INS_SETUP_MOVENUM, INS_FILE, INS_FILE_INPUT,
                          INS_WATCH, INS_GOTO, INS_OPTIONS, INS_PAWN_PROMOTE);
       {*** there is a two-thick border of 'dead squares' around the main board ***}
       RowColType = -1..10;
       {*** Turbo Pascal requires that parameter string be declared like this ***}
       string2 = string[2];
       string10 = string[10];
       string80 = string[80];
       {*** memory for a 52*52 pixel image ***}
       SingleImageType = array [1..SINGLE_IMAGE_SIZE] of byte;
       {*** images must be allocated on the heap because the stack is not large enough ***}
       ImageTypePt = ^ImageType;
       ImageType = array [PieceImageType, PieceColorType, SquareColorType] of SingleImageType;
       {*** text file records for help mode ***}
       HelpPageType = array [1..22] of string80;

       {*** directions to scan when looking for all possible moves of a piece ***}
       PossibleMovesType = array [PieceImageType] of record
                               NumDirections : 1..8;
                               MaxDistance : 1..7;
                               UnitMove : array [1..8] of record
                                   DirRow, DirCol: -2..2;
                               end;
                           end;

       {*** attributes for a piece or board square ***}
       PieceType = record
                       image : PieceImageType;
                       color : PieceColorType;
                       HasMoved : boolean;
                       ValidSquare : boolean;
                   end;

       BoardType = array [RowColType, RowColType] of PieceType;

       {*** representation of the movement of a piece, or 'ply' ***}
       MoveType = record
                      FromRow, FromCol, ToRow, ToCol : RowColType;
                      PieceMoved : PieceType;
                      PieceTaken : PieceType;
                      {*** image after movement - used for pawn promotion ***}
                      MovedImage : PieceImageType;
                  end;

       {*** string of moves - used to store list of all possible moves ***}
       MoveListType = record
                         NumMoves : 0..MOVE_LIST_LEN;
                         Move : array [1..MOVE_LIST_LEN] of MoveType;
                     end;

       {*** attributes of both players ***}
       PlayerType = array [PieceColorType] of record
                        Name : string[20];
                        IsHuman : boolean;
                        LookAhead : 0..MAX_LOOKAHEAD;
                        PosEval : boolean;                  {*** Position Evaluation On / Off ***}
                        ElapsedTime : LongInt;
                        LastMove : MoveType;
                        InCheck : boolean;
                        KingRow, KingCol : RowColType;
                        CursorRow, CursorCol : RowColType;
                    end;

       {*** attributes to represent an entire game ***}
       GameType = record
                     MovesStored : 0..GAME_MOVE_LEN;   {*** number of moves stored ***}
                     MovesPointer : 0..GAME_MOVE_LEN;  {*** move currently displayed - for Takeback, UnTakeback ***}
                     MoveNum : 1..GAME_MOVE_LEN;       {*** current move or 'ply' number ***}
                     Player : PlayerType;
                     Move : array [1..GAME_MOVE_LEN] of MoveType;
                     InCheck : array [0..GAME_MOVE_LEN] of boolean;  {*** if player to move is in check ***}
                     FinalBoard : BoardType;
                     GameFinished : boolean;
                     TimeOutWhite, TimeOutBlack : boolean;  {*** reasons for a game... ***}
                     Stalemate, NoStorage : boolean;        {***   being finished ***}
                     NonDevMoveCount : array [0..GAME_MOVE_LEN] of byte;  {*** since pawn push or take - Stalemate-50 ***}
                     EnPassentAllowed : boolean;
                     SoundFlag : boolean;
                     FlashCount : integer;
                     WatchDelay : integer;
                     TimeLimit : longint;
                 end;

      {*** global variables ***}
  var Game : GameType;
      Board : BoardType;      {*** current board setup ***}
      Player : PlayerType;    {*** current player attributes ***}
      CapturePoints : array [PieceImageType] of integer;      {*** for taking enemy piece ***}
      EnemyColor : array [PieceColorType] of PieceColorType;  {*** opposite of given color ***}
      PossibleMoves : PossibleMovesType;
      LastTime : longint;         {*** last read system time-of-day clock value ***}
      DefaultFileName : string80; {*** for loading and saving games ***}
      ImageStore : ImageTypePt;
      GraphDriver, GraphMode : integer;   {*** for Turbo Pascal graphics ***}

{*** include files ***}

{$I MISC.PAS}     {*** miscellaneous functions ***}
{$I INIT.PAS}     {*** initialization of global variables ***}
{$I DISPLAY.PAS}  {*** display-oriented routines ***}
{$I INPUT.PAS}    {*** keyboard input routines ***}
{$I MOVES.PAS}    {*** move generation and making routines ***}
{$I SETUP.PAS}    {*** default board and custom setup routines ***}
{$I PLAY.PAS}     {*** computer thinking and player input routines ***}
{$I MENU.PAS}     {*** main menu routines ***}

{****************************************************************************}
{*  Main Program: initialize, title screen, play, quit.                     *}
{****************************************************************************}
  begin
    StartupInitialize;
    DefaultBoard;
    DisplayInit;
    DisplayTitleScreen;
    DisplayGameScreen;
    MainMenu;
    CloseGraph;
  end.

  {*** end of main program file CHESS.PAS ***}
