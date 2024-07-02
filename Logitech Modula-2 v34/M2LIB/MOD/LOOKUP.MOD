(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Search routine for files, according to a default                     *)
(*    strategy. Query is also supported.                                   *)
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


(* $T- *)
(* $R- *)
IMPLEMENTATION MODULE Lookup;           (* LG, Moe, BG, opje, FR *)


  FROM SYSTEM IMPORT ADDRESS, DOSCALL;
  FROM RTSMain IMPORT PSPAddress;


  FROM LogiFile IMPORT File, Open, OpenMode;
  FROM Options IMPORT NameParts, NamePartSet, FileNameAndOptions, Termination;
  FROM Terminal IMPORT Write, WriteString, WriteLn;


  CONST
    null      =  0C ; (* null character                        *)
    separator = ';' ; (* separator beetween pathes in a string *)
    GetCurrentDrive = 19H; (* DOS function number *)

  PROCEDURE CurrentDrive(VAR drive: CHAR);

  BEGIN
    DOSCALL(GetCurrentDrive, drive);
    INC(drive, ORD('A'));


  END CurrentDrive;

  PROCEDURE GetPathEnv(VAR PathEnVar, path: ARRAY OF CHAR; VAR done: BOOLEAN);
    VAR PSPPtr: RECORD
                  CASE CARDINAL OF
                    0: addr: ADDRESS;
                  | 1: offset, base: CARDINAL;
                  | 2: strptr: POINTER TO ARRAY [0..10000] OF CHAR;
                  END;
                END;

        ind,i,envNameLength,i1: CARDINAL;
        found:BOOLEAN;

 
    PROCEDURE CHindex(i:CARDINAL): CHAR;
    BEGIN
      RETURN PSPPtr.strptr^[i];
    END CHindex;
 
  BEGIN (* GetPathEnv *)
    found := FALSE;
    done := TRUE;



    PSPPtr.addr := PSPAddress; 
    INC(PSPPtr.addr,44); (*now we point to the address of the environment*)
    PSPPtr.base := CARDINAL(PSPPtr.addr^);

    PSPPtr.offset := 0; (*now, we are pointing to the environment*)
    envNameLength := 0;
    WHILE (envNameLength <= HIGH(PathEnVar)) AND
          (PathEnVar[envNameLength] <> " ") AND
          (PathEnVar[envNameLength] <> null)
    DO
      INC(envNameLength);
    END;
    DEC(envNameLength);
    ind := 0;
    WHILE ((CHindex(ind) <> null) OR (CHindex(ind+1) <> null)) AND
          (NOT found)
    DO
      i1 := 0;
      WHILE (i1 <> envNameLength) AND (CHindex(i1 + ind) = CAP(PathEnVar[i1])) DO  
        INC(i1);
      END;
      IF CHindex(i1 + ind) = CAP(PathEnVar[i1]) THEN 
        found:=TRUE;
      ELSE
        WHILE (CHindex(ind) <> null) DO  
          INC(ind);
        END;
        IF (CHindex(ind+1) <> null) THEN 
          INC(ind);
        END;
      END;
    END;
    IF found THEN   
      i:=ind+i1+1;
      i1 := 0;
      WHILE (CHindex(i-1) <> null) AND (i1 <= HIGH(path)) DO
        path[i1] := CHindex(i+1);
        INC(i);
        INC(i1);
      END;
      IF CHindex(i-1) <> null THEN
        path[HIGH(path)]:=null; (* path truncated, but ok *)
      END; 
    ELSE
      done := FALSE;
    END; 
  END GetPathEnv;

  PROCEDURE LookupFile(prompt: ARRAY OF CHAR;
                       name: ARRAY OF CHAR;
                       paths: ARRAY OF CHAR;
                       defext: ARRAY OF CHAR;
                       VAR file: File;
                       query, autoquery, acceptoptions: BOOLEAN;
                       VAR effectivename: ARRAY OF CHAR;
                       VAR goodfile: BOOLEAN);

    (* for implementation the modules FileNames, *)
    (* Options and LogiFile are imported         *)

    (* prompt        : string is displayed on terminal *)
    (* name          : for construction of a default file name *)
    (* paths         : drive and paths; separated by separator *)
    (* defext        : default extension of searched file *)
    (* file          : opened file *)
    (* query         : explicit asking for file name *)
    (* autoquery     : switch automatically to mode query if not found *)
    (* acceptoptions : accept options appended to file name *)
    (*                 options are not evaluated *)
    (* effectivename : name of found file *)
    (* goodfile      : lookup was successful *)

    CONST namelength = 128;

    TYPE Text = ARRAY [0..15] OF CHAR;
         FileName = ARRAY [0 .. namelength - 1] OF CHAR;

    VAR fname,dname,lname : FileName;
        lext: ARRAY [0..2] OF CHAR;
        i, ix : CARDINAL; (* some indexes *)

        termstat : Termination; (* termination of a filename read *)

        currentPath: FileName;  (* path with which will searched  *)

        searchPathes: FileName; (* all pathes for search strategy *)
        searchPos: CARDINAL;    (* start position of next path    *)

        searching : BOOLEAN; (* continue with search *)

        lookup, default : BOOLEAN; (* some boolean *)
        done, found : BOOLEAN;

        oldQuery: BOOLEAN; (* to save value of parameter 'query' *)

        ReadName: NamePartSet; (* set of typed parts of the filename *)

    PROCEDURE ErrorMessage(mess: Text);
    BEGIN
      WriteLn;
      WriteString("  ---- ");
      WriteString(mess);
    END ErrorMessage;

