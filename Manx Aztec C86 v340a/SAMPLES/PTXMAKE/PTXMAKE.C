/*
   PTXMAKE.c by Bill Buckels 1990
   written in AZTEC C small model

   Supported Screen Mode is CGA COLOR TEXT Mode 4.

  This is a companion utility to be used with BSAVED text images
  and with my .PTX fileviewer PTXVU.EXE which was also written for fun.
  I hope this code proves informative to those of you interested in
  computer graphics.

  This is also a limited example of applied "Run Length Encoding."

  The IBM-PC 80- column text screen buffer-attribute pair arrangement
  is suited to a 2-pass crunching algorithm.

  In purely poetic terms....

  Blocks of repeats occur on increments of every second byte so
  I leapfrog through the file using the .PCX encoding technique
  but I skip every second byte, and encode the ascuii value of
  the text character only, then when I am done I make a second
  pass to encode the bytes that have been skipped on first pass,
  encoding the screen attributes.

  Function:

  converts a BASIC BSAVED .BSV IMAGE FILE (full screen CGA text)
  to a .PTX ( similar to the ZSOFT .PCX format image file per the
  VERSION 2.8 STANDARD without Color Map.)


*/

#include <stdio.h>
#include <fcntl.h>
#include <io.h>

#define SCREENSIZE 4000

FILE *ptxfile;


/* type conversion functions */
unsigned char lsb(word)
unsigned int word;
{
	return word &0xff;
}

unsigned char msb(word)
unsigned int word;
{
	return word >>8;
}

unsigned char ptxheader[128];

/* a microsoft compatible bsaved memory image format descriptor */
unsigned char BSV_header[7]={

    '\xfd',          /* ID Flag = file descriptor identifier bsaved file */

   /* afew words about what BASIC does with this header */
   /* and afew words about extending BASIC's ability to */
   /* read and use BINARY files created in this manner. */

    /* BASIC will use original segment and offset information  */
    /* to reload a memory image unless "DEF SEG" has been used */
    /* and then an explicit offset is used as the second arg   */
    /* of the bload command. */

    /* subsequently, once DEF SEG is invoked  */
    /* If an offset is specified without then */
    /* first calling DEF SEG, The image will then be loaded to */
    /* the segment specified in the last segment pointed to    */
    /* by the last call to DEF SEG. DEF SEG without args returns */
    /* to DGROUP (the default data segment) and resets the thing.*/

    /* we can also implement and store an array in memory by use of */
    /* VARSEG and VARPTR to obtain the window for the array's       */
    /* memory location, i.e. override the defaults by windowing     */
    /* to the array base using DEF SEG = VARSEG(arrayname) then to     */
    /* fill the array we would use BLOAD bsaved.bsv, VARPTR(arrayname) */
    /* using VARPTR to point to the offset from the memory base segment*/

    '\x00', '\xb8',  /* base address     = MSB | LSB original segment    */
    '\x00', '\x00',  /* offset from base = MSB | LSB original offset     */

    '\xA0', '\x0F'   /* file size = MSB | LSB of bytes to be loaded +    */
                     /* size of descriptors in bytes (8)                 */
    };

unsigned char BSAVED_tailer[1]={   /* for reference only */
    '\x1A'
    };


int encline(inbuff,inlen)/* encodes a raw line and writes it out */
unsigned char *inbuff;
int inlen;
{
    unsigned char this,last;
    int srcindex,i;
    register int total;
    register unsigned char runcount;
    total=0;
    last = *(inbuff); runcount=1;

for(srcindex=1;srcindex!=inlen;srcindex++){
    this= *(++inbuff);
    if(this==last){
        runcount++;
        if(runcount==63){
            if(!(i=encput(last,runcount)))
            return(0);
            total+=i;
            runcount=0;
        }
    }
    else{
        if(runcount){
            if(!(i=encput(last,runcount)))
            return(0);
            total+=i;
        }
        last=this;
        runcount=1;
      }
   }

if(runcount){
    if(!(i=encput(last,runcount)))
    return(0);
    return(total+i);
    }
    return (total);

}

int encput(byt,cnt)       /* the writer for the encline function */
unsigned char byt,cnt;
{
          if(cnt){
            if((cnt==1)&& (0xc0 != (0xc0 &byt))){
                if(EOF == fputc((int)byt,ptxfile))
                return(0);
                return(1);
            }
            else{
                if(EOF ==fputc((int)0xc0|cnt,ptxfile))
                return(0);
                if(EOF ==fputc((int)byt,ptxfile))
                return(0);
                return(2);
            }
        }
        return(0);

}


