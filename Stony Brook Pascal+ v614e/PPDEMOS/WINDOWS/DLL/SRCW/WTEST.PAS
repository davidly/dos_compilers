PROGRAM wtest;
{$M 8192}

USES Crt, Body;

VAR
    ch : CHAR;
BEGIN
    WriteLn('Hello World');
    ch := ReadKey;
    DLLPROC;
    WriteLn('ending');
    ch := ReadKey;
END.
