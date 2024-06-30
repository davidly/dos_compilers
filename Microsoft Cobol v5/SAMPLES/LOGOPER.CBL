      $set ans85 noosvs mf
      *******************************************************************
      *                                                                 *
      *                (C) Micro Focus Ltd. 1990                        *
      *                                                                 *
      *                      LOGOPER.CBL                                *
      *                                                                 *
      * This program gives an example of how to use the logical         *
      * call-by-name routines. It uses three, namely                    *
      *                                                                 *
      *    "CBL_OR"                                                     *
      *    "CBL_AND"                                                    *
      *    "CBL_XOR"                                                    *
      *                                                                 *
      * The program also uses a selection of other call-by-name         *
      * routines, mainly for screen handling.                           *
      *                                                                 *
      * The program puts a string of characters on the screen with      *
      * various attributes. These attributes are then manipulated       *
      * via the logical call-by-name routines - according to which      *
      * key has been pressed on the keyboard.                           *
      *                                                                 *
      * The program tends to use values in Hex, where their             *
      * significance is bitwise.                                        *
      *                                                                 *
      * The layout of a screen attribute byte is given below to         *
      * illustrate the effect that the logical call-by-names are        *
      * having.                                                         *
      *                                                                 *
      *                    Attribute Byte                               *
      *                    --------------                               *
      *    Bit    7     6     5     4     3     2     1     0           *
      *          BL    BR    BG    BB    FI    FR    FG    FB           *
      *                                                                 *
      *    where:                                                       *
      *        BL  -   make the foreground blink                        *
      *        BR, BG, BB  -   The RGB colour value for the background  *
      *        FI  -   make the foreground colour high intensity        *
      *        FR, FG, FB  -   The RGB colour value for the foreground  *
      *                                                                 *
      *    The RGB table is:                                            *
      *         R  G  B   Colour    High Intensity Colour               *
      *         0  0  0   Black     Grey                                *
      *         0  0  1   Blue      Light Blue                          *
      *         0  1  0   Green     Light Green                         *
      *         0  1  1   Cyan      Light Cyan                          *
      *         1  0  0   Red       Light Red                           *
      *         1  0  1   Magenta   Light Magenta                       *
      *         1  1  0   Brown     Yellow                              *
      *         1  1  1   White     Bright White                        *
      *                                                                 *
      *******************************************************************
       working-storage section.
       01  clr-char            pic x value space.
       01  clr-attr            pic x value x"0f".

       78  text-start          value 29.
       78  text-len            value 23.
       78  text-end            value 51.

       01  text-scr-pos.
           03  text-row        pic 9(2) comp-x value 12.
           03  text-col        pic 9(2) comp-x value text-start.
       01  text-char-buffer    pic x(text-len)
                               value "Text-in-various-colours".
       01  text-attr-buffer.
           03  first-word      pic x(4) value all x"0f".
           03  second-word     pic x(4) value all x"2c".
           03  third-word      pic x(7) value all x"14".
           03  third-space     pic x value x"30".
           03  fourth-word     pic x(7) value all x"59".
       01  text-length         pic 9(4) comp-x value text-len.

       01  char-read           pic x.
       01  char-length         pic 9(9) comp-5 value 1.

       01  quit-flag           pic 9 comp-x.
           88 not-ready-to-quit    value 0.
           88 ready-to-quit        value 1.

       01  csr-pos.
           03  csr-row         pic 9(2) comp-x value 12.
           03  csr-col         pic 9(2) comp-x value 39.
       01  csr-attr            pic x.
       01  csr-length          pic 9(4) comp-x value 1.

       01  blink-mask          pic x value x"80".
       01  steady-mask         pic x value x"7f".

       01  invert-mask         pic x(text-len) value all x"7f".

       78  instr-len           value 41.
       01  instr-length        pic 9(4) comp-x value instr-len.
       01  instr               pic x(instr-len)
               value "Press (L)eft, (R)ight, (I)nvert or (Q)uit".
       01  instr-pos.
           03  instr-row       pic 9(2) comp-x value 8.
           03  instr-col       pic 9(2) comp-x value 19.

       procedure division.

       main section.
           perform init-screen
           set not-ready-to-quit to true
           perform until ready-to-quit
               perform read-keyboard
               evaluate char-read
                   when "L"
                       perform csr-move-left
                   when "R"
                       perform csr-move-right
                   when "I"
                       perform invert-text
                   when "Q"
                       set ready-to-quit to true
               end-evaluate
           end-perform
           stop run
           .

       init-screen section.
           call "CBL_CLEAR_SCR" using clr-char
                                      clr-attr
           call "CBL_WRITE_SCR_CHARS" using instr-pos
                                            instr
                                            instr-length
           call "CBL_WRITE_SCR_CHARS" using text-scr-pos
                                            text-char-buffer
                                            text-length
           perform put-attrs-on-screen
           perform blink-cursor
           .

       read-keyboard section.
           call "CBL_READ_KBD_CHAR" using char-read
           call "CBL_TOUPPER" using char-read
                                    by value char-length
           .


       csr-move-left section.
           perform steady-cursor
           subtract 1 from csr-col
           if csr-col < text-start
               move text-end to csr-col
           end-if
           perform blink-cursor
           .

       csr-move-right section.
           perform steady-cursor
           add 1 to csr-col
           if csr-col > text-end
               move text-start to csr-col
           end-if
           perform blink-cursor
           .


       blink-cursor section.
      *
      * Turn on the blink bit at the current attribute.
      *
           call "CBL_READ_SCR_ATTRS" using csr-pos
                                           csr-attr
                                           csr-length
           call "CBL_OR" using blink-mask
                               csr-attr
                               by value 1
           call "CBL_WRITE_SCR_ATTRS" using csr-pos
                                            csr-attr
                                            csr-length
           .

       steady-cursor section.
      *
      * Turn off the blink bit at the current attribute.
      *
           call "CBL_READ_SCR_ATTRS" using csr-pos
                                           csr-attr
                                           csr-length
           call "CBL_AND" using steady-mask
                                csr-attr
                                by value 1
           call "CBL_WRITE_SCR_ATTRS" using csr-pos
                                            csr-attr
                                            csr-length
           .

       invert-text section.
      *
      * invert the bits that set the foreground colour, the background
      * colour, and the intensity bits, but leave the blink bit alone.
      *
           call "CBL_READ_SCR_ATTRS" using text-scr-pos
                                           text-attr-buffer
                                           text-length
           call "CBL_XOR" using invert-mask
                                text-attr-buffer
                                by value text-len
           perform put-attrs-on-screen
           .

       put-attrs-on-screen section.
           call "CBL_WRITE_SCR_ATTRS" using text-scr-pos
                                            text-attr-buffer
                                            text-length
           .
