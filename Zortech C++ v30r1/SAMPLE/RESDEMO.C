/*
        Demo program for Zortech's Memory Resident C/C++ Toolkit
           (c)1989 Zortech Ltd, written by Kevin Powis.
*/
#include <disp.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <bios.h>
#include <dos.h>

/* *********************************************  */
/*     All programs must have these statments     */
/* Define: Hotkey+scan / fingerprint / ok_bigbuf  */

#include <tsr.h>

unsigned TSR_HOTSHIFT = LSHIFT+RSHIFT;
char     TSR_HOTSCAN  = SCAN_D;
char tsr_fprint[20] = "Fingerprint";

/* *********************************************  */

unsigned scbuff[4000];
union REGS regs;

unsigned cur_pg,cur_p,cur_s;
extern int _okbigbuf = 0 ;

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

        printf("Installing...Hot key is Left Shift+Right Shift+D\n");

        i=tsr_install(POPONLY+TSR_DEBUG);

        if(i==1)
           printf("Can not load, program already loaded!\n");
        else
           printf("Failed to install, error %i\n",i);
}

void popmain(void)
{
/*
        POPMAIN is a special "reserved name", function, which the
        TSR routines will pass control to when the hot key is pressed.
*/

        save_cursor();
        disp_open();
        peek(disp_base,0,&scbuff,4000);

        demo4();
        demo1();
        demo2();
        demo3();
        demo4();
        demo5();
        demo6();

        poke(disp_base,0,&scbuff,4000);
        disp_close();
        restore_cursor();
}

demo1()
{
        disp_move(0,0);
        disp_eeop();
        disp_box(0,31,5,5,20,70);
        message(6,16,"Welcome to the Zortech C TSR Toolkit Demo.");
        message(7,25,"Written By Kevin Powis.");
        message(9,12,"Now your C and C++ programs can become popup TSR's.");
        message(10,12,"Choose your own HOT KEY and simply call the supplied");
        message(11,12,"INSTALL and UNINSTALL functions. Your program will");
        message(12,12,"then POP up whenever your chosen hot key is pressed.");

        message(14,12,"Your program can use most of the standard library");
        message(15,12,"functions, just has this demo is doing! All you have");
        message(16,12,"to do is write your program as normal. Then say,");
        message(17,12,"'TSR_INSTALL' and you have your popup.");

        message(19,17,"Press any key to continue with this demo.");

	while(bioskey(1)==0)
		tsr_service();

        bioskey(0);
}

demo2()
{
long fsiz;
char dbuff[200],*p;
char *openerr = "Failed to open ";
char *readerr = "Failed reading ";

int fp,bread;
int down,x;
        dbuff[196]=0;
        disp_box(0,32,10,0,23,79);
        disp_scroll(0,11,1,22,78,7);
        message(11,18,"File Handling Example using normal C functions.");

        fsiz=filesize("C:\\AUTOEXEC.BAT");
        if(fsiz != -1L)
        {
           disp_move(13,19);
           disp_printf("Your AUTOEXEC.BAT file is %ld bytes long.",fsiz);
        }
        else
        {
           disp_move(16,15);
           disp_printf("** This demo needs AUTOEXEC.BAT-not found **");
           goto d2_5;
        }

        fp=open("C:\\AUTOEXEC.BAT",O_RDONLY);
        if(fp==-1)
        {
           perror(openerr);
           goto d2_5;
        }

        down=15;
        while(down<22)
        {
           fsiz=lseek(fp,0L,SEEK_CUR);
           bread=read(fp,&dbuff,195);
           if(bread==-1)
           {
              perror(readerr);
              break;
           }

           x=0;
           p=&dbuff[0];
           while((*p++!=10) &&( x<74))
           {
             x+=1;
           }
           *p=0;
           x+=1;

           fsiz+=x;
           lseek(fp,fsiz,SEEK_SET);

           disp_move(down,3);
           disp_printf(dbuff);
           down+=1;
         }

d2_5:
         close(fp);
         message(22,25,"Press any key to continue.");
         while(bioskey(1)==0)
              tsr_service();

         bioskey(0);

}

