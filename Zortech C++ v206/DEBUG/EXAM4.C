/*
	EXAMPLE FOUR
	
	This program illustrates a calling functions using register variables
*/

#include <stdio.h>

char	buff[128];

long factor(n)
int		n;
{
	int		i;
	long	f;

	f = 0;
	for (i=1;i<=n;i++) {
		f += i;
	}
	return(f);
}
	
display(i)
int		i;
{
	long	j;
	char	*p;

	p = buff;
	j = i*i;
	sprintf(p,"%d squared is %ld - the progressive sum of %d is %ld",i,j,i,factor(i));
}

dummy()
{
	return;
}

main()
{
	int		i;

	printf("EXAMPLE 4\n");
	for (i=0;i<10;i++) {
		display(i);
		printf("%s\n",buff);
	}
	printf("EXAMPLE 4 finished\n");
	exit(0);
}
