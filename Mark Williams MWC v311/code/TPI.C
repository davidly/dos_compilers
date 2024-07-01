#include <stdio.h>

#define HIGH_MARK 500 /* 2800 */

static long r[HIGH_MARK + 1];

int main() {
    long i, k, c;
    long b, d, v;
    long iteration;

    int iterations = 1;

    for ( iteration = 0; iteration < iterations; iteration++ ) {
        c = 0;

        for (i = 0; i < HIGH_MARK; i++) {
            r[i] = 2000;
        }
    
        for (k = HIGH_MARK; k > 0; k -= 14) {
            d = 0;
    
            i = k;
            for (;;) {
                d += r[i] * 10000;
                b = 2 * i - 1;
    
                r[i] = d % b;
                d /= b;
                i--;
                if (i == 0) break;
                d *= i;
            }
            if ( iteration == ( iterations - 1 ) )
            {
#ifdef MWC
                v = c + d / 10000;
                if ( v < 10 )
                    printf( "000" );
                else if ( v < 100 )
                    printf( "00" );
                else if ( v < 1000 )
                    printf( "0" );
#endif
                printf( "%.4d", c + d / 10000 );
                fflush( stdout );
            }
            c = d % 10000;
        }
    }

    printf( "\n" );
    return 0;
}
