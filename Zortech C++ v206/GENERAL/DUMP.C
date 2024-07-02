/*_ dump.c   Thu Jul 31 1986   Modified by: Walter Bright */
/* Copyright (C) 1985 by Northwest Software	*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

#include	<stdio.h>
#include	<ctype.h>
#include 	<stdlib.h>

main(argc,argv)
int argc;
char *argv[];
{ FILE *f;
  int i, buffer[16];
  unsigned long offset = 0;

  if (argc < 2 || argc > 3)
  {	printf("Error: wrong number of arguments\n");
	printf("Use: dump file [starting offset in hex]\n");
	exit(1);
  }
  f = fopen(argv[1],"rb");		/* open file for binary read	*/
  if (!f)
  {	printf("Can't open file '%s'\n",argv[1]);
	exit(1);
  }

  if (argc == 3)
  {	sscanf(argv[2],"%lx",&offset);
	fseek(f,offset,0);
  }
  while (1)
  {	for (i = 0; i < 16; i++)
		buffer[i] = fgetc(f);
	if (buffer[0] == -1) break;	/* done				*/
	printf("%04lx: ",offset);
	for (i = 0; i < 16; i++)
		if (buffer[i] != -1)
			printf("%2x ",buffer[i]);
		else
			printf("   ");
	printf("   ");
	for (i = 0; i < 16; i++)
	{
		if (buffer[i] != -1)
		{	if (!isprint(buffer[i])) buffer[i] = '.';
			putchar(buffer[i]);
		}
		else
			putchar(' ');
	}
	putchar('\n');
	offset += 16;
  }
}
