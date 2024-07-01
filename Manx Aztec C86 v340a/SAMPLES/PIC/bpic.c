
/* bpic.c (C) Copyright 2008 Bill Buckels. All rights reserved. */

/* A BASIC BSaved graphics image loader for
   DOS 2.0 or CP/M-86

   Written in Aztec C86 v3X

   Handles CGA 320 x 200 x 4-Color or 640 x 200 x 2 Color screens.

   For more info on these See my Wikipedia Article at:

   http://en.wikipedia.org/wiki/BSAVE_(graphics_image_format)

   For a program to create these in Windows XP from a variety of
   sources download a copy of my ClipShop program at:

   www.clipshop.ca

   */

#include <fcntl.h>

/* one of my headers */
#include <regs.h>

/* no need to load the entire image
   just load the 192 bytes between the interleaves
   to simplify for a contiguous load */

#define SCREENSIZE 16192
#define SCREENSEG 0xb800

/* a read buffer */
char databuf[SCREENSIZE];

/* a microsoft compatible bsaved image format descriptor */
char bsave_header[7]={'\xfd','\x00','\xb8','\x00','\x00','\x00','\x40'};

/* for verification... check the first 5 bytes only!

   the marker byte 0xfd is followed by 3 intel 16 bit integers
   giving originating segment, offset, and filelength of the image.

   The filelength can vary here but the first 5 bytes are
   pretty mich invariant. As far as length most of these were 0x4000
   (16384) bytes not including the 7 byte header and BASIC's ubiquituous
   [CTRL]-Z (0x1a) footer (which was reminiscent of the early x86 file systems
   but wasn't always present at the end of these either depending on who and how).

   The reason that most of us saved them that way was probably because
   of the example in the GWBASIC manual... and IBM PC StoryBoard's
   PicturMaker (PM.EXE) v1 saved them that way as well... perhaps they read the
   same manual.

   But John Bridges saved these in PicEM the same way I am loading
   them here... without the padding on the end. (John didn't code in BASIC
   even in those days), and Eugene Ying who did saved them as 16512 bytes
   in PCPG which doesn't make much sense to me.

   That was a long time ago anyway.

 */

/* K & R style function body */
main(argc, argv)
int argc;
char **argv;
{

	int fh, idx, status, vmode = 'M';
	union REGS inregs, outregs;
	struct SREGS sregs;

    if (argc < 2) {
	   printf("Usage: bpic [my.bas] [options 'H' for hires or 'M' for medres]\n");
	   exit(1);

	}

	/* check for video mode */
	if (argc > 2) {
	  if (argv[2][0] == '-')idx =1;
	  else idx = 0;
	  if (argv[2][idx] == 'h' || argv[2][idx] == 'H')vmode = 'H';

	}

	sysint(0x11,&inregs,&outregs); /* get equipment list from the bios */

	/* get display type (bits 4 and 5 of ax) */
    if (!((outregs.x.ax & 0x30) < 0x30)) {
		printf("CGA compatible displays only! Exiting.\n");
        exit(1);
	}


    fh = open(argv[1],O_RDONLY);


    if (fh == -1) {
	   printf("Unable to open %s!\n",argv[1]);
	   exit(1);
	}



    read(fh,databuf,7);
    for (idx = 0; idx < 5; idx++) {
    	if(databuf[idx]!= bsave_header[idx]) {
			close(fh);
			printf("Unsupported Format!\n");
			exit(1);
		}

	}

    /* we are in small memory model so need to get the segment
       that we are running-in to move image data direct
       to the CGA screen address... */
    segread(&sregs);

	read(fh,&databuf[0],SCREENSIZE);
	close(fh);

    mode(vmode);

    /* note that I am using the ds register value with
       the datasegment address of my near pointer
       for my image data buffer as the base address for
       the source of my memory block move... */
    movblock(&databuf[0],sregs.ds,0,SCREENSEG,SCREENSIZE);

    /* wait for a key press */
	/* use sysint to generate int 16h */

	inregs.x.ax = 0x0000;
	inregs.x.dx = 0x0000;
	sysint(0x16,&inregs,&outregs);
	/* return the low order char */
	status = outregs.x.ax&0x00ff;

    mode('L');

    exit(status);


 }
