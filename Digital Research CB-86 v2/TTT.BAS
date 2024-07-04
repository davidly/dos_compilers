rem coded for CBASIC Compiler CB-80      21 May 83  Version 2.0
rem Tic Tac Toe solving app that learns what WOPR learned: you can't win
rem Only three starting positions are examined. Others are just reflections of these
rem b%   -- The board
rem al%  -- Alpha, for pruning
rem be%  -- Beta, for pruning
rem l%   -- Top-level loop iteration
rem mv%  -- the first move taken
rem wi%  -- The winning piece (0 none, 1 X, 2, O )
rem re%  -- Resulting score of 4000/minmax board position. 5 draw, 6 X win, 4 Y win
rem sX%  -- Stack arrays for "recursion" X can be P, V, A, or B for those variables.
rem v%   -- Value of a board position
rem st%  -- Stack Pointer. Even for alpha/beta pruning Minimize plys, Odd for Maximize
rem p%   -- Current position where a new piece is played
rem mc%  -- Move count total for debugging. Should be a multiple of 6493
rem Note: Can't use real recursion with GOSUB because stack is limited to roughly 5 deep
rem       BASIC doesn't support goto/gosub using arrays for target line numbers
rem build like this:
rem    ntvdm -t cb86 tttcb86
rem    ntvdm -t link86 tttcb86 = tttcb86

     li% = val( command$ )
     if 0 = li% then li% = 1
     dim b%(9)
     dim sp%(10)
     dim sv%(10)
     dim sa%(10)
     dim sb%(10)
     mc% = 0
     for l% = 1 to li%
     mv% = 0 : p% = 0
     mc% = 0
     al% = 2
     be% = 9
     b%(mv%) = 1
     goto 4000
55   b%(mv%) = 0
     mv% = 1 : p% = 1
     b%(mv%) = 1
     al% = 2
     be% = 9
     goto 4000
65   b%(mv%) = 0
     mv% = 4 : p% = 4
     b%(mv%) = 1
     al% = 2
     be% = 9
     goto 4000
75   b%(mv%) = 0
     next l%
87   print "iterations: "; li%
     print "move count: "; mc%
     stop

rem this version is slower but works if there are no computed gotos

2000 wi% = b%( 0 )
     if 0 = wi% then goto 2100
     if wi% = b%( 1 ) and wi% = b%( 2 ) then goto 4106
     if wi% = b%( 3 ) and wi% = b%( 6 ) then goto 4106
2100 wi% = b%( 3 )
     if 0 = wi% then goto 2200
     if wi% = b%( 4 ) and wi% = b%( 5 ) then goto 4106
2200 wi% = b%( 6 )
     if 0 = wi% then goto 2300
     if wi% = b%( 7 ) and wi% = b%( 8 ) then goto 4106
2300 wi% = b%( 1 )
     if 0 = wi% then goto 2400
     if wi% = b%( 4 ) and wi% = b%( 7 ) then goto 4106
2400 wi% = b%( 2 )
     if 0 = wi% then goto 2500
     if wi% = b%( 5 ) and wi% = b%( 8 ) then goto 4106
2500 wi% = b%( 4 )
     if 0 = wi% then goto 4106
     if wi% = b%( 0 ) and wi% = b%( 8 ) then goto 4106
     if wi% = b%( 2 ) and wi% = b%( 6 ) then goto 4106
     wi% = 0
     goto 4106

3000 wi% = b%(0)
     if ( ( wi% = b%(1) ) and ( wi% = b%(2) ) ) then goto 4106
     if ( ( wi% = b%(3) ) and ( wi% = b%(6) ) ) then goto 4106
     if ( ( wi% = b%(4) ) and ( wi% = b%(8) ) ) then goto 4106
     wi% = 0
     go to 4106

3010 wi% = b%(1)
     if ( ( wi% = b%(0) ) and ( wi% = b%(2) ) ) then goto 4106
     if ( ( wi% = b%(4) ) and ( wi% = b%(7) ) ) then goto 4106
     wi% = 0
     go to 4106

