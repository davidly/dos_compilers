CC  THREEGRAPHS - This subroutine displays three graphs for REALG.
$NOTRUNCATE
$NOTSTRICT

      INCLUDE  'FGRAPH.FI'

      SUBROUTINE threegraphs()

      INCLUDE  'FGRAPH.FD'

      INTEGER*2            dummy, halfx, halfy
      INTEGER*2            xwidth, yheight, cols, rows
      RECORD /videoconfig/ screen
      COMMON               screen

      CALL clearscreen( $GCLEARSCREEN )
      xwidth  = screen.numxpixels
      yheight = screen.numypixels
      cols    = screen.numtextcols
      rows    = screen.numtextrows
      halfx   = xwidth / 2
      halfy   = (yheight / rows) * (rows / 2)
C
C     First window
C
      CALL setviewport( 0, 0, halfx - 1, halfy - 1 )
      CALL settextwindow( 1, 1, rows / 2, cols / 2 )
      dummy = setwindow( .FALSE., -2.0, -2.0, 2.0, 2.0 )
      CALL gridshape( INT2( rows / 2 ) )
      dummy = rectangle( $GBORDER, 0, 0, halfx - 1, halfy - 1 )
C
C     Second window
C
      CALL setviewport( halfx, 0, xwidth - 1, halfy - 1 )
      CALL settextwindow( 1, (cols / 2) + 1, rows / 2, cols )
      dummy = setwindow( .FALSE., -3.0, -3.0, 3.0, 3.0 )
      CALL gridshape( INT2( rows / 2 ) )
      dummy = rectangle_w( $GBORDER, -3.0, -3.0, 3.0, 3.0 )
C  
C     Third window
C
      CALL setviewport( 0, halfy, xwidth - 1, yheight - 1 )
      CALL settextwindow( (rows / 2 ) + 1, 1, rows, cols )
      dummy = setwindow( .TRUE., -3.0, -1.5, 1.5, 1.5 )
      CALL gridshape( INT2( (rows / 2) + MOD( rows, 2 ) ) )
      dummy = rectangle_w( $GBORDER, -3.0, -1.5, 1.5, 1.5 )
   
      READ (*,*)         ! Wait for ENTER key to be pressed
      dummy = setvideomode( $DEFAULTMODE )
      END