demo3()
{
double one,onea,two;
int three;
long four,five;
        disp_box(0,5,4,15,20,55);
        disp_scroll(0,5,16,19,54,7);
        message(5,24,"Floating Point Example.");

        disp_move(7,17);
        one=3.1415926;
        two=exp(one);
        disp_printf("EXP(%f)     = %f",one,two);

        disp_move(8,17);
        one=-1.0;
        two=fabs(one);
        disp_printf("FABS(%f)   = %f",one,two);

        disp_move(9,17);
        one=floor(4.8);
        disp_printf("FLOOR(4.8)        = %f",one);

        disp_move(10,17);
        one=5.0;
        two=3.0;
        disp_printf("FMOD (%.2f, %.2f) = %f",one,two,fmod(one,two));

        disp_move(11,17);
        one=15.3;
        two=frexp(one,&three);
        disp_printf("FREXP(%f)  = %f",one,two);

        disp_move(12,17);
        one=123;
        two=456;
        disp_printf("HYPOTenuse (%f, %f)",one,two);
        disp_move(12,35);
        disp_printf("=%f",hypot(one,two));

        disp_move(13,17);
        four=-31459L;
        five=labs(four);
        disp_printf("LABS (%ld)     = (%ld)",four,five);

        disp_move(14,17);
        one=1,5;
        three=5;
        two=ldexp(one,three);
        disp_printf("LDEXP (%f %d)=%f",one,three,two);

        disp_move(15,17);
        one=-41.56789;
        two=modf(one,&onea);
        disp_printf("MODF(%f) f=%f",one,two);
        disp_move(16,17);
        disp_printf("                 i=%f",onea);

        disp_move(19,21);
        disp_printf("Press any key to continue.");

        while(bioskey(1)==0)
              tsr_service();

        bioskey(0);
}

demo4()
{
int tc,tr,bc,br,attr,delay,delayval;
       tr=12;
       tc=39;
       bc=41;
       br=14;
       attr=0;
       delayval=1000;

       disp_move(0,0);
       disp_eeop();

       while(tr>1)
       {
           if(disp_base==0xb800)
              attr+=1;
           else
              attr=2;

           disp_box(0,attr,tr,tc,br,bc);
           tr-=1;
           tc-=2;
           bc+=2;
           br+=1;
           for(delay=0;delay<delayval;++delay)
           {
           }
       }
}

demo5()
{
struct FIND *p;
int cnt;
       disp_printf("Directory of current drive...\n");
       p=findfirst("*.*",0);
dodir:
       cnt=0;
       while((p) && (cnt<23))
       {
              disp_printf(" %s\n",p->name);
              p=findnext();
              cnt++;
       }

       if(cnt==23)
       {
            disp_printf("Press any key..");

            while(bioskey(1)==0)
                  tsr_service();

            bioskey(0);
            disp_scroll(0,1,0,24,15,7);
            disp_move(1,0);
            goto dodir;
       }

       disp_printf("Press any key..");

       while(bioskey(1)==0)
             tsr_service();

       bioskey(0);

}

demo6()
{
int result;

       disp_box(1,4,10,20,12,60);
       disp_scroll(0,11,21,11,59,4);
       message(11,32,"Unload TSR? (Y/N)");

       while((result != 'Y') && (result != 'N'))
       {
          result=toupper((bioskey(0)&0xff));
       }

       if(result=='Y')
       {
           result=tsr_uninstall();
           disp_scroll(0,11,21,11,59,4);

           if(result==0)
              message(11,27,"TSR Removed OK - Press a key");
           else
              message(11,25,"Unable to Remove - Press a key");

           while(bioskey(1)==0)
                 tsr_service();

           bioskey(0);
       }
}

message(x,y,mess)
int x,y;
char *mess;
{
       disp_move(x,y);
       disp_printf(mess);
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


