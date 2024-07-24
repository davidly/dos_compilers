masm asm;
IF %2==DEBUG GOTO D1
IF %2==debug GOTO D1
IF %2==VIEW GOTO D2
IF %2==view GOTO D2
link  cobol asm %2 %3 %4 %5 %6 %7 %8 %9,%1,,cobol1 cobol2/NOD
GOTO D3
:D1
link  cobol asm %2 %3 %4 %5 %6 %7 %8 %9,%1,,debug cobol1 cobol2/NOD
GOTO D3
:D2
link  cobol asm %2 %3 %4 %5 %6 %7 %8 %9,%1,,view1 view2/NOD
:D3
dir %1.*
