/* loader and demo for .ANS, .TXT, .PTX, or .BSV files in aztec C */
/* TEXTVU.c by bill buckels 1990 */

/* these files can be created in the THEDRAW or in GWBASIC, etc.   */
/* this program turns off the cursor, loads the file, waits for a  */
/* key press then turns the cursor on and returns the key value as */
/* an exit code. can be used as a slide show driver or batch menu. */

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <io.h>

#define SCREENSIZE 4000
unsigned int SCREENSEG= 0xb000;

/* this macro converts a base and offset to a far pointer */
#define MK_FP(seg,off) ((char far *)(((long)(seg) << 16) | (off)))

struct regs{
    int AX;
    int BX;
    int CX;
    int DX;
    int SI;
    int DI;
    int DS;
    int ES;
}inregs,outregs;

main(int argc, char **argv)
{
    int fh,i;
    static char far *crt;
 
    unsigned int byteoff=0,secondoff=1,packet;
    unsigned char byte,bytecount;
    int wordcount,target;
    unsigned char *databuf;
    char combuffer[128];
    unsigned int status = 0;

    
    sysint(0x11,&inregs,&outregs); /* get equipment list from the bios */
    /* get display type (bits 4 and 5 of ax) */
    if ((outregs.AX & 0x30) < 0x30)SCREENSEG=0xb800;


switch(argc)
{
    case 2:

    crt = MK_FP(SCREENSEG,0x0000);
    databuf=malloc(SCREENSIZE);

               /* clearscreen and turn cursor off */
                      system("cls");
                      inregs.AX = 0x0100;
                      inregs.CX = 0x2000;
                      sysint(0x10,&inregs,&outregs);

    fh = open(argv[1],O_RDONLY);
    read(fh,databuf,7);

    /********************* beginning of run raw ******************/
    if(databuf[0]== '\xfd' && databuf[1]== 0)
    {
     read(fh,databuf,SCREENSIZE);
     close(fh);
     i=SCREENSIZE+1;
     while(i-->0)*crt++=*databuf++;
     status++ ;
     }

  /******************** beginning of run length encoded *************/

 if(databuf[0]==0 && databuf[1]==3 && databuf[2]==1 && databuf[3]==16)
    {
     status++;
     read(fh,databuf,121);/* blow the rest of the header */
     target = read(fh,databuf,SCREENSIZE);
     close(fh);

    wordcount=0;
    do{ bytecount=1;                          /* start with a seed count */
        byte=databuf[wordcount];
        wordcount++;
                                              /* check to see if its raw */
        if(0xC0 == (0xC0 &byte)){             /* if its not, run encoded */
                    bytecount= 0x3f &byte;
                    byte=databuf[wordcount];
                    wordcount++;
                    }
        for(packet=0;packet<bytecount;packet++){
                   if(byteoff<SCREENSIZE){
                        crt[byteoff]=byte;
                        byteoff+=2;
                        }
                   else{
                        crt[secondoff]=byte;
                        secondoff+=2;
                        }
                    }
                     
        }while(wordcount<target);
        }

       /****************** begin run cooked ******************/
   if(status==0)
        {
            sprintf(combuffer,"TYPE %s",argv[1]);
            system(combuffer);
         }

   free(databuf);

   /*********** then wait for a key press ****************/

                      inregs.AX = 0x0000;
                      inregs.DX = 0x0000;
                      sysint(0x16,&inregs,&outregs);
                     /* use sysint to generate int 16h */
                     /* return the low order char */
                     status = outregs.AX&0x00ff;

                     /* turn cursor on */
                      inregs.AX = 0x0100;
                      inregs.CX = 0x0607;
                      sysint(0x10,&inregs,&outregs);

            default: exit(status);
             }

}

