CC  ANIMATE.FOR - Illustrates animation functions including:
CC                imagesize     getimage     putimage

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*1        buffer[ALLOCATABLE] (:)
      INTEGER*2        status, x, y, error, action(5)
      INTEGER*4        imsize
      CHARACTER*6      descrip(5)
      RECORD /rccoord/ curpos

      DATA action  / $GPSET, $GPRESET, $GXOR, $GOR, $GAND  /
      DATA descrip / 'PSET  ', 'PRESET', 'XOR  ', 'OR  ', 'AND  ' /

C
C     Find graphics mode.
C
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 ) 
     +    STOP 'Error:  cannot set graphics mode'

      status = setcolor( 3 )
      y     = 30
      DO i = 1, 5
         x = 50
         y = y + 40
C
C        Display action type.
C
         CALL settextposition( 1, 1, curpos )
         CALL outtext( descrip(i) )
C
C        Draw and measure ellipse, allocate memory for image.
C
         status  = ellipse( $GFILLINTERIOR, x - 15, y - 15, x + 15,
     +                     y + 15 )
         imsize = imagesize( x - 16, y - 16, x + 16, y + 16 )
         ALLOCATE( buffer( imsize ), STAT = error )
         IF( error .NE. 0 ) THEN
            status = setvideomode( $DEFAULTMODE )
            STOP 'Error:  insufficient memory'
         END IF
C
C        Get master copy of ellipse.
C
         CALL getimage( x - 16, y - 16, x + 16, y + 16, buffer )
C
C        Copy row of ellipses with specified action.
C
         DO x = 55, 255, 5
            CALL putimage( x - 16, y - 16, buffer, action(i) )
         END DO

C
C        Free memory, wait for ENTER key to continue.
C
         DEALLOCATE( buffer )
         READ (*,*)
      END DO

      status = setvideomode( $DEFAULTMODE )
      END
