del %1.lod
del %1.lnk
del %1.ref
del %1.map
ntvdm m2 comp %1.mod /S- /R- /T-
ntvdm m2 link %1
ntvdm -p m2 %1.lod

