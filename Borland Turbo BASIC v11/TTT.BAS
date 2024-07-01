1  rem Tic Tac Toe solving app that learns what WOPR learned: you can't win
2  rem Only three starting positions are examined. Others are just reflections of these
3  rem b%   -- The board
4  rem al%  -- Alpha, for pruning
5  rem be%  -- Beta, for pruning
6  rem l%   -- Top-level loop iteration
7  rem wi%  -- The winning piece (0 none, 1 X, 2, O )
8  rem re%  -- Resulting score of 4000/minmax board position. 5 draw, 6 X win, 4 Y win
9  rem sx%  -- Stack array for "recursion" X can be P, V, A, or B for those variables.
10 rem v%   -- Value of a board position
11 rem st%  -- Stack Pointer. Even for alpha/beta pruning Minimize plys, Odd for Maximize
12 rem p%   -- Current position where a new piece is played
14 rem rw%  -- Row in the Winner function (2000)
15 rem cw%  -- Column in the Winner function (2000)
18 rem mc%  -- Move count total for debugging. Should be a multiple of 6493
19 rem Note: Can't use real recursion with GOSUB because stack is limited to roughly 5 deep
20 rem       BASIC doesn't support goto/gosub using arrays for target line numbers
21 rem this version is modified for Turbo Basic to send results to the console
29 it% = 10
30 dim b%(9)
32 dim sp%(10)
34 dim sv%(10)
36 dim sa%(10)
37 dim sb%(10)
38 mc% = 0
39 s1$ = "start time: " + time$
40 for l% = 1 to it%
41 mc% = 0
42 al% = 2
43 be% = 9
44 b%(0) = 1
45 gosub 4000
58 al% = 2
59 be% = 9
60 b%(0) = 0
61 b%(1) = 1
62 gosub 4000
68 al% = 2
69 be% = 9
70 b%(1) = 0
71 b%(4) = 1
72 gosub 4000
73 b%(4) = 0
80 next l%
85 s2$ = "end time: " + time$
87 s$ = s1$
88 gosub 1000
89 s$ = s2$
90 gosub 1000
92 s$ = "for " + str$( it% ) + " iterations"
93 gosub 1000
94 s$ = "move count: " + str$( mc% )
95 gosub 1000
98 system
99 end

999 rem turbo basic sends print output to memory, which isn't helpful
1000 l% = len( s$ )
1010 for i% = 1 to l%
1020 c$ = mid$( s$, i%, 1 )
1040 reg 4, asc( c$)
1050 reg 1, &h0600
1060 call interrupt &h21
1070 next i%
1080 reg 4, 10
1090 reg 1, &h0600
1100 call interrupt &h21
1110 reg 4, 13
1120 reg 1, &h0600
1130 call interrupt &h21
1200 return

2000 wi% = b%( 0 )
2010 if 0 = wi% goto 2100
2020 if wi% = b%( 1 ) and wi% = b%( 2 ) then return
2030 if wi% = b%( 3 ) and wi% = b%( 6 ) then return
2100 wi% = b%( 3 )
2110 if 0 = wi% goto 2200
2120 if wi% = b%( 4 ) and wi% = b%( 5 ) then return
2200 wi% = b%( 6 )
2210 if 0 = wi% goto 2300
2220 if wi% = b%( 7 ) and wi% = b%( 8 ) then return
2300 wi% = b%( 1 )
2310 if 0 = wi% goto 2400
2320 if wi% = b%( 4 ) and wi% = b%( 7 ) then return
2400 wi% = b%( 2 )
2410 if 0 = wi% goto 2500
2420 if wi% = b%( 5 ) and wi% = b%( 8 ) then return
2500 wi% = b%( 4 )
2510 if 0 = wi% then return
2520 if wi% = b%( 0 ) and wi% = b%( 8 ) then return
2530 if wi% = b%( 2 ) and wi% = b%( 6 ) then return
2540 wi% = 0
2550 return

4000 rem minmax function to find score of a board position
4010 rem recursion is simulated with gotos
4030 st% = 0
4040 v% = 0
4060 re% = 0
4100 mc% = mc% + 1
4102 rem gosub 3000
4104 if st% < 4 then goto 4150
4105 gosub 2000
4106 if 0 = wi% then goto 4140
4110 if wi% = 1 then re% = 6: goto 4280
4115 re% = 4
4116 goto 4280
4140 if st% = 8 then re% = 5: goto 4280
4150 if st% and 1 then v% = 2 else v% = 9
4160 p% = 0
4180 if 0 <> b%(p%) then goto 4500
4200 if st% and 1 then b%(p%) = 1 else b%(p%) = 2
4210 sp%(st%) = p%
4230 sv%(st%) = v%
4245 sa%(st%) = al%
4246 sb%(st%) = be%
4260 st% = st% + 1
4270 goto 4100
4280 st% = st% - 1
4290 p% = sp%(st%)
4310 v% = sv%(st%)
4325 al% = sa%(st%)
4326 be% = sb%(st%)
4328 b%(p%) = 0
4330 if st% and 1 then goto 4340
4331 if re% = 4 then goto 4530
4332 if re% < v% then v% = re%
4334 if v% < be% then be% = v%
4336 if be% <= al% then goto 4520
4338 goto 4500
4340 if re% = 6 then goto 4530
4341 if re% > v% then v% = re%
4342 if v% > al% then al% = v%
4344 if al% >= be% then goto 4520
4500 p% = p% + 1
4505 if p% < 9 then goto 4180
4520 re% = v%
4530 if st% = 0 then return
4540 goto 4280

