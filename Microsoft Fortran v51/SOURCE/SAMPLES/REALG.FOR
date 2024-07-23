CC  REALG.FOR - Illustrates real coordinate graphics.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      LOGICAL  fourcolors
      EXTERNAL fourcolors

      IF( fourcolors() ) THEN
         CALL threegraphs()
      ELSE
         WRITE (*,*) ' This program requires a CGA, EGA, or',
     +               ' VGA graphics card.'
      END IF
      END 

C     Additional functions defined below

CC  FOURCOLORS - Function to enter graphics mode for REALG.

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


CC  THREEGRAPHS - This subroutine displays three graphs for REALG.

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


CC  GRIDSHAPE - This subroutine plots data for the REALG program.

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
