CC  COLOR.FOR - Sets a medium resolution mode
CC              with maximum color choices. 

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2            dummy
      RECORD /videoconfig/ vc

C
C     Set mode for maximum number of colors.
C
      IF( setvideomode( $MAXCOLORMODE ) .EQ. 0 )
     +    STOP 'Error:  no color graphics capability'
      CALL getvideoconfig( vc )

      WRITE (*, 9000) vc.numcolors, vc.numxpixels, vc.numypixels
      READ (*,*)       ! Wait for ENTER key to be pressed
      CALL clearscreen( $GCLEARSCREEN )
      dummy = setvideomode( $DEFAULTMODE )

 9000 FORMAT( ' available colors: ', I5 / ' horizontal pixels:', I5 /
     +        ' vertical pixels:  ', I5 )

      END
