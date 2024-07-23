CC  SINE.FOR - Illustrates basic graphics commands.

      INCLUDE  'FGRAPH.FI'

      CALL graphicsmode()
      CALL drawlines()
      CALL sinewave()
      CALL drawshapes()
      CALL endprogram()
      END

C     Definitions of subroutines go here . . .


      SUBROUTINE graphicsmode() 

      INCLUDE  'FGRAPH.FD'

      INTEGER*2            dummy, maxx, maxy
      RECORD /videoconfig/ myscreen
      COMMON               maxx, maxy

C
C     Find graphics mode.
C
      CALL getvideoconfig( myscreen )
      SELECT CASE( myscreen.adapter )
         CASE( $CGA )
            dummy = setvideomode( $HRESBW )
         CASE( $OCGA )
            dummy = setvideomode( $ORESCOLOR )
         CASE( $EGA, $OEGA )
            IF( myscreen.monitor .EQ. $MONO ) THEN
                dummy = setvideomode( $ERESNOCOLOR )
            ELSE
                dummy = setvideomode( $ERESCOLOR )
            END IF
         CASE( $VGA, $OVGA, $MCGA )
            dummy = setvideomode( $VRES2COLOR )
         CASE( $HGC )
            dummy = setvideomode ( $HERCMONO )
         CASE DEFAULT
            dummy = 0
      END SELECT

      IF( dummy .EQ. 0 ) STOP 'Error:  cannot set graphics mode'

C
C     Determine the minimum and maximum dimensions.
C
      CALL getvideoconfig( myscreen )
      maxx = myscreen.numxpixels - 1
      maxy = myscreen.numypixels - 1
      END

CC  NEWX - This function finds new x coordinates.

      INTEGER*2 FUNCTION newx( xcoord )

      INTEGER*2 xcoord, maxx, maxy
      REAL*4    tempx
      COMMON    maxx, maxy

      tempx = maxx / 1000.0
      tempx = xcoord * tempx + 0.5
      newx  = tempx 
      END


CC  NEWY - This function finds new y coordinates.

      INTEGER*2 FUNCTION newy( ycoord )

      INTEGER*2 ycoord, maxx, maxy
      REAL*4    tempy
      COMMON    maxx, maxy

      tempy = maxy / 1000.0
      tempy = ycoord * tempy + 0.5
      newy  = tempy
      END


CC  DRAWLINES - This subroutine draws a box and several lines.

      SUBROUTINE drawlines()

      INCLUDE  'FGRAPH.FD'

      EXTERNAL         newx,newy
      INTEGER*2        dummy, newx, newy, maxx, maxy
      RECORD /xycoord/ xy
      COMMON           maxx, maxy

C
C     Draw the box.
C
      dummy = rectangle( $GBORDER, 0, 0, maxx, maxy )
      CALL setvieworg( 0, newy( INT2( 500 ) ), xy )
C
C     Draw the lines.
C
      CALL    moveto( 0, 0, xy )
      dummy = lineto( newx( INT2( 1000 ) ), 0 )
      CALL    setlinestyle( #AA3C )
      CALL    moveto( 0, newy( INT2( -250 ) ), xy )
      dummy = lineto( newx( INT2( 1000 ) ), newy( INT2( -250 ) ) )
      CALL    setlinestyle( #8888 )
      CALL    moveto( 0, newy( INT2( 250 ) ), xy )
      dummy = lineto( newx( INT2( 1000 ) ), newy( INT2( 250 ) ) )
      END


CC  SINEWAVE - This subroutine calculates and plots a sine wave.

      SUBROUTINE sinewave()

      INCLUDE  'FGRAPH.FD'

      INTEGER*2        dummy, newx, newy, locx, locy, i
      DOUBLE PRECISION rad, PI
      EXTERNAL         newx, newy

      PARAMETER        ( PI = 3.14159 )

C
C     Calculate each position and display it on the screen.
C
      DO i = 0, 999, 3
         rad   = -SIN( PI * i / 250.0 )
         locx  = newx( i )
         locy  = newy( INT2( rad * 250.0 ) )
         dummy = setpixel( locx, locy )
      END DO
      END


CC  DRAWSHAPES - This subroutine draws two boxes and two ellipses.

      SUBROUTINE drawshapes()

      INCLUDE  'FGRAPH.FD'

      EXTERNAL  newx, newy
      INTEGER*2 dummy, newx, newy

C
C     Create a masking (fill) pattern.
C
      INTEGER*1 diagmask(8),  linemask(8) 
      DATA diagmask / #93, #C9, #64, #B2, #59, #2C, #96, #4B /
      DATA linemask / #FF, #00, #7F, #FE, #00, #00, #00, #CC /
C 
C     Draw the rectangles.
C
      CALL setlinestyle( #FFFF )
      CALL setfillmask( diagmask )
      dummy = rectangle( $GBORDER,
     +                  newx( INT2( 50  ) ), newy( INT2( -325 ) ),
     +                  newx( INT2( 200 ) ), newy( INT2( -425 ) ) )
      dummy = rectangle( $GFILLINTERIOR,
     +                  newx( INT2( 550 ) ), newy( INT2( -325 ) ),
     +                  newx( INT2( 700 ) ), newy( INT2( -425 ) ) )
C
C     Draw the ellipses.
C
      CALL setfillmask( linemask )
      dummy = ellipse( $GBORDER,
     +                newx( INT2( 50  ) ), newy( INT2( 325 ) ),
     +                newx( INT2( 200 ) ), newy( INT2( 425 ) ) )
      dummy = ellipse( $GFILLINTERIOR,
     +                newx( INT2( 550 ) ), newy( INT2( 325 ) ),
     +                newx( INT2( 700 ) ), newy( INT2( 425 ) ) )

      END


CC  ENDPROGRAM - This subroutine waits for the ENTER key to be
CC  pressed, then resets the screen to normal before returning.

      SUBROUTINE endprogram()

      INCLUDE  'FGRAPH.FD'
      INTEGER*2  dummy

      READ (*,*)                       ! Wait for ENTER key
      dummy = setvideomode( $DEFAULTMODE )
      END
