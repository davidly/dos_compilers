str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.AXE 2>/dev/null
rm $str.EXE 2>/dev/null

# /n removes array bounds checks and must be after the source file
ntvdm -r:. -u ada $str.ada /n
ntvdm -r:. -u linklib $str

# interpreter runs on the .AXE file
ntvdm -r:. -u -c -p ai $str

# native code. I've found a86 to be buggy.
#    note: a86 produces bad code for the stock ttt.ada so the board is passed as an argument.
#    note2: a86 produces bad code for the stock e.ada so more locals were added to reduce complexity.
ntvdm -r:. -u a86 $str.axe /n
ntvdm -r:. -u -c -p $str.exe
