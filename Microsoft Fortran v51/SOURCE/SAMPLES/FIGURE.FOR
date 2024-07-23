CC  FIGURE.FOR - Illustrates graphics drawing functions including:
CC               arc      ineto     pie         setpixel
CC               ellipse moveto    rectangle

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2        status, x, y
      INTEGER*4        ncolor
      RECORD /xycoord/ xy

C
C     Find graphics mode.
C
      IF ( setvideomode( $MAXRESMODE ) .EQ. 0 )
     +     STOP 'Error:  cannot set graphics mode'

      WRITE (*,*) ' Press ENTER to continue'
C
C     Draw pixels.
C
      ncolor = 2
      status  = setcolor( ncolor )
      x      = 10
      DO y = 50, 89, 3
         status = setpixel( x, y )
         x     = x + 2
      END DO
      READ (*,*) ! Wait for ENTER to be pressed
C
C     Draw lines.
C
      ncolor = ncolor + 1
      status  = setcolor( ncolor )
      x      = 60
      DO y = 50, 89, 3
         CALL moveto( x, y, xy )
         status = lineto( x + 20, y )
      END DO
      READ (*,*) ! Wait for ENTER to be pressed
C
C     Draw rectangles.
C
      ncolor = ncolor + 1
      status  = setcolor( ncolor )
      x      = 110
      y      = 70
      status  = rectangle( $GBORDER,       x - 20, y - 20, x, y )
      status  = rectangle( $GFILLINTERIOR, x + 20, y + 20, x, y )
      READ (*,*) ! Wait for ENTER to be pressed
C
C     Draw ellipses.
C
      ncolor = ncolor + 1
      status  = setcolor( ncolor )
      x      = 160
      status  = ellipse( $GBORDER,       x - 20, y - 20, x, y )
      status  = ellipse( $GFILLINTERIOR, x + 20, y + 20, x, y )
      READ (*,*) ! Wait for ENTER to be pressed
C
C     Draw arcs.
C
      ncolor = ncolor + 1
      status  = setcolor( ncolor )
      x      = 210
      status  = arc( x - 20, y - 20, x, y, x, y - 10, x - 10, y )
      status  = arc( x + 20, y + 20, x, y, x + 10, y + 20, x + 20,
     +              y + 10 )
      READ (*,*) ! Wait for ENTER to be pressed
C
C     Draw pies.
C
      ncolor = ncolor + 1
      status  = setcolor( ncolor )
      x      = 260
      status  = pie( $GBORDER,   x - 20, y - 20, x, y, x,
     +              y - 10, x - 10, y)
      status  = pie( $GFILLINTERIOR, x + 20, y + 20, x, y, x + 10,
     +              y + 20, x + 20, y + 10 )
      READ (*,*) ! Wait for ENTER to be pressed
      status = setvideomode( $DEFAULTMODE )
      END
