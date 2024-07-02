/*
	EXAMPLE TWO
	
	This program illustrates a calling functions with parameters
	and automatics.
*/

#include <stdio.h>

char	buff[128];

factor(n)
int		n;
{
	char	*s;
	int		i;
	long	f;

	s = buff;
	while (*s) s++;
	f = 1;
	for (i=1;i<=n;i++) {
		f *= i;
	}
	sprintf(s," - %d factorial is %ld",n,f);
}
	
display(i)
int		i;
{
	long	j;
	char	*p;

	p = buff;
	j = i*i;
	sprintf(p,"%d squared is %ld",i,j);
	factor(i);
}

main()
{
	int		i;

	printf("EXAMPLE 2\n");
	for (i=0;i<10;i++) {
		display(i);
		printf("%s\n",buff);
	}
	printf("EXAMPLE 2 finished\n");
	exit(0);
}
