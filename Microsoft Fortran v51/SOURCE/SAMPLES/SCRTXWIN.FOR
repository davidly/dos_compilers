C  This program displays text in text windows and then
C  scrolls, inserts, and deletes lines.

       INCLUDE 'FGRAPH.FI'
       INCLUDE 'FGRAPH.FD'

       INTEGER*2 row, rowsset
       CHARACTER string*9
       RECORD /rccoord/ oldpos

C  Set up screen for scrolling and put text window around scroll area

       row = 25
       rowsset = settextrows( row )
       CALL clearscreen( $GCLEARSCREEN )

       DO row = 1, 24
         string = 'Line     '
         CALL settextposition( row, 1, oldpos )
         WRITE( string(8:9), '(I2)' ) row
         CALL outtext( string )
       END DO

       READ( *, * )   ! Wait for the ENTER key
       CALL settextwindow( 1, 1, 25, 10 )

C  Delete some lines

       CALL settextposition( 11, 1, oldpos )
       DO row = 12, 20
         CALL deleteline()
       END DO

       CALL status( 'Deleted 8 lines' )

C  Insert some lines

       CALL settextposition( 5, 1, oldpos )
       DO row = 1, 6
         CALL insertline()
       END DO

       CALL status( 'Inserted 5 lines' )

C  Scroll up and down

       CALL scrolltextwindow( -7 )
       CALL status( 'Scrolled down 7 lines' )
       CALL scrolltextwindow( 5 )
       CALL status( 'Scrolled up 5 lines' )

C End the program

       !  CALL setvideomode( $DEFAULTMODE )
       END

C
C  Subroutine Definitions
C

C  Delete lines by scrolling them off the top of the current
C  text window. Save and restore original window

       SUBROUTINE deleteline()

       INCLUDE 'FGRAPH.FD'

       INTEGER*2          top, left, bottom, right
       RECORD / rccoord / rc

       CALL gettextwindow( top, left, bottom, right )
       CALL gettextposition( rc )
       CALL settextwindow( rc.row, left, bottom, right )
       CALL scrolltextwindow( $GSCROLLUP )
       CALL settextwindow( top, left, bottom, right )
       CALL settextposition( rc.row, rc.col, rc )
       
       END

C  Insert lines by scrolling in blank lines from the top of the
C  current text window. Save and restore original window.

       SUBROUTINE insertline()

       INCLUDE 'FGRAPH.FD'

       INTEGER*2          top, left, bottom, right
       RECORD / rccoord / rc

       CALL gettextwindow( top, left, bottom, right )
       CALL gettextposition( rc )
       CALL settextwindow( rc.row, left, bottom, right )
       CALL scrolltextwindow( $GSCROLLDOWN )
       CALL settextwindow( top, left, bottom, right )
       CALL settextposition( rc.row, rc.col, rc )
       
       END

C  Display and clear status line in its own window

       SUBROUTINE status( text )

       INCLUDE 'FGRAPH.FD'

       CHARACTER*(*)      text
       INTEGER*2          top, left, bottom, right

       CALL gettextwindow( top, left, bottom, right )
       CALL settextwindow( 1, 50, 2, 80 )
       CALL outtext( text )
       READ( *, * )   ! Wait for ENTER key
       CALL clearscreen( $GWINDOW )
       CALL settextwindow( top, left, bottom, right )

       END
       
