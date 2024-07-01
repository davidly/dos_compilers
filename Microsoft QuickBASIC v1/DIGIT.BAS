rem ** compile this with main.bas and dec.bas **
common a(1),n$,b,ln
m = ln -1
for j = 0 to m
   a$ = mid$(n$,j+1,1)
   if a$ < "A" then a(m-j) = val(a$) _
   else  a(m-j) = asc(a$) - 55 
next
chain "dec"

