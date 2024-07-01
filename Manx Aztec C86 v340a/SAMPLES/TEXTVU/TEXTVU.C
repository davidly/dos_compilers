/* TEXTVU (C) Copyright Bill Buckels 1990 - 2008. All rights reserved. */
/* loader and demo for .ANS, .TXT, .PTX, or .BSV files in aztec C      */

/* this version compiles and runs in MS-DOS or CP/M 86 */

/* these files can be created in the THEDRAW or in GWBASIC, etc.      */
/* this program turns off the cursor, loads the file, waits for a     */
/* key press then turns the cursor on and returns the key value as    */
/* an exit code. It can be used as a slide show driver or batch menu. */

#include <fcntl.h>
/* one of my headers */
#include <regs.h>

#define SCREENSIZE 4000
unsigned int SCREENSEG=0xb000;

/* read buffers */
char packbuf[SCREENSIZE];
char databuf[SCREENSIZE];

/* a microsoft compatible bsaved image format descriptor */
char bsave_header[7]={'\xfd','\x00','\xb8','\x00','\x00','\xA0','\x0F'};

/* for verification... check the first 2 bytes only!

   the marker byte 0xfd is followed by 3 intel 16 bit integers
   giving originating segment, offset, and filelength of the image.

   the segment was not always b800 and on a monochrome display
   including a hercules would be b000 but the offset was generally 0.

   The filelength can vary here but the first 5 bytes are
   pretty much invariant. As far as length these were 4000 bytes
   or up to 4096 bytes (with the last up to 96 bytes being unused)
   not including the 7 byte header and BASIC's ubiquituous
   [CTRL]-Z (0x1a) footer (which was reminiscent of the early x86 file systems
   but wasn't always present at the end of these either depending on who and how).

   The header above is for a CGA mode text screen of 4000 bytes.

 */

/* the header fragment below is part of the header for
   a run length encoded ptx text screen */
char ptx_header[4]={'\x00','\x03','\x01','\x10'};

