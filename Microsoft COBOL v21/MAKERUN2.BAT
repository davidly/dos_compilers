a:
PAUSE insert disk with MASM.EXE in drive b:
b:masm asm;
PAUSE insert disk with LINK.EXE in drive b:
IF %2==DEBUG GOTO D1
IF %2==debug GOTO D1
IF %2==VIEW GOTO D2
IF %2==view GOTO D2
b:link  cobol asm %2 %3 %4 %5 %6 %7 %8 %9,%1,,b:cobol1 b:cobol2/NOD
GOTO D3
:D1
b:link  cobol asm %3 %4 %5 %6 %7 %8 %9,%1,,b:debug b:cobol1 b:cobol2/NOD
GOTO D3
:D2
b:link  cobol asm %3 %4 %5 %6 %7 %8 %9,%1,,b:view1 b:view2/NOD
:D3
dir %1.*
