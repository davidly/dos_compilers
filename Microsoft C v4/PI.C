#define	MAXPRC	4000

char p[MAXPRC];
char t[MAXPRC];
int q;

main(argc,argv)
int argc;
char *argv[];
{
	long startime, endtime;
	register int i;

	if (argc == 2) {
		sscanf(argv[1],"%d",&q);
	} else {
		printf("Usage: pi [precision]\n");
		exit(55);
	}

	if (q > MAXPRC)	{
		printf("Precision too large\n");
		exit(66);
	}

	/* compute pi */

	time(&startime);
	arctan(2);
	arctan(3);
	mul4();
	time(&endtime);

	/* print pi */

	printf("pi = %d.",p[0]);
	for (i = 1; i <= q; i++)
		printf("%d",p[i]);
	printf("\n");
	printf("%ld seconds to compute %d digits of pi\n",endtime-startime,q);
}
