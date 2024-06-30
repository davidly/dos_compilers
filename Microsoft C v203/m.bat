rem errorlevel can't be used because all 3 apps use the value-less cp/m exit function

del %1.exe 1>nul 2>nul

ntvdm mc1 %1

ntvdm mc2 %1

ntvdm link %1 + cs + gettm,, %1.map, mcs


