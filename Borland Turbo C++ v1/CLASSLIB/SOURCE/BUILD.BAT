echo off
if %1.==.  goto usage
if %1.==all.    build s c m l h
if %1.==ALL.    build s c m l h
:loop
if %1.==s.      goto ok
if %1.==S.      goto ok
if %1.==c.      goto ok
if %1.==C.      goto ok
if %1.==m.      goto ok
if %1.==M.      goto ok
if %1.==l.      goto ok
if %1.==L.      goto ok
if %1.==h.      goto ok
if %1.==H.      goto ok
if %1.==.       goto done
goto error
:ok
  tcc -P -c -m%1 -n..\lib -I..\include *.cpp
  cd ..\lib
  if exist tclass%1.lib del tclass%1.lib 
  tlib tclass%1.lib @..\source\classlib.rsp
  del *.obj
  cd ..\source
  shift
goto loop
:error
echo Error: bad argument %1
goto done
:usage
echo Usage:  BUILD model or all 
echo         where model is any combination of [s c m l h]
echo         Example:  BUILD s l   builds small and large models
echo                   BUILD all   builds all of the memory models
:done



