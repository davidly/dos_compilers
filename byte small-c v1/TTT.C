#include <stdio.h>

#define true 1
#define false 0

#define ABPrune true         /* alpha beta pruning */
#define WinLosePrune true    /* stop early on win/lose */
#define ScoreWin 6
#define ScoreTie 5
#define ScoreLose  4
#define ScoreMax 9
#define ScoreMin 2
#define DefaultIterations 10

#define PieceX 1
#define PieceO 2
#define PieceBlank 0

#define ttype char

int g_Iterations;
int g_IMoves;
ttype g_board[ 9 ];

/*
    In Small-C v1.2 the "&&" operator doesn't work in LookForWinner. Use bitwise & instead.
*/

LookForWinner()
{
    int p;
    p = g_board[0]; /* faster as int than ttype on 8086 and Z80 */
    if ( PieceBlank != p )
    {
        if ( p == g_board[1] & p == g_board[2] )
            return p;

        if ( p == g_board[3] & p == g_board[6] )
            return p;
    }

    p = g_board[3];
    if ( PieceBlank != p & p == g_board[4] & p == g_board[5] )
        return p;

    p = g_board[6];
    if ( PieceBlank != p & p == g_board[7] & p == g_board[8] )
        return p;

    p = g_board[1];
    if ( PieceBlank != p & p == g_board[4] & p == g_board[7] )
        return p;

    p = g_board[2];
    if ( PieceBlank != p & p == g_board[5] & p == g_board[8] )
        return p;

    p = g_board[4];
    if ( PieceBlank != p )
    {
        if ( p == g_board[0] & p == g_board[8] )
            return p;

        if ( p == g_board[2] & p == g_board[6] )
            return p;
    }

    return PieceBlank;
} /*LookForWinner*/

MinMax( alpha, beta, depth ) ttype alpha; ttype beta; ttype depth; 
{
    ttype pieceMove, score;   /* better perf with char than int. out of registers so use stack */
    int z, p, value;    /* better perf with these as an int on Z80, 8080, and 8086 */

    g_IMoves++;

    if ( depth >= 4 )
    {
        p = LookForWinner();

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

    p = 0;
    while ( p < 9 )
    {
        if ( PieceBlank == g_board[ p ] )
        {
            g_board[p] = pieceMove;
            score = MinMax( alpha, beta, depth + 1 );
            g_board[p] = PieceBlank;

            if ( depth & 1 ) 
            {
                if ( ScoreWin == score )
                    return ScoreWin;

                if ( score > value )
                {
                    value = score;

                    if ( value >= beta )
                        return value;
                    if ( value > alpha )
                        alpha = value;
                }
            }
            else
            {
                if ( ScoreLose == score )
                    return ScoreLose;

                if ( score < value )
                {
                    value = score;

                    if ( value <= alpha )
                        return value;
                    if ( value < beta )
                        beta = value;
                }
            }
        }

        p++;
    }

    return value;
}  /*MinMax*/

FindSolution( position ) ttype position;
{
    int i;

    i = 0;
    while ( i < 9 )
    {
        g_board[ i ] = PieceBlank;
        i++;
    }

    g_board[ position ] = PieceX;
    i = 0;
    while ( i < g_Iterations )
    {
        g_IMoves = 0;
        MinMax( ScoreMin, ScoreMax, 0 );
        i++;
    }

    return g_IMoves;
} /*FindSolution*/

main()
{
    int moves;
    moves = 0;
    g_IMoves = 0;
    g_Iterations = DefaultIterations;

    moves = FindSolution( 0 );
    moves = moves + FindSolution( 1 );
    moves = moves + FindSolution( 4 );

    printf( "move count:      %d\n", moves ); /* 6493 * g_Iterations */
    printf( "iteration count: %d\n", g_Iterations );
    return 0;
} /*main*/

