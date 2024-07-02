/*
	Example Program 5b
	
	called from example program 5a to plot a point
*/

#include <dos.h>

#define VIDEO_INT	int86(0x10,&regs,&regs)

union REGS	regs;

plot(int x,int y)
{
	regs.x.ax = 0x0c03;
	regs.x.cx = x;
	regs.x.dx = y;
	VIDEO_INT;
}
