CC  TEXT.FOR - Illustrates text output functions including:
CC             clearscreen      getbkcolor       gettextcolor
CC             gettextposition outtext          setbkcolor
CC             settextcolor    settextposition
CC

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2          dummy2, blink, fgd, oldfgd
      INTEGER*4          dummy4, bgd, oldbgd
      CHARACTER*4        str
      RECORD / rccoord / curpos

C
C     Save original foreground, background, and text position.
C
      oldfgd = gettextcolor()
      oldbgd = getbkcolor()
      CALL clearscreen( $GCLEARSCREEN )
C
C     First time no blink, second time blinking.
C
      DO blink = 0, 16, 16
C
C        Loop through 8 background colors.
C
         DO bgd = 0, 7
            dummy4 = setbkcolor( bgd )
            CALL settextposition( INT2( bgd + 1 ) + ((blink / 16) * 8),
     +             1, curpos )
            dummy2 = settextcolor( 15 )
            WRITE (str, '(I4 )') bgd
            CALL outtext( 'Back:' // str(3:4) // '  Fore:' )
C
C           Loop through 16 foreground colors.
C
            DO fgd = 0, 15
               dummy2 = settextcolor( fgd + blink )
               WRITE (str, '(I4)') fgd + blink
               CALL outtext( str )
            END DO
         END DO
      END DO

      WRITE (*, '(///// A \)') ' Press ENTER to exit . . . '
      READ (*,*)

C
C     Restore original foreground and background.
C
      dummy2 = settextcolor( oldfgd )
      dummy4 = setbkcolor( oldbgd )
      CALL clearscreen( $GCLEARSCREEN )
      END
