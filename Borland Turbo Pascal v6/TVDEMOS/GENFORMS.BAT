ECHO OFF
REM ===============================================================
REM This batch file generates two forms data files, PHONENUM.TVF
REM and PARTS.TVF. These can be loaded and edited using TVFORMS.PAS
REM ===============================================================
ECHO Generating data files for TVFORMS demo program...
tpc /m /q /dPHONENUM genform
IF ERRORLEVEL 1 GOTO CompilerError
genform
IF ERRORLEVEL 1 GOTO RuntimeError
tpc /m /q /dPARTS genform
IF ERRORLEVEL 1 GOTO CompilerError
genform
IF ERRORLEVEL 1 GOTO RuntimeError

GOTO Success

:CompilerError
ECHO Error encountered trying to make GENFORM.PAS
GOTO Success

:RuntimeError
ECHO Error trying to run GENFORM.EXE
GOTO Success

:Success
