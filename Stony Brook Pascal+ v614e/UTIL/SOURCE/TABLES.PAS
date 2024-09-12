UNIT Tables;
{$I-}

INTERFACE

Uses Dos;

CONST
    LeftButton	= 0;
    RightButton	= 1;
TYPE
    LogRec =
	RECORD
	key		: WORD;
	MouseX		: WORD;
	MouseY		: WORD;
	MouseB		: SET OF 0..15;
	WasMouse	: BOOLEAN;
	END;

TYPE
    MacroPointer	= ^MacroRec;
    MacroRec	=
	RECORD
	next	: MacroPointer;
	name	: STRING[32];
	data	: STRING;	(* short allocated *)
	END;
	
    BuiltInRec	=
	RECORD
	name	: STRING[8];
	key	: WORD;
	END;
CONST
    MaxBuiltIns	= 54;
    BuiltIns : ARRAY [1..MaxBuiltIns] OF BuiltInRec =
	(
	 (name:'ESC'; key:27),
	 (name:'ENTER'; key:13),
	 (name:'LEFT'; key:331),
	 (name:'RIGHT'; key:333),
	 (name:'UP'; key:328),
	 (name:'DOWN'; key:336),
	 (name:'HOME'; key:327),
	 (name:'END'; key:335),
	 (name:'PGUP'; key:329),
	 (name:'PGDN'; key:337),
	 (name:'INS'; key:338),
	 (name:'DEL'; key:339),
	 (name:'BS'; key:8),
	 (name:'TAB'; key:9),
	 (name:'ALTAKEY'; key:286),
	 (name:'ALTBKEY'; key:304),
	 (name:'ALTCKEY'; key:302),
	 (name:'ALTDKEY'; key:288),
	 (name:'ALTEKEY'; key:274),
	 (name:'ALTFKEY'; key:289),
	 (name:'ALTGKEY'; key:290),
	 (name:'ALTHKEY'; key:291),
	 (name:'ALTIKEY'; key:279),
	 (name:'ALTJKEY'; key:292),
	 (name:'ALTKKEY'; key:293),
	 (name:'ALTLKEY'; key:294),
	 (name:'ALTMKEY'; key:306),
	 (name:'ALTNKEY'; key:305),
	 (name:'ALTOKEY'; key:280),
	 (name:'ALTPKEY'; key:281),
	 (name:'ALTQKEY'; key:272),
	 (name:'ALTRKEY'; key:275),
	 (name:'ALTSKEY'; key:287),
	 (name:'ALTTKEY'; key:276),
	 (name:'ALTUKEY'; key:278),
	 (name:'ALTVKEY'; key:303),
	 (name:'ALTWKEY'; key:273),
	 (name:'ALTXKEY'; key:301),
	 (name:'ALTYKEY'; key:277),
	 (name:'ALTZKEY'; key:300),
	 (name:'ALT1KEY'; key:376),
	 (name:'ALT2KEY'; key:377),
	 (name:'ALT3KEY'; key:378),
	 (name:'ALT4KEY'; key:379),
	 (name:'ALT5KEY'; key:380),
	 (name:'ALT6KEY'; key:381),
	 (name:'ALT7KEY'; key:382),
	 (name:'ALT8KEY'; key:383),
	 (name:'ALT9KEY'; key:384),
	 (name:'ALT0KEY'; key:385),
	 (name:'PARAM1'; key:65001),
	 (name:'PARAM2'; key:65002),
	 (name:'PARAM3'; key:65003),
	 (name:'PARAM4'; key:65004)
	);

VAR
    FirstMacro	: MacroPointer;
    LastMacro	: MacroPointer;
    
PROCEDURE ConstructFileName(pri, def : PathStr; VAR result : PathStr);

PROCEDURE AddMacro(macroText : STRING; line : WORD);

PROCEDURE ReadMacros;

IMPLEMENTATION

