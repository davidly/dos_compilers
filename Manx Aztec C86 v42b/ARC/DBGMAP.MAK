#
#	convert a .DBG file to a .MAP file
#	Paul McClintock April 22, 1987
#

dbgmap.obj : dbgmap.c 
	msc dbgmap /Od /Zd;

dbgmap.exe : dbgmap.obj 
	link dbgmap /line /m;


