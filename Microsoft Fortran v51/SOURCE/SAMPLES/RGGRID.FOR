CC  GRIDSHAPE - This subroutine plots data for the REALG program.

$NOTRUNCATE        ! required for some names to be significant
$NOTSTRICT         ! uses structures which are non-standard conforming


      INCLUDE  'FGRAPH.FI'

      SUBROUTINE gridshape( numc )

      INCLUDE  'FGRAPH.FD'

      INTEGER*2            dummy, numc, i
      CHARACTER*2          str
      DOUBLE PRECISION     bananas(21), x
      RECORD /videoconfig/ screen
      RECORD /wxycoord/    wxy
      RECORD /rccoord/     curpos
      COMMON               screen
C
C     Data for the graph
C
      DATA bananas /-0.3  , -0.2 , -0.224, -0.1, -0.5  ,
     +               0.21 ,  2.9 ,  0.3  ,  0.2,  0.0  ,
     +              -0.885, -1.1 , -0.3  , -0.2,  0.001,
     +               0.005,  0.14,  0.0  , -0.9, -0.13 , 0.31 /

C
C     Print colored words on the screen.
C
      IF( screen.numcolors .LT. numc ) numc = screen.numcolors - 1
      DO i = 1, numc
         CALL settextposition( i, 2, curpos )
         dummy = settextcolor( i )
         WRITE (str, '(I2)') i
         CALL outtext( 'Color ' // str )
      END DO
C
C     Draw a bordered rectangle around the graph.
C
      dummy = setcolor( 1 )
      dummy = rectangle_w( $GBORDER, -1.00, -1.00, 1.00, 1.00 )
      dummy = rectangle_w( $GBORDER, -1.02, -1.02, 1.02, 1.02 )
C
C     Plot the points.
C
      x = -0.90
      DO i = 1, 19
         dummy = setcolor( 2 )
         CALL    moveto_w( x, -1.0, wxy )
         dummy = lineto_w( x,  1.0 )
         CALL    moveto_w( -1.0, x, wxy )
         dummy = lineto_w(  1.0, x )
         dummy = setcolor( 14 )
         CALL    moveto_w( x - 0.1, bananas( i ), wxy )
         dummy = lineto_w( x, bananas( i + 1 ) )
         x     = x + 0.1
      END DO

      CALL    moveto_w( 0.9, bananas( i ), wxy )
      dummy = lineto_w( 1.0, bananas( i + 1 ) )
      dummy = setcolor( 3 )
      END
