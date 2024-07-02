/*
   This version builds with old compilers including:
       Aztec C 1.06 for 8080 & Z80 on CP/M.
       Microsoft C Compiler V1.04 for 8086 on DOS. (This is Lattice C)
       Microsoft C Compiler V2.03 for 8086 on DOS. (Still Lattice C)
       Microsoft C Compiler V3.00 for 8086 on DOS.
       QuickC 1.0
       Turbo C 2.0
   The syntax is old and reminds me of 7th grade summer vacation.
   Much of this code is awkward to satisfy the lowest common denominator of many compilers.
   unsigned long isn't supported in many older compilers, so long is used instead.
   Early DOS and CP/M require register variabes to be int, not char or other types.
   The perf improvement of using register-int instead of stack-char is worth it.
*/

#define LINT_ARGS

#include <stdio.h>
#include <time.h>

#ifdef DOSTIME
#include <time.h>
#include <dos.h>
#endif

#define true 1
#define false 0

/* Function Pointers are the fastest implementation for almost every compiler */
#define UseFunPointers 1
#define UseWinner2 2
#define UseLookForWinner 3
#define WinMethod UseFunPointers

#define ABPrune true         /* alpha beta pruning */
#define WinLosePrune true    /* stop early on win/lose */
#define ScoreWin 6
#define ScoreTie 5
#define ScoreLose  4
#define ScoreMax 9
#define ScoreMin 2
#define DefaultIterations 100

#define PieceX 1
#define PieceO 2
#define PieceBlank 0

typedef char ttype;  /* 8-bit and 16-bit cpus do best with char aside from register in locals */

int g_Iterations = DefaultIterations;
ttype g_board[ 9 ];

#if WinMethod == UseFunPointers

ttype pos0func()
{
    /* using "register int" instead of "ttype" for x is faster on 8086 and Z80 */
    register int x = g_board[0];
    
    if ( ( x == g_board[1] && x == g_board[2] ) ||
         ( x == g_board[3] && x == g_board[6] ) ||
         ( x == g_board[4] && x == g_board[8] ) )
        return x;
    return PieceBlank;
}

ttype pos1func()
{
    register int x = g_board[1];
    
    if ( ( x == g_board[0] && x == g_board[2] ) ||
         ( x == g_board[4] && x == g_board[7] ) )
        return x;
    return PieceBlank;
} 

ttype pos2func()
{
    register int x = g_board[2];
    
    if ( ( x == g_board[0] && x == g_board[1] ) ||
         ( x == g_board[5] && x == g_board[8] ) ||
         ( x == g_board[4] && x == g_board[6] ) )
        return x;
    return PieceBlank;
} 

ttype pos3func()
{
    register int x = g_board[3];
    
    if ( ( x == g_board[4] && x == g_board[5] ) ||
         ( x == g_board[0] && x == g_board[6] ) )
        return x;
    return PieceBlank;
} 

ttype pos4func()
{
    register int x = g_board[4];
    
    if ( ( x == g_board[0] && x == g_board[8] ) ||
         ( x == g_board[2] && x == g_board[6] ) ||
         ( x == g_board[1] && x == g_board[7] ) ||
         ( x == g_board[3] && x == g_board[5] ) )
        return x;
    return PieceBlank;
} 

ttype pos5func()
{
    register int x = g_board[5];
    
    if ( ( x == g_board[3] && x == g_board[4] ) ||
         ( x == g_board[2] && x == g_board[8] ) )
        return x;
    return PieceBlank;
} 

ttype pos6func()
{
    register int x = g_board[6];
    
    if ( ( x == g_board[7] && x == g_board[8] ) ||
         ( x == g_board[0] && x == g_board[3] ) ||
         ( x == g_board[4] && x == g_board[2] ) )
        return x;
    return PieceBlank;
} 

ttype pos7func()
{
    register int x = g_board[7];
    
    if ( ( x == g_board[6] && x == g_board[8] ) ||
         ( x == g_board[1] && x == g_board[4] ) )
        return x;
    return PieceBlank;
} 

ttype pos8func()
{
    register int x = g_board[8];
    
    if ( ( x == g_board[6] && x == g_board[7] ) ||
         ( x == g_board[2] && x == g_board[5] ) ||
         ( x == g_board[0] && x == g_board[4] ) )
        return x;
    return PieceBlank;
} 

typedef ttype pfunc_t();

pfunc_t * winner_functions[9] =
{
    pos0func,
    pos1func,
    pos2func,
    pos3func,
    pos4func,
    pos5func,
    pos6func,
    pos7func,
    pos8func,
};

#endif

#if WinMethod == UseWinner2

