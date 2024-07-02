{****************************************************************************}
{*  MENU.PAS:  this include file contains the routines which implement the  *}
{*  main menu of the game.                                                  *}
{****************************************************************************}

{****************************************************************************}
{*  Online Help:  Display the information in the help file.  The user is    *}
{*  allowed to move up and down by pages, and to exit back to the main      *}
{*  program.  The file on the disk is in the format of 22 strings to a      *}
{*  page, where each string is displayed on one line of the help screen.    *}
{*  I/O error checking is performed to react properly if something goes     *}
{*  wrong.                                                                  *}
{****************************************************************************}
  procedure OnlineHelp;
    var Page : HelpPageType;            {*** currently displayed page data ***}
        key : char;
        HelpFile : file of HelpPageType;
        i : integer;
        PageNum, PageLim : longint;
        SeparatorLine : string80;       {*** a line of the separator character ***}
        IOerror : boolean;

    begin
      {*** initialize and open help file ***}
      SeparatorLine := '';
      for i := 1 to 79 do SeparatorLine := SeparatorLine + #205;
      assign (HelpFile, 'CHESS.HLP');
      reset (HelpFile);
      IOerror := IOResult <> 0;
      if not IOerror then begin
          {*** read and display the current help page ***}
          PageNum := 1;
          PageLim := FileSize (HelpFile);
          repeat
              Seek (HelpFile, PageNum - 1);
              read (HelpFile, Page);
              IOerror := IOResult <> 0;
              if not IOerror then begin
                  ClrScr;
                  TextColor (Green);
                  write ('Help.  Use PAGE_UP and PAGE_DOWN to view and ESC to exit.');
                  writeln ('     Page ', PageNum, ' of ', PageLim, '.');
                  writeln(SeparatorLine);
                  TextColor (LightGray);
                  for i := 1 to 22 do writeln (Page[i]);
                  TextColor (Green);
                  write (SeparatorLine);
                  TextColor (LightGray);
                  {*** get user input ***}
                  repeat
                      key := GetKey;
                  until key in ['i', 'm', 'x', ' ', 'e'];
                  case key of
                      'i': if PageNum > 1 then PageNum := PageNum - 1;
                      'm', ' ', 'e': if PageNum < PageLim then
                                         PageNum := PageNum + 1;
                  end;
              end;
          until (key = 'x') or IOerror;
      end;
      {*** report error if one ***}
      if IOerror then begin
          ClrScr;
          write ('IO error trying to access "CHESS.HLP".  Press key...');
          key := ReadKey;
      end else
          close (HelpFile);
    end;

