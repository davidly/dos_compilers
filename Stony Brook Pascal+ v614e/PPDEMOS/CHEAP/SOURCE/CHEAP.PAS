UNIT CHeap;
(*$//CODE:L//DATA:M//NOMODINIT//NOOPT:X*)

INTERFACE

(* This GetMem will be used by all units that use this unit *)

PROCEDURE GetMem(VAR a : POINTER; s : WORD);

(* This FreeMem will be uses by all units AND precompiled (RTL) *)
(* units that uses this unit *)
(* This uses undocumented knowledge of how Pascal+ names FreeMem *)

PROCEDURE FreeMem(a : POINTER; s : WORD); EXTERNAL 'SYSTEMP_FREEMEM';

FUNCTION MemAvail() : LONGINT; EXTERNAL 'SYSTEMP_MEMAVAIL';

FUNCTION MaxAvail() : LONGINT; EXTERNAL 'SYSTEMP_MAXAVAIL';

PROCEDURE Mark(VAR p : POINTER); EXTERNAL 'SYSTEMP_MARK';

PROCEDURE Release(p : POINTER); EXTERNAL 'SYSTEMP_RELEASE';

IMPLEMENTATION

FUNCTION malloc(s : WORD) : POINTER
    [C]; FAR; EXTERNAL '_malloc';

PROCEDURE free(a : POINTER)
    [C]; FAR; EXTERNAL '_free';

PROCEDURE GetMem(VAR a : POINTER; s : WORD);
BEGIN
    a := malloc(s);
END;

(* This GetMem is used by all precompiled (RTL) units calling GetMem *)
(* from the RTL *)
(* This uses knowledge of how Pascal+ implements and names GetMem *)
(* i.e. GetMem is implemented differently than it is declared *)

FUNCTION FooGetMem(s : WORD) : POINTER; FAR; PUBLIC 'SYSTEMP_GETMEM';
BEGIN
    FooGetMem := malloc(s);
END;

PROCEDURE FreeMem(a : POINTER; s : WORD);
BEGIN
    free(a);
END;

FUNCTION MemAvail() : LONGINT;
BEGIN
    RunError(204);
END;

FUNCTION MaxAvail() : LONGINT;
BEGIN
    RunError(204);
END;

PROCEDURE Mark(VAR p : POINTER);
BEGIN
    RunError(204);
END;

PROCEDURE Release(p : POINTER);
BEGIN
    RunError(204);
END;

END.
