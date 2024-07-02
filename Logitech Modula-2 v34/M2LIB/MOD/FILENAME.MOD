(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Read a file specification from the terminal.         	 	   *)
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
(*$T-*)
(*$R-*)


IMPLEMENTATION MODULE FileNames; (* Moe *)

  FROM ASCII    IMPORT esc, del, bs, bel, can, EOL;
  FROM Terminal IMPORT Read, ReadAgain, Write;

  FROM SYSTEM   IMPORT DOSCALL;

  CONST
    GetCurrentDrive = 19H; (* dos function number *)



  PROCEDURE FileNameChar (c: CHAR) : CHAR;
    (* Checks if 'c' is legal character for DOS-2.0 filename. *)
    (* Lowercase characters are transformed in uppercase.     *)
    (* Returns 0C if illegal                                  *)
  BEGIN
    CASE c OF
      'A'..'Z', '0'..'9'  : RETURN (c);
    | 'a'..'z'            : RETURN (CAP(c));
    | '$', '&', '#', '@', '!', '%', "'", '`', '(', ')',
      '-', '_', '^', '~'  : RETURN (c);
    | '.', ':', '\'       : RETURN (c); (* for complete pathname *)
    ELSE                    RETURN (0C);
    END;
  END FileNameChar;

  PROCEDURE ReadFileName
           (VAR resultFN: ARRAY OF CHAR; defaultFN: ARRAY OF CHAR;
            VAR ReadInName: FNPartSet);
    VAR

      ch, lastch: CHAR;
      currentDrive: CHAR;
      resultIndex, i: CARDINAL;
      dotFlag: BOOLEAN;
        (* the dot beetween name and extension was encountered *)
      firstBackSlash: CARDINAL;
        (* index of first backslash '\' *)
      nilIndex: CARDINAL;
        (* value to determine unused index: HIGH(resultFN) + 1 *)
      default: BOOLEAN; (* default name taken by typing <CR> *)
      defaultNameBegin: CARDINAL;
        (* position of first character belonging to name of *)
        (* analysed filename                                *)
      defaultExtBegin: CARDINAL;
        (* position of first character belonging to extenstion *)
        (* of analysed filename                                *)
      wildCardFlag: BOOLEAN;
        (* wildcards allowed if one is given in defaultFN *)

    PROCEDURE AnalyseDefault;
      VAR index: CARDINAL;
          ch: CHAR;
    BEGIN
      IF (defaultFN[0] = 'D') AND (defaultFN[1] = 'K') AND  (defaultFN[2] = ':') THEN
        defaultFN[0] := currentDrive;
        FOR index := 1 TO HIGH(defaultFN) - 1 DO
          defaultFN[index] := defaultFN[index+1];
        END;
        defaultFN[HIGH(defaultFN)] := 0C;
      END;
      index := 0;
      defaultNameBegin := 0;
      defaultExtBegin := 0;
      wildCardFlag := FALSE;
      WHILE ((index <= HIGH(defaultFN)) AND (defaultFN[index] <> 0C)) DO
        ch := defaultFN[index];
        IF (ch = ':') OR (ch = '\') THEN
          defaultNameBegin := index + 1;
        ELSIF ch = '.' THEN
          defaultExtBegin := index;
        ELSE
          IF (ch = '*') OR (ch = '?') THEN
            wildCardFlag := TRUE;
          END;
        END;
        INC(index);
      END;
      IF defaultExtBegin = 0 THEN defaultExtBegin := index; END;
    END AnalyseDefault;

    PROCEDURE ExpandFrom(i: CARDINAL);
    BEGIN
      WHILE (resultIndex <= HIGH(resultFN)) AND
            (i <= HIGH(defaultFN)) AND (defaultFN[i] <> 0C) DO
        resultFN[resultIndex] := defaultFN[i];
        Write(resultFN[resultIndex]);
        INC(resultIndex);
        INC(i);
      END;
    END ExpandFrom;

  BEGIN (* ReadFileName *)
    default := FALSE;
    nilIndex := HIGH(resultFN) + 1;
    firstBackSlash := nilIndex;
    resultIndex := 0;
    ReadInName := FNPartSet{FNName, FNExt};
    dotFlag := FALSE;


    DOSCALL(GetCurrentDrive, currentDrive);
    INC(currentDrive, ORD('A'));

    AnalyseDefault;
    LOOP
      LOOP (* get next legal character *)
        Read (ch);
        IF (ch=esc) OR (ch=can) OR (ch=EOL) OR (ch=bs) THEN EXIT END;
        IF (ch >= 40C) AND (ch < 200C) THEN EXIT END;
        Write (bel);
      END;
      IF (ch = esc) OR (ch = can) THEN
        ReadInName := FNPartSet{};
        resultFN[0] := 0C;
        ReadAgain;
        EXIT;
      END;
      IF (ch = EOL) OR (ch = '/') OR (ch = ' ') THEN (* terminator *)
        IF resultIndex = 0 THEN
          ExpandFrom(0);
          default := TRUE;
          ReadInName := FNPartSet{};
        ELSE
          lastch := resultFN[resultIndex - 1];
          IF (lastch = ':') OR (lastch = '\') THEN
            (* copy filename and extension *)
            ExpandFrom(defaultNameBegin);
            ReadInName := ReadInName - FNPartSet{FNName, FNExt};
          ELSIF lastch = '.' THEN (* no extension appended *)
            DEC(resultIndex);
            resultFN[resultIndex] := 0C;
            EXCL(ReadInName, FNExt);
          ELSIF NOT dotFlag THEN (* append dot and extension of defaultFN *)
            ExpandFrom(defaultExtBegin);
            EXCL(ReadInName, FNExt);
          END;
        END;
        IF resultIndex <= HIGH(resultFN) THEN
          resultFN[resultIndex] := 0C;
        END;
        IF (default AND (defaultNameBegin = 0)) OR
           ((NOT default) AND (NOT (FNDrive IN ReadInName)))
        THEN (* take current drive *)
          FOR i := resultIndex TO 0 BY -1 DO
            IF i + 2 <= HIGH(resultFN) THEN
              resultFN[i + 2] := resultFN[i];
            END;
          END;
          resultFN[0] := currentDrive;
          resultFN[1] := ':';
        END;
        ReadAgain;
        EXIT;
      ELSIF (ch = del) OR (ch = bs) THEN
        IF resultIndex = 0 THEN
          dotFlag := FALSE;
          Write (bel);
        ELSE
          Write (del);
          DEC (resultIndex);
          IF resultFN[resultIndex] = '.' THEN
            dotFlag := FALSE;
          ELSIF resultFN[resultIndex] = ':' THEN
            EXCL(ReadInName, FNDrive);
          ELSIF (resultFN[resultIndex] = '\') AND (resultIndex = firstBackSlash) THEN
            EXCL(ReadInName, FNPath);
            firstBackSlash := nilIndex;
          END;
        END;
      ELSE
        IF resultIndex <= HIGH(resultFN) THEN
          IF ((ch = '*') OR (ch = '?')) AND NOT wildCardFlag THEN
            Write(bel);
          ELSE
            IF (FileNameChar(ch) <> 0C) OR (ch = '*') OR (ch = '?') THEN
              IF ch = '.' THEN
                dotFlag := TRUE;
              ELSIF ch = '\' THEN
                (* reset dot flag if directories '..' or '.' specified *)
                dotFlag := FALSE;
                INCL(ReadInName, FNPath);
                IF firstBackSlash = nilIndex THEN
                  firstBackSlash := resultIndex;
                END;
              ELSIF ch = ':' THEN
                INCL(ReadInName, FNDrive);
              END;
              Write (ch);
              resultFN [resultIndex] := ch;
              INC (resultIndex);
            ELSE
              Write(bel);
            END;
          END;
        ELSE
          Write (bel);
        END;
      END; (* IF *)
    END; (* LOOP *)
  END ReadFileName;

END FileNames.
