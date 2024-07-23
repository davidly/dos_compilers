CC  WRAP.FOR - Illustrates:
CC             wrapon

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2              status2, old_color, old_mode, row, col
      INTEGER*4              status4, old_bk
      CHARACTER*22           text
      CHARACTER*80           border
      RECORD / rccoord /     curpos
      RECORD / videoconfig / vc

      DATA text / 'Here text DOES wrap.  ' /
      CALL getvideoconfig( vc )
      old_mode  = vc.mode
      old_color = gettextcolor()
      old_bk    = getbkcolor()
      IF( vc.numtextcols .NE. 80 ) THEN
         IF( setvideomode( $TEXTC80 ) .EQ. 0 )
     +       status2 = setvideomode( $TEXTMONO )
      END IF
      status2    = settextcolor( 14 )
      status4    = setbkcolor( 1 )
      CALL clearscreen( $GCLEARSCREEN )
C
C     Draw window borders.
C
      DO i = 1, 80
         border(i:i) = CHAR( 219 )
      END DO
      CALL settextposition( 13, 1, curpos )
      CALL outtext( border )
      col = 60
      DO row = 1, 25
         IF( row .EQ. 13 ) col = 20
         CALL settextposition( row, col, curpos )
         CALL outtext( border(1:1) )
      END DO
C
C     Display wrapped and unwrapped text in windows.
C
      status4 = setbkcolor( 0 )
      CALL settextwindow( 1, 1, 13, 59 )
      CALL settextposition( 1, 1, curpos )
      status2 = wrapon( $GWRAPON )
      status2 = settextcolor( 10 )
      DO i = 1, 32
         CALL outtext( text )
      END DO
      CALL outtext( text )
      CALL settextwindow( 14, 21, 25, 80 )
      CALL settextposition( 1, 1, curpos )
      status2 = wrapon( $GWRAPOFF )
      status2 = settextcolor( 12 )
      DO row = 1, 12
         CALL settextposition( row, 1, curpos )
         DO i = 1, 3
            CALL outtext( text(1:15) // 'NOT ' // text(16:22) )
         END DO
      END DO

      READ (*,*)  ! Wait for ENTER to be pressed
      status2 = setvideomode( old_mode )
      status2 = settextcolor( old_color )
      status4 = setbkcolor( old_bk )
      END
