ntvdm  /r:. -c binb\pas1 %1,%1,%1,%1
ntvdm  /r:. -c binb\pas2
ntvdm  /r:. -c binb\pas3
ntvdm  /r:. -e:lib=lib -c binb\link %1 djldos,%1,%1,,nul.def

ntvdm %1

