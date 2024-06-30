mc1 %1%
if errorlevel 1 goto skip
mc2 %1%
if errorlevel 1 goto skip
link %1% + cs,, nul.map, mcs
if errorlevel 1 goto skip
del %1%.obj
:skip
                                                                                         