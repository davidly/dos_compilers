
'BEGIN''INTEGER' COLOR1,COLOR2,COLOR3,COLOR4,
       ROW,COL,OLDROW,OLDCOL,MAXCOL;
'INTEGER''ARRAY' HYP[1:4],BOARD[1:10,1:4],WHITES,BLACKS[1:10];
'BOOLEAN''ARRAY' OLDMAT,NEWMAT[1:4];

'PROCEDURE' PATERN(ROW); 'VALUE' ROW; 'INETEGR' ROW;
'BEGIN''INTEGER' COL;
       'FOR' COL:=1,2,3,4 'DO'
       'IF' BOARD[ROW,COL]=1 'THEN' TEXT(1,"RED ")
       'ELSE''IF' BOARD[ROW,COL]=2 'THEN' TEXT(1,"BLUE ")
       'ELSE''IF' BOARD[ROW,COL]=3 'THEN' TEXT(1,"GREEN ")
       'ELSE''IF' BOARD[ROW,COL]=4 'THEN' TEXT(1,"YELLOW ")
       'ELSE''IF' BOARD[ROW,COL]=5 'THEN' TEXT(1,"BLACK ")
       'ELSE''IF' BOARD[ROW,COL]=6 'THEN' TEXT(1,"WHITE ")
       'ELSE' TEXT(1,"SPACE ");
'END' PRINT PATTERN;

'PROCEDURE' PRINTROW;
'BEGIN' TEXT(1,"*NMy guess "); WRITE(1,ROW);
       TEXT(1," is: ");
PATERN(ROW);
'END' PRINT THE CURRENT ROW;



START: TEXT(1,"*N*NMastermind Codebreaker*NVersion 1 or 2 ?");
       MAXCOL:=READ(7);
       'IF''NOT' (MAXCOL=1 'OR' MAXCOL=2)'THEN''GOTO' START;
       MAXCOL:=MAXCOL+5;
ROW:=1;

       'FOR' COLOR1:=1 'STEP' 1 'UNTIL' MAXCOL 'DO'
       'FOR' COLOR2:=2 'STEP' 1 'UNTIL' MAXCOL,1 'DO'
       'FOR' COLOR3:=3 'STEP' 1 'UNTIL' MAXCOL,1,2 'DO'
       'FOR' COLOR4:=4 'STEP' 1 'UNTIL' MAXCOL,1,2,3 'DO'
       'BEGIN'
'INTEGER' BLACK,WHITE;
       HYP[1]:=COLOR1; HYP[2]:=COLOR2;
       HYP[3]:=COLOR3; HYP[4]:=COLOR4;
'COMMENT' SET UP THE HYPOTHESIS ROW.
A ROW IS CONSISTENT WITH ALL PREVIOUS ROWS IF IT
GIVES RISE TO THE SAME NUMBER OF BLACK AND WHITE INFORMATION
PEGS AS THOSE ROWS;
'FOR' OLDROW:=1 'STEP' 1 'UNTIL' ROW-1 'DO'
'BEGIN'
       BLACK:=0;
       'FOR' COL:=1,2,3,4 'DO'
       'BEGIN''BOOLEAN' TEMP;
       TEMP:=OLDMAT[COL]:=NEWMAT[COL]:= HYP[COL]=BOARD[OLDROW,COL];
       'IF' TEMP 'THEN' BLACK:=BLACK+1;
       'END';
       'IF' BLACK#BLACKS[OLDROW] 'THEN''GOTO' NOT VIABLE;
       WHITE:=0;
       'FOR' COL:=1,2,3 'DO'
       'FOR' OLDCOL:=COL+1 'STEP' 1 'UNTIL' 4 'DO'
       'BEGIN'
       'IF' HYP[COL]=BOARD[OLDROW,OLDCOL] 'THEN'
              'BEGIN''IF''NOT' (NEWMAT[COL] 'OR' OLDMAT[OLDCOL]) 'THEN'
                      'BEGIN' NEWMAT[COL]:=OLDMAT[OLDCOL]:='TRUE';
                      WHITE:=WHITE+1;
                      'END';
              'END';
       'IF' HYP[OLDCOL]=BOARD[OLDROW,COL] 'THEN'
              'BEGIN''IF''NOT' (NEWMAT[OLDCOL] 'OR' OLDMAT[COL]) 'THEN'
                      'BEGIN' NEWMAT[OLDCOL]:=OLDMAT[COL]:='TRUE';
                      WHITE:=WHITE+1;
                      'END';
              'END';
       'END';
       'IF' WHITE#WHITES[OLDROW] 'THEN''GOTO' NOT VIABLE;
'END' LOOK AT EACH PREVIOUS ROW;
'COMMENT' AT THIS POINT THE HYPOTHESIS ROW IS VIABLE;
       'FOR' COL:=1 'STEP' 1 'UNTIL' 4 'DO' BOARD[ROW,COL]:=HYP[COL];
               PRINTROW;
JUNK:          TEXT(1,"*NHow many black pegs ? ");
               BLACKS[ROW]:=READ(7);
               'IF' BLACKS[ROW]=4 'THEN'
               'BEGIN' TEXT(1,"Thanks for the game");
                       'GOTO' START;
               'END' PROBLEM SOLVED
               'ELSE''IF' BLACKS[ROW]=3 'THEN' WHITES[ROW]:=0
               'ELSE'
               'BEGIN'
                       'IF' BLACKS[ROW]<0 'OR' BLACKS[ROW]>4 'THEN'
                       'BEGIN' TEXT(1,"TWIT !!"); 'GOTO' JUNK;
                       'END';
                       TEXT(1,"How many white pegs ? ");
                       WHITES[ROW]:=READ(7);
                       'IF' WHITES[ROW]<0 'OR'
                       WHITES[ROW]+BLACKS[ROW]>4 'THEN'
                       'BEGIN' TEXT(1,"TWIT !!"); 'GOTO' JUNK;
                       'END';
               'END';
   ROW:=ROW+1;
   'IF' ROW=10 'THEN'
      'BEGIN'
       TEXT(1,"*NWELL DONE, YOU WIN !!");
   'GOTO' START;
   'END';

NOT VIABLE:
'END' LOOK AT EACH POSSIBLE ROW;

       TEXT(1,"*NTwit !!! you made a mistake");
       'GOTO' START;
'END' OF MASTERMIND CODEBREAKER
'FINISH'



