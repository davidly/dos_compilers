/*
	Example Program 5a
	
	called from example program 5 to draw a box
		plot is in exam5b
*/

int		plot(int x,int y);

int		box(int x,int y,int w,int h)
{
	int		i;

	while (w>0&&h>0) {
		for (i=x;i<x+w;i++) plot(i,y);
		for (i=y+1;i<y+h;i++) plot(x,i);
		for (i=x;i<x+w;i++) plot(i,y+h-1);
		for (i=y+1;i<y+h;i++) plot(x+w-1,i);
		w -= 40;
		h -= 20;
		x += 20;
		y += 10;
	}
}

