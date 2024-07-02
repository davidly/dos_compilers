/*_ zcmore.c   Fri Oct 13 1989   Modified by: Samuel Druker */
/* Copyright (C) 1986 by Northwest Software	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

/* This is a program meant to demonstrate the use of the disp package	*/
/* of functions. It also illustrates how ftell() and fseek() can be	*/
/* used with text files.						*/
/* ZCMORE is a functional replacement for the MORE program supplied	*/
/* with MS-DOS. It, however, does not work with non-IBM PC compatible	*/
/* displays.								*/
/* To compile:								*/
/*	ZTC -mti zcmore							*/
/* To use:								*/
/*	ZCMORE filename							*/

#include <stdio.h>
#include <disp.h>

main(argc,argv)
int argc;
char *argv[];
{	FILE *f;
	int c;
	int rows;
	unsigned long fsize,fpos,startpage,lastpage;

	if (argc == 2)		/* expecting 1 arg, the file name	*/
	{	f = fopen(argv[1],"r");
		if (!f)
		{	fprintf(stderr,"Can't open file '%s'\n",argv[1]);
			exit(1);
		}
		fsize = filesize(argv[1]);
	}
	else
	{	fprintf(stderr,"ZCMORE: a program to peruse files\n\
Use:\n\tZCMORE filename\n");
		exit(1);
	}

	disp_open();			/* initialize display package	*/
	rows = 0;			/* row 0 == top row		*/
	lastpage = 0;			/* no previous page		*/
	startpage = 0;			/* start of this page		*/
	while ((c = fgetc(f)) != EOF)	/* while not end of file	*/
	{	c &= 0x7F;		/* so WordStar files can be read */
		disp_putc(c);		/* display character read	*/
		if (disp_cursorcol == 0)	/* if finished a line	*/
		{	rows++;			/* # of lines output	*/
			if (rows == disp_numrows - 1) /* if end of screen */
			{	disp_startstand();
				fpos = ftell(f); /* where are we in file? */
				disp_printf("--More-- %2ld%%",(fpos*100)/fsize);
				disp_endstand();
				disp_putc(' ');
			loop:
				disp_flush();	/* flush output to display */
				c = getch();	/* wait for user input	*/
				switch (c)
				{
				    case 't':	/* start of file	*/
				    case 'T':
					lastpage = 0;
					/* FALL-THROUGH */
				    case 'b':	/* go back a screen	*/
				    case 'B':
					fseek(f,lastpage,0);
					fpos = startpage = lastpage;
					/* FALL-THROUGH */
				    case ' ':
					rows = 0;	/* next screen	*/
					lastpage = startpage;
					startpage = fpos;
					disp_move(0,0);
					disp_eeop();	/* clear screen	*/
					break;
				    case '\r':
					/* just one more line */
					rows = disp_numrows - 2;
					disp_putc('\r');
					disp_eeol();	/* erase 'More'	*/
					break;
				    case 3:
				    case 'Q':
				    case 'q':
					disp_putc('\r');
					disp_eeol();	/* erase 'More'	*/
					goto done;	/* quit		*/
				    default:		/* error	*/
					disp_printf("' '=next page, 'b'=\
back page, 't'=top, Return=next line, 'q'=quit");
					disp_move(disp_numrows - 1,13);
					goto loop;	/* try again	*/
				}
			}
		}
	} /* while */

done:	disp_close();			/* finish up gracefully		*/
}
