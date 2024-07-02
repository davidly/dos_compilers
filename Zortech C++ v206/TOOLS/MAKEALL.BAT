echo off
if NOT EXIST slist.hpp goto nohdr
del *.obj
make MODEL=S
del *.obj
make MODEL=M
del *.obj
make MODEL=C
del *.obj
make MODEL=L
del *.obj
echo Build Completed
goto ok
:nohdr
echo C++ Tools Header Files required in this directory
:ok
