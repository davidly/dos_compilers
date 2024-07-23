CC  FONTS.FOR - Illustrates fonts functions including:   
CC              getfontinfo     setfont       unregisterfonts    
CC              getgtextextent  registerfonts      
CC              outgtext        setgtextvector   
   
   
      INCLUDE  'FGRAPH.FI'   
      INCLUDE  'FGRAPH.FD'   
   
      PARAMETER            ( NFONTS = 6 )   
   
      INTEGER*2            dummy, x, y, iend   
      INTEGER*4            ifont   
      CHARACTER*11         face(NFONTS)   
      CHARACTER*10         options(NFONTS)   
      CHARACTER*20         list   
      CHARACTER*64         fontpath   
      RECORD /videoconfig/ vc   
      RECORD /xycoord/     xy   
      RECORD /fontinfo/    fi   
   
      DATA face    / "Courier"   , "Helvetica"  , "Times Roman",   
     +               "Modern"    , "Script"     , "Roman"      /   
      DATA options / "t'courier'", "t'helv'"    , "t'tms rmn'" ,   
     +               "t'modern'" , "t'script'"  , "t'roman'"   /   
   
      CALL clearscreen( $GCLEARSCREEN )   
      WRITE (*,*) 'Enter file specification for .FON files'
      WRITE (*,*) '[pathname\*.FON]:'   
      WRITE (*,*)   
      READ  (*, '(A)') fondir   
C   
C     Locate .FON files, then register fonts by reading header   
C     information from all files.   
C   
      IF( registerfonts( '*.FON' ). LT. 0 ) THEN   
         WRITE (*, '(A/)') ' Enter directory for .FON files:'   
         READ (*, '(A )') fontpath   
         iend = INDEX( fontpath, ' ' )   
         fontpath( iend:iend + 5 ) = '\*.FON'   
         IF( registerfonts( fontpath ). LT. 0 )   
     +      STOP 'Error: cannot find font files'   
      ENDIF   
   
C   
C     Find graphics mode.   
C   
      IF( setvideomode( $MAXRESMODE ) .EQ. 0 )    
     +    STOP 'Error:  cannot set graphics mode'   
      CALL getvideoconfig( vc )   
   
C   
C     Display each font name centered on screen.   
C   
      DO ifont = 1, NFONTS   
   
C   
C        Build options string.   
C   
         list = options(ifont) // 'h30w24b'    
   
         CALL clearscreen( $GCLEARSCREEN )   
         IF( setfont( list ) .GE. 0 ) THEN   
C   
C           Use length of text and height of font to center text.   
C   
            x = (vc.numxpixels-getgtextextent   
     +           (face( ifont))) / 2   
            IF( getfontinfo( fi ) .NE. 0 ) THEN   
               CALL outtext( 'Error:  cannot get font info' )   
               READ (*,*)   
            END IF   
            y = (vc.numypixels - fi.ascent) / 2   
            CALL moveto( x, y, xy )   
            IF( vc.numcolors .GT. 2 ) dummy = setcolor( ifont )    
            CALL setgtextvector( 1, 0 )   
            CALL outgtext( face(ifont))   
            CALL setgtextvector( 0, 1 )   
            CALL outgtext( face(ifont))   
            CALL setgtextvector( -1, 0 )   
            CALL outgtext( face(ifont))   
            CALL setgtextvector( 0, -1 )   
            CALL outgtext( face(ifont))    
         ELSE   
            CALL outtext( 'Error:  cannot set font' )   
         END IF   
         READ (*,*)   
      END DO   
      CALL unregisterfonts()   
      dummy = setvideomode( $DEFAULTMODE )   
      END   