/* K & R style function body */
main(argc, argv)
int argc;
char **argv;
{

	union REGS inregs, outregs;
	struct SREGS sregs;

    int fh,i;

    unsigned int byteoff=0,secondoff=1,packet;
    unsigned char byte,bytecount;
    int wordcount,target;
    unsigned int status = 0;


    if (argc < 2) {
	   printf("Usage: textvu [my.bsv]\n");
	   exit(1);
	}

    fh = open(argv[1],O_RDONLY);

    if (fh == -1) {
	   printf("Unable to open %s!\n",argv[1]);
	   exit(1);
	}

    sysint(0x11,&inregs,&outregs); /* get equipment list from the bios */
    /* get display type (bits 4 and 5 of ax) */
    if ((outregs.x.ax & 0x30) < 0x30)SCREENSEG=0xb800;


	/* clearscreen and turn cursor off */

    /*
	Function 06h: Scroll Text Lines Up Scrolls part or all of the
	current display page up by one or more text lines. This
	function can also be used to clear part or all of the screen.

	Inputs

	AH = 06h

	AL = Number of lines to be scrolled up (AL = 00h will clear
	the window).

	BH = Color attribute for blank lines. In text mode, this
	corresponds to the attribute byte. In VGA graphics modes, this
	is the color number to which all the pixels in the blank lines
	will be set. In text mode the high nibble contains the text
	background and the low nibble the text color (bg << 4 | color).
	Background is in the range of 0-7 and color 0-15. Background
	of over 8-15 sets the blink attribute on the color display.
	Colors of 7-15 is the equivalent of adding high intensity
	to colors 0-7. The same holds true for determining what
	background the blink will be set to. Monochrome screens behave
	somewhat differently and generally the colors will be messed-up
	if a monochrome text color scheme is displayed on a color display
	or vice-versa, so these values were historically assigned independently
	or a simple text color scheme was used which suited both.

	CH = Top row of window to be scrolled up.
	CL = Leftmost column of window.

	DH = Bottom row of window.
	DL = Rightmost column of window.

    */
	inregs.x.ax = 0x0600;
	inregs.x.bx = 0x0f00;  /* black background, bwhite text */
	inregs.x.cx = 0;
	inregs.h.dh = 24;
	inregs.h.dl = 79;
	sysint(0x10,&inregs,&outregs);

    /*
	Function 02h: Set Cursor Position Moves the cursor to the specified
	position on the screen. The video hardware maintains a separate cursor for
	each display page, and the cursor will move only if the page number given
	in BH is the current display page. Giving a position that is off the
	screen will cause the cursor to disappear from the screen.

	Inputs

	AH = 02h

	BH = Display page (valid only in text modes--use 00h for graphics modes).

	DH = Row (00h is top row).

	DL = Column (00h is leftmost column).

    */
	inregs.x.ax = 0x0200;
	inregs.x.bx = 0;
	inregs.x.dx = 0;
	sysint(0x10,&inregs,&outregs);

    /*
	Function 01h: Define Cursor Appearance Sets the starting and ending lines
	of the screen cursor, and can also be used to make the cursor invisible.
	In some modes, the characters are not exactly 8 lines high in these cases
	the graphics hardware will adapt the input values to the current character
	size.

	Inputs

	AH = 01h

	CH = Starting line of cursor (0-7). Add 20h to make the cursor invisible.

	CL = Ending line of cursor (0-7).
    */

	inregs.x.ax = 0x0100;
	inregs.x.cx = 0x2000;
	sysint(0x10,&inregs,&outregs);

    read(fh,databuf,7);

    /* beginning of run raw */
    if(databuf[0]== bsave_header[0] && databuf[1]== bsave_header[1])
    {
     read(fh,databuf,SCREENSIZE);
     close(fh);
     status = 1;
     }
	else if(databuf[0]==ptx_header[0] && databuf[1]==ptx_header[1] &&
         	databuf[2]==ptx_header[2] && databuf[3]==ptx_header[3])
    {
		 /* beginning of run length encoded */
		status = 1;
		read(fh,databuf,121);/* blow the rest of the header */
		target = read(fh,packbuf,SCREENSIZE);
		close(fh);

		wordcount=0;
		do{ bytecount=1;                     /* start with a seed count */
		byte=packbuf[wordcount];
		wordcount++;
											  /* check to see if its raw */
		if(0xC0 == (0xC0 &byte)){             /* if its not, run encoded */
					bytecount= 0x3f &byte;
					byte=packbuf[wordcount];
					wordcount++;
					}
		for(packet=0;packet<bytecount;packet++){
				   if(byteoff<SCREENSIZE){
						databuf[byteoff]=byte;
						byteoff+=2;
						}
				   else{
						databuf[secondoff]=byte;
						secondoff+=2;
						}
					}

		}while(wordcount<target);
	}

    if (status ==0) {
 	       /* begin run cooked */
	       for (i = 0; i < 7; i++) {
			  putchar(databuf[i]);
			}
			target = read(fh,databuf,SCREENSIZE);
			for (i = 0; i < target; i++)putchar(databuf[i]);
			close(fh);

    }
	else {
	/* we are in small memory model so need to get the segment
	   that we are running-in to move image data direct
	   to the CGA screen address... */
	segread(&sregs);

	/* note that I am using the ds register value with
	   the datasegment address of my near pointer
	   for my image data buffer as the base address for
	   the source of my memory block move... */
	movblock(&databuf[0],sregs.ds,0,SCREENSEG,SCREENSIZE);

	}

    /* wait for a key press */
   	/* use sysint to generate int 16h */

   	inregs.x.ax = 0x0000;
   	inregs.x.dx = 0x0000;
   	sysint(0x16,&inregs,&outregs);
   	/* return the low order char */
	status = outregs.x.ax&0x00ff;

    exit(status);

}
