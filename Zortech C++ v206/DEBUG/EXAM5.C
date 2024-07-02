/*
	Example Program 5
	
	Shows how more than one source file is debugged
	'box' is in exam5a
	Demonstrates graphics being debugged, cga and ega
*/

#include <stdio.h>
#include <dos.h>

#define VIDEO_INT	int86(0x10,&regs,&regs)

union	REGS regs;
unsigned old_mode;

int		box(int x,int y,int w,int h);

main()
{
	printf("EXAMPLE 5\n");

/*  get old mode  */

	regs.x.ax = 0x0f00;
	VIDEO_INT;
	old_mode = regs.x.ax&0xff;

/*	set CGA mode  */

	regs.x.ax = 0x0004;									  /*  CGA graphics  */
	VIDEO_INT;

/*	draw some boxes */

	box(0,0,319,199);		    						/*  box the screen  */
	printf("press any key\n");
	getch();

/*  test if EGA present  */

	regs.h.bl = 0x10;
	regs.h.ah = 0x12;
	VIDEO_INT;
	if (regs.h.bl!=0x10) {
	
/*	set EGA mode  */

		regs.x.ax = 0x0010;								  /*  EGA graphics  */
		VIDEO_INT;

/*	draw some boxes */

		box(0,0,639,349);
		printf("press any key\n");
		getch();
	}

/*  restore old mode  */

	regs.x.ax = old_mode;
	int86(0x10,&regs,&regs);

	printf("EXAMPLE 5 finished\n");
	exit(0);
}

