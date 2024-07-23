CC  CGA.FOR - Demonstrates CGA colors.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2 dummy2, i, j, k
      INTEGER*4 dummy4
      INTEGER*4 bkcolor(8) /
     +          $BLACK, $BLUE   , $GREEN, $CYAN,
     +          $RED  , $MAGENTA, $BROWN, $WHITE /

      CHARACTER*7  bkcolorname(8) /
     +             'BLACK', 'BLUE'   , 'GREEN', 'CYAN',
     +             'RED'  , 'MAGENTA', 'BROWN', 'WHITE' /

      RECORD / rccoord / curpos

      IF( setvideomode( $MRES4COLOR ) .EQ. 0 )
     +    STOP 'Error:  cannot set CGA graphics mode'
 
      DO i = 0, 3
         dummy2 = selectpalette( i )
         DO k = 1, 8
            dummy4 = setbkcolor( bkcolor(k) )
            DO j = 0, 3
               CALL settextposition( 1, 1, curpos )
               WRITE (*, 9000) bkcolorname(k), i, j
               dummy2 = setcolor( INT4( j ) )
               dummy2 = rectangle( $GFILLINTERIOR, 160, 100, 320, 200 )
               READ (*,*)     ! Wait for ENTER key to be pressed
            END DO
         END DO
      END DO
      dummy2 = setvideomode( $DEFAULTMODE )

 9000 FORMAT( ' background color: ', A / ' palette:', I3 /
     +        ' color:  ', I3 / )

      END
