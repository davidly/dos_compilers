MODULE DigClock;

FROM ANSIScreen IMPORT 
     ClrScr, GotoXY, SetAttribute, Reverse, Normal;
FROM TimeDate IMPORT 
     GetTime, TimeToString, Time;
FROM Terminal IMPORT
     KeyPressed, Write, WriteString, Read;

   CONST CornerX   = 29; (* X coordinate of upper left corner  *)
         CornerY   = 15; (* Y coordinate of upper left corner  *)
         SecPos  = 16; (* index of the seconds in the string *)

   VAR actualTimeDate : Time;
       ch, oldSeconds : CHAR;
       timeString     : ARRAY [0..17] OF CHAR;


BEGIN  (* Example2 *)
  ClrScr;
  SetAttribute (Reverse);
  GotoXY (CornerX, CornerY);   WriteString ("ษอออออออออออออออออออป");
  GotoXY (CornerX, CornerY+1); WriteString ("บ                   บ");
  GotoXY (CornerX, CornerY+2); WriteString ("ศอออออออออออออออออออผ");
  SetAttribute (Normal);
  GotoXY (54,25); (* set cursor to bottom right corner *)
  WriteString (" press any key to exit...");
  oldSeconds := ' '; (* set to any non-digit *)
  REPEAT
    GetTime (actualTimeDate);
    TimeToString (actualTimeDate, timeString);
    IF timeString[SecPos] <> oldSeconds THEN
      (* update screen only if seconds have changed *)
      GotoXY (CornerX+2, CornerY+1);
      WriteString (timeString);
      (* place a separation between date and time: *)
      SetAttribute (Reverse);
      GotoXY (CornerX+10, CornerY+1);
      Write (' ');
      SetAttribute (Normal);
      GotoXY (80,25); (* get cursor out of way *)
      oldSeconds := timeString[SecPos];
    END;
  UNTIL KeyPressed();
  Read (ch); (* clear the keyboard buffer *)
  ClrScr;    (* and the screen            *)
END DigClock.
