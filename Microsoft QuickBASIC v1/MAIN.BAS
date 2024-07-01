rem ** compile this with digit.bas and dec.bas **
common a(1),n$,b,ln
input "base,number:  ",b,n$
print
while b
   ln = len(n$)
   dim a(ln)
   chain "digit"
wend
end

