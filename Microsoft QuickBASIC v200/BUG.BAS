tron
defint a-z

for startrow = 1 to 12 step 12
    for startcol = 16 to 64 step 24
        call triangle (startrow,startcol)
    next startcol
next startrow

sub triangle (vertical,horizontal) static
for row = 0 to 10
    locate vertical+row,horizontal-row
    for x = horizontal-row to horizontal+row
        locate vertical+row,x
        print "*"
    next x
next row
end sub
