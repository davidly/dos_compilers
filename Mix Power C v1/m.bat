rem: this will crash because pc.exe trashes its own stack. but that's after it's done

ntvdm pc /c /ms /dpowerc /j /fi /q %1.c 1>nul 2>nul

ntvdm pcl %1

del %1.mix 1>nul 2>nul


