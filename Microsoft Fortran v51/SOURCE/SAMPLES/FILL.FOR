CC  FILL.FOR - Illustrates color, filling, and linestyle functions
CC             including:        floodfill            setfillmask
CC                                getlinestyle        setlinestyle
CC                                setcolor
CC
CC  The getfillmask function is not shown, but its use is similar 
CC  to getlinestyle.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*1            fill(8)
      INTEGER*2            status, xinc, yinc, i,
     +                     irand, xwid, ywid, rseed
      INTEGER*4            ncolor
      REAL*4               rand
      RECORD /xycoord/     xy
      RECORD /videoconfig/ vc

C
C     Find graphics mode.
C
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 ) 
     +   STOP 'Error:  cannot set graphics mode'
      CALL getvideoconfig( vc )

C
C     Size variables to mode.
C
      xinc = vc.numxpixels / 8.0
      yinc = vc.numypixels / 8.0
      xwid = (xinc / 2.0) - 4.0
      ywid = (yinc / 2.0) - 4.0

C
C     Seed random-number generator.
C
      CALL GETTIM( status, status, status, rseed)
      CALL SEED( rseed )

C
C     Draw ellipses and lines with different patterns.
C
      DO x = xinc, (vc.numxpixels - xinc), xinc
         DO y = yinc, (vc.numypixels - yinc), yinc
C
C           Randomize fill and color.  Array FILL holds
C           random numbers between 0 and 255.
C
            DO i = 1, 8
               CALL RANDOM( rand )
               fill(i) = INT1( rand * 256.0 )
            END DO

            CALL setfillmask( fill )
            irand  = rand * 256.0
            ncolor = MOD( irand, vc.numcolors ) + 1
            status  = setcolor( ncolor )
C
C           Draw ellipse and fill with random color.
C
            status  = ellipse( $GBORDER, x - xwid, y - ywid,
     +                         x + xwid, y + ywid )
            CALL RANDOM( rand )
            irand  = rand * 256.0
            i      = ncolor
            ncolor = MOD( irand, vc.numcolors ) + 1
            status  = setcolor( ncolor )
            status  = floodfill( x, y, i )
C
C           Draw vertical and horizontal lines. Vertical line style
C           is anything other than horizontal style. Since lines 
C           are overdrawn with several line styles, this has the
C           effect of combining colors and styles.
C
            CALL RANDOM( rand )
            irand = rand * 256.0
            CALL setlinestyle( irand )
            CALL moveto( 0, y + ywid + 4, xy )
            status = lineto( vc.numxpixels - 1, y + ywid + 4 )
C
C           Get linestyle, invert bits, and reset linestyle.
C
            CALL setlinestyle( 255 - getlinestyle() )
            CALL moveto( x + xwid + 4, 0, xy )
            status = lineto( x + xwid + 4, vc.numypixels - 1 )
         END DO
      END DO

      READ (*,*)       ! Wait for ENTER to be pressed
      status = setvideomode( $DEFAULTMODE )
      END
