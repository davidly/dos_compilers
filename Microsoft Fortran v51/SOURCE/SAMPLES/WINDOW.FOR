CC  WINDOW.FOR - Illustrates windows and coordinate systems using
CC               the following functions:
CC               clearscreen   ellipse        ellipse_w 
CC               rectangle      rectangle_w   setcliprgn
CC               setvieworg     setviewport    setwindow
CC
CC  Although not all illustrated here, functions ending in _w
CC  are similar to rectangle_w and ellipse_w.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2  status, xhalf, yhalf, xquar, yquar
      DOUBLE PRECISION  x_upleft, y_upleft, x_botrght, y_botrght
      RECORD / xycoord /     xy
      RECORD / videoconfig / vc

C
C     Find graphics mode.
C
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 ) 
     +    STOP 'Error:  cannot set graphics mode'
      CALL getvideoconfig( vc )
      xhalf = vc.numxpixels / 2
      yhalf = vc.numypixels / 2
      xquar = xhalf / 2
      yquar = yhalf / 2

C
C     First window - integer physical coordinates
C
      CALL setviewport( 0, 0, xhalf - 1, yhalf - 1 )
      status = setcolor( 2 )
      status = rectangle( $GBORDER, 0, 0, xhalf - 1, yhalf - 1 )
      status = setcolor( 1 )
      status = ellipse( $GFILLINTERIOR, xquar / 4, yquar / 4,
     +                 xhalf - (xquar / 4), yhalf - (yquar / 4) )
      READ (*,*) ! Wait for ENTER to be pressed
      CALL clearscreen( $GVIEWPORT )
      status = rectangle( $GBORDER, 0, 0, xhalf - 1, yhalf - 1 )

C
C     Second window - integer world coordinates with clip region
C
      CALL setcliprgn( xhalf, 0, vc.numxpixels, yhalf )
      CALL setvieworg( xhalf + xquar - 1, yquar - 1, xy )
      status = setcolor( 3 )
      status = rectangle( $GBORDER, -xquar + 1, -yquar + 1, xquar,
     +                   yquar )
      status = setcolor( 2 )
      status = ellipse( $GFILLINTERIOR, (-xquar * 3) / 4,
     +                 (-yquar * 3) / 4, (xquar * 3) / 4,
     +                 (yquar * 3) / 4 )
      READ (*,*) ! Wait for ENTER to be pressed
      CALL clearscreen( $GVIEWPORT )
      status = rectangle( $GBORDER, -xquar + 1, -yquar + 1, xquar,
     +                   yquar )

C
C     Third window
C
      CALL setviewport( xhalf, yhalf, vc.numxpixels - 1,
     +                  vc.numypixels - 1 )
      status = setwindow( .FALSE., -4.0, -5.0, 4.0, 5.0 )
      status = setcolor( 4 )
      status = rectangle_w( $GBORDER, -4.0, -5.0, 4.0, 5.0 )
      status = setcolor( 3 )
      status = ellipse_w( $GFILLINTERIOR, -3.0, -3.5, 3.0, 3.5 )
      READ (*,*) ! Wait for ENTER to be pressed
      CALL clearscreen( $GVIEWPORT )
      status = rectangle_w( $GBORDER, -4.0, -5.0, 4.0, 5.0 )

C
C     Fourth window
C
      CALL setviewport( 0, yhalf, xhalf - 1, vc.numypixels - 1 )
      status = setwindow( .FALSE., -4.0, -5.0, 4.0, 5.0 )
      x_upleft  = -4.0
      y_upleft  = -5.0
      x_botrght =  4.0
      y_botrght =  5.0
      status = setcolor( 5 )
      status = rectangle_w( $GBORDER, x_upleft, y_upleft,
     +                     x_botrght, y_botrght )
      x_upleft  = -3.0
      y_upleft  = -3.5
      x_botrght =  3.0
      y_botrght =  3.5
      status = setcolor( 4 )
      status = ellipse_w( $GFILLINTERIOR, x_upleft, y_upleft,
     +                   x_botrght, y_botrght )

      READ (*,*) ! Wait for ENTER to be pressed
      status = setvideomode( $DEFAULTMODE )
      END
