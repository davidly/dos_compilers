CC    PAGE.FOR - Illustrates animation effects by changing the video page.
CC             The video page functions demonstrated include:
CC             getactivepage  getvisualpage  setactivepage  setvisualpage

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2        error, oldapage, oldvpage
      INTEGER*2        i, j, k, l
      CHARACTER*3      jumper(4,3)
      RECORD /rccoord/ curpos

      DATA jumper / '\o/', '_o_', ' o ', ' o ',
     +              ' O ', ' O ', '/O\', ' O ',
     +              '/ \', '( )', '/ \', '( )' /

      oldapage  = getactivepage()
      oldvpage  = getvisualpage()
      IF( setvideomode( $TEXTBW40 ) .EQ. 0 )
     +    STOP 'Error:  cannot set 40-column mode'
      error     = displaycursor( $GCURSOROFF )

C
C     Draw 24 images on each page.
C
      DO i = 1, 4
         error = setactivepage( i - 1 )
         DO j = 1, 22, 7
            DO k = 1, 36, 7
               DO l = 0, 2

                  CALL settextposition( j + l, k, curpos )
                  CALL outtext( jumper(i,l + 1) )
               END DO
            END DO
         END DO
      END DO

C
C     Cycle 10 times through pages 0-3.
C
      DO i = 1, 10
         DO j = 0, 3
            error = setvisualpage( j )
            CALL delay( INT2( 10 ) )
         END DO
      END DO

C
C     Restore original page.
C
      error = setvideomode( $DEFAULTMODE )
      error = setactivepage( oldapage )
      error = setvisualpage( oldvpage )
      END


CC  DELAY - Pauses for a specified number of 1/100 seconds.
CC
CC  Params:  Wait - pause time in 0.01 seconds

      SUBROUTINE delay( wait )
      INTEGER*2 wait, tick0, tick1, tick, kount, dummy

      kount = 0
      CALL GETTIM( dummy, dummy, dummy, tick0 )
      DO WHILE( kount .LT. wait )
         CALL GETTIM( dummy, dummy, dummy, tick1 )
         tick = tick1 - tick0
         IF( tick .LT. 0 ) tick = tick + 100 
         tick0 = tick1
         kount = kount + tick
      END DO
      RETURN
      END