{****************************************************************************}
{*  Get Player Color Info:  Inputs from the user all of the attributes for  *}
{*  the player of the given color.  This routine is called for each player  *}
{*  by the main menu routine when Set Player Info is selected.  The pixel   *}
{*  location of where to start the input block is given.                    *}
{****************************************************************************}
  procedure GetPlayerColorInfo (Color : PieceColorType; Xpos, Ypos : integer);
    var TempStr : string80;   {*** for user input ***}
        Error : integer;
        Level : integer;

    begin
      {*** display player's color ***}
      if (Color = C_WHITE) then
          OutTextXY (Xpos - 24, Ypos - 20, 'WHITE')
      else
          OutTextXY (Xpos - 24, Ypos - 20, 'BLACK');

      {*** get player's name; default is present name ***}
      TempStr := Player[Color].Name;
      UserInput (Xpos, Ypos, 11,'Name: ', TempStr);
      Player[Color].Name := TempStr;

      {*** get player's elapsed time ***}
      TempStr := TimeString (Player[Color].ElapsedTime);
      UserInput (Xpos, Ypos+20, 8, 'Elapsed Time: ', TempStr);
      Player[Color].ElapsedTime := StringToTime (TempStr);

      {*** get player's type (Human / Machine) ***}
      if Player[Color].IsHuman then TempStr := 'H' else TempStr := 'M';
      UserInput (Xpos, Ypos+40, 1, 'Player Type (H/M): ', TempStr);
      Player[Color].IsHuman := (TempStr = 'H');

      {*** get player's lookahead ply count, set to 3 if error ***}
      Str (Player[Color].LookAhead, TempStr);
      UserInput (Xpos, Ypos+60, 1, 'Look Ahead (0-9): ', TempStr);
      Val (TempStr, Level, Error);
      if (Error = 0) then
          Player[Color].LookAhead := Level
      else
          Player[Color].LookAhead := 3;

      {*** get player's position evaluation setting ***}
      if Player[Color].PosEval then TempStr := 'Y' else TempStr := 'N';
      UserInput (Xpos, Ypos+80, 1, 'Evaluate Pos (Y/N): ', TempStr);
      Player[Color].PosEval := (TempStr <> 'N');
    end;

{****************************************************************************}
{*  Get Options:  Gets the values for the user settable options (global     *}
{*  variables) of the game.  Called by the main menu.  For numeric values,  *}
{*  if the entered value is in error, then a default is used.               *}
{****************************************************************************}
  procedure GetOptions (Xpos, Ypos: integer);
    var TempStr: string80;   {*** for user input ***}
        Error: integer;

    begin
      {*** set the number of times to flash a piece when it is moving ***}
      Str (Game.FlashCount, TempStr);
      UserInput (Xpos, Ypos, 1, 'Flash Count: ', TempStr);
      Val (TempStr, Game.FlashCount, Error);
      if (Error <> 0) then Game.FlashCount := 2;

      {*** set sound enable / disable ***}
      if (Game.SoundFlag) then TempStr := 'Y' else TempStr := 'N';
      UserInput (Xpos, Ypos + 24, 1, 'Sound (Y/N): ', TempStr);
      Game.SoundFlag := (TempStr <> 'N');

      {*** set whether en passent move is to be allowed or not ***}
      if Game.EnPassentAllowed then TempStr := 'Y' else TempStr := 'N';
      UserInput (Xpos, Ypos + 48, 1, 'En Passent (Y/N): ', TempStr);
      Game.EnPassEntAllowed := (TempStr <> 'N');
      Str (Game.WatchDelay, TempStr);

      {*** set time to wait between displaying moves in watch mode ***}
      UserInput (Xpos, Ypos + 72, 5, 'Watch Delay (ms): ', TempStr);
      Val (TempStr, Game.WatchDelay, Error);
      if (Error <> 0) or (Game.WatchDelay < 0) or (Game.WatchDelay > 30000) then
          Game.WatchDelay := 700;

      {*** set the time limit for the game (00:00:00 means no time limit) ***}
      TempStr := TimeString (Game.TimeLimit);
      UserInput (Xpos, Ypos + 96, 8, 'Time Limit: ', TempStr);
      Game.TimeLimit := StringToTime (TempStr);
    end;

{****************************************************************************}
{*  Input File Name:  Displays a title and asks the user to enter the name  *}
{*  of the file which is to be used for some operation, which is returned.  *}
{*  The default filename is provided to this routine.  This routine is      *}
{*  called by Load Game, Save Game, and Print Game.                         *}
{****************************************************************************}
  procedure InputFileName (Title : string80; var FileName : string80);
    begin
      DisplayInstructions (INS_FILE_INPUT);
      SetFillStyle (SolidFill, DarkGray);
      Bar (BOARD_X1, BOARD_Y1, BOARD_X2, BOARD_Y2);
      SetColor (Yellow);
      SetTextStyle (DefaultFont, HorizDir, 2);
      OutTextXY (54, 20, Title);
      UserInput (54, 70, 8, 'File Name: ', FileName);
    end;

{****************************************************************************}
{*  Print Game:  Prints a text file representation of the game.  All of the *}
{*  moves showing the turn number, color to move, piece moved, and piece    *}
{*  taken are printed, as well as the final board setup.  The end of the    *}
{*  game is taken to be the board currently displayed on the screen (incase *}
{*  the user has taken back moves and is not looking at the end of all the  *}
{*  moves made).  The default output file is "PRN" which will print to the  *}
{*  printed; however, the user can change this name to print to a disk      *}
{*  file in standard DOS text file format.  I/O error checking is performed *}
{*  to respond to any errors.  This routine is called from the file menu.   *}
{****************************************************************************}
  procedure PrintGame;
    type string20 = string[20];
    var PrintFile : Text;   {*** Turbo Pascal text file type ***}
        i : integer;
        PrintFileName : string80;
        IOerror : boolean;
        {*** conversions from internal piece type to external string names ***}
        PieceName : array [PieceImageType] of string20;
        PieceAbbrev : array [PieceImageType] of string20;
        ColorName : string20;
        MoveFromTo : string20;
        PieceTakenStr : string20;
        CurMoveNum : integer;
        Movement : MoveType;
        key : char;

{----------------------------------------------------------------------------}
{  Dump Board:  Prints out the text representation of the final board.       }
{  Each entry in the matrix printed out shows the piece (K/Q/R/N/B/P) and    }
{  color (B/W) of the piece occupying that square, or prints blanks if no    }
{  piece.  No error checking is performed in here (hopefully, the printer    }
{  is still working after printing out the moves.                            }
{----------------------------------------------------------------------------}
    procedure DumpBoard;
      var row, col : RowColType;
          SqDesc : string20;     {*** square description ***}
          LineDesc : string80;   {*** accumulated output line ***}

      begin
        writeln (PrintFile);
        for row := BOARD_SIZE downto 1 do begin
            {*** separator line ***}
            writeln (PrintFile, '    +--+--+--+--+--+--+--+--+');
            LineDesc := '    |';
            for col := 1 to BOARD_SIZE do begin
                {*** get square description ***}
                SqDesc := PieceAbbrev [Board[row, col].image];
                if SqDesc = ' ' then
                    SqDesc := '  '
                else begin
                    if Board[row, col].color = C_WHITE then
                        SqDesc := SqDesc + 'W'
                    else
                        SqDesc := SqDesc + 'B';
                end;
                {*** add square description to output line ***}
                LineDesc := LineDesc + SqDesc + '|';
            end;
            {*** flush line ***}
            writeln (PrintFile, LineDesc);
        end;
        {*** print final separator line ***}
        writeln (PrintFile, '    +--+--+--+--+--+--+--+--+');
      end; {DumpBoard}

{----------------------------------------------------------------------------}
    begin {PrintGame}
      {*** set the names and abbreviations of the pieces ***}
      PieceName[BLANK]  := '              ';   PieceAbbrev[BLANK]  := ' ';
      PieceName[PAWN]   := 'Pawn          ';   PieceAbbrev[PAWN]   := 'P';
      PieceName[KNIGHT] := 'Knight        ';   PieceAbbrev[KNIGHT] := 'N';
      PieceName[BISHOP] := 'Bishop        ';   PieceAbbrev[BISHOP] := 'B';
      PieceName[ROOK]   := 'Rook          ';   PieceAbbrev[ROOK]   := 'R';
      PieceName[QUEEN]  := 'Queen         ';   PieceAbbrev[QUEEN]  := 'Q';
      PieceName[KING]   := 'King          ';   PieceAbbrev[KING]   := 'K';

      {*** get output file name and open it ***}
      PrintFileName := 'PRN';
      InputFileName ('Print Game to File', PrintFileName);
      assign (PrintFile, PrintFileName);
      rewrite (PrintFile);
      IOerror := IOResult <> 0;
      if not IOerror then begin
          writeln (PrintFile, 'Chess Game Listing - KC Chess');
          IOerror := IOResult <> 0;
      end;
      if not IOerror then begin
          {*** print heading information ***}
          writeln (PrintFile);
          writeln (PrintFile, 'White: ', Player[C_WHITE].Name);
          writeln (PrintFile, 'Black: ', Player[C_BLACK].Name);
          writeln (PrintFile);
          writeln (PrintFile, 'MOVE   COLOR   FROM/TO   PIECE-MOVED   PIECE-TAKEN');
          writeln (PrintFile);
          i := 1;
          {*** print each move; pad fields with blanks to make them line up ***}
          while (not IOerror) and (i <= Game.MovesPointer) do begin
              {*** move number and player to move ***}
              CurMoveNum := i + (Game.MoveNum - 1 - Game.MovesPointer);
              if CurMoveNum mod 2 = 1 then
                  ColorName := 'White'
              else
                  ColorName := 'Black';

              {*** move from/to and piece taken ***}
              Movement := Game.Move[i];
              MoveFromTo := MoveStr (Movement);
              if MoveFromTo = 'PxP EP' then
                  PieceTakenStr := 'Pawn          '
              else
                  PieceTakenStr := PieceName[Movement.PieceTaken.image];
              MoveFromTo := MoveFromTo + Copy ('       ', 1, 10-length(MoveFromTo));

              {*** print move information ***}
              writeln (PrintFile, (CurMoveNum + 1) div 2 : 4, '   ', ColorName, '   ',
                       MoveFromTo, PieceName[Movement.PieceMoved.image], PieceTakenStr);
              IOerror := IOResult <> 0;
              i := i + 1;
          end;
          {*** print final board ***}
          DumpBoard;
          close (PrintFile);
      end;
      {*** report I/O error if any ***}
      if IOerror then begin
          OutTextXY (35, 200, 'I/O Error!!  Press a key.');
          key := ReadKey;
      end;
      {*** redisplay the game board on the main screen after filename ***}
      DisplayBoard;
    end; {PrintGame}

{****************************************************************************}
{*  Load Game:  Given the filename of the file which contains the game to   *}
{*  be loaded, load it and check for I/O errors.  This routine is called    *}
{*  from the file menu.                                                     *}
{****************************************************************************}
  procedure LoadGame (FileName: string80);
    var GameFile: file of GameType;
        LoadGame: GameType;   {*** game loaded ***}
        key: char;
        IOError: boolean;

    begin
      {*** open file using ".CHS" extension ***}
      assign (GameFile, FileName + '.CHS');
      reset (GameFile);
      IOError := true;
      if IOResult = 0 then begin
          {*** get new game ***}
          read (GameFile, LoadGame);
          if IOResult = 0 then begin
              IOError := false;
              close (GameFile);
          end;
      end;
      if IOerror then begin
          {*** report I/O error ***}
          OutTextXY (35, 200, 'I/O Error!!  Press a key.');
          key := ReadKey;
      end else begin
          {*** make the loaded game permanent only if there were no I/O errors ***}
          Game := LoadGame;
          {*** unpack these two variables from the game ***}
          Player := Game.Player;
          Board := Game.FinalBoard;
      end;
    end; {LoadGame}

{****************************************************************************}
{*  Save Game:  Given the filename to use, writes the Game variable to it.  *}
{*  This routine is called from the file menu.                              *}
{****************************************************************************}
  procedure SaveGame (FileName: string80);
    var GameFile: file of GameType;
        key: char;
        IOError: boolean;

    begin
      {*** pack the Player and Board variables into the Game structure ***}
      Game.Player := Player;
      Game.FinalBoard := Board;
      {*** open file for write and check for errors ***}
      assign (GameFile, FileName + '.CHS');
      rewrite (GameFile);
      IOError := true;
      if IOResult = 0 then begin
          {*** save game ***}
          write (GameFile, Game);
          if IOResult = 0 then begin
              IOError := false;
              close (GameFile);
          end;
      end;

      {*** indicate if any I/O errors occured ***}
      if IOError then begin
          OutTextXY (35, 200, 'I/O Error!!  Press a key.');
          key := ReadKey;
      end;
    end; {SaveGame}

{****************************************************************************}
{*  Watch Game:  Display all of the moves in the current game, from the     *}
{*  current move of the game.  If the current move is the last move of the  *}
{*  game, then the game is shown from the beginning.  If the user presses   *}
{*  a key or if all of the moves have been displayed, this routine exits    *}
{*  back to the main menu.                                                  *}
{****************************************************************************}
  procedure WatchGame;
    var Movement : MoveType;
        DummyScore : integer;

    begin
      DisplayInstructions (INS_WATCH);

      {*** go to first move if currently on the last move of the game ***}
      if Game.MovesPointer = Game.MovesStored then begin
          GotoMove (Game.MoveNum - Game.MovesPointer);
          DisplayBoard;
          DisplayConversationArea;
      end;

      {*** display until user hits key or all moves displayed ***}
      while (GetKey = 'n') and (Game.MovesPointer < Game.MovesStored) do begin
          Movement := Game.Move[Game.MovesPointer + 1];
          MakeMove (Movement, false, DummyScore);
          DisplayMove (Movement);
          DisplayWhoseMove;
          Delay (Game.WatchDelay);
      end;
    end;

{****************************************************************************}
{*  User Goto Move:  Inputs the move of the game that the user wants to go  *}
{*  to, and goes there.  This routine is called from the main menu.         *}
{****************************************************************************}
  procedure UserGotoMove;
    var NewMoveNum : integer;
        TempStr : string80;
        Error : integer;
    begin
      {*** instructions, clear board area ***}
      DisplayInstructions (INS_GOTO);
      SetFillStyle (SolidFill, DarkGray);
      Bar (BOARD_X1, BOARD_Y1, BOARD_X2, BOARD_Y2);
      SetColor (Yellow);
      SetTextStyle (DefaultFont, HorizDir, 2);
      OutTextXY (54, 20, 'Goto Move Number');

      {*** get move number and convert to ply number if valid ***}
      Str ((Game.MoveNum + 1) div 2, TempStr);
      UserInput (54, 70, 4, 'Move Number: ', TempStr);
      Val (TempStr, NewMoveNum, Error);
      if Error = 0 then begin
          NewMoveNum := NewMoveNum * 2 - 1;

          {*** get whose turn to go to within move ***}
          if Game.MoveNum mod 2 = 1 then
              TempStr := 'W'
          else
              TempStr := 'B';
          UserInput (54, 100, 1, 'Player''s Turn (B/W): ', TempStr);
          if TempStr = 'B' then NewMoveNum := NewMoveNum + 1;

          {*** go to move ***}
          GotoMove (NewMoveNum);
      end;

      {*** redisplay main screen ***}
      DisplayBoard;
      DisplayConversationArea;
    end;

{****************************************************************************}
{*  File System:  Displays options available in the file menu and gets      *}
{*  user's selection.  Available choices are: D = display Directory of all  *}
{*  chess games in current directory, L = Load game, S = Save game,         *}
{*  P = Print game, and ESC = return to main menu.  This routine is called  *}
{*  by the main menu.                                                       *}
{****************************************************************************}
  procedure FileSystem;
    var Key : char;
    begin
      repeat
          {*** instructions and get selection ***}
          DisplayInstructions (INS_FILE);
          while not KeyPressed do;
          Key := Getkey;
          case Key of
              {*** directory ***}
              'D': begin
                       {*** go back to text mode (cf. hires graphics) ***}
                       RestoreCrtMode;
                       {*** execute the DIR command under MS-DOS command interpreter ***}
                       exec (fsearch('\command.com',getenv('PATH')), '/c dir *.CHS /p');
                       {*** check errors ***}
                       if DosExitCode <> 0 then begin
                           write ('I/O Error!!  Press a key.');
                           key := ReadKey;
                       end;
                       {*** wait until user is finished looking ***}
                       write ('Press any key to return to KC Chess...');
                       key := ReadKey;
                       {*** restore hires graphics mode and redisplay main screen ***}
                       SetGraphMode (GraphMode);
                       DisplayGameScreen;
                   end;

              {*** load ***}
              'L': begin
                       {*** get filename, load, redisplay board ***}
                       InputFileName ('Load Game', DefaultFileName);
                       LoadGame (DefaultFileName);
                       DisplayBoard;
                       DisplayConversationArea;
                       {*** force exit from file menu ***}
                       key := 'x';
                   end;

              {*** save ***}
              'S': begin
                       {*** get filename, save, redisplay board ***}
                       InputFileName ('Save Game', DefaultFileName);
                       SaveGame (DefaultFileName);
                       DisplayBoard;
                       {*** force exit from file menu ***}
                       key := 'x';
                   end;

              {*** print ***}
              'P': PrintGame;
          end;
      until Key = 'x';
    end;


{****************************************************************************}
{*  Main Menu:  Display main menu instructions, get selection, and perform. *}
{*  This routine is called directly from the main routine and represents    *}
{*  all of the time that the user is actually using the game.               *}
{****************************************************************************}
  procedure MainMenu;
    var key : char;
        Movement: MoveType;
        DummyScore : integer;

    begin
      DisplayInstructions (INS_MAIN);
      repeat
          key := GetKey;
          case key of
              {*** RETURN = continue current game ***}
              'e': begin
                       PlayGame;
                       DisplayWhoseMove;  {*** display finish reason ***}
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** N = setup board for New game ***}
              'N': begin
                       DefaultBoard;
                       DisplayBoard;
                       DisplayConversationArea;
                       PlayGame;
                       DisplayWhoseMove;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** S = Setup custom board configuration ***}
              'S': begin
                       SetupBoard;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** T = Take back move ***}
              'T': begin
                       UnMakeMove (Movement);
                       Game.GameFinished := false;
                       DisplayUnMadeMove (Movement);
                   end;

              {*** U = Un-takeback move; only if not currently at end of game ***}
              'U': if Game.MovesPointer < Game.MovesStored then begin
                       {*** get the stored next move ***}
                       Movement := Game.Move[Game.MovesPointer + 1];
                       {*** make the move and display it ***}
                       MakeMove (Movement, false, DummyScore);
                       DisplayMove (Movement);
                       DisplayWhoseMove;
                   end;

              {*** P = set Player info ***}
              'P': begin
                       DisplayInstructions (INS_PLAYER);
                       {*** clear the board area ***}
                       SetFillStyle (SolidFill, DarkGray);
                       Bar (BOARD_X1, BOARD_Y1, BOARD_X2, BOARD_Y2);
                       SetColor (Yellow);
                       SetTextStyle (DefaultFont, HorizDir, 2);
                       {*** title, get info for each player ***}
                       OutTextXY (54, 20, 'Player Info');
                       GetPlayerColorInfo (C_WHITE, 54, 90);
                       GetPlayerColorInfo (C_BLACK, 54, 255);
                       {*** redisplay board and new player info ***}
                       DisplayBoard;
                       DisplayConversationArea;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** O = set game Options ***}
              'O': begin
                       DisplayInstructions (INS_OPTIONS);
                       {*** clear board area ***}
                       SetFillStyle (SolidFill, DarkGray);
                       Bar (BOARD_X1, BOARD_Y1, BOARD_X2, BOARD_Y2);
                       SetColor (Yellow);
                       SetTextStyle (DefaultFont, HorizDir, 2);
                       {*** title and get options ***}
                       OutTextXY (44, 20, 'Options');
                       GetOptions (44, 90);
                       {*** redisplay board and new options ***}
                       DisplayBoard;
                       DisplayConversationArea;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** G = Go to move ***}
              'G': begin
                       UserGotoMove;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** W = Watch game ***}
              'W': begin
                       WatchGame;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** F = enter File menu ***}
              'F': begin
                       FileSystem;
                       DisplayInstructions (INS_MAIN);
                   end;

              {*** H = Help ***}
              'H': begin
                       {*** go back to text mode (cf. hires graphics) ***}
                       RestoreCrtMode;
                       {*** display help information ***}
                       OnlineHelp;
                       {*** restore hires graphics mode and redisplay screen ***}
                       SetGraphMode (GraphMode);
                       DisplayGameScreen;
                       DisplayInstructions (INS_MAIN);
                   end;
          end;
      until key = 'Q';
    end;

{*** end of MENU.PAS include file ***}
