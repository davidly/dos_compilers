/*
   BSAVEINC.c by Bill Buckels 1990
   written in AZTEC C small model

   Supported Screen Mode is CGA COLOR TEXT Mode 4.

  This is a companion utility to be used with BSAVED text images
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
  to a .inc inlude file for a C program in the form of character array.
  ( similar to the ZSOFT .PCX format image file per the
  VERSION 2.8 STANDARD without Color Map.)


*/

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <io.h>

#define SCREENSIZE 4000

FILE *incfile;

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


int linelen=0;
int encput(byt,cnt)       /* the writer for the encline function */
unsigned char byt,cnt;
{
          if(linelen>16){
                      fprintf(incfile,"\n");
                      linelen=0;
                      }

          if(cnt){
            if((cnt==1)&& (0xc0 != (0xc0 &byt))){
                fprintf(incfile,"%3d,",(int)byt);
                linelen++;
                return(1);
                 }
            else{
                fprintf(incfile,"%3d,",(int)(0xc0|cnt));
                fprintf(incfile,"%3d,",(int)byt);
                linelen+=2;
                return(2);
                }
                }
        return(0);
}




int BSV2INC(char *name1, char *name2, char *name3)
{
    unsigned char *scratchbuffer;
    unsigned char *buf;

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

    printf("BSAVEINC(C) Copyright by Bill Buckels\n\n");
    printf("Input  File: %s\n",name1);
    printf("Output File: %s\n",name2);

    scratchbuffer= malloc(SCREENSIZE);
    buf=malloc(SCREENSIZE/2);

    read(fh,scratchbuffer,SCREENSIZE);
    close(fh);

    /* seperate the attribute bytes */
    /* use the two-tank system.     */

    incfile=fopen(name2,"w");
    fprintf(incfile,"unsigned char %s[]={\n",name3);

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

            fprintf(incfile,"\n0}; /* terminator */\n");
            fclose(incfile);
            free(scratchbuffer);
            free(buf);
            printf("Done!\n");
            return 0;
}

main(int argc,char *argv[])
{
   char buffer[66];
   char  name1[66];
   char  name2[66];
   char  name3[66];

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
                    strcat(name2,".INC");
                    strcpy(name3,buffer);

                        status=BSV2INC(name1,name2,name3);
                        if(status==0)exit(0);

 default: printf("BSAVEINC(C) Copyright by Bill Buckels 1990\n");
          printf(
 "Usage : \"BSAVEINC [filename]\"\n");
          printf(
          "Converts .BSV BSAVED IMAGES to .INC encoded C arrays.\n");
          printf("CGA COLOR TEXT mode, screen dumps only.\n");
          }
          exit(0);
}

