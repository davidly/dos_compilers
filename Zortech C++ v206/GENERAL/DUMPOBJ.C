/*_ dumpobj.c   Mon Feb 29 1988   Modified by: Walter Bright */
/*****************************************************
 * Dump .OBJ files.
 * Use:
 *	dumpobj	filename.obj
 */

#include	<stdio.h>
#include	<stdlib.h>

/* Prototypes */
void chkeof(void);
int gchar(void);
int putrecord(void);
int getrecord(void);
int isprint(unsigned c);

int xc = ' ';		/* last char read from file			*/
unsigned rectyp;	/* record type					*/
unsigned chksum = 0;	/* current check sum				*/
unsigned reclength;	/* record length				*/
unsigned char *record = NULL;	/* pointer to data bytes		*/
FILE *f;		/* input file pointer				*/

main(argc,argv)
int argc;
char *argv[];
{ int i, buffer[16];

  if (argc != 2)
  {	printf("Error: wrong number of arguments\r\n");
	printf("Use: dumpobj filename.obj\r\n");
	exit(1);
  }
  f = fopen(argv[1],"rb");		/* open file for binary read	*/
  if (!f)
  {	printf("Can't open file '%s'\r\n",argv[1]);
	exit(1);
  }

  while (gchar() != EOF)		/* while not end of file	*/
  {	getrecord();			/* read in a record		*/
	putrecord();			/* display a record		*/
  }
}

/***************************************
 * Get a record.
 *	record ::= rectyp reclength { data_bytes } chksum
 */

getrecord()
{ unsigned i;

  rectyp = xc;				/* record type			*/
  reclength = gchar();
  reclength += gchar() << 8;		/* 2 byte record length		*/
  if (record) free(record);		/* junk pre-existing record	*/
  record = malloc(reclength - 1);
  chkeof();				/* check for premature eof	*/
  for (i = 0; i < reclength - 1; i++)
  {	record[i] = gchar();
	chkeof();
  }
  gchar();				/* read chksum byte		*/
  if (chksum & 0xFF)
  {	printf("Bad checksum: %x\r\n",chksum & 0xFF);
	exit(1);
  }
}

int gchar()
{
  return xc = fgetc(f);
}

putrecord()
{ static char *typtab[] =
	{"RHEADR","REGINT","REDATA","RIDATA","OVLDEF","ENDREC","BLKDEF",
	 "BLKEND","DEBSYM","THEADR","lHEADR","PEDATA","PIDATA","COMENT",
	 "MODEND","EXTDEF","TYPDEF","PUBDEF","LOCSYM","LINNUM","LNAMES",
	 "SEGDEF","GRPDEF","FIXUPP","(none)","LEDATA","LIDATA","LIBHED",
	 "LIBNAM","LIBLOC","LIBDIC"
	};
  int i,j;

  i = (rectyp - 0x6E) / 2;
  if (i == (0xB0 - 0x6E) / 2)
	printf("COMDEF");
  else if (i < 0 || i >= sizeof(typtab) / sizeof(char *))
	printf("%6x",rectyp);
  else
  	printf(typtab[i]);		/* record type string		*/
  for (j = 0; j < reclength - 1; j += 16)
  {
	if (j) printf("      ");
	for (i = 0; i < 16; i++)
	{	if (j + i < reclength - 1)
			printf(" %2x",record[j + i]);
		else
			printf("   ");
	}
	printf("    ");
	for (i = 0; i < 16; i ++)
	{	if (j + i < reclength - 1)
		{
			if (isprint(record[j+i]))
				putchar(record[j+i]);
			else
				putchar('.');
		}
		else
			putchar(' ');
	}
	printf("\r\n");
  }
}

int isprint(unsigned c)
{
  return c >= ' ' && c <= '~';
}

void chkeof(void)
{
  if (xc == EOF)
  {	printf("Premature end of file\r\n");
	exit(1);
  }
}
