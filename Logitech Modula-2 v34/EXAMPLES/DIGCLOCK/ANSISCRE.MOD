IMPLEMENTATION MODULE ANSIScreen;
FROM Terminal IMPORT Write, WriteString;
FROM CardinalIO IMPORT WriteCardinal;

CONST ESC = 33C;

PROCEDURE GotoXY (colon, line : CARDINAL);
(* positions the cursor at the given colon and line *)
BEGIN
  Write (ESC); Write ('[');
  WriteCardinal (line,0);
  Write (';');
  WriteCardinal (colon,0);
  Write ('H');
END GotoXY;

PROCEDURE ClrScr;
(* the screen is erased and the cursor set in the top left corner *)
BEGIN
  Write (ESC); WriteString ('[2J');
  Write (ESC); WriteString ('[H');
END ClrScr;

PROCEDURE SetAttribute (attr : CHAR);
(* all subsequent writing on the screen will use the given attribute
   until it is changed by further calls to this procedure. Any 
   combination of attributes can be obtained by calling SetAttribute
   multiple times. *)
BEGIN
  Write (ESC); Write ('['); Write (attr); Write ('m');
END SetAttribute;

END ANSIScreen.
