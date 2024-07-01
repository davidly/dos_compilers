def fndegrad(d,m,s)
   pi = 3.14159263
   d = d + m/60 + s/3600
   fndegrad = d * (pi/180)
end def
deg = 45:min = 10
print tab(5);"Angle measurement";tab(38);"SINE"
print:print
for sec = 0 to 50 step 10
   print tab(5);deg;chr$(248);",";min;"',";sec;chr$(34);
   rad = fndegrad(deg,min,sec)
   print tab(35);sin(rad)
next
