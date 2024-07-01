rem ** compile this with main.bas and digit.bas **
common a(1),n$,b,ln
dec = 0
for i = 0 to (ln-1)
   dec = dec + a(i)*b^i
next
erase a
print "Decimal # = ";dec : print
print "Input 0 for base to end program."
chain "main"

