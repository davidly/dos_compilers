(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*	  Library module to read a filename, followed by		   *)
(*	  options from the terminal.					   *)
(*                                                                         *)
(*    Release :    Dec 89                                                  *)
(*                                                                         *)
(*    Copyright (C)  1987, 1989 Logitech, All rights reserved              *)
(*                                                                         *)
(*    Permission is hereby granted to registered users to use or abstract  *)
(*    the following program in the implementation of customized versions.  *)
(*    This permission does not include the right to redistribute the       *)
(*    source code of this program.                                         *)
(*                                                                         *)
(***************************************************************************)
(*$T- *)
(*$R- *)
IMPLEMENTATION MODULE Options; 		(* Moe, opje *)
  IMPORT ASCII;
  FROM ASCII IMPORT del, bs, bel, EOL;
  FROM Terminal IMPORT Read, Write, WriteString;
  FROM FileNames IMPORT ReadFileName, FNParts, FNPartSet;


  (* (* definitons from definition module *)

  EXPORT QUALIFIED FileNameAndOptions, GetOption, Termination;

  TYPE Termination = (norm, empty, can, esc);

  (* end definitions *) *)

  CONST separator = '/';
        inpStrMax =  87;

  VAR inpStr: ARRAY [0..inpStrMax] OF CHAR;
      current,last: INTEGER;

  PROCEDURE FileNameAndOptions(default: ARRAY OF CHAR;VAR name: ARRAY OF CHAR;
                               VAR term: Termination; acceptOption: BOOLEAN;
                               VAR ReadInName: NamePartSet);

    (*Read file name and options from terminal.
      Reads until a <cr>, blank, <can>, or <esc> is typped.
      To read the file name a default name can be proposed.
      name returns the read file name.
      term returns the status of the input termination:
          norm   : normally terminated
          empty  : normally terminated, but name is empty
          can    : <can> is typed, input line cancelled
          esc    : <esc> is typed, no file specified.
      If acceptOption is TRUE, then options preceded by '/' will be accepted.*)

    VAR ch,chW: CHAR;
        lastSep: INTEGER;
        RiN: FNPartSet;
  BEGIN
    ReadFileName(name,default,RiN);
    ReadInName := NamePartSet{};
    IF FNDrive IN RiN THEN  INCL(ReadInName, NameDrive)  END;
    IF FNPath  IN RiN THEN  INCL(ReadInName, NamePath)   END;
    IF FNName  IN RiN THEN  INCL(ReadInName, NameName);  END;
    IF FNExt   IN RiN THEN  INCL(ReadInName, NameExt);   END;
(*this line allows default to be true in Lookup! *)
    IF ReadInName=NamePartSet{} THEN term := empty ELSE term := norm END;

    current := 0; last := -1; lastSep := 0;
    Read(ch);
    IF ch = separator THEN Write(' ') END;
    LOOP
      IF ((ch = EOL) OR (ch = ' ')) AND (lastSep <> last) THEN
        EXIT;
      ELSIF ch = ASCII.can THEN
        last := 0;
        term := can;
        EXIT;
      ELSIF ch = ASCII.esc THEN
        last := 0;
        term := esc;
        EXIT;
      END;
      chW := bel;
      IF (last >= 0) OR (acceptOption AND (ch = separator)) THEN
        IF (ch = del) OR (ch = bs) THEN
          chW := del;
          DEC(last); lastSep := 0;
          IF (last >= 0) AND (inpStr[last] = separator) THEN
            lastSep := last;
          END;
        ELSIF last < inpStrMax THEN
          INC(last); chW := ch; ch := CAP(ch);
          IF (ch > 40C ) AND (ch < 177C) THEN
            inpStr[last] := ch;
          ELSIF (chW = separator) AND (lastSep <> last-1) THEN
            lastSep := last;
            inpStr[last] := separator; chW := separator;
          ELSE DEC(last); chW := bel;
          END;
        END;
      END;
      Write(chW);
      Read(ch);
    END; (* LOOP *)
  END FileNameAndOptions;

  PROCEDURE GetOption(VAR optStr: ARRAY OF CHAR; VAR length: CARDINAL);

    (*To be called repeatedly after FileNameAndOptions, until length = 0.
      The characters of the next option are returned in optstr
      (terminated with a 0C character if length <= HIGH(optstr) ). *)

  BEGIN
    INC(current); length := 0;
    IF current <= last THEN
      LOOP
        IF length <= HIGH(optStr) THEN
          optStr[length] := inpStr[current]
        END;
        INC(length);
        IF current = last THEN EXIT END;
        INC(current);
        IF inpStr[current] = separator THEN EXIT END;
      END;
    END;
    IF length <= HIGH(optStr) THEN
      optStr[length] := 0C;
    END;
  END GetOption;

BEGIN (*Options*)
  current := 0; last := 0;
END Options.
