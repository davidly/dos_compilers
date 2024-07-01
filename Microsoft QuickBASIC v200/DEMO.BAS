defint a-z

startrow=1:startcol=16
for row = 0 to 10
    locate startrow+row,startcol-row
    for x = startcol-row to startcol+row
        locate startrow+row,x
        print "*"
    next x
next row

