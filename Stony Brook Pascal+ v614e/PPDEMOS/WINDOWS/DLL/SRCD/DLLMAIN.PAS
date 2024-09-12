LIBRARY DLLMain;
{$X+}

USES Windows;

VAR
    SaveExit : POINTER;
    
PROCEDURE MyExit; FAR;
CONST
    s : ARRAY [0..0] OF CHAR = (#7);
BEGIN
    ASM
	mov	bx, 1
	mov	ah, 40h
	mov	cx, 1
	mov	dx, offset s
	int	21h
    END;
    ExitProc := SaveExit;
END;

BEGIN
    SaveExit := ExitProc;
    ExitProc := @MyExit;
    ExitCode := 1;
END.
