1  REM Tic Tac Toe solving app that learns what WOPR learned: you can't win
2  REM Only three starting positions are examined. Others are just reflections of these
3  REM b%   -- The board
4  REM al%  -- Alpha, for pruning
5  REM be%  -- Beta, for pruning
6  REM l%   -- Top-level loop iteration
7  REM wi%  -- The winning piece (0 none, 1 X, 2, O )
8  REM re%  -- Resulting score of 4000/minmax board position. 5 draw, 6 X win, 4 Y win
9  REM sx%  -- Stack array for "recursion" X can be P, V, A, or B for those variables.
10 REM v%   -- Value of a board position
11 REM st%  -- Stack Pointer. Even for alpha/beta pruning Minimize plys, Odd for Maximize
12 REM p%   -- Current position where a new piece is played
14 REM rw%  -- Row in the Winner function (2000)
15 REM cw%  -- Column in the Winner function (2000)
18 REM mc%  -- Move count total for debugging. Should be a multiple of 6493
19 REM Note: Can't use real recursion with GOSUB because stack is limited to roughly 5 deep
20 REM       BASIC doesn't support goto/gosub using arrays for target line numbers
23 li% = VAL(COMMAND$)
24 IF 0 = li% THEN li% = 1
30 DIM b%(9)
32 DIM sp%(10)
34 DIM sv%(10)
36 DIM sa%(10)
37 DIM sb%(10)
38 mc% = 0
39 PRINT "start time: "; TIME$
40 FOR l% = 1 TO li%
41 mc% = 0
42 al% = 2
43 be% = 9
44 b%(0) = 1
45 GOSUB 4000
58 al% = 2
59 be% = 9
60 b%(0) = 0
61 b%(1) = 1
62 GOSUB 4000
68 al% = 2
69 be% = 9
70 b%(1) = 0
71 b%(4) = 1
72 GOSUB 4000
73 b%(4) = 0
74 REM print "mc: "; mc%; "  l is "; l%
80 NEXT l%
82 REM print elap$
83 PRINT "end time: "; TIME$
84 PRINT "iterations: "; li%
85 PRINT "final move count "; mc%
88 SYSTEM
100 END

2000 wi% = b%(0)
2010 IF 0 = wi% GOTO 2100
2020 IF wi% = b%(1) AND wi% = b%(2) THEN RETURN
2030 IF wi% = b%(3) AND wi% = b%(6) THEN RETURN
2100 wi% = b%(3)
2110 IF 0 = wi% GOTO 2200
2120 IF wi% = b%(4) AND wi% = b%(5) THEN RETURN
2200 wi% = b%(6)
2210 IF 0 = wi% GOTO 2300
2220 IF wi% = b%(7) AND wi% = b%(8) THEN RETURN
2300 wi% = b%(1)
2310 IF 0 = wi% GOTO 2400
2320 IF wi% = b%(4) AND wi% = b%(7) THEN RETURN
2400 wi% = b%(2)
2410 IF 0 = wi% GOTO 2500
2420 IF wi% = b%(5) AND wi% = b%(8) THEN RETURN
2500 wi% = b%(4)
2510 IF 0 = wi% THEN RETURN
2520 IF wi% = b%(0) AND wi% = b%(8) THEN RETURN
2530 IF wi% = b%(2) AND wi% = b%(6) THEN RETURN
2540 wi% = 0
2550 RETURN

4000 REM minmax function to find score of a board position
4010 REM recursion is simulated with gotos
4030 st% = 0
4040 v% = 0
4060 re% = 0
4100 mc% = mc% + 1
4102 REM gosub 3000
4104 IF st% < 4 THEN GOTO 4150
4105 GOSUB 2000
4106 IF 0 = wi% THEN GOTO 4140
4110 IF wi% = 1 THEN re% = 6: GOTO 4280
4115 re% = 4
4116 GOTO 4280
4140 IF st% = 8 THEN re% = 5: GOTO 4280
4150 IF st% AND 1 THEN v% = 2 ELSE v% = 9
4160 p% = 0
4180 IF 0 <> b%(p%) THEN GOTO 4500
4200 IF st% AND 1 THEN b%(p%) = 1 ELSE b%(p%) = 2
4210 sp%(st%) = p%
4230 sv%(st%) = v%
4245 sa%(st%) = al%
4246 sb%(st%) = be%
4260 st% = st% + 1
4270 GOTO 4100
4280 st% = st% - 1
4290 p% = sp%(st%)
4310 v% = sv%(st%)
4325 al% = sa%(st%)
4326 be% = sb%(st%)
4328 b%(p%) = 0
4330 IF st% AND 1 THEN GOTO 4340
4331 IF re% = 4 THEN GOTO 4530
4332 IF re% < v% THEN v% = re%
4334 IF v% < be% THEN be% = v%
4336 IF be% <= al% THEN GOTO 4520
4338 GOTO 4500
4340 IF re% = 6 THEN GOTO 4530
4341 IF re% > v% THEN v% = re%
4342 IF v% > al% THEN al% = v%
4344 IF al% >= be% THEN GOTO 4520
4500 p% = p% + 1
4505 IF p% < 9 THEN GOTO 4180
4520 re% = v%
4530 IF st% = 0 THEN RETURN
4540 GOTO 4280

