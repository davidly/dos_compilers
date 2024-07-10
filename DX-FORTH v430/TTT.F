( prove you can't win at tic-tac-toe if the opponent is competent. expected visited board positions: 6493 )

VARIABLE board 9 ALLOT
VARIABLE moves
VARIABLE alpha
VARIABLE beta
VARIABLE recursionDepth
VARIABLE piecemove
VARIABLE val
VARIABLE boardIndex
VARIABLE score

6 CONSTANT scoreWin
5 CONSTANT scoreTie
4 CONSTANT scoreLose
9 CONSTANT scoreMax
2 CONSTANT scoreMin
0 CONSTANT scoreInvalid

0 CONSTANT pieceBlank
1 CONSTANT pieceX
2 CONSTANT pieceO

board 0 + CONSTANT B0
board 1 + CONSTANT B1
board 2 + CONSTANT B2
board 3 + CONSTANT B3
board 4 + CONSTANT B4
board 5 + CONSTANT B5
board 6 + CONSTANT B6
board 7 + CONSTANT B7
board 8 + CONSTANT B8

: LOOKFORWINNER
    B0 C@
    DUP pieceBlank <> IF
        DUP B1 C@ = IF DUP B2 C@ = IF EXIT THEN THEN
        DUP B3 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
    THEN
    DROP

    B1 C@
    DUP pieceBlank <> IF DUP B4 C@ = IF DUP B7 C@ = IF EXIT THEN THEN THEN
    DROP

    B2 C@
    DUP pieceBlank <> IF DUP B5 C@ = IF DUP B8 C@ = IF EXIT THEN THEN THEN
    DROP

    B3 C@
    DUP pieceBlank <> IF DUP B4 C@ = IF DUP B5 C@ = IF EXIT THEN THEN THEN
    DROP

    B6 C@
    DUP pieceBlank <> IF DUP B7 C@ = IF DUP B8 C@ = IF EXIT THEN THEN THEN
    DROP

    B4 C@
    DUP pieceBlank <> IF
        DUP B0 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
        DUP B2 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
    THEN
    DROP

    pieceBlank
    ;

: dumpboard
    ." board: "
    9 0 DO
        I board + C@ .
    LOOP
    CR
    ;

: MINMAX ( stack: alpha beta )
    1 moves +!
    0 val !

    recursionDepth @ 3 > IF
        LOOKFORWINNER
        DUP pieceBlank <> IF
            pieceX = IF scoreWin ELSE scoreLose THEN
            val !
        ELSE
            DROP recursionDepth @ 8 = IF scoreTie val ! THEN
        THEN
    THEN

    0 val @ = IF
        recursionDepth @ 1 AND IF
            scoreMin val !
            pieceX pieceMove !
        ELSE
            scoreMax val !
            pieceO pieceMove !
        THEN

        beta !
        alpha !
        0 boardIndex !

        BEGIN boardIndex @ 9 < WHILE
            boardIndex @ board + C@ 0 = IF
                pieceMove @ board boardIndex @ + C!
                boardIndex @ piecemove @ val @ alpha @ beta @       \ save locals on stack
                1 recursionDepth +!
                alpha @ beta @ RECURSE
                -1 recursionDepth +!
                score !
                beta ! alpha ! val ! pieceMove ! boardIndex !       \ restore locals

                pieceBlank  boardIndex @ board + C!

                pieceX pieceMove @ = IF
                    score @ val @ > IF
                        score @ val !
                        scoreWin val @ = val @ beta @ < INVERT OR IF
                            10 boardIndex !
                        ELSE
                            val @ alpha @ > IF val @ alpha ! THEN
                        THEN
                    THEN
                ELSE
                    score @ val @ < IF
                        score @ val !
                        scoreLose val @ = val @ alpha @ > INVERT OR IF
                            10 boardIndex !
                        ELSE
                            val @ beta @ < IF val @ beta ! THEN
                        THEN
                    THEN
                THEN
            THEN
            1 boardIndex +!
        REPEAT
    ELSE
        DROP DROP
    THEN

    val @
    ;

: RUNIT  ( move -- )
    pieceX
    OVER board + C!               \ make the move
    0 recursionDepth !
    scoreMin scoreMax MINMAX

    scoreTie <> IF ." there's a bug somewhere" THEN

    pieceBlank
    OVER board + C!               \ restore the board to the original state
    DROP
    ;

: TTT

    board 9 pieceBlank FILL           ( for i := 0 to 8 do board[i] := pieceBlank; )

    10 0 DO
        0 moves !
        0 RUNIT                           ( runit{ 0 }; )
        1 RUNIT                           ( runit{ 1 }; )
        4 RUNIT                           ( runit{ 4 }; )
    LOOP

    ." 10 iterations" cr
    ." moves evaluated: " MOVES ? CR ( WriteLn{ 'moves evaluated:  ', evaluated }; )
;
