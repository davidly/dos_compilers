CC  CURSOR.FOR - Illustrates cursor functions including:
CC               displaycursor  gettextcursor  settextcursor

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2            status, oldcursor, newcursor,
     +                     curs_start, curs_end, block
      CHARACTER*40         str
      RECORD /rccoord/     curpos
      RECORD /videoconfig/ vc

C
C     Save old cursor shape and make sure cursor is on.
C

      CALL clearscreen( $GCLEARSCREEN )
      oldcursor = gettextcursor()
      status     = displaycursor( $GCURSORON )
      CALL settextposition( 1, 1, curpos )
      CALL outtext( 'Press ENTER to continue . . .' )
C
C     Change cursor shape.
C     Cursor uses scan lines 0-7.
C
      CALL getvideoconfig( vc )
      block = 7
      curs_start = 0
      DO curs_end = block, 0, -1
         CALL settextposition( 10, 1, curpos )
         WRITE (str, 9000) curs_start, curs_end
         CALL outtext( str )
         newcursor = (curs_start * 256) + curs_end
         status     = settextcursor( newcursor )
         READ (*,*)  ! Wait for ENTER to be pressed
         curs_start = curs_start + 1
      END DO

      WRITE (str, '(A13)') 'Cursor off:  '
      CALL settextposition( 12, 1, curpos )
      CALL outtext( str )
      status = displaycursor( $GCURSOROFF )
      READ (*,*)  ! Wait for ENTER to be pressed
      WRITE (str, '(A13)') 'Cursor on :  '
      CALL settextposition( 13, 1, curpos )
      CALL outtext( str )
      status = settextcursor( block )
      status = displaycursor( $GCURSORON )
      READ (*,*)  ! Wait for ENTER to be pressed
C
C     Restore original cursor shape.
C
      status = settextcursor( oldcursor )
      CALL clearscreen( $GCLEARSCREEN )

 9000 FORMAT ( 'Start line:', I4, 8x, 'Endline:', I4, 3x )

      END
