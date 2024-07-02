(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Provides the basic functions, needed by FileSystem,  		   *)
(*    for disk files. Files are implemented on MSDOS 2.0. 		   *)
(*    Drives "A" through "P" and the default drive are     		   *)
(*    supported by this driver. The corresponding medium  		   *)
(*    names are "A".."P" for specific drives and "DK" for		   *)
(*    the default drive.                                  		   *)
(*    In the current implementation, there is a buffer of		   *)
(*    512 bytes per opened file.                         		   *)
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
(* T-*)
(* R-*)


IMPLEMENTATION MODULE DiskFiles;                (* WS, opje, AW *)



  FROM RTSMain IMPORT InstallTermProc;
  FROM SYSTEM IMPORT ADDRESS, DOSCALL, ADR, WORD, CODE, BX, CX, DI, GETREG;
  FROM FileSystem IMPORT File, Command, Response, Flag, FlagSet,
                         MediumType, CreateMedium, FileNameChar,
                         ReadWriteMode, NormalAttribute, ReadOnlyMode,
                         WriteOnlyMode, ExclusiveAccessMode;






  CONST                         
    nul = 0C;
    MaxFiles = 15; (* maximal number of opened files *)
       (* maximum of file handles under DOS, 20 minus 5 predefined *)
       (* Note: this limit could be removed by using dynamic variable
          ****  for the file-descriptors and the buffers.
       *)

    BufSize   = 512; (*bytes per buffer*)

    namelength=79; (*maximum length for full file specification*)

    (* The function calls for the Operating System: *)
    CreateFct = 3CH;
    OpenFct   = 3DH;
    CloseFct  = 3EH;
    ReadFct   = 3FH;
    WriteFct  = 40H;
    DeleteFct = 41H;
    SetPosFct = 42H;
    GetSetAttFct = 43H;
    RenameFct = 56H;



  TYPE

    Buffer = ARRAY [0..BufSize-1] OF CHAR;

    FileStatus = (opened, reading, modifying, writing);

    FileName = ARRAY [0..namelength-1] OF CHAR;

    FileDesc = RECORD
                 inUse: BOOLEAN;
                   (* indicates, if this descriptor is used *)
                 tempFile: BOOLEAN;
                   (* if TRUE, the file will be destroyed upon a close *)


                 FileHandle: WORD;
                   (*used by DOS 2.0 for all calls to an open file*)

                 eofh: CARDINAL;
                   (*high and low parts of eof pointer, used...*)
                 eofl: CARDINAL; (*by length function and by setpos*)
                 FileDesig: FileName; (*actual file specification*)
                 state: FileStatus; (* redundant, derived from "flags" *)
                 owner: CARDINAL;
                   (* program identifier of the current layer,
                      when the file was opened *)
                 written: BOOLEAN;
                   (* TRUE, if the file was once in writing state *)
                 buffer: Buffer;
                   (* its data is the 512 byte block read/written to the file*)
                 count: CARDINAL;
                   (*buffer count so we don't have to emulate CP/M!*)

                 filerec: POINTER TO File;
                   (*actual associated file record*)

               END;

  BufAddr = RECORD
               CASE BOOLEAN OF
                 TRUE: addr: ADDRESS;
               | FALSE: offset,base: CARDINAL
               END
            END;



  VAR
    files:   ARRAY [0..MaxFiles-1] OF FileDesc;
    dosMajor, dosMinor: CHAR;


    dos2 : BOOLEAN; (* will be TRUE if DOS version less than 3.0 *)


(******************************************************************)

PROCEDURE InitDiskSystem;
  VAR i: CARDINAL;
      response: BOOLEAN;
      drive: MediumType;
BEGIN
  (* Install the mediums. 'DK' is the name of the default drive: *)
  CreateMedium ('DK ', DiskFileProc, DiskDirProc, response);
  (* The other 16 drives, supported by MSDOS are 'A' through 'P': *)
  drive[0] := 'A';  drive[1] := ' ';  drive [2] := ' ';
(* MOE Feb 6'86 *)
  FOR i:=0 TO (ORD('Z') - ORD('A')) DO
    CreateMedium (drive, DiskFileProc, DiskDirProc, response);
    INC (drive[0]);
  END;
  (* If the program of this level (usually resident part) terminates,
     we have to remove all the mediums: *)
  InstallTermProc (TerminateLevel);
  FOR i:=0 TO MaxFiles-1 DO
    WITH files[i] DO
      inUse   := FALSE;

      filerec := NIL;

    END;
  END;
END InitDiskSystem;


PROCEDURE TerminateLevel;
  VAR i, result: CARDINAL;
      fAddr:BufAddr;

      (*curProg,*) buflen : CARDINAL;

BEGIN
  (* curProg := RTSMain.curProcess^^.currOverlay^.programLevel; *)
  FOR i := 0 TO MaxFiles-1 DO
    WITH files[i] DO
      IF inUse THEN
        (*IF owner = curProg THEN*)
          (* we have to close it and to free its descriptor *)

          IF filerec <> NIL THEN
            buflen := filerec^.bufind;
            IF (NOT tempFile) AND written AND
               (buflen > 0) AND (buflen <= BufSize) THEN 
              WriteBuffer (files[i], ADR(buffer), buflen, result);
              (* operation: write default buffer, length=bufind.
              *)
            END;
          END;
          DOSCALL(CloseFct,FileHandle,result);
          IF tempFile THEN
            DOSCALL(DeleteFct,ADR(FileDesig),result);
          END;


          inUse := FALSE;
        (*END;*)
      END;
    END; (* WITH *)
  END; (* FOR *)
END TerminateLevel;


(******************************************************************)

MODULE FileOperations;

  IMPORT ADDRESS, ADR, WORD,
         files, File, FileDesc, FileStatus,
         Command, Response, Flag, FlagSet,
         MaxFiles, ReadFct, WriteFct, SetPosFct,
         BufAddr, BufSize, ReadOnlyMode, WriteOnlyMode,

         DOSCALL;



  EXPORT WriteBuffer, DiskFileProc;


PROCEDURE SetError (VAR f: File; errorCode: Response);
BEGIN
  WITH f DO
    res := errorCode;
    eof := TRUE;
    validlength := 0;
    flags := FlagSet {er,ef};
    files[fHint].state := opened;
  END;
END SetError;


PROCEDURE RePos(VAR f:File); 
(* Reposition a file at point before last read *)
(* The effect is that the current position (known by the OS)
   is the one of the first byte in the buffer of DiskFile.
   If later we are going to write the buffer to the file, it
   will be placed there with the right offset.
*)

VAR high, low, n, error: CARDINAL; handle: WORD;


BEGIN
  n:=files[f.fHint].count;
  IF n>0 THEN
    handle := files[f.fHint].FileHandle;


    DOSCALL (SetPosFct, handle, 01, 0,0, high,low, error);
      (* position file at zero offset from current place *)
    IF low<n THEN DEC(high) END;    
(*$R-*)
    low:=low-n;
(*$R=*)
    DOSCALL (SetPosFct, handle, 00, high,low, high,low, error);
      (* position file at absolute position 'high,low' *)

  END
END RePos;

PROCEDURE FPos(VAR f:File);
(* move a file forward to end of last read *)

VAR low, high, error: CARDINAL;
BEGIN  
  low:=f.bufind;
  IF low>0 THEN
    DOSCALL (SetPosFct, files[f.fHint].FileHandle, 01,
             0,low, high,low, error);
             (* move file from current position *)
  END


END FPos;
 
(****************************************************************)

  PROCEDURE WriteBuffer (VAR fDesc: FileDesc; bufptr:ADDRESS; 
                         bufLength: CARDINAL; VAR response: CARDINAL);
    VAR error: CARDINAL;
  BEGIN
    response:=0;
    IF bufLength>0 THEN

      DOSCALL (WriteFct, fDesc.FileHandle, bufLength, bufptr,
               response, error);


      IF error=0 THEN 
        IF response=bufLength THEN 
          response:=0;
        ELSE
          response:=1;
        END;
      ELSE response := error;
      END;
    END;
  END WriteBuffer;

  PROCEDURE ReadBuffer (VAR f: File);
    VAR result, error : CARDINAL;
  BEGIN

    DOSCALL (ReadFct, files[f.fHint].FileHandle, f.buflength, f.bufa, (* AW June 5th, 87 *)
             result, error);


    IF (error<>0) THEN
      IF (error=5) THEN
        f.res:=accesserror;
      ELSE
        f.res:=notdone;
      END;
      f.eof:=TRUE;
      result := 0;
      INCL (f.flags,ef);
    ELSIF (result=0) THEN
      f.eof:=TRUE;
      INCL (f.flags,ef);
    END;
    f.validlength:=result;
    files[f.fHint].count:=result
  END ReadBuffer;


PROCEDURE DiskFileProc (VAR f: File);

  VAR response, error: CARDINAL;

      cposL, cposH : CARDINAL; 


BEGIN
  WITH f DO
    IF fHint >= MaxFiles THEN
      res := paramerror;
      flags := FlagSet {er,ef};
      RETURN;
    END;
    WITH files[fHint] DO
      CASE com OF
          setread:   IF (fMode MOD 8) = WriteOnlyMode THEN
                       SetError( f, accesserror );
                     ELSE
                       res := done;  EXCL (flags, er);
                       CASE state OF
                           opened:  ReadBuffer (f);
                         | reading: INCL(flags, rd); RETURN;
                         | writing, modifying:
                                    WriteBuffer (files[fHint], bufa,
                                      bufind, response);
                                    (* we write the buffer back in any case *)
                                    count := bufind;
                                    IF (response=5) THEN
                                      res:=accesserror; 
                                    ELSIF (response=6) THEN
                                      res:=notdone; 
                                    ELSIF (response <> 0) THEN
                                      res := eom;
                                    ELSE
(* May 24'85 MOE *)
                                      IF bufind >= BufSize THEN
                                        (* current pos is not in the buffer *)
                                        ReadBuffer (f);
                                        bufind:=0; (* as for doio *)
                                      ELSIF (state=modifying) THEN
                                        (* simulate sequential reading: *)


                                        DOSCALL (SetPosFct, FileHandle, 01,
                                          0, validlength-bufind, cposH, cposL, error);
                                          (* set DOS position to the last read
                                             byte in buffer. *)

                                      END;
(* May 24'85 MOE *)
                                    END;
                       END; (* CASE *)
                       IF res = done THEN
                         flags := FlagSet {rd};
                         state := reading;
                         eof := FALSE;
                       ELSE SetError (f, res);
                       END;
                     END;

        |  setwrite: IF (fMode MOD 8) = ReadOnlyMode THEN
                       SetError( f, accesserror );
                     ELSE
                       IF state = reading THEN RePos(f) END;
                       res := done;
                       flags := FlagSet {ef, wr};
                       eof := TRUE;
                       state := writing;
                       written := TRUE;
                       validlength := bufind; (* soft truncate *)
                       (* truncate the file physically! (not yet implem.) *)
                     END;

        | setmodify: IF ( (fMode MOD 8 ) = ReadOnlyMode  ) OR
                        ( (fMode MOD 8 ) = WriteOnlyMode ) THEN
                       SetError( f, accesserror );
                     ELSE
                       res := done;  EXCL (flags, er);
                       IF state = reading THEN RePos(f) END;
                       IF state = opened THEN
                         ReadBuffer (f); RePos(f) (*set file back for write*)
                       END;
                       IF res = done THEN
                         eof := FALSE;
                         flags := FlagSet {rd, wr};
                         state := modifying;
                         written := TRUE;
                       ELSE SetError (f, res)
                       END;
                     END;

        | setopen:   response := 0;
                     IF (wr IN flags) THEN
                       WriteBuffer (files[fHint],bufa,
                         bufind, response);
                       validlength := 0;
                       bufind := 0;
                       (* the buffer will be considered non-initialized *)
                     END;
                     IF (response=5) THEN
                       res:=accesserror;
                     ELSIF (response=6) THEN
                       res:=notdone;
                     ELSIF (response <> 0) THEN  
                       SetError (f, eom);
                     ELSE
                       IF res <> eom THEN
                         (* keep the result 'eom', because the 'setopen' can
                            be used as a sort of flush (force the writing of
                            buffers).
                         *)
                         res := done;
                         eof := FALSE;
                         flags := FlagSet {};
                       END;
                       state := opened
                     END;

        | doio:      IF res <> eom THEN
                       res := done;  EXCL (flags, er);
                     END;
                     IF (wr IN flags) THEN
                       WriteBuffer (files[fHint],bufa,
                         bufind, response);
                       IF (response=5) THEN
                         res := accesserror;
                       ELSIF (response=6) THEN 
                         res:=notdone;
                       ELSIF response <> 0 THEN
                         res := eom
                       ELSE bufind:=0
                       END
                     END;
                     IF (rd IN flags) THEN
                       IF bufind=BufSize THEN
                         bufind:=0
                       END;
                       ReadBuffer (f);
                       IF state=modifying THEN RePos(f) END
                     END;
                     IF res <> done THEN SetError (f, res); END;

        | setpos:    res:=done;  EXCL (flags, er);
                     IF (wr IN flags) THEN
                       WriteBuffer(files[fHint],bufa,bufind,response);
                       IF (response=5) THEN
                         res:=accesserror;
                       ELSIF (response=6) THEN
                         res:=notdone;
                       ELSIF response<>0 THEN 
                         res:=eom 
                       END
                     END;
                     IF res=done THEN
                       bufind:=0;


                       DOSCALL (SetPosFct, FileHandle, 02 (*eof*),
                                0,0, eofh,eofl, error);
                       IF ((lowpos>eofl) AND (highpos=eofh)) OR
                          (highpos>eofh) THEN
                         (*if you tried to position past eof...*)
                         SetError(f,paramerror); (* set the error flags *)
                         highpos:=eofh; (*and reset your call values*)
                         lowpos:=eofl;  (*to position AT eof.*)
                       ELSIF state=writing THEN  (* writing always at EOF *)
                         eof:=TRUE;  INCL (flags, ef);
                       ELSE
                         eof:=FALSE;  EXCL (flags, ef);
                       END;
                       cposH:=highpos; cposL:=lowpos; (* it's easier for compiler! *)
                       DOSCALL (SetPosFct, FileHandle, 00 (*absolute*),
                                cposH,cposL, eofh,eofl, error);

                       IF error <> 0 THEN res:=notdone;
                       ELSIF (rd IN flags) THEN
                         ReadBuffer (f);
                         eof:=FALSE; EXCL(flags,ef);  (* per definition *)
                         IF state=modifying THEN RePos(f) END
                       ELSIF state = writing THEN
                         validlength := bufind; (* soft truncate *)
                         (* truncate the file physically! (not yet implem.) *)
                       END;
                     END;
                     IF res <> done THEN SetError (f, res); END;
                     
        | getpos:

                     DOSCALL (SetPosFct, FileHandle, 01 (*current pos*),
                              0,0,(*offset 0*) highpos,lowpos, error);
                     IF (wr IN flags) THEN
                       (* The physical position is the one of last writing,
                          i.e we have to add the number of bytes in buffer: *)
                       (*$R-  wrap around: *) lowpos:=lowpos+bufind; (*$R=*)
                       IF lowpos<bufind THEN highpos:=highpos+1 END
                     ELSIF (rd IN flags) THEN
                       (* If sequential reading, the physical position is
                          the one of the last byte in buffer: *)
                       IF lowpos < (validlength-bufind) THEN
                         highpos:=highpos-1; (* there is a wrap-around *)
                       END;
                       (*$R-*) lowpos:=lowpos-(validlength-bufind); (*$R=*)
                     END;


                     res := done;  EXCL (flags, er);

        | length:

                     DOSCALL (SetPosFct, FileHandle, 01 (*current pos*),
                              0,0,(*offset 0*) cposH,cposL, error);
                     IF (wr IN flags) THEN
                       (* add the bytes in the buffer to be written: *)
                       (*$R-*) lowpos:=cposL + bufind; (*$R=*)
                       IF lowpos < cposL THEN highpos:=cposH+1;
                       ELSE highpos:=cposH; END
                     END;
                     IF state <> writing THEN
                       DOSCALL (SetPosFct, FileHandle, 02 (*eof*),
                                0,0,(*offset 0*) eofh,eofl, error);
                       IF state = modifying THEN
                         (* take the larger of the 2 pos (current or eof): *)
                         IF eofh > highpos THEN highpos:=eofh; lowpos:=eofl;
                         ELSIF eofh=highpos THEN
                           IF eofl>lowpos THEN lowpos:=eofl END;
                         END;
                       ELSE (* reading or opened *)
                         highpos := eofh; lowpos := eofl;
                       END;
                       DOSCALL (SetPosFct, FileHandle, 00 (*absolute*),
                                cposH,cposL, cposH,cposL, error);
                     END;


                     res:=done;  EXCL (flags, er);

        ELSE  res := notsupported;  INCL (flags, er);
      END; (* CASE *)
    END; (* WITH *)
  END; (* WITH *)
END DiskFileProc;

END FileOperations;


(**********************************************************************)


MODULE DirOperations;
  IMPORT WriteBuffer, ADR, WORD, ADDRESS, 
         CreateFct, OpenFct, CloseFct, DeleteFct, RenameFct, SetPosFct,
         GetSetAttFct, 
         files, Flag, FlagSet, MediumType,
         File, FileName, FileDesc, FileStatus, Command, Response,
         FileNameChar, MaxFiles, nul, BufSize, namelength,
         ReadWriteMode, 
         ExclusiveAccessMode, NormalAttribute,

         DOSCALL, dos2,
         CODE, BX, CX, DI, GETREG;


  EXPORT DiskDirProc;


PROCEDURE GetFreeFile (VAR f: File): BOOLEAN;
BEGIN
  WITH f DO
    fHint := 0;
    LOOP
      IF fHint = MaxFiles THEN
        res := toomanyfiles;
        eof := TRUE;
        validlength := 0;
        flags := FlagSet {er,ef};
        EXIT;
      END;
      IF NOT files [fHint].inUse THEN EXIT; END;
      INC (fHint);
    END;
    RETURN (fHint < MaxFiles);
  END; (* WITH *)
END GetFreeFile;


PROCEDURE SetEmptyName (f:File; fno: CARDINAL; VAR name: ARRAY OF CHAR);
  (* sets the filename for a temporary file in the string "name",
     including drive, filename and type "$$$".
     In the filename is encoded the internal number of the file,
     given in the parameter "fno".
  *)
VAR ind:CARDINAL;
BEGIN
  IF (f.mt[0]="D") AND (f.mt[1]="K") THEN (*default drive*)
    ind:=0
  ELSE
    name[0]:=f.mt[0];
    name[1]:=":";
    ind:=2
  END;
  name[ind+0] := 'T';
  name[ind+1] := 'E';
  name[ind+2] := 'M';
  name[ind+3] := 'P';
  name[ind+4] := CHR (fno DIV 10 + ORD('0'));
    (* we assume that fno < 100 ! *)
  name[ind+5] := CHR (fno MOD 10 + ORD('0'));
  name[ind+6] := '.';
  name[ind+7] := '$';
  name[ind+8] := '$';
  name[ind+9] := '$';
  name[ind+10] := nul;
END SetEmptyName;



PROCEDURE InitFile (VAR f: File);
  (* Initializes "f" and its FileDescriptor to be "opened"
     and positioned at the beginning of the file.
     Undefined are: eof.
  *)
BEGIN
  WITH f DO
    WITH files[fHint] DO
      (* initialise f: *)
      res := done;
      bufa := ADR (buffer);
      validlength := 0;
      buflength := BufSize;
      bufind := 0;
      flags := FlagSet {};
      (* initialise files: *)
      inUse := TRUE;
      owner := 1;               (* 2.05 curProcess^^.sharedId *)
      state := opened;
      written := FALSE;

      filerec := ADR (f);

    END; (* WITH *)
  END; (* WITH *)
END InitFile;


PROCEDURE CreateFile (VAR f: File);
  (* Creates a file on the disk. "f" has to contain a
     valid "fHint" and the corresponding FileDesig has to be
     initialized. Upon return, "f" and its FileDescriptor
     are initialized, except the fields "eof" and "tempFile".
     The caller has to make sure, that a file with the
     same name does not already exist on the same drive.
  *)
  VAR 

      result, error: CARDINAL;
BEGIN
  WITH f DO
    WITH files[fHint] DO


      DOSCALL (CreateFct, ADR(FileDesig), 0(*attributes*),
               result (*handle*), error);

      IF error<>0 THEN
        IF error = 4 THEN
          res := toomanyfiles;
        ELSIF error = 5 THEN
          res := accesserror;
        ELSE
          res:=notdone;         
        END; (* IF *)
        flags:=FlagSet {er, ef};
        eof:=TRUE;
        RETURN;
      END; (* if *)


      FileHandle:=WORD(result);

      InitFile (f);
      fMode   := ReadWriteMode;
      fCreate := TRUE;
      fAttribAfterCreation := fileCreationAttribute;
    END; (* WITH *)
  END; (* WITH *)
END CreateFile;


PROCEDURE RenameTheFile (VAR f: File; newName: ARRAY OF CHAR);
  (* change the name of the existing and open file "f"
     into "newName".
  *)


  VAR names: FileName;
        (* used as local copy to assure that name terminates with 0C *)
      answer, i, result: CARDINAL; empty: BOOLEAN;
      tMode: CARDINAL;

      high, low: CARDINAL;


BEGIN
  (* copy and truncate original name; if truncated it was anyway too long *)
  (* because 'names' holds the longest possible filename under DOS 2.0    *)
  i := 0;
  WHILE (i <= HIGH(newName)) AND (i < HIGH(names)) DO
    names[i] := newName[i];
    INC(i);
  END;
  names[i] := 0C;
  WITH f DO
    IF fHint >= MaxFiles THEN
      res := paramerror;
      INCL(flags, er);
      RETURN;
    END;
    WITH files[fHint] DO
      i:=0;
      WHILE (i#4) AND (names[i]#0C) DO
        i:=i+1
      END;  
      IF (i=0) OR ((names[i-1]=":") AND (names[i]=nul)) THEN
        (* this is a rename into a empty name: *)
        empty := TRUE;
        SetEmptyName (f, fHint, names);
      ELSE
        empty := FALSE;
      END;
      res := notdone; (* initial value; set to done when ok *)
      tMode := ReadWriteMode + ExclusiveAccessMode;

      IF dos2 THEN tMode := tMode MOD 4 END;
      DOSCALL (OpenFct, ADR(names), tMode, answer, result);
      IF result=0 THEN  (* the file exists already *)
        DOSCALL (CloseFct, answer, result);
      ELSE (* let's try to rename it *)
        (* first we get the current DOS-fileposition *)
        DOSCALL (SetPosFct, FileHandle, 01 (*current pos*),
                 0,0,(*offset 0*) high,low, result);
        IF result = 0 THEN
          (* second we close the original file *)
          DOSCALL (CloseFct, FileHandle, result);
          IF result = 0 THEN
            (* then we rename the closed file *)
            DOSCALL (RenameFct, ADR(FileDesig), ADR(names), result);
            IF result = 0 THEN
              FileDesig := names;
              tempFile := empty;
            END;
          END;
          (* re-open the file in any case *)
          IF dos2 THEN fMode := fMode MOD 4 END;
          DOSCALL (OpenFct, ADR(FileDesig), fMode, FileHandle, result);
          IF result = 0 THEN
            DOSCALL (SetPosFct, FileHandle, 00 (*absolute*),
                     high, low, high, low, result);
            IF result = 0 THEN
              res := done; (* we did it *)
            END;
          END;
        END;
      END;


    END;
    IF res <> done THEN
      INCL(flags, er);
    END;
  END; (* WITH *)
END RenameTheFile;


PROCEDURE FileAttribute ( set: BOOLEAN; VAR f: File );

CONST
  PushF = 09CH;
  PopBX = 05BH;
  Carry = 0;
VAR
  cpuFlag     : BITSET;
  localAttrib : CARDINAL;


  result      : CARDINAL;
BEGIN
  WITH f DO
    WITH files[fHint] DO
      IF set THEN

        DOSCALL (GetSetAttFct, ADR(FileDesig), 1, fileAttribute, result);
      ELSE
        DOSCALL (GetSetAttFct, ADR(FileDesig), 0, fileAttribute, result);
      END;
    END;
    res := done;
    IF result<>0 THEN
      CASE result OF
        1   : res := callerror;
      | 2, 3: res := unknownfile;
      | 5   : res := accesserror;
      ELSE    res := notdone;
      END;


      flags := FlagSet {er};
    END;
  END;
END FileAttribute;


PROCEDURE DiskDirProc (VAR f: File; name: ARRAY OF CHAR);
  (* Treats the commands:
       create: "name" is not used, field "mt" in "f" is used instead.
       close : "name" is not used.
       lookup: "name" contains the drive plus filename plus type.
       rename: "name" may be empty, which sets the renamed file
               to be temporary.
       delete: "name" contains the drive plus filename plus type.
  *)
(* June 6'85 V 1.14 begin changes *)


  VAR result, result1, i, namelast: CARDINAL;

BEGIN
  IF (name[0]="D") AND (name[1]="K") AND (name[2]=":") THEN
    i:=3;
    WHILE (i<=HIGH(name)) AND (name[i]#" ") AND (name[i]#0C) DO
      name[i-3]:=name[i];
      INC(i);
    END;
    name[i-3]:=0C;
  END;
(* June 6'85 V 1.14 end changes *)
  namelast:=HIGH(name);
  IF namelast>=namelength THEN namelast:=namelength-1 END;
  WITH f DO
    IF (com = create) OR (com = lookup) OR (com = delete) OR
       (com = createfile) OR (com = openfile) OR
       (com = getattrib ) OR (com = setattrib) THEN
      IF NOT GetFreeFile (f) THEN
        (* the error code is already set in GetFreeFile *)
        RETURN;
      END; (* IF *)
    END;
    IF fHint >= MaxFiles THEN
      res := notdone;
      eof := TRUE;
      flags := FlagSet {er,ef};
      RETURN;
    END;
    WITH files[fHint] DO
      CASE com OF
          createfile,
          create    : 
                  IF (com = create) THEN
                    (* Creates a temporary file, with the name "TEMPXX.$$$"
                       on the drive, specified by "mt" in "f". XX in the
                       filename is the internal filenumber in BCD.
                       If such a file exists already, it is deleted before
                       the new-one is created.
                    *)
                    SetEmptyName (f, fHint, FileDesig);
                    (* we use "mt" from "f"; alternatively we could
                       use the parameter "name", but "mt" is assumed
                       to be a correct name. *)
                  ELSE
                    FOR i:=0 TO namelast DO
                      FileDesig[i]:=name[i];
                    END;
                    IF namelast<HIGH(FileDesig) THEN
                      FileDesig[namelast+1]:=0C;
                    END;
                  END;


                  DOSCALL (DeleteFct, ADR(FileDesig), result);
                  (* delete it, in case it exists already *)

                  CreateFile (f);
                  IF res <> done THEN
                    inUse := FALSE;
                    flags := FlagSet {er,ef};
                    fHint := 0FFFFH; (* for sure not valid *)
                    RETURN;
                  END;
                  tempFile := (com = create);
                  flags := FlagSet {ef}; (* opened state, empty file *)
                  eof := TRUE;

        | close : IF res<>eom THEN res := done; END; (*keep eom indicator*)
                  IF (NOT tempFile) AND (wr IN flags) AND (bufind <> 0) THEN
                    WriteBuffer (files[fHint], bufa,bufind, result);
                    IF (result=5) THEN
                      res:=accesserror;
                    ELSIF (result=6) THEN
                      res:=notdone;
                    ELSIF result <> 0 THEN
                      res := eom; (* usually disk full *)
                    END;
                  END;


                  DOSCALL (CloseFct, FileHandle, result);

                    (* The file is closed, even if there was an error in the
                       last writing, to save the previously written data: *)
                  IF result=6 THEN
                    res := notdone; (* invalid handle *)
                  ELSIF tempFile THEN
                    (* We have to close the file first, the DELETE function
                       frees only the blocks that are marked in the directory.
                    *)


                    DOSCALL (DeleteFct, ADR(FileDesig), result);

                    res := done;
                  ELSIF fCreate THEN
                    fileAttribute := fAttribAfterCreation;
                    FileAttribute( TRUE, f );
                  END;
                  inUse := FALSE;
                  eof := TRUE;
                  flags := FlagSet {ef};
                  IF res<>done THEN INCL (flags,er) END;
                  fHint := 65535; (* -1; *) (* out of usefull range *)

        | openfile,
          lookup  : 
                  res:=done;
                  FOR i:=0 TO namelast DO
                    FileDesig[i]:=name[i];
                  END;
                  IF namelast<HIGH(FileDesig) THEN 
                    FileDesig[namelast+1]:=0C;
                  END;
                  fCreate := FALSE;
                  IF (com = lookup) THEN
                    IF new THEN
                      fMode := ReadWriteMode + ExclusiveAccessMode;

                    ELSE
                      fMode := ReadWriteMode;

                    END;
                  ELSE
                    fMode := fileMode;

                  END;


                  IF dos2 THEN fMode := fMode MOD 4 END;
                  DOSCALL (OpenFct, ADR(FileDesig), fMode, FileHandle, result);
                  IF (result=2) OR (result=18 (*too many file*)) THEN

                    IF (com = lookup) AND new THEN
                      fileCreationAttribute := NormalAttribute;
                      CreateFile(f); (*file not found, create it*)
                      new:=TRUE; (* overlap with fileCreationAttribute !!! *)
                    ELSE
                      res:=notdone (*file not found, no create specified*)
                    END
                  ELSIF result=4 THEN 
                    res:=toomanyfiles;
                    flags:=FlagSet {er,ef};
                    inUse:=FALSE
                  ELSIF result=5 THEN
                    res:=accesserror;
                  ELSIF result#0 THEN
                    res:=notdone;
                  ELSE
                    new:=FALSE;
                    InitFile(f)
                  END;
                  IF res=done THEN
                    flags := FlagSet {}; (* opened state *)
                    eof := FALSE;
                    tempFile := FALSE
                  ELSE
                    inUse := FALSE;
                    flags := FlagSet {er,ef};
                    fHint := 0FFFFH; (* for sure not valid *)
                  END;

        | rename: RenameTheFile (f, name);

        | getattrib,
          setattrib:
                  FOR i:=0 TO namelast DO
                    FileDesig[i]:=name[i];
                  END;
                  IF namelast<HIGH(FileDesig) THEN
                    FileDesig[namelast+1]:=0C;
                  END;
                  FileAttribute( (com = setattrib), f );

        | delete: 
                  FOR i:=0 TO namelast DO
                    FileDesig[i]:=name[i];
                  END;
                  IF namelast<HIGH(FileDesig) THEN
                    FileDesig[namelast+1]:=0C;
                  END;


                  DOSCALL (DeleteFct, ADR(FileDesig), result);

                  flags := FlagSet {ef};
                  eof := TRUE;
                  IF result=2 THEN
                    res := unknownfile;
                    INCL (flags, er);
                  ELSIF result=5 THEN
                    res := accesserror;
                  ELSE
                    res := done;
                  END;
                  inUse := FALSE; (* release the file descriptor *)
                  fHint := 65535; (* some out-of-range value *)
        ELSE      res := paramerror;
      END; (* CASE *)
    END; (* WITH *)
  END; (* WITH *)
END DiskDirProc;

END DirOperations; (*************************************************)


BEGIN
  DOSCALL(30H, dosMajor, dosMinor);
  dos2 := ORD(dosMajor) < 3;


END DiskFiles.
