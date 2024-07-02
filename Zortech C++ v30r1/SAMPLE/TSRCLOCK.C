/*
                             TSRCLOCK.C

        Demo program for Zortech's Memory Resident C/C++ Toolkit
           (c)1989 Zortech Ltd, written by Kevin Powis.

This is an example of the TIMESLICE facility of the TSR toolkit. If you
press the hot key, you will toggle ON/OFF a clock on the screen. This clock
will run in the background, while you continue to work as normal in the
forground.
*/

#include <disp.h>
#include <dos.h>

/*   ***********************************************  */
/*   >>All programs must have these statements        */
#include <stdio.h>
#include <tsr.h>                    /*must use this */

unsigned TSR_HOTSHIFT = CTRL+LSHIFT;  /* Your hotkey  */
char     TSR_HOTSCAN  = SCAN_Q;       /* combo        */
char tsr_fprint[20] = "tsrclock.v1";  /* unique string*/

/*  >>In addition background programs must have this  */
extern unsigned _tsr_timeslice;

/*   ***********************************************  */

/*   ------------Then enter your program---------     */

union REGS regs;
int cur_pg,cur_s,cur_p;
int toggle=1;
int hours,mins,secs;

main(argc,argv)
int argc;
char **argv;
{
int i;
        if((strncmp(argv[1],"/R",2) ==0)  || (strncmp(argv[1],"/r",2)==0))
        {
             i=tsr_uninstall();
             if(i==0)
                printf("Program removed\n");
             if(i==2)
                printf("Can not remove, Program not loaded!\n");
             if(i==3)
                printf("Can not remove, Another program loaded above\n");
             exit(0);
         }

        printf("Press Control+Left Shift+Q to toggle clock ON/OFF\n");

        i=tsr_install(TIMESLICE+TSR_DEBUG);

                          /* if it returns, error has occured       */
        if(i==1)
           printf("Can not load, program already loaded!\n");
        else
           printf("Failed to install, error %i\n",i);
}

void popmain(popmain)
{
/*      
        POPMAIN is a special "reserved name", function, which the
        TSR routines will pass control to when the hot key is pressed.
*/

	if(_tsr_timeslice==0)			/* if hotkey		*/
	{
		toggle=toggle*-1;		/* set toggle on/off	*/
		return;
	}

	if(toggle<0)				/* only display when on	*/
		return;

	regs.h.ah=0x2c;
	intdos(&regs,&regs);

	if(secs==regs.h.dh)			/* and if secs changed	*/
		return;

	hours=regs.h.ch;
	mins=regs.h.cl;
	secs=regs.h.dh;				/*save_cursor will destroy*/

	save_cursor();
	disp_open();
	disp_move(0,66);
	disp_setattr(14);
	disp_printf("TIME:%2.2i:%2.2i:%2.2i",hours,mins,secs);
	disp_close();
	restore_cursor();
}

save_cursor()
{
     regs.x.ax=15*256;
     int86(0x10,&regs,&regs);
     cur_pg = regs.x.bx;
     regs.x.ax=3*256;
     int86(0x10,&regs,&regs);
     cur_p = regs.x.dx;
     cur_s = regs.x.cx;

     regs.x.dx=(24*256)+80;
     regs.x.ax=2*256;
     regs.x.bx=cur_pg;
     int86(0x10,&regs,&regs);
}

restore_cursor()
{
     regs.x.ax=256;
     regs.x.bx=cur_pg;
     regs.x.cx=cur_s;
     int86(0x10,&regs,&regs);
     regs.x.dx=cur_p;
     regs.x.ax=2*256;
     int86(0x10,&regs,&regs);
}
