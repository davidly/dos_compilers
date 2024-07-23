CC  GRAPHIC.FOR - Displays every graphics mode.

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      INTEGER*2 key
      EXTERNAL  printmenu
      EXTERNAL  showmode

      CALL printmenu( key )
      DO WHILE( key .NE. 0 )
         CALL showmode( key )
      END DO
      END



      SUBROUTINE printmenu( key )

      INCLUDE  'FGRAPH.FD'

      INTEGER*2  dummy, key

      key = -1
      DO WHILE( (key .LT. 0)  .OR.  (key .GT. 12) )
         dummy = setvideomode( $DEFAULTMODE )
         WRITE (*, 9000)
         READ (*,*) key
      END DO

 9000 FORMAT( ' Please ENTER a graphics mode.' /
     +        ' (To exit, ENTER 0.)' /// '  0 Exit'  /
     +        '  1 MRES4COLOR'   / '  2 MRESNOCOLOR' / 
     +        '  3 HRESBW'       / '  4 HERCMONO'    / 
     +        '  5 MRES16COLOR'  / '  6 HRES16COLOR' / 
     +        '  7 ERESNOCOLOR'  / '  8 ERESCOLOR'   / 
     +        '  9 VRES2COLOR'   / ' 10 VRES16COLOR' / 
     +        ' 11 MRES256COLOR' / ' 12 ORESCOLOR'   / )

      END


      SUBROUTINE showmode( which )

      INCLUDE  'FGRAPH.FD'

      INTEGER*2 which, dummy, i, height, width
      INTEGER*2 modes(12) /
     +         $MRES4COLOR , $MRESNOCOLOR, $HRESBW      , $HERCMONO  ,
     +         $MRES16COLOR, $HRES16COLOR, $ERESNOCOLOR , $ERESCOLOR ,
     +         $VRES2COLOR , $VRES16COLOR, $MRES256COLOR, $ORESCOLOR /

      RECORD /videoconfig/ screen

      IF( setvideomode( modes(which) ) .NE. 0 ) THEN
         CALL getvideoconfig( screen )
         width  = screen.numxpixels / screen.numcolors
         height = screen.numypixels / 2
         DO i = 0, screen.numcolors - 1
            dummy = setcolor( INT4( i ) )
            dummy = rectangle( $GFILLINTERIOR, i * width, 0,
     +                       ( i + 1 ) * width, height )
         END DO
      ELSE
         WRITE (*, 9000)
      END IF

      READ (*,*)       ! Wait for ENTER key to be pressed
      dummy = setvideomode( $DEFAULTMODE )
      CALL printmenu( which )

 9000 FORMAT ( ' Video mode is not available.' /
     +         ' Please press ENTER.   ' \ )

      END
