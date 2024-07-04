#include <stdio.h>

#ifdef AZTEC86
#include <stdlib.h>
#endif

#ifdef HISOFTC
#include <stdlib.h>
#endif

#define OLDMSC
#ifdef OLDMSC
#define unsigned
#define void int
#endif

#ifdef WATCOM
#include <malloc.h>
#include <process.h>
#endif


#ifdef powerc
#define allocs 50
#else
#ifdef HISOFTC
#define allocs 66 /* not enough RAM with hisoft to go higher */
#else
/* most c runtimes work up to 69, but use 66 to have a consistent benchmark */
#define allocs 66
#endif
#endif

int logging = 1;

char * memset_x( p, v, c ) char * p; int v; int c;
{
    unsigned char * pc = (unsigned char *) p;
    unsigned char val = (unsigned char) ( v & 0xff );
    int i;

    if ( 0 == p )
    {
        printf( "request to memset a null pointer\n" );
        exit( 1 );
    }

    if ( logging )
#ifdef CPMTIME
        printf( "  memset p %u, v %d, val %x, c %d\n", p, v, val, c );
#else

#ifdef HISOFTC
        printf( "  memset p %u, v %d, val %x, c %d\n", p, v, val, c );
#else
        printf( "  memset p %p, v %d, val %x, c %d\n", p, v, val, c );
#endif
#endif

    for ( i = 0; i < c; i++ )
        *pc++ = val;
    return p;
}

void chkmem( p, v, c ) char * p; int v; int c;
{
    unsigned char * pc = (unsigned char *) p;
    unsigned char val = (unsigned char) ( v & 0xff );
    int i;

    if ( 0 == p )
    {
        printf( "request to chkmem a null pointer\n" );
        exit( 1 );
    }

    for ( i = 0; i < c; i++ )
    {
        if ( *pc != val )
        {
#ifdef CPMTIME
            printf( "memory isn't as expected! p %u, v %d, c %d, *pc %d\n",p, v, c, *pc );
#else
            printf( "memory isn't as expected! p %p, v %d, c %d, *pc %d\n",p, v, c, *pc );
#endif
            exit( 1 );
        }
        pc++;
    }
}

int main( argc, argv ) int argc; char * argv[];
{
    int i, cb, c_cb, j;
    char * pc;
    char * ap[ allocs ];

    logging = ( argc > 1 );
    pc = argv[ 0 ]; /* evade compiler warning */

    for ( j = 0; j < 10; j++ )
    {
        if ( logging )
            printf( "in alloc mode\n" );
    
        for ( i = 0; i < allocs; i++ )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 5;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );

            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memset_x( pc, 0xcc, c_cb );
    
            ap[ i ] = (char *) malloc( cb );
            memset_x( ap[ i ], 0xaa, cb );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    
        if ( logging )
            printf( "in free mode, even first\n" );
    
        for ( i = 0; i < allocs; i += 2 )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 3;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memset_x( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            memset_x( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    
        if ( logging )
            printf( "in free mode, now odd\n" );
    
        for ( i = 1; i < allocs; i += 2 )
        {
            cb = 8 + ( i * 10 );
            c_cb = cb + 7;
            if ( logging )
                printf( "  i, cb: %d %d\n", i, cb );
    
            pc = (char *) calloc( c_cb, 1 );
            chkmem( pc, 0, c_cb );
            memset_x( pc, 0xcc, c_cb );
    
            chkmem( ap[ i ], 0xaa, cb );
            memset_x( ap[ i ], 0xff, cb );
            free( ap[ i ] );
    
            chkmem( pc, 0xcc, c_cb );
            free( pc );
        }
    }

    printf( "success\n" );
    return 0;
}
