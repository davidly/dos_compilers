CC  EGA.FOR - Demonstrates use of EGA palettes.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2        dummy2
      INTEGER*4        dummy4
      RECORD /xycoord/ xy

      dummy2 = setvideomode( $ERESCOLOR )
      dummy2 = setcolor( 4 )
      dummy2 = rectangle( $GFILLINTERIOR, 50, 50, 200, 200 )
C
C     Display normal palette message.
C
      CALL settextposition( 1, 1, xy )
      CALL outtext( 'Normal palette   ' )
      CALL outtext( 'Press ENTER to continue' )
      READ (*,*)          ! Wait for ENTER key to be pressed
      dummy4 = remappalette( 4, $BLUE )
C
C     Display new palette message.
C
      CALL settextposition( 1, 1, xy )
      CALL outtext( 'Remapped palette ' )
      CALL outtext( 'Press ENTER to continue' )
      READ (*,*)
      dummy4 = remappalette( 4, $RED )
C
C     Display original palette message.
C
      CALL settextposition( 1, 1, xy )
      CALL outtext( 'Restored palette ' )
      CALL outtext( 'Press ENTER to clear the screen' )
      READ (*,*)
C
C     Return to original video mode.
C
      CALL clearscreen( $GCLEARSCREEN )
      dummy2 = setvideomode( $DEFAULTMODE )
      END
