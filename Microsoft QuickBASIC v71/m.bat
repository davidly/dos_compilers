ntvdm -r:. -c bc %1.bas %1.obj %1.lst /O
ntvdm -r:. -c link %1,,%1,.\,nul.def

