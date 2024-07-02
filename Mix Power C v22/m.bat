ntvdm -r:. pc -f /c /ms /dpowerc /dDOSTIME /j /fi /q %1.c 1>nul 2>nul

ntvdm -r:. pcl %1

del %1.mix 1>nul 2>nul


