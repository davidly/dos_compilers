#include <stdio.h>

#define unsigned

typedef unsigned long uint32_t;

int main()
{
    uint32_t limit = 40;
    uint32_t prev2 = 1;
    uint32_t prev1 = 1;
    uint32_t next, i, last_shown = 0;

    printf( "should tend towards 1.61803398874989484820458683436563811772030\n" );

    for ( i = 1; i <= limit; i++ )
    {
        next = prev1 + prev2;
        prev2 = prev1;
        prev1 = next;

        if ( i == ( last_shown + 5 ) )
        {
            last_shown = i;
            printf( "  at %2lu iterations: %lf\n", i, (double) prev1 / (double) prev2 );
        }
    }

    printf( "done\n" );
    return 0;
}
