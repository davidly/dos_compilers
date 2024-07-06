BEGIN INTEGER c, dev;

start:
text(1,"Input device ? "); dev:=read(1);
IF dev < 0 OR dev > 10 THEN GOTO start;

REPEAT
	REPEAT c:=chin(dev) UNTIL c#0;
	skip(1); rwrite(1,c,4,0);
	IF c>32 THEN chout(1,c)
UNTIL c=3;
END FINISH
