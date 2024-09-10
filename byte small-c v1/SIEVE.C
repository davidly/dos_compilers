/*  sieve.c */

/* Eratosthenes Sieve Prime Number Program in C from Byte Jan 1983
   to compare the speed. */

#include "stdio.h"

#define SIZE 8190

char flags[8191];

main()
{
    int i,k;
    int prime,count,iter;

    iter = 1;
    while ( iter <= 10 )
    {
        count = 0;                      /* initialize prime counter */
        i = 0;
        while ( i <= SIZE )
        {
            flags[i] = 1;
            i++;
        }

        i = 0;
        while ( i <= SIZE )
        {
            if (flags[i])
            {
                prime = i + i + 3;      /* twice index + 3 */
                k = i + prime;
                while ( k <= SIZE )
                {

                    flags[k] = 0;       /* kill all multiples */
                    k = k + prime;
                }

                count++;                /* primes found */
            }

            i++;
        }
        iter++;
    }

    printf("%d primes.\n",count);           /*primes found in 10th pass */
    return 0;
}