ttype winner2( move ) ttype move;
{
    register int x;  /* faster than ttype x on the stack */

    switch( move ) /* msc v3 from 1985 generates a jump table! */
    {
        case 0:
        {
            x = g_board[ 0 ];
            if ( ( ( x == g_board[1] ) && ( x == g_board[2] ) ) ||
                 ( ( x == g_board[3] ) && ( x == g_board[6] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[8] ) ) )
               return x;
            break;
        }
        case 1:
        {
            x = g_board[ 1 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[2] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[7] ) ) )
                return x;
            break;
        }
        case 2:
        {
            x = g_board[ 2 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[1] ) ) ||
                 ( ( x == g_board[5] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[6] ) ) )
                return x;
            break;
        }
        case 3:
        {
            x = g_board[ 3 ];
            if ( ( ( x == g_board[4] ) && ( x == g_board[5] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[6] ) ) )
                return x;
            break;
        }
        case 4:
        {
            x = g_board[ 4 ];
            if ( ( ( x == g_board[0] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[6] ) ) ||
                 ( ( x == g_board[1] ) && ( x == g_board[7] ) ) ||
                 ( ( x == g_board[3] ) && ( x == g_board[5] ) ) )
                return x;
            break;
        }
        case 5:
        {
            x = g_board[ 5 ];
            if ( ( ( x == g_board[3] ) && ( x == g_board[4] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[8] ) ) )
                return x;
            break;
        }
        case 6:
        {
            x = g_board[ 6 ];
            if ( ( ( x == g_board[7] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[3] ) ) ||
                 ( ( x == g_board[4] ) && ( x == g_board[2] ) ) )
                return x;
            break;
        }
        case 7:
        {
            x = g_board[ 7 ];
            if ( ( ( x == g_board[6] ) && ( x == g_board[8] ) ) ||
                 ( ( x == g_board[1] ) && ( x == g_board[4] ) ) )
                return x;
            break;
        }
        case 8:
        {
            x = g_board[ 8 ];
            if ( ( ( x == g_board[6] ) && ( x == g_board[7] ) ) ||
                 ( ( x == g_board[2] ) && ( x == g_board[5] ) ) ||
                 ( ( x == g_board[0] ) && ( x == g_board[4] ) ) )
                return x;
            break;
         }
    }

    return PieceBlank;
} /*winner2*/

#endif

#if WinMethod == UseLookForWinner

ttype LookForWinner()
{
    register int p = g_board[0]; /* faster as register int than ttype on 8086 and Z80 */
    if ( PieceBlank != p )
    {
        if ( p == g_board[1] && p == g_board[2] )
            return p;

        if ( p == g_board[3] && p == g_board[6] )
            return p;
    }

    p = g_board[3];
    if ( PieceBlank != p && p == g_board[4] && p == g_board[5] )
        return p;

    p = g_board[6];
    if ( PieceBlank != p && p == g_board[7] && p == g_board[8] )
        return p;

    p = g_board[1];
    if ( PieceBlank != p && p == g_board[4] && p == g_board[7] )
        return p;

    p = g_board[2];
    if ( PieceBlank != p && p == g_board[5] && p == g_board[8] )
        return p;

    p = g_board[4];
    if ( PieceBlank != p )
    {
        if ( ( p == g_board[0] ) && ( p == g_board[8] ) )
            return p;

        if ( ( p == g_board[2] ) && ( p == g_board[6] ) )
            return p;
    }

    return PieceBlank;
} /*LookForWinner*/

#endif

int g_IMoves = 0;

ttype MinMax( alpha, beta, depth, move ) ttype alpha; ttype beta; ttype depth; ttype move;
{
    ttype pieceMove, score;   /* better perf with char than int. out of registers so use stack */
    register int p, value;    /* better perf with these as an int on Z80, 8080, and 8086 */

    g_IMoves++;

    if ( depth >= 4 )
    {
#if WinMethod == UseFunPointers
        p = ( * winner_functions[ move ] )();
#endif
#if WinMethod == UseWinner2
        p = winner2( move );
#endif
#if WinMethod == UseLookForWinner
        p = LookForWinner();
#endif

        if ( PieceBlank != p )
        {
            if ( PieceX == p )
                return ScoreWin;

            return ScoreLose;
        }

        if ( 8 == depth )
            return ScoreTie;
    }

    if ( depth & 1 ) 
    {
        value = ScoreMin;
        pieceMove = PieceX;
    }
    else
    {
        value = ScoreMax;
        pieceMove = PieceO;
    }

    for ( p = 0; p < 9; p++ )
    {
        if ( PieceBlank == g_board[ p ] )
        {
            g_board[p] = pieceMove;
            score = MinMax( alpha, beta, depth + 1, p );
            g_board[p] = PieceBlank;

            if ( depth & 1 ) 
            {
#if WinLosePrune   /* #if statements must be in first column for MS C 1.0 */
                if ( ScoreWin == score )
                    return ScoreWin;
#endif

                if ( score > value )
                {
                    value = score;

#if ABPrune
                    if ( value >= beta )
                        return value;
                    if ( value > alpha )
                        alpha = value;
#endif
                }
            }
            else
            {
#if WinLosePrune
                if ( ScoreLose == score )
                    return ScoreLose;
#endif

                if ( score < value )
                {
                    value = score;

#if ABPrune
                    if ( value <= alpha )
                        return value;
                    if ( value < beta )
                        beta = value;
#endif
                }
            }
        }
    }

    return value;
}  /*MinMax*/

