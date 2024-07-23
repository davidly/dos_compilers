CC  COLTEXT.FOR - Displays text color with various color or
CC                monochrome attributes.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2          dummy2, blink, fgd
      INTEGER*4          dummy4, bgd
      CHARACTER*2        str
      RECORD / rccoord / curpos

      CALL clearscreen( $GCLEARSCREEN )
      CALL outtext( 'Text color/monochrome attributes:' )
 
      DO  blink = 0, 16, 16
         DO bgd = 0, 7
            dummy4 = setbkcolor( bgd )
            CALL settextposition( INT2( bgd ) +
     +                          (( blink / 16 ) * 9) + 3, 1, curpos ) 
            dummy2 = settextcolor( 15 )
            WRITE (str, '(I2)') bgd
            CALL outtext( 'Back:' // str // '  Fore:' )
C
C           Loop through 16 foreground colors.  For monochrome,
C           these will be underscore and low/high intensity.
C
            DO fgd = 0, 15
               dummy2 = settextcolor( fgd + blink )
               WRITE (str, '(I2)') fgd + blink
               CALL outtext( '  ' // str )
            END DO
         END DO
      END DO

      CALL settextposition( 25, 1, curpos )
      CALL outtext( 'Press ENTER to exit' )
      READ (*,*)
      dummy2 = setvideomode( $DEFAULTMODE )
      END
