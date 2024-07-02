/*
	EXAMPLE ONE
	
	This program illustrates a simple 'C' program that executes
	a loop, outputting information to the screen as it goes. This is a long source line for use as an example in window line scrolling.
*/

#include <stdio.h>

int		j;

main()
{
	int		i;

	printf("EXAMPLE 1\n");
	for (i=0;i<10;i++) {
		j = i*i;
		printf("%d squared is %d\n",i,j);
	}
	printf("EXAMPLE 1 finished\n");
	exit(0);
}