(* not used in this version
    PROCEDURE ComparePaths(str1, str2: ARRAY OF CHAR; VAR equal: BOOLEAN);

      VAR i: CARDINAL;
    BEGIN
      i := 0;
      WHILE (i <= HIGH(str1)) AND (str1[i] <> null) AND
            (i <= HIGH(str2)) AND (str2[i] <> null) AND
            (str1[i] = str2[i]) DO
        INC(i);
      END;
      IF (i <= HIGH(str1)) AND (i <= HIGH(str2)) THEN
        equal := str1[i] = str2[i];
      ELSE
        equal := FALSE;
      END;
    END ComparePaths;

    PROCEDURE New(): BOOLEAN;
      (* tests whether currentPath was already in searchPathes *)
      (* to avoid multiple search on same subdirectory         *)
    BEGIN
      RETURN TRUE;
    END New;
*)

    PROCEDURE InitSearch;
      (* initialization for search strategy  *)
      (* build the string 'searchPathes' of  *)
      (* first path of parameter 'paths' and *)
      (* all the pathes that are specified   *)
      (* in the environment that corresponds *)
      (* to the extension 'ext'. the name of *)
      (* the environment variable is m2ext   *)
      (* e.g. 'M2SYM' is the name of the     *)
      (* environment for the symbol files    *)
      VAR i, j, first: CARDINAL;
          envExists: BOOLEAN; (* an environment variable exists *)
          environment: ARRAY [0..4] OF CHAR;
          envPathes: FileName;
    BEGIN
    (* build name of environment *)
      environment[0] := 'M';
      environment[1] := '2';
      FOR ix := 0 TO 2 DO
        environment[ix + 2] := defext[ix];
      END;

    (* copy the pathes of parameter 'paths' to 'searchPathes' *)
      i := 0;
      WHILE (i <= HIGH(searchPathes)) AND (i <= HIGH(paths)) AND
            (paths[i] <> null) DO
        searchPathes[i] := paths[i];
        INC(i);
      END;
      IF i <= HIGH(searchPathes) THEN
        searchPathes[i] := separator;
        INC(i);
      END;

    (* get the pathes of the environment into searchPathes *)
      GetPathEnv(environment, envPathes, envExists);
      IF envExists THEN (* make place for first path *)
        j := 0;
        WHILE (i <= HIGH(searchPathes)) AND (j <= HIGH(envPathes)) AND
              (envPathes[j] <> null) DO
          searchPathes[i] := envPathes[j];
          INC(i);
          INC(j);
        END;
        IF i <= HIGH(searchPathes) THEN
          searchPathes[i] := separator;
          INC(i);
        END;
      END;

      IF i <= HIGH(searchPathes) THEN
        searchPathes[i] := null;
      END;

      searchPos := 0; (* set on beginning of string *)

      IF NOT default THEN
        (* extract filename without path and extension from 'fname' into 'name' *)
     (* skip pathname *)
        i := 0;
        first := 0;
        WHILE (i <= HIGH(fname)) AND (fname[i] <> null) DO
          IF (fname[i] = ':') OR (fname[i] = '\') THEN first := i + 1 END;
          INC(i);
        END;
     (* take filename *)
        i := 0;
        WHILE (i <= HIGH(lname)) AND (first <= HIGH(fname)) AND
              (fname[first] <> '.')  AND (fname[first] <> null) DO
          lname[i] := fname[first];
          INC(i);
          INC(first);
        END;
        IF i <= HIGH(lname) THEN
          lname[i] := null;
        END;
        INC(first);
     (* take extension *)
        i := 0;
        WHILE (i <= HIGH(lext)) AND (first <= HIGH(fname)) AND (fname[first] <> null) DO
          lext[i] := fname[first];
          INC(i);
          INC(first);
        END;
        IF i <= HIGH(lext) THEN
          lext[i] := null;
        END;
      ELSE
        i := 0;
        WHILE (i <= HIGH(lname)) AND (i <= HIGH(name)) DO
          lname[i] := name[i];
          INC(i);
        END;
        IF i <= HIGH(lname) THEN
          lname[i] := null;
        END;
        i := 0;
        WHILE (i <= HIGH(lext)) AND (i <= HIGH(defext)) DO
          lext[i] := defext[i];
          INC(i);
        END;
        IF i <= HIGH(lext) THEN
          lext[i] := null;
        END;
      END;
    END InitSearch;

    PROCEDURE SearchNext(VAR defaultName: ARRAY OF CHAR; VAR done: BOOLEAN);
      VAR
        ix, hix: CARDINAL;
    BEGIN
      done := TRUE;
      ix := 0;
      WHILE (searchPos <= HIGH(searchPathes)) AND
            (ix <= HIGH(currentPath)) AND
            (searchPathes[searchPos] <> separator) AND
            (searchPathes[searchPos] <> null)
      DO
        currentPath[ix] := CAP(searchPathes[searchPos]);
        INC(ix);
        INC(searchPos);
      END;
      IF ix = 0 THEN (* two following separators means current drive *)
        IF (searchPos > HIGH(searchPathes)) OR
           (searchPathes[searchPos] = null)
        THEN
          done := FALSE;
          RETURN;
        ELSE
          CurrentDrive(currentPath[0]);
          currentPath[1] := ':';
          currentPath[2] := null;
        END;
      ELSIF ix <= HIGH(currentPath) THEN
        IF (currentPath[ix-1] <> '\') AND (currentPath[ix-1] <> ':') THEN
          currentPath[ix] := '\';
          INC(ix);
        END;
        IF ix <= HIGH(currentPath) THEN currentPath[ix] := null END;
      END;
      IF (searchPos <= HIGH(searchPathes)) AND
         (searchPathes[searchPos] = separator)
      THEN
        INC(searchPos); (* for separator *)
      END;
(* not used in this version
      IF New() THEN
*)
        (* Build Default FileName *)
        ix := 0;
        WHILE (ix <= HIGH(defaultName)) AND
              (ix <= HIGH(currentPath)) AND
              (currentPath[ix] <> null)
        DO
          defaultName[ix] := currentPath[ix];
          INC(ix);
        END;
(* if a path name was specified, it MUST end in "\" !! *)
        hix := 0;
        WHILE (ix <= HIGH(defaultName)) AND
              (hix < 8) AND (hix <= HIGH(lname)) AND (lname[hix] <> null)
        DO
          defaultName[ix] := lname[hix];
          INC(hix);
          INC(ix);
        END;
        IF ix <= HIGH(defaultName) THEN defaultName[ix] := "."; INC(ix) END;
        hix := 0;
        WHILE (ix <= HIGH(defaultName)) AND (hix <= HIGH(lext)) AND
              (lext[hix] <> null) DO
          defaultName[ix] := lext[hix];
          INC(ix); INC(hix);
        END;
        WHILE ix <= HIGH(defaultName) DO defaultName[ix] := null; INC(ix) END;
(* not used in this version
      ELSE
        SearchNext(defaultName, done);
      END;
*)
    END SearchNext;

  BEGIN
    (* initialisation *)
    searching := TRUE;
    goodfile := FALSE;
    (* search file *)
    oldQuery := query;
    WHILE searching DO
      default := TRUE;
      WriteString ( " " );
      WriteString(prompt);
      lookup := FALSE;
      IF query THEN
        InitSearch;
        SearchNext(dname, done);
        IF NOT done THEN dname := "DK:*.MOD" END;
        WriteString ( ">" ); WriteString ( " " );
        FileNameAndOptions(dname,fname,termstat,acceptoptions,ReadName);
        IF termstat = norm THEN
          Open(file, fname, ReadOnly, done);
          IF NOT done AND (NameDrive IN ReadName) THEN
            ErrorMessage('file not found');
          ELSE
            lookup := TRUE; default := FALSE;
          END;
        ELSIF termstat = esc THEN
          searching := FALSE;
        ELSIF termstat = empty THEN
          IF name[0] <> null THEN
            lookup := TRUE; default := TRUE;
            fname := dname; done := FALSE;
          ELSE
            ErrorMessage("no default file");
          END;
        END;
      ELSE (* NOT query *)
        WriteString ( ":" ); WriteString ( " " );
        lookup := TRUE; default := TRUE;
        fname := dname; done := FALSE;
        searching := FALSE; (* go ahead when file not found *)
      END;
      IF lookup THEN
        IF NOT done THEN
          InitSearch;
          LOOP
            SearchNext(fname, found);
            IF found THEN
              Open(file, fname, ReadOnly, done);
              IF done THEN
                EXIT
              ELSIF query AND 
                    ((ReadName=NamePartSet{}) OR
                     (ReadName=NamePartSet{NameName})) THEN
                default:=TRUE
              END;
            ELSE
              done := FALSE;
              EXIT;
            END;
          END; (* LOOP *)
        END;
        IF done THEN (* file found *)
          IF default THEN (* write file name *)
            IF query THEN
              WriteLn;
              IF HIGH(prompt) >= 14 THEN
                FOR i:=1 TO HIGH(prompt)-14 DO WriteString ( " " ) END;
              END;
              WriteString('     file found : ');
            END;
            WriteString(fname);
          END;
          goodfile := TRUE;
          searching := FALSE;
        ELSE
          IF NOT query THEN WriteString(fname); END;
          ErrorMessage("file not found");
          IF autoquery AND (oldQuery = query) AND NOT oldQuery THEN
            query := TRUE; searching := TRUE;
          END;
        END;
      END;
      IF searching THEN WriteLn END;
    END;  (* WHILE *)
    IF goodfile THEN
      ix := 0;
      WHILE (ix <= HIGH(fname)) AND (ix <= HIGH(effectivename)) DO
        effectivename[ix] := fname[ix];
        INC(ix);
      END;
      IF ix <= HIGH(effectivename) THEN
        effectivename[ix] := null;
      END;
    END;
  END LookupFile;

END Lookup.
