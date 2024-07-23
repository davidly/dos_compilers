CC  MAGNIFY.FOR - Illustrates translation between window and view
CC                coordinate systems using the following functions:
CC                getphyscoord     getviewcoord   getviewcoord_w
CC                getwindowcoord   lineto        moveto 
CC                rectangle        rectangle_w    settextposition
CC                setwindow       setviewport
CC
CC  Although not all illustrated here, functions ending in _w
CC  are similar to rectangle_w.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2              status, rseed, j, k, m, n
      INTEGER*2              coord(3,2,2), fill(2)
      INTEGER*4              i
      REAL*4                 rand
      DOUBLE PRECISION       x(2), y(2)
      CHARACTER*18           text
      RECORD / xycoord  /    xy, xy1
      RECORD / wxycoord /    wxy
      RECORD / rccoord  /    curpos
      RECORD / videoconfig / vc
      DATA text / 'magnification:  1x' /
      DATA fill / $GFILLINTERIOR, $GBORDER /

C
C     Find graphics mode.
C
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 ) 
     +    STOP 'Error:  cannot set graphics mode'
      CALL getvideoconfig( vc )

C
C     Find physical (pixel) coordinates for windows 1, 2, and 3.
C
      coord(1,1,1) = vc.numxpixels * 3 / 16
      coord(1,1,2) = vc.numypixels * 7 / 32
      coord(1,2,1) = coord(1,1,1) + vc.numxpixels / 8
      coord(1,2,2) = coord(1,1,2) + vc.numypixels / 16
      coord(2,1,1) = vc.numxpixels * 9 / 16
      coord(2,1,2) = vc.numypixels * 5 / 32
      coord(2,2,1) = coord(2,1,1) + vc.numxpixels * 3 / 8
      coord(2,2,2) = coord(2,1,2) + vc.numypixels * 3 / 16
      coord(3,1,1) = 0
      coord(3,1,2) = vc.numypixels / 2
      coord(3,2,1) = vc.numxpixels - 1
      coord(3,2,2) = vc.numypixels - 1

C
C     Connect windows with lines.
C
      status = setcolor( 4 )
      DO i = 1, 2
         DO j = 1, 2
            DO k = 1, 2
               CALL moveto( coord(i,j,1), coord(i,k,2), xy )
               status = lineto( coord(i + 1,j,1), coord(i + 1,k,2) )
            END DO
         END DO
      END DO

C
C     Label windows and frame with rectangles.
C
      DO i = 1, 3
         status  = setcolor( i )
         row    = ( coord(i,1,2) * 25 ) / vc.numypixels
         column = ( coord(i,1,1) * 80 ) / vc.numxpixels
         CALL settextposition( row, column, curpos )
         CALL outtext( text )
         text(17:17) = '3'

         IF( i .EQ. 2 ) text(17:17) = '8'
         CALL setviewport(  coord(i,1,1), coord(i,1,2) ,
     +                      coord(i,2,1), coord(i,2,2) )
         CALL getviewcoord( coord(i,1,1), coord(i,1,2), xy  )
         CALL getviewcoord( coord(i,2,1), coord(i,2,2), xy1 )
         status = rectangle( $GBORDER, xy.xcoord, xy.ycoord,
     +                      xy1.xcoord, xy1.ycoord )
      END DO

C
C     Seed random number generator.
C
      CALL GETTIM( status, status, status, rseed )
      CALL SEED( rseed )
C
C     Get random window coordinates (x, y) for rectangles,
C     where x and y are between 0 and 1000.
C
      DO i = 8, 15
         status = setcolor( i )
         CALL RANDOM( rand )
         x(1)  = rand * 980.0
         x(2)  = rand * ( 999.0 - x(1) ) + x(1)
         CALL RANDOM( rand )
         y(1)  = rand * 980.0
         y(2)  = rand * ( 999.0 - y(1) ) + y(1)
         k     = rand + 1.5

C
C        Display rectangles in normal and magnified views.
C
         DO j = 1, 3
            CALL setviewport( coord(j,1,1), coord(j,1,2) ,
     +                        coord(j,2,1), coord(j,2,2) )
            status = setwindow( .TRUE., 0.0, 0.0, 1000.0, 1000.0 )
            status = rectangle_w( fill(k), x(1), y(1), x(2), y(2) )
C
C           In last window, make rectangle sides 2 pixels wide by
C           encasing unfilled rectangles with another rectangle.
C           Convert window coords (x, y) to physical coords, 
C           adjust, and translate back into window coords.
C
            IF( (j .EQ. 3)  .AND.  (k .EQ. 2) ) THEN
               m = -1
               DO n = 1, 2
                  CALL getviewcoord_w(x(n), y(n), xy)
                  CALL getphyscoord(xy.xcoord, xy.ycoord, xy)
                  CALL getviewcoord(xy.xcoord+m, xy.ycoord+m, xy)
                  CALL getwindowcoord(xy.xcoord, xy.ycoord, wxy)
                  x(n) = wxy.wx
                  y(n) = wxy.wy
                  m    = 1
               END DO
            status = rectangle_w( fill(k), x(1), y(1), x(2), y(2) )
            END IF
         END DO
      END DO

      READ (*,*)  ! Wait for ENTER to be pressed
      status = setvideomode( $DEFAULTMODE )
      END
