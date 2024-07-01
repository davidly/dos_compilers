defint a-z

sub tri (startd) static
startrow=10:startcol=startd
for row = 0 to 10
    locate startrow+row,startcol-row
    for x = startcol - row to startcol+row
        locate startrow+row,x
        print "*"
    next x
next row
end sub
