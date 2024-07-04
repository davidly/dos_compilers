/*	Eratosthenes Sieve Prime Number Program in C, Byte January 1983.
 *	The code has been corrected to produce primes correctly.
*/
#include <stdio.h>

#define TRUE	1
#define FALSE	0
#define NITER	150
#define SIZE	8190

char flags[SIZE+1]={0};


main ()
	{
	register int i,k;
	int iter, count;

	printf ("%d iterations: ", NITER);

	for( iter = 1; iter <= NITER; iter++ )     /* Do sieve 150 times */
		{
		count = 0;
		for( i = 0; i <= SIZE; i++)	  /* set all flags true */
			flags[i] = TRUE;

		for( i = 2; i <= SIZE; i++ )
			{
			if ( flags[i] )		  /* found a prime */
				{
				for ( k = i + i; k <= SIZE; k += i )
					flags[k] = FALSE;	/* Cancel its multiples */
				count++;
				}
			}
		}

	printf ("%d primes\n", count);

	exit(0);

	}