VAR
    ReadingMacroFile	: BOOLEAN;
    
PROCEDURE ConstructFileName(pri, def : PathStr; VAR result : PathStr);
VAR
    priPath, defPath : DirStr;
    priName, defName : NameStr;
    priExt, defExt : ExtStr;
BEGIN
    FSplit(pri, priPath, priName, priExt);
    FSplit(def, defPath, defName, defExt);
    
    IF priPath = '' THEN
	result := defPath
    ELSE
	result := priPath;
	
    IF priName = '' THEN
	result := result + defName
    ELSE
	result := result + priName;
	
    IF priExt = '' THEN
	result := result + defExt
    ELSE
	result := result + priExt;
	
END;

PROCEDURE AddMacro(macLine : STRING; line : WORD);
VAR
    i		: WORD;
    l		: WORD;
    nameStart	: WORD;
    nameEnd	: WORD;
    temp	: MacroRec;
    newMac	: MacroPointer;
    mac		: MacroPointer;

    PROCEDURE SkipSpace;
    BEGIN
	WHILE (i <= l) AND ((macLine[i] = ' ') OR (macLine[i] = #9)) DO
	    INC(i);
    END;
BEGIN
    l := Length(macLine);
    i := 1;
    
    SkipSpace;
    
    nameStart := i;
    nameEnd := nameStart;
    WHILE (i <= l) AND (macLine[i] <> '=') DO BEGIN
	IF (nameEnd = NameStart) AND
	   (
	    (macLine[i] = ' ') OR (macLine[i] = #9)
	   )
	THEN
	    nameEnd := i;
	INC(i);
    END;
    IF nameEnd = nameStart THEN
	nameEnd := i;

    INC(i);
    
    SkipSpace;
    
    IF i < l THEN BEGIN
	temp.name := Copy(macLine, nameStart, nameEnd-nameStart);
	temp.data := Copy(macLine, i, l-i+1);
	temp.next := NIL;
	
	FOR i := 1 TO Length(temp.name) DO
	    temp.name[i] := UpCase(temp.name[i]);

	GetMem(newMac, 38+Length(temp.data));
	Move(temp, newMac^, 38+Length(temp.data));
	
	mac := FirstMacro;
	WHILE mac <> NIL DO BEGIN
	    IF mac^.name = newMac^.name THEN BEGIN
		Write('Warning: Duplicate macro at ', line);
		IF ReadingMacroFile THEN
		    WriteLn(' in macro file')
		ELSE
		    WriteLn(' in script file');
		WriteLn(macLine);
	    END;
	    mac := mac^.next;
	END;
	
	IF FirstMacro = NIL THEN
	    FirstMacro := newMac
	ELSE BEGIN
	    LastMacro^.next := newMac;
	END;
	LastMacro := newMac;
    END;
END;

PROCEDURE ReadMacros;
VAR
    f		: Text;
    endOfFile	: BOOLEAN;
    curLine	: WORD;
    macLine	: STRING;
    macName	: PathStr;
    buf		: ARRAY [1..512] OF CHAR;
BEGIN
    FirstMacro := NIL;
    ReadingMacroFile := TRUE;

    ConstructFileName('.MAC', ParamStr(0), macName);

    Assign(f, macName);
    Reset(f);
    IF IOResult() = 0 THEN BEGIN
	SetTextBuf(f, buf, SizeOf(buf));
	curLine := 0;
	REPEAT
	    REPEAT
		endOfFile := Eof(f);
		IF NOT endOfFile THEN BEGIN
		    ReadLn(f, macLine);
		    INC(curLine);
		END;
	    UNTIL endOfFile OR (macLine[1] <> ';') AND (Length(macLine) <> 0);
	    
	    IF NOT endOfFile THEN
		AddMacro(macLine, curLine);

	UNTIL endOfFile;
	Close(f);
    END;
    ReadingMacroFile := FALSE;
END;

END.
