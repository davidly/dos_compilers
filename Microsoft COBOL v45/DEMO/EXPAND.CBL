      $set ans85 mf noosvs
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     EXPAND.CBL                           *
      *                                                          *
      *    This program demonstrates a special expanding accept. *
      *    It uses the SIZE IS clause of the SCREEN SECTION to   *
      *    dynamically alter the size of the data item being     *
      *    accepted.                                             *
      *                                                          *
      *    The program repeats the same ACCEPT twenty times      *
      *    each time increasing the size of the data item by 1.  *
      *                                                          *
      ************************************************************
       special-names.
           cursor is cursor-pos.
       working-storage section.
       01 buffer pic x(20).
       01 buf-size pic 99.
       01 cursor-pos.
          02 line-p pic 99.
          02 col-p  pic 99.
       screen section.
       01 screen-1.
         02  value "Expanding accept (" line 1 column 1.
         02  pic x(20) using buffer SIZE IS buf-size line 1 column + 1
              auto.
         02  value ")" line 1 column + 1.
       procedure division.
       main-para.
            display space upon crt.
            move 1 to buf-size, line-p, col-p.
            perform with test after until buf-size = 20
                display screen-1
                accept  screen-1
                add 1 to buf-size, col-p
            end-perform.
            stop run.

