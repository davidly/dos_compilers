( Prove you can't win at tic-tac-toe if the opponent is competent. )
( Expected visited board positions: 6493 )

(  board: 0 1 2 )
(         3 4 5 )
(         6 7 8 )
( Each search owns a DO loop; I survives recursive calls. )
( Pass the last move explicitly; LEAVE ends only this search loop. )

( true global variables )
VARIABLE board 9 ALLOT
VARIABLE moves
VARIABLE recursionDepth

( effectively locals in MINMAX )
VARIABLE alpha
VARIABLE beta
VARIABLE pieceMove
VARIABLE val

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

: WIN0 ( piece -- winner )
  DUP B1 C@ = IF DUP B2 C@ = IF EXIT THEN THEN
  DUP B3 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
  DUP B4 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN1 ( piece -- winner )
  DUP B0 C@ = IF DUP B2 C@ = IF EXIT THEN THEN
  DUP B4 C@ = IF DUP B7 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN2 ( piece -- winner )
  DUP B0 C@ = IF DUP B1 C@ = IF EXIT THEN THEN
  DUP B5 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DUP B4 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN3 ( piece -- winner )
  DUP B4 C@ = IF DUP B5 C@ = IF EXIT THEN THEN
  DUP B0 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN4 ( piece -- winner )
  DUP B3 C@ = IF DUP B5 C@ = IF EXIT THEN THEN
  DUP B1 C@ = IF DUP B7 C@ = IF EXIT THEN THEN
  DUP B0 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DUP B2 C@ = IF DUP B6 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN5 ( piece -- winner )
  DUP B3 C@ = IF DUP B4 C@ = IF EXIT THEN THEN
  DUP B2 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN6 ( piece -- winner )
  DUP B7 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DUP B0 C@ = IF DUP B3 C@ = IF EXIT THEN THEN
  DUP B2 C@ = IF DUP B4 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN7 ( piece -- winner )
  DUP B6 C@ = IF DUP B8 C@ = IF EXIT THEN THEN
  DUP B1 C@ = IF DUP B4 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: WIN8 ( piece -- winner )
  DUP B6 C@ = IF DUP B7 C@ = IF EXIT THEN THEN
  DUP B2 C@ = IF DUP B5 C@ = IF EXIT THEN THEN
  DUP B0 C@ = IF DUP B4 C@ = IF EXIT THEN THEN
  DROP pieceBlank ;
: LOOKFORWINNER ( lastMove -- winner )
    DUP board + C@ SWAP
    DUP 0 = IF DROP WIN0 EXIT THEN
    DUP 1 = IF DROP WIN1 EXIT THEN
    DUP 2 = IF DROP WIN2 EXIT THEN
    DUP 3 = IF DROP WIN3 EXIT THEN
    DUP 4 = IF DROP WIN4 EXIT THEN
    DUP 5 = IF DROP WIN5 EXIT THEN
    DUP 6 = IF DROP WIN6 EXIT THEN
    DUP 7 = IF DROP WIN7 EXIT THEN
    DROP WIN8 ;

: dumpboard
    ." board: "
    9 0 DO
        I board + C@ .
    LOOP
    CR
    ;

: MINMAX ( alpha beta lastMove -- alpha beta score )
    1 moves +!
    0 val !

    recursionDepth @ 3 > IF
        LOOKFORWINNER
        DUP pieceBlank <> IF
            pieceX = IF scoreWin ELSE scoreLose THEN
            val !
        ELSE
            DROP
            recursionDepth @ 8 = IF scoreTie val ! THEN
        THEN
    ELSE
        DROP
    THEN

    0 val @ = IF
        recursionDepth @ 1 AND IF
            scoreMin val !
            pieceX pieceMove !
        ELSE
            scoreMax val !
            pieceO pieceMove !
        THEN

        2DUP beta ! alpha !

        9 0 DO
            I board + DUP C@ 0 = IF
                pieceMove @ OVER C!
                pieceMove @ val @
                1 recursionDepth +!

                alpha @ beta @ I RECURSE

                -1 recursionDepth +!
                >R
                beta ! alpha ! val ! pieceMove !
                pieceBlank SWAP C!
                R>

                pieceX pieceMove @ = IF
                    DUP val @ > IF
                        DUP val !
                        DUP scoreWin = OVER beta @ < 0= OR IF
                            DROP LEAVE
                        ELSE
                            DUP alpha @ > IF DUP alpha ! THEN
                        THEN
                    THEN
                ELSE
                    DUP val @ < IF
                        DUP val !
                        DUP scoreLose = OVER alpha @ > 0= OR IF
                            DROP LEAVE
                        ELSE
                            DUP beta @ < IF DUP beta ! THEN
                        THEN
                    THEN
                THEN
                DROP
            ELSE
                DROP
            THEN
        LOOP
    THEN

    val @
    ;

: RUNIT  ( move -- )
    pieceX
    OVER board + C!       ( make the move )
    0 recursionDepth !
    DUP >R
    scoreMin scoreMax R> MINMAX

    scoreTie <> IF ." there's a bug somewhere" THEN
    DROP DROP             ( remove alpha and beta )

    pieceBlank
    SWAP board + C!       ( restore the board to the original state )
    ;

: TTT
    board 9 pieceBlank FILL

    ( all other first moves are reflections of these 3 )
    10 0 DO
        0 moves !
        0 RUNIT
        1 RUNIT
        4 RUNIT
    LOOP

    ." 10 iterations" CR
    ." moves evaluated: " moves @ . CR
;

TTT
BYE