3020 wi% = b%(2)
     if ( ( wi% = b%(0) ) and ( wi% = b%(1) ) ) then goto 4106
     if ( ( wi% = b%(5) ) and ( wi% = b%(8) ) ) then goto 4106
     if ( ( wi% = b%(4) ) and ( wi% = b%(6) ) ) then goto 4106
     wi% = 0
     go to 4106

3030 wi% = b%(3)
     if ( ( wi% = b%(4) ) and ( wi% = b%(5) ) ) then goto 4106
     if ( ( wi% = b%(0) ) and ( wi% = b%(6) ) ) then goto 4106
     wi% = 0
     go to 4106

3040 wi% = b%(4)
     if ( ( wi% = b%(0) ) and ( wi% = b%(8) ) ) then goto 4106
     if ( ( wi% = b%(2) ) and ( wi% = b%(6) ) ) then goto 4106
     if ( ( wi% = b%(1) ) and ( wi% = b%(7) ) ) then goto 4106
     if ( ( wi% = b%(3) ) and ( wi% = b%(5) ) ) then goto 4106
     wi% = 0
     go to 4106

3050 wi% = b%(5)
     if ( ( wi% = b%(3) ) and ( wi% = b%(4) ) ) then goto 4106
     if ( ( wi% = b%(2) ) and ( wi% = b%(8) ) ) then goto 4106
     wi% = 0
     go to 4106

3060 wi% = b%(6)
     if ( ( wi% = b%(7) ) and ( wi% = b%(8) ) ) then goto 4106
     if ( ( wi% = b%(0) ) and ( wi% = b%(3) ) ) then goto 4106
     if ( ( wi% = b%(4) ) and ( wi% = b%(2) ) ) then goto 4106
     wi% = 0
     go to 4106

3070 wi% = b%(7)
     if ( ( wi% = b%(6) ) and ( wi% = b%(8) ) ) then goto 4106
     if ( ( wi% = b%(1) ) and ( wi% = b%(4) ) ) then goto 4106
     wi% = 0
     go to 4106

3080 wi% = b%(8)
     if ( ( wi% = b%(6) ) and ( wi% = b%(7) ) ) then goto 4106
     if ( ( wi% = b%(2) ) and ( wi% = b%(5) ) ) then goto 4106
     if ( ( wi% = b%(0) ) and ( wi% = b%(4) ) ) then goto 4106
     wi% = 0
     go to 4106

4000 rem minmax function to find score of a board position
     rem recursion is simulated with gotos and arrays as stacks
     st% = 0
     v% = 0
     re% = 0
4100 mc% = mc% + 1
     rem print "{"; b%(0);b%(1);b%(2);b%(3);b%(4);b%(5);b%(6);b%(7);b%(8);"}";al%;be%;p%;st%
     if st% < 4 then goto 4150
     rem goto 2000
     on (p% + 1) goto 3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080
4106 if 0 = wi% then goto 4140
     if wi% = 1 then re% = 6: goto 4280
     re% = 4
     goto 4280
4140 if st% = 8 then re% = 5: goto 4280
4150 if st% and 1 then v% = 2 else v% = 9
     p% = 0
4180 if 0 <> b%(p%) then goto 4500
     if st% and 1 then b%(p%) = 1 else b%(p%) = 2
     sp%(st%) = p%
     sv%(st%) = v%
     sa%(st%) = al%
     sb%(st%) = be%
     st% = st% + 1
     goto 4100
4280 st% = st% - 1
     p% = sp%(st%)
     v% = sv%(st%)
     al% = sa%(st%)
     be% = sb%(st%)
     b%(p%) = 0
     if st% and 1 then goto 4340
     if re% = 4 then goto 4530
     if re% < v% then v% = re%
     if v% < be% then be% = v%
     if be% <= al% then goto 4520
     goto 4500
4340 if re% = 6 then goto 4530
     if re% > v% then v% = re%
     if v% > al% then al% = v%
     if al% >= be% then goto 4520
4500 p% = p% + 1
     if p% < 9 then goto 4180
4520 re% = v%
4530 if st% = 0 then on ( 1 + mv% ) goto 55, 65, 87, 87, 75
     goto 4280
     end
