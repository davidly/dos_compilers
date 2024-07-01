defint a-z

sub ex (startb,startc) static
size = 5
for x=0 to size
   locate startb+x, startc+x
   print "*"
   locate startb+x, startc+size-x
   print "*"
next x
end sub
