/*		dump.c		core style dump of a file	*/

/*		usage: A>DUMP B:BLIP.O					*/


char buffer[4096];

main(argc,argv)
	int  argc;
	char *argv[]; {
	unsigned i,numin,tot,file;
	char *cfrom;

	if (argc < 2) {
		puts("Missing Filename\n");
		}

	tot=0;
	if ((file=open(argv[1],0)) == -1) {
		puts("Cannot Open ");
		puts(argv[1]);
		exit(1);
		}

/*	read and dump 4k at a time	*/

	do {
		numin=read(file,buffer,4096);
		if (numin == -1) {
			puts("Cannot Read ");
			puts(argv[1]);
			exit(1);
			}
		cfrom=0;
		while (cfrom < numin) {

/*	print the offset in hex	*/

			ohw(cfrom+tot);
			putchar(' ');

/*	print 16 bytes in hex	*/

			for (i=0; i < 16; i++) {
				putchar(' ');
				ohb(buffer[cfrom++]);
				}
			cfrom-=16;
			puts("  *");

/*	print the bytes in ascii	*/

			for (i=0; i < 16; i++) {
				putchar((buffer[cfrom] >= ' ' && buffer[cfrom] < 0x7f)
					 ? buffer[cfrom]: '.');
				cfrom++;
				}
			puts("*\n");
			}
		tot+=numin;
		}
	while (numin == 4096);
	}

/*	print a word in hex	*/

ohw(wrd)
	unsigned wrd; {
	ohb(wrd>>8);
	ohb(wrd);
	}

/*	print a byte in hex	*/

ohb(byt)
	char byt; {
	onib(byt>>4);
	onib(byt);
	}

/*	print a nibble as a hex character	*/

onib(nib)
	char nib; {

	nib&=15;
	putchar((nib >= 10) ? nib-10+'A': nib+'0');
	}
