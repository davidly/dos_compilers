/*
	Simple example program showing the use of assembler modules
	mixed with C modules. The function gotoxy is written in assembler.
*/

#include <stdio.h>

void	gotoxy(int y,int x);		 /*  assembler function in exam6a.asm  */

int		loop,x,y;

main()
{

	printf("EXAMPLE 6\n");
	for (loop=0;loop<10;loop++) {
		for (y=0;y<25;y++) gotoxy(y,0);
		for (x=0;x<80;x++) gotoxy(24,x);
		for (y=24;y>=0;y--) gotoxy(y,79);
		for (x=79;x>=0;x--) gotoxy(0,x);
	}
	printf("EXAMPLE 6 finished\n");
	exit(0);
}
