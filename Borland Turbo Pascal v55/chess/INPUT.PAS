{****************************************************************************}
{*  INPUT.PAS:  this file contains the routines which involve direct        *}
{*  input from the keyboard.                                                *}
{****************************************************************************}

{****************************************************************************}
{*  Get Key:  return the code for the key the user just typed, or a special *}
{*  code if no keys have been typed.  Letters are converted to uppercase    *}
{*  and the uppercase letter is returned.  Numbers and punctuation are      *}
{*  returned exactly.  The special codes for special keys follows:          *}
{*                                                                          *}
{*    CODE   KEY                CODE   KEY              CODE   KEY          *}
{*    'u'    Cursor Up          'i'    Page Up          'e'    Return       *}
{*    'd'    Cursor Down        'j'    Home             'x'    Escape       *}
{*    'l'    Cursor Left        'k'    End              'b'    Backspace    *}
{*    'r'    Cursor Right       'm'    Page Down        'n'    <no key>     *}
{****************************************************************************}
  function GetKey : char;
    var key : char;
    begin
      if KeyPressed then begin
          key := ReadKey;
          if key = chr(0) then begin
              key := ReadKey;
              {*** special two-character keyboard codes ***}
              case key of
                  'H': key := 'u';
                  'P': key := 'd';
                  'K': key := 'l';
                  'M': key := 'r';
                  'I': key := 'i';
                  'Q': key := 'm';
                  'G': key := 'j';
                  'O': key := 'k';
                  else
                      key := 'n';
              end;
              GetKey := key;
          end else begin
              if (key >='a') and (key <='z') then
                  {*** letters to uppercase ***}
                  GetKey := chr (ord(key) - ord('a') + ord('A'))
              else begin
                  {*** handle special single-character keyboard codes ***}
                  case key of
                      #8 : key := 'b';
                      #13: key := 'e';
                      #27: key := 'x';
                  end;
                  GetKey := key;
              end;
          end;
      end else
          GetKey := 'n';    {*** no key pressed ***}
    end;

{****************************************************************************}
{*  Move Cursor:  moves the 'cursor' around the game board until the user   *}
{*  types a non-cursor key.  Takes the location to initially display the    *}
{*  cursor and returns the final location of the cursor and the non-cursor  *}
{*  key that was typed.  The Update and Color parameters tell if and whose  *}
{*  elapsed time is to be updated while waiting for a key.                  *}
{****************************************************************************}
  procedure MoveCursor (var row, col : RowColType; Color : PieceColorType;
                        Update : boolean; var OutChar : char);
    var key : char;
    begin
      OutChar := '@';
      repeat
          {*** flash the cursor until a key is pressed ***}
          repeat
              if not KeyPressed then begin
                  DisplaySquare (row, col, true);
                  if not KeyPressed then
                      Delay (30);
                  DisplaySquare (row, col, false);
                  if not KeyPressed then
                      Delay (30);
              end;
              key := GetKey;

              {*** update player's elapsed time ***}
              if UpDate then
                  UpDateTime (Color);
          until key <> 'n';

          {*** if cursor key, move cursor; else exit ***}
          case key of
              'j': col := 1;
              'k': col := BOARD_SIZE;
              'i': row := BOARD_SIZE;
              'm': row := 1;
              'u': row := row mod BOARD_SIZE + 1;
              'd': row := (row + BOARD_SIZE -2) mod BOARD_SIZE + 1;
              'l': col := (col + BOARD_SIZE -2) mod BOARD_SIZE + 1;
              'r': col := col mod BOARD_SIZE + 1;
              else OutChar := key;
          end;
      until OutChar <> '@';
    end;

{****************************************************************************}
{*  User Input: given the pixel location, prompt, default value and maximum *}
{*  length, input a string from the user on the hires screen.  The only     *}
{*  editing key is Backspace.  Pressing Return terminates the input.        *}
{****************************************************************************}
  procedure UserInput (Xpos, Ypos, LenLim: integer; Prompt: string80; var InStr: string80);
    var Key : char;

    function Input : char;
      var Key : char;
      begin
        repeat
            while not KeyPressed do;
            Key := GetKey;
        until Key in ['A'..'Z', '0'..'9', '!', '-', '.', 'b', 'e', ' ', ':'];
        Input := Key;
      end;

    begin
      {*** display prompt, default input string, and cursor ***}
      MoveTo (Xpos, Ypos);
      OutText (Prompt + InStr + '_');
      Key := Input;
      while (Key <> 'e') do begin
          if (Key = 'b') then begin
              {*** backspace: move cursor back and delete last character ***}
              if (length (InStr) > 0) then begin
                  InStr := copy (InStr, 1, length (InStr) -1);
                  Bar (GetX - 32, GetY, GetX, GetY + 15);
                  MoveTo (GetX - 32, GetY);
                  OutText ('_');
              end;
          end else
              {*** new char: display and move cursor ***}
              if (length (InStr) < LenLim) then begin
                  Bar (GetX - 16, GetY, GetX, GetY + 15);
                  MoveTo (GetX - 16, GetY);
                  OutText (Key);
                  InStr := InStr + Key;
                  OutText ('_');
              end;
          Key := Input;
      end;
      {*** erase cursor after input ***}
      Bar (GetX - 16, GetY, GetX, GetY + 15);
    end;

{*** end of INPUT.PAS include file ***}
