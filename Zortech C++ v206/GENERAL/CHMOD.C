/*_ chmod.c   Mon Feb 29 1988   Modified by: Walter Bright */
/* Copyright (C) 1987-1988 by Walter Bright	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/
/* To compile with Zortech C:			*/
/*	ztc -mti chmod				*/

#include <stdio.h>
#include <dos.h>
#include <stdlib.h>
#include <ctype.h>

/* Prototypes */
void usage(void);
void faterr(char*, char*);	
int chmod(char* filename, int mode);

/* Attribute bits:	*/
#define R	1
#define H	2
#define S	4
#define V	8
#define D	0x10
#define A	0x20

main(argc,argv)
int argc;
char *argv[];
{	int i,j,c;
	char *p;
	struct FIND *find;
	unsigned onmask,offmask;
	static char flag[9] = "RHSVDAUU";

	if (argc <= 1)
		usage();
	p = argv[1];
	if (*p == '+' || *p == '-')
	{
	    onmask = 0;
	    offmask = 0;
	    while (1)
	    {
		c = toupper(p[1]);
		if (*p == '+')
		{    switch (c)
		     {	case 'R':	onmask |= R;	break;
			case 'H':	onmask |= H;	break;
			case 'S':	onmask |= S;	break;
			case 'V':	onmask |= V;	break;
			case 'D':	onmask |= D;	break;
			case 'A':	onmask |= A;	break;
			default:
				faterr("unrecognized flag '%s'",p);
		    }
		}
		else if (*p == '-')
		{    switch (c)
		     {	case 'R':	offmask |= R;	break;
			case 'H':	offmask |= H;	break;
			case 'S':	offmask |= S;	break;
			case 'V':	offmask |= V;	break;
			case 'D':	offmask |= D;	break;
			case 'A':	offmask |= A;	break;
			default:
				faterr("unrecognized flag '%s'",p);
		    }
		}
		else if (*p == 0)
		    break;
		else
		    faterr("unrecognized flag '%s'",p);
		p += 2;
	    }
	    for (i = 2; i < argc; i++)
	    {
		find = findfirst(argv[i],0xFF);
		while (find)
		{	c = find->attribute;
			c = (c & ~offmask) | onmask;
			chmod(find->name,c);
			find = findnext();
		}
	    }
	}
	else /* merely print the attributes of the files */
	{
	    for (i = 1; i < argc; i++)
	    {
		find = findfirst(argv[i],0xFF);
		while (find)
		{   c = find->attribute;
		    for (j = 7; j >= 0; j--)
			if ((1 << j) & c)
				printf("%c",flag[j]);
			else
				printf("-");
		    printf("\t0x%02x\t%s\n",c,find->name);
		    find = findnext();
		}
	    }
	}
}

/********************
 * Change attribute of file.
 */

int chmod(char* filename, int mode)
{	union REGS regs;

	regs.x.ax = 0x4301;
	regs.x.cx = mode;
	regs.x.dx = (int) filename;
	intdos(&regs,&regs);
}

void faterr(f,p)
char *f,*p;
{
	printf("Fatal error: ");
	printf(f,p);
	printf("\n");
	exit(1);
}

void usage(void)
{
	printf("\
File attribute byte display/modification program.\n\
Use:\n\
	chmod {(+|-)flag} file...\n\
Where:\n\
	flag is one of R,H,S,V,D,A\n\
	R	Read-only\n\
	H	Hidden\n\
	S	System\n\
	V	Volume label\n\
	D	Sub-directory\n\
	A	Archive\n\
\n\
If no flags are given, the attributes are displayed.\n\
");
}

