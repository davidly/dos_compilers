CC  PALETTE.FOR - Illustrates functions for assigning color values 
CC                to color indices.  Functions include:
CC                remapallpalette    remappalette

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2            status2, mode, cells, x, y, xinc, yinc, i
      INTEGER*4            status4, pal(256), iblue, ired, igreen
      INTEGER*4            RGB, tmp, inc
      CHARACTER*3          str1, str2
      RECORD /videoconfig/ vc

C
C     Make sure all palette numbers are valid.
C
      DO i = 1, 256
         pal(i) = $BLACK
      END DO
C
C     Loop through each graphics mode that supports palettes.
C

      DO mode = $MRES4COLOR, $MRES256COLOR
         IF( mode .EQ. $ERESNOCOLOR ) CYCLE
         IF( setvideomode( mode ) .EQ. 0 ) CYCLE

C
C        Get configuration variables for current mode.
C
         CALL getvideoconfig( vc )
         SELECT CASE( vc.numcolors )

            CASE( 256 )
C
C              Active bits in this order:
C              ???????? ??bbbbbb ??gggggg ??rrrrrr
C
               cells = 13
               inc   = 12

            CASE( 16 )
C
C              If $ERES or $VRES16, active bits in this order:
C              ???????? ??????bb ??????gg ??????rr
C
C              Else in this order:
C              ???????? ??????Bb ??????Gg ??????Rr
C
               cells = 4
               inc   = 32
               IF( (vc.mode .EQ. $ERESCOLOR)  .OR.
     +             (vc.mode .EQ. $VRES16COLOR)) inc = 16

            CASE( 4 )
C
C              Active bits in this order:
C              ???????? ??????Bb ??????Gg ??????Rr
C
               cells = 2
               inc   = 32

            CASE DEFAULT
               CYCLE

         END SELECT

         xinc = vc.numxpixels / cells
         yinc = vc.numypixels / cells

C
C        Fill palette arrays in BGR order.
C
         i = 1
         DO iblue = 0, 63, inc
            DO igreen = 0, 63, inc
               DO ired = 0, 63, inc
                  pal(i) = RGB( ired, igreen, iblue )
C
C                 Special case: using 6 bits to represent 16 colors
C                 If both bits are on for a color, intensity is set
C                 If one bit is set for a color, the color is on.
C
                  IF( inc .EQ. 32 )
     +                pal(i + 8) = pal(i) .OR. (pal(i) / 2)
                  i = i + 1
               END DO
            END DO
         END DO
C
C        If palettes available, remap all palettes at once.
C        Otherwise, quit.
C
         IF( remapallpalette( pal ) .EQ. 0 ) THEN
            status2 = setvideomode( $DEFAULTMODE )
            STOP 'Palettes not available with this adapter'
         END IF
C
C        Draw colored squares.
C
         i = 0
         DO x = 0, ( xinc * cells ) - 1, xinc
            DO y = 0, ( yinc * cells ) - 1, yinc
               status2 = setcolor( INT4( i ) )
               status2 = rectangle( $GFILLINTERIOR, x, y, x + xinc,
     +                             y + yinc )
               i      = i + 1
            END DO
         END DO

         status2 = setcolor( INT4( vc.numcolors / 2 ) )
         WRITE (str1, '(I3)') vc.mode
         WRITE (str2, '(I3)') vc.numcolors
         CALL outtext( 'Mode' // str1 // ' has' //
     +                  str2 // ' colors' )
         READ (*,*)

C
C        Change each palette entry separately in GRB order.
C
         i = 0
         DO igreen = 0, 63, inc
            DO ired = 0, 63, inc
               DO iblue = 0, 63, inc
                  tmp    = RGB( ired, igreen, iblue )
                  status4 = remappalette( i, tmp )
                  IF( inc .EQ. 32 )
     +               status4 = remappalette(i + 8, tmp.OR.(tmp / 2))
                  i = i + 1
               END DO
            END DO
         END DO

READ (*,*)      ! Wait for ENTER to be pressed
      END DO

      status2 = setvideomode( $DEFAULTMODE )
      END



CC  RGB - Function for mixing red, green, and blue color elements.
CC
CC  Params:r,g,b-Valuesforred,green,and blue, respectively
CC
CC  Return:Mixed color value

      INTEGER*4 FUNCTION RGB( r, g, b )
      INTEGER*4 r, g, b
      
      RGB = ISHL( ISHL( b, 8 ) .OR. g, 8 ) .OR. r
      RETURN
      END
