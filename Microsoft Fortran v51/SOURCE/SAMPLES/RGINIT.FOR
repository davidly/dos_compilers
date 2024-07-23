CC  RGINIT.FOR - Function to enter graphics mode for REALG.

$NOTRUNCATE
$NOTSTRICT

      INCLUDE  'FGRAPH.FI'

      LOGICAL FUNCTION fourcolors()

      INCLUDE  'FGRAPH.FD'

      INTEGER*2            dummy
      RECORD /videoconfig/ screen
      COMMON               screen
 
C
C     Set to maximum number of available colors.
C
      CALL getvideoconfig( screen )
      SELECT CASE( screen.adapter )
         CASE( $CGA, $OCGA )
            dummy = setvideomode( $MRES4COLOR )
         CASE( $EGA, $OEGA )
            dummy = setvideomode( $ERESCOLOR )
         CASE( $VGA, $OVGA )
            dummy = setvideomode( $VRES16COLOR )
         CASE DEFAULT
            dummy = 0
      END SELECT

      CALL getvideoconfig( screen )
      fourcolors = .TRUE.
      IF( dummy .EQ. 0 ) fourcolors = .FALSE.
      END