/* the zsoft technical reference manual details the */
/* structure of the following header */
int makeheader()
{
    /* makes a standard header for a .PTX CGA FULL-SCREEN TEXT FILE    */
    /* since this info is not really intended for text mode, we fudge  */
    /* some portions of the info, but we try to be faithful as possible*/

    int i;
    unsigned char notzsoft=0,version=3,codetype=1,pixbits=16;
    unsigned int  xmin=0, ymin=0, xmax=79, ymax=24;
    unsigned int  hres=80, vres=25;
    unsigned char no_planes=1;
    unsigned int  bytesperline=160;

    for(i=0;i!=128;i++)ptxheader[i]=0;/* pad the header with nulls */

    ptxheader[0]=notzsoft;
    ptxheader[1]=version;
    ptxheader[2]=codetype;
    ptxheader[3]=pixbits;
    ptxheader[4] =lsb(xmin);
    ptxheader[5] =msb(xmin);
    ptxheader[6] =lsb(ymin);
    ptxheader[7] =msb(ymin);
    ptxheader[8] =lsb(xmax);
    ptxheader[9] =msb(xmax);
    ptxheader[10]=lsb(ymax);
    ptxheader[11]=msb(ymax);
    ptxheader[12]=lsb(hres);
    ptxheader[13]=msb(hres);
    ptxheader[14]=lsb(vres);
    ptxheader[15]=msb(vres);
    ptxheader[65]=no_planes;
    ptxheader[66]=lsb(bytesperline);
    ptxheader[67]=msb(bytesperline);
    return 0;

}

int BSV2PTX(name1, name2)
char *name1, *name2;
{
    unsigned char *scratchbuffer;
    unsigned char *buf;
    char *malloc();

    unsigned char header[7];
    int i,j,k;

    int fh;

    if((fh = open(name1,O_RDONLY)) == -1)return -1;
    read(fh,header,7);

    /* make sure that we have a valid BSAVED file format */
    /* we can only check the first 2-bytes since it may  */
    /* have been made on the HERCULES */

    if(header[0]!=BSV_header[0] || header[1]!=BSV_header[1])
        {
         close(fh);
         return -2;
         }

    printf("BSV2PTX(C) Copyright Bill Buckels 1990-2008. All rights reserved.\n\n");
    printf("Input  File: %s\n",name1);
    printf("Output File: %s\n",name2);

    scratchbuffer= (unsigned char *)malloc(SCREENSIZE);
    buf=(unsigned char *)malloc(SCREENSIZE/2);

    read(fh,scratchbuffer,SCREENSIZE);
    close(fh);

    /* seperate the attribute bytes */
    /* use the two-tank system.     */

    makeheader();
    ptxfile=fopen(name2,"w");
    for(i=0;i!=128;i++)fputc(ptxheader[i],ptxfile);/* write the header */

                for(k=0;k!=2;k++)
                   {
                    j=0;
                    for(i=k;i<SCREENSIZE;i+=2)
                    {
                     buf[j]=scratchbuffer[i];
                     j++;
                     }
                     encline(buf,SCREENSIZE/2);
                     }

            fclose(ptxfile);
            free(scratchbuffer);
            free(buf);
            printf("Done!\n");
            return 0;
}

main(argc,argv)
int argc;
char *argv[];
{
   char buffer[128];
   char  name1[128];
   char  name2[128];
   int status=0;

          switch(argc)
          {
            case 2: strcpy(buffer,argv[1]);

                    while(buffer[status]!=0)
                          {
                            if(buffer[status]=='.')buffer[status]=0;
                            else status++;
                            }

                    strcpy(name1,buffer);
                    strcat(name1,".BSV");
                    strcpy(name2,buffer);
                    strcat(name2,".PTX");

                        status=BSV2PTX(name1,name2);
                        if(status==0)exit(0);

 default: printf("PTXMAKE(C) Copyright Bill Buckels 1990-2008.All rights reserved.\n");
          printf(
 "Usage : \"PTXMAKE [filename]\"\n");
          printf(
          "Converts .BSV BSAVED IMAGES to .PTX PACKED TEXT IMAGES.\n");
          printf("CGA COLOR TEXT mode, screen dumps only.\n");
          }
          exit(0);
}
