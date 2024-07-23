CC  SAMPLER.FOR - Displays sample text in various fonts.
CC

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2            NFONTS
      INTEGER*2            dummy, i, iend
      CHARACTER*30         list
      CHARACTER*64         fontpath
      RECORD /videoconfig/ vc
      RECORD /xycoord/     xy

      PARAMETER ( NFONTS   = 6 )

      CHARACTER*( 7 )  text(2 * NFONTS) /
     +                 "COURIER",      "courier",
     +                 "HELV"   ,      "helv"   ,
     +                 "TMS RMN",      "tms rmn",
     +                 "MODERN" ,      "modern" ,
     +                 "SCRIPT" ,      "script" ,
     +                 "ROMAN"  ,      "roman"  /

      CHARACTER*( 10 ) option(NFONTS) /
     +                 "t'courier'",   "t'helv'"  ,
     +                 "t'tms rmn'",   "t'modern'",
     +                 "t'script'" ,   "t'roman'" /

C
C     Locate .FON files, then register fonts by reading header
C     information from all files.
C
      IF( registerfonts( '*.FON' ). LT. 0 ) THEN
         WRITE (*, '(A/)') ' Enter directory for .FON files:'
         READ  (*, '(A )') fontpath
         iend = INDEX( fontpath, ' ' )
         fontpath(iend:iend + 5) = '\*.FON'
         IF( registerfonts( fontpath ). LT. 0 )
     +       STOP 'Error:  cannot find font files'
      ENDIF

C
C     Find graphics mode.
C
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 )
     +   STOP 'Error:  cannot set graphics mode'

C
C     Copy video configuration into structure vc.
C
      CALL getvideoconfig( vc )

C
C     Display six lines of sample text.
C
      DO i = 1, NFONTS
         list = option(i) // 'h30w24b'
         IF( setfont( list ) .EQ. 0 ) THEN
            dummy = setcolor( INT4( i ) )
            CALL moveto( 0, (i - 1) * vc.numypixels / NFONTS, xy )
            CALL outgtext( text((i * 2) - 1) )
            CALL moveto( vc.numxpixels/2,
     +                   (i - 1) * vc.numypixels / NFONTS, xy )
            CALL outgtext( text(i * 2) )
         ELSE
            dummy = setvideomode( $DEFAULTMODE )
            STOP 'Error:  cannot set font'
         END IF
      END DO

      READ (*,*)
      dummy = setvideomode( $DEFAULTMODE )
C
C     Return memory when finished with fonts.
C
      CALL unregisterfonts()
      END
