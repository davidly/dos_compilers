@ECHO OFF
mode CON COLS=80 LINES=25
IF NOT EXIST TEXTVU.COM GOTO HANDLER
IF NOT EXIST PICSTOO\*.* GOTO HANDLER
CD PICSTOO
GOTO START

This Batchfile Demonstrates feeding an exitcode from
a program into a batchfile to create a menu.

The Program TEXTVU.COM is used to display a text
menu until a key is pressed. The keypress is then
returned to DOS and used to branch a control structure
in a batch file.

Remember to clear all higher errorlevels before capturing
the target keypress since DOS evaluates from high to low
and can't tell a higher key from the target key.

Remember that the ascii value of the key is the same
as the DOS errorlevel.

check for missing files and doit !
:START


IF NOT EXIST SOUP.BSV GOTO HANDLER
IF NOT EXIST STARVE.BSV GOTO HANDLER
IF NOT EXIST STOP.BSV GOTO HANDLER
IF NOT EXIST SUNSHINE.BSV GOTO HANDLER
IF NOT EXIST ALARM.BSV GOTO HANDLER
IF NOT EXIST COMPUTER.BSV GOTO BEGIN

..\textvu COMPUTER.BSV
rem clear all keypresses
IF ERRORLEVEL 28 GOTO BEGIN
rem check if escape was pressed
IF ERRORLEVEL 27 GOTO END
   
:BEGIN
..\textvu SOUP.BSV

   rem clear all keypresses
   IF ERRORLEVEL 52 GOTO BEGIN

   rem evaluate valid keypresses
   IF ERRORLEVEL 51 GOTO THIRD
   IF ERRORLEVEL 50 GOTO SECOND
   IF ERRORLEVEL 49 GOTO FIRST

   rem clear all keypresses
   IF ERRORLEVEL 28 GOTO BEGIN

   rem check if escape was pressed
   IF ERRORLEVEL 27 GOTO END

GOTO BEGIN

:FIRST
 echo 
 ..\textvu STOP.BSV
 
GOTO BEGIN

:SECOND
 echo 
 ..\textvu ALARM.BSV

GOTO BEGIN

:THIRD
 echo 
 ..\textvu SUNSHINE.BSV
 
GOTO BEGIN

:END

..\textvu STARVE.BSV
CLS

:HANDLER
CD ..
