UNIT PHeap;
(* this unit should be compiled to an OBJ not a LIB *)
(* and it will only work when used in combination with the alternate *)
(* heap manager Storage *)
(* your $M heap variables should be zero *)

INTERFACE

(* malloc and free are implemented *)
(* you may want to implement other functions as well if necessary *)
(* the storage module should have a function that maps onto most *)
(* anything the C library would have *)

FUNCTION malloc(size : WORD) : POINTER; EXTERNAL '_malloc';

PROCEDURE free(p :  POINTER); EXTERNAL '_free';

IMPLEMENTATION

Uses Storage;

FUNCTION malloc(size : WORD) : POINTER;
VAR
    p : POINTER;
BEGIN
    GetMem(p, size);
    malloc := p;
END;

PROCEDURE free(p :  POINTER);
BEGIN
    (* the storage module ignores the size field unless *)
    (* SetDebug was set to true *)
    (* the amount of memory allocated to p will be deallocated *)
    
    FreeMem(p, 0);
END;

END.
