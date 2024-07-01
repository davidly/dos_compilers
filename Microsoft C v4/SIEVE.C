/* sieve.c */

/* Eratosthenes Sieve Prime Number Program in C from Byte Jan 1983
   to compare the speed. */

#include <stdio.h>

#define TRUE 1
#define FALSE 0
#define SIZE 8190
typedef int bool;

char flags[SIZE+1];

int cdecl main()
        {
        int i,k;
        int prime,count,iter;

        for (iter = 1; iter <= 10; iter++) {    /* do program 10 times */
                count = 0;                      /* initialize prime counter */
                for (i = 0; i <= SIZE; i++)     /* set all flags TRUE */
                        flags[i] = TRUE;
                for (i = 0; i <= SIZE; i++) {
                        if (flags[i]) {         /* found a prime */
                                prime = i + i + 3;      /* twice index + 3 */
                                for (k = i + prime; k <= SIZE; k += prime)
                                        flags[k] = FALSE;       /* kill all multiples */
                                count++;                /* primes found */
                                }
                        }
                }
        printf("%d primes.\n",count);           /*primes found in 10th pass */
        return 0;
        }