long g_Moves = 0;

int FindSolution( position ) ttype position;
{
    register int i;

    for ( i = 0; i < 9; i++ )
        g_board[ i ] = PieceBlank;

    g_board[ position ] = PieceX;

    for ( i = 0; i < g_Iterations; i++ )
    {
        g_IMoves = 0;
        MinMax( ScoreMin, ScoreMax, 0, position );
        g_Moves += g_IMoves;  /* do the 4-byte long addition once per loop to save work */
    }

    return 0;
} /*FindSolution*/

#ifdef CPMTIME

struct CPMTimeValue
{
    int h, m, s, l;
};

void print_time_now()
{
    /* This CP/M BDOS call of 105 is only implemented in NTVCM -- it's not a standard CP/M 2.2 call */

    struct CPMTimeValue t;
    t.h = t.m = t.s = t.l = 0;

    bdos( 105, &t );
    printf( "current time: %02d:%02d:%02d.%02d\n", t.h, t.m, t.s, t.l );
} /*print_time_now*/

long get_ms()
{
    /* This CP/M BDOS call of 105 is only implemented in NTVCM -- it's not a standard CP/M 2.2 call */

    long h, m, s, l;
    struct CPMTimeValue t;
    t.h = t.m = t.s = t.l = 0;

    bdos( 105, &t );
    h = t.h;
    m = t.m;
    s = t.s;
    l = t.l;

    return h * 3600000 + m * 60000 + s * 1000 + l * 10;
} /*get_ms*/

#else /* no elif with old compilers */

#ifdef DOSTIME

void print_time_now()
{
    /* Make a DOS interrupt call to get the time */

    union REGS wrIn, wrOut;

    wrIn.h.ah = 0x2c;
    intdos( &wrIn, &wrOut );
    printf( "current time: %02d:%02d:%02d.%02d\n", wrOut.h.ch, wrOut.h.cl, wrOut.h.dh, wrOut.h.dl );
    fflush( stdout );
} /*print_time_now*/

long get_ms()
{
    /* this function takes about 3 milliseconds on the original IBM PC */

    long h, m, s, l;
    union REGS wrIn, wrOut;

    wrIn.h.ah = 0x2c;
    intdos( &wrIn, &wrOut );

    h = wrOut.h.ch;
    m = wrOut.h.cl;
    s = wrOut.h.dh;
    l = wrOut.h.dl;

    return h * 3600000 + m * 60000 + s * 1000 + l * 10;
} /*get_ms*/

#else

int print_time_now() { return 0; }

long get_ms()
{
    struct tm t;
    long hs = 0;

    dostime( &t );

    hs = t.tm_hsec + (long) t.tm_sec * 100 + (long) t.tm_min * 60 * 100 + (long) t.tm_hour * 24 * 60 * 100;

    return hs * 10;
}

#endif
#endif

int main( argc, argv ) int argc; char * argv[];
{
    long start_time, end_time;

    if ( 2 == argc )
        sscanf( argv[ 1 ], "%d", &g_Iterations ); /* no atoi in MS C 1.0 */

    start_time = get_ms();

    FindSolution( 0 );
    FindSolution( 1 );
    FindSolution( 4 );

    end_time = get_ms();

    printf( "runtime in ms:   %ld\n", end_time - start_time );
    printf( "move count:      %ld\n", g_Moves ); /* 6493 * g_Iterations */
    printf( "iteration count: %d\n", g_Iterations );
    printf( "method:          %s\n",
            ( WinMethod == UseFunPointers ) ? "function pointers" :
            ( WinMethod == UseWinner2 ) ? "winner2" :
            ( WinMethod == UseLookForWinner ) ? "look for winner" :
            "invalid method" );
    return 0;
} /*main*/

