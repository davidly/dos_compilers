program TestWindow;
{$C-}

const
   Windows    = 3;
   Wtab       : array[1..Windows,1..5] of Integer
                = (( 5,  2,  35, 11,  1), { X0,Y0,X1,Y1,LineNo }
                   (45,  2,  75, 11,  1),
                   ( 5, 15,  75, 23,  1)
                  );
type
   String255  = String[255];

var
   i          : Integer;
   Ch         : Char;


   procedure Frame(UpperLeftX, UpperLeftY, LowerRightX, LowerRightY: Integer);
   var
      i: Integer;
   begin
      GotoXY(UpperLeftX, UpperLeftY);  Write(chr(218));
      for i:=UpperLeftX+1 to LowerRightX-1 do Write(chr(196));
      Write(chr(191));
      for i:=UpperLeftY+1 to LowerRightY-1 do
      begin
         GotoXY(UpperLeftX , i);  Write(chr(179));
         GotoXY(LowerRightX, i);  Write(chr(179));
      end;
      GotoXY(UpperLeftX, LowerRightY);
      Write(chr(192));
      for i:=UpperLeftX+1 to LowerRightX-1 do Write(chr(196));
      Write(chr(217));
   end  { Frame };


   function RanStr(Len: Integer): String255;
   var
      S: String255;
      i: Integer;
   begin
      S[0]:=Chr(Len);
      for Len:=1 to Len do
      begin
         repeat  i:=Random(255)  until not (Chr(I) in[^@,^G,^H,^J,^M]);
         S[Len]:=Chr(i);
      end;
      RanStr:=S;
   end  { RanStr };


   procedure SelectWindow(Win: Integer);
   begin
      Window(Wtab[Win,1], Wtab[Win,2], Wtab[Win,3], Wtab[Win,4])
   end  { SelectWindow };


   procedure Window1;
   begin
      LowVideo;
      SelectWindow(1);
      GotoXY(1,1);
      DelLine;
      GotoXY(1, Wtab[1,4]-Wtab[1,2]+1);
      Write('Line ', Wtab[1,5]:5,' ',chr(219),' ',RanStr(15));
      Wtab[1,5]:=Succ(Wtab[1,5]);
      NormVideo;
   end  { Window1 };

   procedure Window2;
   begin
      LowVideo;
      SelectWindow(2);
      GotoXY(1,1);
      DelLine;
      GotoXY(1, Wtab[2,4]-Wtab[2,2]+1);
      Write('Line ', Wtab[2,5]:5,' ',chr(219),' ',RanStr(15));
      Wtab[2,5]:=Succ(Wtab[2,5]);
      NormVideo;
   end  { Window2 };


   procedure Window3;
   begin
      LowVideo;
      SelectWindow(3);
      GotoXY(1,1);
      InsLine;
      WriteLn('Line ', Wtab[3,5]:5,' ',chr(219),' ',RanStr(55));
      Wtab[3,5]:=Succ(Wtab[3,5]);
      NormVideo;
   end  { Window3 };

begin
   GotoXY(15,25);
   Write('TURBO PASCAL Window Demo  -  Press any key to stop');

   for i:=1 to Windows do
      Frame(Wtab[i,1]-1, Wtab[i,2]-1, Wtab[i,3]+1, Wtab[i,4]+1);

   repeat
      Window1;
      Window2;
      Window3;
   until KeyPressed;
   Read(KBD, Ch);
   Window(1,1,80,25);
   GotoXY(1,24);

end.
