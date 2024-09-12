PROGRAM UseCHeap;
(*$//CMAIN*)

{$M 4192, 0, 0}

USES CHeap;

VAR
    p : POINTER;
    
BEGIN
    GetMem(p, 50);
    FreeMem(p, 50);
END.
