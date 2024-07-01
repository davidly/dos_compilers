@echo of
if "%CLIB%" == "" goto START
rem this demo uses the cpm emulator
cpm bpic.cmd NO1.BAS h
cpm bpic.cmd NO1.BAS m
cpm bpic.cmd PEANUT1.BAS
cpm bpic.cmd PEANUT2.BAS
cpm bpic.cmd PEANUT3.BAS
cpm bpic.cmd PEANUT4.BAS
cpm bpic.cmd Change.BAS h
cpm bpic.cmd Change.BAS m
goto END
:START
rem this demo uses the dos version 
bpic.com NO1.BAS h
bpic.com NO1.BAS m
bpic.com PEANUT1.BAS
bpic.com PEANUT2.BAS
bpic.com PEANUT3.BAS
bpic.com PEANUT4.BAS
bpic.com Change.BAS h
bpic.com Change.BAS m
:END
