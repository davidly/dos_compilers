PROGRAM BGI;

(* minimal stack and NO, yes NO!, heap size *)

{$M 1024, 0, 0}

(* drag in the BGI *)

USES Graph;

{$L BGIASM.OBJ}

PROCEDURE InitProcVars; EXTERNAL;

PROCEDURE DummyProc; EXTERNAL;

BEGIN
    (* DummyProc will make us return to the Pascal+ graph init code *)
    (* ie. this program never ends *)
    
    DummyProc;
    
    (* we will never get here *)
END.
