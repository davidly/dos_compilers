CC  MODES.FOR - Illustrates configuration and text window
CC              functions including:
CC              getvideoconfig     outtext         settextwindow
CC              setvideomoderows   setvideomode 

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      PARAMETER            ( NUM_ROWS =  5 )
      PARAMETER            ( NUM_MODE = 17 )

      INTEGER*2              status, irow, x, y
      INTEGER*2              modes(NUM_MODE), rows(NUM_ROWS)
      CHARACTER*12           names(NUM_MODE), str
      RECORD / videoconfig / vc

      DATA modes / $TEXTBW40     ,  $TEXTC40     ,  $TEXTBW80    ,
     +             $TEXTC80      ,  $MRES4COLOR  ,  $MRESNOCOLOR ,
     +             $HRESBW       ,  $TEXTMONO    ,  $HERCMONO    ,
     +             $MRES16COLOR  ,  $HRES16COLOR ,  $ERESNOCOLOR ,
     +             $ERESCOLOR    ,  $VRES2COLOR  ,  $VRES16COLOR ,
     +             $MRES256COLOR ,  $ORESCOLOR   /

      DATA names / '    $TEXTBW40', '    $TEXTC40', '   $TEXTBW80',
     +             '     $TEXTC80', ' $MRES4COLOR', '$MRESNOCOLOR',
     +             '      $HRESBW', '   $TEXTMONO', '   $HERCMONO',
     +             '$MRES16COLOR', '$HRES16COLOR', '$ERESNOCOLOR',
     +             '   $ERESCOLOR', ' $VRES2COLOR', '$VRES16COLOR',
     +             '$MRES256COLOR', '  $ORESCOLOR' /

      DATA rows  / 60, 50, 43, 30, 25 /

      status = displaycursor( $GCURSOROFF )
C
C     Try each mode.
C
      DO i = 1, NUM_MODE
         DO j = 1, NUM_ROWS
C
C           Try each possible number of rows.
C
            irow = setvideomoderows( modes(i), rows(j) )
            IF( ( irow .EQ. 0 )  .OR.  (rows(j) .NE. irow) ) THEN
               GOTO 100
            ELSE
               CALL getvideoconfig( vc )
               y = (vc.numtextrows - 12) / 2
               x = (vc.numtextcols - 25) / 2
            END IF
C
C           Use text window to place output in middle of screen.
C
            CALL settextwindow( y, x, vc.numtextrows - y,
     +                          vc.numtextcols - x - 2 )
C
C           Display all information on the screen.
C
            CALL outtext( 'Video mode:  ' // names(i) )
            WRITE (str, '(I12)') vc.numxpixels
            CALL outtext( 'X pixels:    ' // str )
            WRITE (str, '(I12)') vc.numypixels
            CALL outtext( 'Y pixels:    ' // str )
            WRITE (str, '(I12)') vc.numtextcols
            CALL outtext( 'Text columns:' // str )
            WRITE (str, '(I12)') vc.numtextrows
            CALL outtext( 'Text rows:   ' // str )
            WRITE (str, '(I12)') vc.numcolors
            CALL outtext( 'Colors:      ' // str )
            WRITE (str, '(I12)') vc.bitsperpixel
            CALL outtext( 'Bits/pixel:  ' // str )
            WRITE (str, '(I12)') vc.numvideopages
            CALL outtext( 'Video pages: ' // str )
            WRITE (str, '(I12)') vc.mode
            CALL outtext( 'Mode:        ' // str )
            WRITE (str, '(I12)') vc.adapter
            CALL outtext( 'Adapter:     ' // str )
            WRITE (str, '(I12)') vc.monitor
            CALL outtext( 'Monitor:     ' // str )
            WRITE (str, '(I12)') vc.memory
            CALL outtext( 'Memory:      ' // str )

            READ (*,*)  ! Wait for ENTER to be pressed
  100    END DO
      END DO

      status = displaycursor( $GCURSORON )
      status = setvideomode( $DEFAULTMODE )
      END
