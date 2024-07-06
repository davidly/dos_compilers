BEGIN INTEGER dev, char;

get dev:
text(1,"*NInput device tester, type number ");
ioc(0); ioc(1); dev := read(1);

IF dev < 1 OR dev > 7 THEN GOTO get dev;

text(1,"Type away*N"); ioc(0); ioc(1);
loop:
char := chin(dev); 
IF NOT (dev = 3 AND char = 0 ) THEN
BEGIN chout(1, char); write(1,char) END;
IF char # 3 THEN GOTO loop;

END FINISH

