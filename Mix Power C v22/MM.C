/* BYTE magazine October 1982. Jerry Pournelle. */
/* ported to C by David Lee */
/* A and B hold small whole numbers, so every float format gets exactly 465880 */
/* expected result: 465880 */

#include <stdio.h>

#define l 20 /* rows in A and resulting matrix C */
#define m 20 /* columns in A and rows in B (must be identical) */
#define n 20 /* columns in B and resulting matrix C */

float Summ;
float A[ l ][ m ];
float B[ m ][ n ];
float C[ l ][ n ];

filla()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < m; j++ )
            A[ i ][ j ] = i + j + 2;
}

fillb()
{
    int i, j;
    for ( i = 0; i < m; i++ )
        for ( j = 0; j < n; j++ )
            B[ i ][ j ] = ( i + j + 2 ) / ( j + 1 );
}

fillc()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            C[ i ][ j ] = 0;
}

matmult()
{
    int i, j, k;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            for ( k = 0; k < m; k++ )
                C[ i ][ j ] += A[ i ][ k ] * B[ k ][ j ];
}

summit()
{
    int i, j;
    for ( i = 0; i < l; i++ )
        for ( j = 0; j < n; j++ )
            Summ += C[ i ][ j ];
}

main()
{
    Summ = 0;

    filla();
    fillb();
    fillc();
    matmult();
    summit();

    printf( "summ is : %f\n", Summ );
    return 0;
}
