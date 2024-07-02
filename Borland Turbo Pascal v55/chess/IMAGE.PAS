{****************************************************************************}
{*  Get Images:  this is not part of the chess program.  This program reads *}
{*  the text file "PIECES.PAS" and converts the piece images found there    *}
{*  into a format compatible with Turbo Pascal's GetImage and PutImage      *}
{*  graphics routines, such that the images can be displayed on the screen  *}
{*  quickly.  The output file "PIECES.IMG" from this program is read in     *}
{*  when the chess program starts.  To change the piece images, edit the    *}
{*  PIECES.PAS file and then execute this program.                          *}
{****************************************************************************}

program GetImages;
  uses graph, crt;
  const HIGH = 52; WIDE = 52; OFFY = 100; OFFX = 10; SiImageSize = 1500;
  type PieceType = (P_BLANK, P_PAWN, P_BISHOP, P_KNIGHT, P_ROOK, P_QUEEN,
                    P_KING);
       PieceColorType = (C_WHITE, C_BLACK);
       SquareColorType = (S_LIGHT, S_DARK, S_CURSOR);
       SingleImageType = array [1..SiImageSize] of byte;
       ImageType = array [PieceType, PieceColorType, SquareColorType]
                          of SingleImageType;
  var GraphDriver, GraphMode :integer;
      i,j,c :integer;
      InLn   :string[80];
      InFile :TEXT;
      OutFile : file of ImageType;
      ImageStore :ImageType;
      CurPiece   :PieceType;
      schar :char;
  begin
    GraphDriver := VGA;
    GraphMode := VGAHi;
    InitGraph (GraphDriver, GraphMode, '');
    assign (InFile, 'PIECES.TXT');
    reset (InFile);
    readln (InFile, InLn);
    CurPiece := P_BLANK;
    for c := 0 to 6 do begin
        readln (InFile, InLn);
        readln (InFile, InLn);
        SetFillStyle (SolidFill, LightGray);
        Bar (OFFX+c*WIDE,OFFY,OFFX+c*WIDE+WIDE-1,OFFY+HIGH-1);
        Bar (OFFX+c*WIDE,OFFY+HIGH*2,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*3-1);
        SetFillStyle (SolidFill, Brown);
        Bar (OFFX+c*WIDE,OFFY+HIGH,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*2-1);
        Bar (OFFX+c*WIDE,OFFY+HIGH*3,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*4-1);
        SetFillStyle (SolidFill, LightGreen);
        Bar (OFFX+c*WIDE,OFFY+HIGH*4,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*5-1);
        Bar (OFFX+c*WIDE,OFFY+HIGH*5,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*6-1);
        for i := 1 to HIGH do begin
            readln (InFile, InLn);
            InLn := copy (InLn, 5, 52);
            for j := 0 to WIDE-1 do begin
                if copy (InLn,j+1,1) = '*' then begin
                    PutPixel (OFFX+j+c*WIDE,OFFY+i,White);
                    PutPixel (OFFX+j+c*WIDE,OFFY+i+HIGH,White);
                    PutPixel (OFFX+j+c*WIDE,OFFY+i+HIGH*2,Black);
                    PutPixel (OFFX+j+c*WIDE,OFFY+i+HIGH*3,Black);
                    PutPixel (OFFX+j+c*WIDE,OFFY+i+HIGH*4,White);
                    PutPixel (OFFX+j+c*WIDE,OFFY+i+HIGH*5,Black);
                end;
            end;
        end;
        GetImage (OFFX+c*WIDE,OFFY,OFFX+c*WIDE+WIDE-1,OFFY+HIGH-1,
                  ImageStore[CurPiece, C_WHITE, S_LIGHT]);
        GetImage (OFFX+c*WIDE,OFFY+HIGH*2,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*3-1,
                  ImageStore[CurPiece, C_BLACK, S_LIGHT]);
        GetImage (OFFX+c*WIDE,OFFY+HIGH,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*2-1,
                  ImageStore[CurPiece, C_WHITE, S_DARK]);
        GetImage (OFFX+c*WIDE,OFFY+HIGH*3,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*4-1,
                  ImageStore[CurPiece, C_BLACK, S_DARK]);
        GetImage (OFFX+c*WIDE,OFFY+HIGH*4,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*5-1,
                  ImageStore[CurPiece, C_WHITE, S_CURSOR]);
        GetImage (OFFX+c*WIDE,OFFY+HIGH*5,OFFX+c*WIDE+WIDE-1,OFFY+HIGH*6-1,
                  ImageStore[CurPiece, C_BLACK, S_CURSOR]);
       readln (InFile, InLn);
        if CurPiece <> P_KING then
            CurPiece := succ(CurPiece);
    end;
    close (InFile);
    assign (outFile, 'PIECES.IMG');
    rewrite (OutFile);
    write (OutFile, ImageStore);
    close (OutFile);
    SetTextStyle (DefaultFont, HorizDir, 2);
    OutTextXY (0,0,'Press any key to continue...');
    schar := ReadKey;
    RestoreCrtMode;
  end.
