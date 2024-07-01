rem compile to .obj in the app then link like this:

ntvdm -c link %1,,%1,.\,nul.def
