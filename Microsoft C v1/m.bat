rem errorlevel can't be used because all 3 apps use the value-less cp/m exit function

ntvdm mc1 %1

ntvdm mc2 %1

ntvdm link %1 + c + gettm,, %1.map, mc

