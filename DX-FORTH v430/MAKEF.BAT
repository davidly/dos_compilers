rem opts: NOFLOAT NOFSTACK FLOORED NOHIDE
rem opts: EMS= HMS= SMS= FILES=
tasmx /t /dnofstack /d%1 /d%2 /d%3 /d%4 /d%5 /d%6 kernel.asm
tlink /t kernel
kernel.com - 1 fload EXTEND save FORTH-C.EXE bye
tasmx /l /t /d%1 /d%2 /d%3 /d%4 /d%5 /d%6 kernel.asm
tlink /t kernel
kernel.com - 1 fload EXTEND save FORTH-F.EXE bye
forth-f - checking off forget -FP checking on 1 fload EXTEND save FORTH.EXE bye
forth-f - 1 fload SED aka sed EDIT save DX.EXE bye
del kernel.obj
del kernel.map
