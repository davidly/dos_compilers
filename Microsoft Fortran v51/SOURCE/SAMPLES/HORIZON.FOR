CC  HORIZON.FOR - Illustrates VGA graphics with cycling of 256 colors.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2   MYRED, MYBLU, MYWHT, STEP
      PARAMETER ( MYRED = #000003FF )
      PARAMETER ( MYBLU = #003F0000 )
      PARAMETER ( MYWHT = #003F3F3F )
      PARAMETER ( STEP  = 21 )

      INTEGER*2        dummy, i, j
      INTEGER*4        rainbow(0:511), col, ngray
      RECORD /rccoord/ curpos
      RECORD /xycoord/ xy

C
C     Check to see if adapter can handle 256 colors.
C
      IF( setvideomode( $MRES256COLOR ) .EQ. 0 )
     +    STOP 'This program requires a VGA card.' 
C
C     Create the colors.
C
      DO col = 0, 63
         ngray = (col .OR. ISHFT( col,8 )) .OR. ISHFT( col,16 )
         rainbow(col)             = MYBLU .AND. ngray
         rainbow(col + 256)       = rainbow(col)
         rainbow(col + 64)        = MYBLU .OR. ngray
         rainbow(col + 64 + 256)  = rainbow(col + 64)
         rainbow(col + 128)       = MYRED .OR.
     +                            ( MYWHT .AND. .NOT. ngray )
         rainbow(col + 128 + 256) = rainbow( 64 + 128)
         rainbow(col + 192)       = MYRED .AND. .NOT. ngray
         rainbow(col + 192 + 256) = rainbow(col + 192)
      END DO
      CALL setvieworg( 160, 85, xy )
C
C     Draw shapes on screen.
C
      DO i = 0, 254
         dummy = setcolor( INT4( 255 - i ) )
         CALL    moveto(  i, i - 255, xy )
         dummy = lineto( -i, 255 - i )
         CALL    moveto( -i, i - 255, xy )
         dummy = lineto(  i, 255 - i )
         dummy = ellipse( $GBORDER, -i, -i / 2, i, i / 2 )
      END DO
C
C     Cycle through the colors.
C
      i = 0
      DO j = 1, 256
         dummy = remapallpalette( rainbow(i) )
         i     = MOD( i + STEP, 256 )
      END DO

      dummy = settextcolor( 15 )
      CALL settextposition( 25, 1, curpos )
      CALL outtext( 'Press ENTER to exit' )
      READ (*,*)
      dummy = setvideomode( $DEFAULTMODE ) 
      END
