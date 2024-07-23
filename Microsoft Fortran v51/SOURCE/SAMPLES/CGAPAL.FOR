CC  CGAPAL.FOR - Illustrates CGA palettes using:
CC               selectpalette

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2        status2
      INTEGER*4        status4, bkcolor(8)
      CHARACTER*7      bkname(8)
      CHARACTER*40     str
      RECORD /rccoord/ curpos

      DATA bkcolor / $BLACK , $BLUE    , $GREEN , $CYAN   ,
     +               $RED   , $MAGENTA , $BROWN , $WHITE  /
      DATA bkname  / 'BLACK', 'BLUE'   , 'GREEN', 'CYAN'  ,
     +               'RED'  , 'MAGENTA', 'BROWN', 'WHITE' /
C
C     Set video mode.
C
      IF( setvideomode( $MRES4COLOR ) .EQ. 0 )
     +    STOP 'Error:  cannot set CGA color mode'
C
C     Palette loop
C
      DO i = 0, 3
         status2 = selectpalette( i )
C
C        Background color loop
C
         DO k = 1, 8
            CALL clearscreen( $GCLEARSCREEN )
            status4 = setbkcolor( bkcolor(k) )
            CALL settextposition( 1, 1, curpos )
            WRITE (str, 9000) bkname(k), i
            CALL outtext( str )
C
C           Foreground color loop
C
            DO j = 1, 3
               status2 = setcolor( INT4( j ) )
               status2 = ellipse( $GFILLINTERIOR, 100, j * 30, 220,
     +                           80 + (j * 30))
            END DO
            READ (*,*)    ! Wait for ENTER to be pressed
         END DO
      END DO

      status2 = setvideomode( $DEFAULTMODE )

 9000 FORMAT ('Background: ', A, 10x, 'Palette: ', I2)

      END 
