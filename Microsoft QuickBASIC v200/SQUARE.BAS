defint a-z
sub square(starta) static
for x = starta to (starta+5)
    for y = (starta) to (starta+5)
        locate x,y:print "*"
    next y
next x
end sub
