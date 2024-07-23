CC  RGMAIN.FOR - Illustrates real coordinate graphics.

$NOTRUNCATE
$NOTSTRICT

      INCLUDE  'FGRAPH.FI'
      INCLUDE  'FGRAPH.FD'

      LOGICAL  fourcolors
      EXTERNAL fourcolors

      IF( fourcolors() ) THEN
         CALL threegraphs()
      ELSE
         WRITE (*,*) ' This program requires a CGA, EGA, or',
     +               ' VGA graphics card.'
      END IF
      END 
