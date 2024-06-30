      $set ans85 mf align(2)
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     TICTAC.CBL                           *
      *                                                          *
      *    This program demonstrates how to use a CRT.           *
      *                                                          *
      ************************************************************
       identification division.
           program-id. tictac.
       environment division.
       configuration section.
           source-computer. ibm-pc.
           object-computer. ibm-pc.
       special-names.
           console is crt.
       data division.
       working-storage section.
       01 tictac-00.
        02 tictac-q.
           03 game             pic x(10) value spaces.
           03 filler-0         pic x(70) value spaces.
           03 question         pic x(20) value spaces.
        02 filler.
           03 filler-1         pic x(414) value all spaces.
           03 tictac-00-0735   pic x(17) value "7บ      8บ      9".
           03 filler-2         pic x(64) value all spaces.
           03 tictac-00-0836   pic x(09) value "บ       บ".
           03 filler-3         pic x(71) value all spaces.
           03 tictac-00-0936   pic x(09) value "บ       บ".
           03 filler-4         pic x(64) value all spaces.
           03 tictac-00-1029 pic x(23) value "อออออออฮอออออออฮอออออออ".
           03 filler-5         pic x(63) value all spaces.
           03 tictac-00-1135   pic x(17) value "4บ      5บ      6".
           03 filler-6         pic x(64) value all spaces.
           03 tictac-00-1236   pic x(09) value "บ       บ".
           03 filler-7         pic x(71) value all spaces.
           03 tictac-00-1336   pic x(09) value "บ       บ".
           03 filler-8         pic x(64) value all spaces.
           03 tictac-00-1429 pic x(23) value "อออออออฮอออออออฮอออออออ".
           03 filler-9         pic x(63) value all spaces.
           03 tictac-00-1535   pic x(17) value "1บ      2บ      3".
           03 filler-10        pic x(64) value all spaces.
           03 tictac-00-1636   pic x(09) value "บ       บ".
           03 filler-11        pic x(71) value all spaces.
           03 tictac-00-1736   pic x(09) value "บ       บ".
           03 filler-12        pic x(595) value all spaces.
       01 entry-array.
           03 entry-char       pic x               occurs 9 times.
       01 check-array.
           03 check            pic s99     comp  occurs 9 times.
       01 xcount               pic 9(2)    comp.
       01 ocount               pic 9(2)    comp.
       01 factor               pic s9(2)   comp.
       01 char                 pic x.
       01 char9 redefines char pic 9.
       01 idx                  pic 9(2)    comp.
       01 result               pic 9(2)    comp.
       01 cursor-pos.
           03 row              pic 9(2)    comp  value 99.
           03 filler           pic 9(2)    comp  value 99.
       01 address-init.
           03 filler           pic 9(4)    value   1732.
           03 filler           pic 9(4)    value   1740.
           03 filler           pic 9(4)    value   1748.
           03 filler           pic 9(4)    value   1332.
           03 filler           pic 9(4)    value   1340.
           03 filler           pic 9(4)    value   1348.
           03 filler           pic 9(4)    value   0932.
           03 filler           pic 9(4)    value   0940.
           03 filler           pic 9(4)    value   0948.
       01 address-array        redefines   address-init.
           03 addr             pic 9(4)    occurs 9 times.
       01 location             pic 9(4).
       01 game-lines value     "147123311113332436978979".
           03 a                pic 9       occurs 8 times.
           03 b                pic 9       occurs 8 times.
           03 c                pic 9       occurs 8 times.
       01 i                    pic 9(2)    comp.
       01 j                    pic 9(2)    comp.
       01 moves                pic 9(2)    comp.

       78 clear-screen        value x"e4".
       78 sound-bell          value x"e5".

       procedure division.
       play-game section.
       play-1.
           perform with test after
               until char not = "Y" and char not = "y"
               call clear-screen
               display
                   "To select a square type a number between 1 and 9"
                   upon crt
               perform init
               move "Shall I start ? " to question
               perform get-reply
               if char = "Y" or char = "y"
                   move 10 to check(5)
                   perform put-move
               end-if
               perform new-move until game not = spaces
               move "Play again ?    " to question
               perform get-reply
           end-perform.

       play-stop.
           display space
           stop run.

       get-reply section.
           display tictac-q at 0201
           accept char at 0317 with no-echo auto-skip
           move spaces to question
           display tictac-00 at 0201.

       init section.
           move "y" to char
           move spaces to entry-array
           move low-values to check-array
           move spaces to game
           move zero to moves.

       new-move section.
           perform get-move with test after until char9 not = 0
           perform move-check
           if game not = "stalemate"
               move low-values to check-array
               perform check-line varying i from 1 by 1
                               until i > 8 or game not = spaces
               if game not = "You win"
                   perform put-move
               end-if
               if game = "I win" or game = "You win"
                     perform varying idx from a(j) by b(j)
                                                until idx > c(j)
                         move addr(idx) to location
                         move entry-char(idx) to char
                         display char at location with blink highlight
                     end-perform
               end-if
           end-if.

       check-line section.
           move zero to xcount,ocount,factor
           perform count-up varying idx from a(i) by b(i)
                                            until idx > c(i)
           if ocount = 0 or xcount = 0
               evaluate true
               when ocount = 2
                   if i = 4
                       move 6 to j
                       move zero to xcount,ocount
                       perform count-up varying idx from a(j) by b(j)
                                                until idx > c(j)
                       if xcount = 3
                           move 6 to i
                       end-if
                   end-if
                   if xcount not = 3
                       move 50 to factor
                       move "I win" to game
                       move i to j
                   end-if
               when xcount = 2
                   move 20 to factor
               when ocount = 1
                   move  4 to factor
               when xcount = 1
                   if entry-char(5) = "x"
                       move  1 to factor
                   else
                       move -1 to factor
                   end-if
               when ocount = 0
                   if xcount = 0
                       move  2 to factor
                   end-if
               end-evaluate
           end-if
           if xcount = 3
               move "You win" to game
               move i to j
           else
               perform varying idx from a(i) by b(i) until idx > c(i)
                   if entry-char(idx) = space
                       add factor to check(idx)
                   end-if
               end-perform
           end-if.

       count-up section.
           if entry-char(idx) = "X"        add 1 to xcount
           else if entry-char(idx) = "O"   add 1 to ocount.

       put-move section.
           move zero to idx
           move -99 to factor
           perform find-pos varying i from 1 by 1 until i > 9
           move "O" to entry-char(idx)
           perform move-check.

       move-check section.
           move addr(idx) to location
           move entry-char(idx) to char
           display char at location
           add 1 to moves
           if moves > 8 and game = spaces
               move "stalemate" to game
           end-if.

       find-pos section.
           if entry-char(5) = space
               move check(5) to factor
               move 5 to idx
           else
               if check(i) not < factor and entry-char(i) = space
                   move check(i) to factor
                   move i to idx
               end-if
           end-if.

       get-move section.
           display "Please select an empty square" at 0201
           move 0 to char9
           accept char9 at 0231 with auto-skip
           if char9 = 0
               call sound-bell
           else
               move char9 to idx
               if entry-char(idx) = space
                   move "X" to entry-char(idx)
               else
                   move 0 to char9
                   call sound-bell
               end-if
           end-if.
