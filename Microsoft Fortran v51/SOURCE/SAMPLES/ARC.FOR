       INCLUDE   'FGRAPH.FI'
       INCLUDE   'FGRAPH.FD'

       INTEGER*2          status
       RECORD / xycoord / xystart, xyend, xyfill
 
       status = setvideomode( $MRES16COLOR )
       status = arc( 80, 50, 240, 150, 80, 50, 240, 150 )

       status = getarcinfo( xystart, xyend, xyfill )
       CALL moveto( xystart.xcoord, xystart.ycoord, xyfill )
       status = lineto( xyend.xcoord, xyend.ycoord )
       status = floodfill( xyfill.xcoord, xyfill.ycoord, getcolor() )

       READ( *, * )     ! Press ENTER to exit
       status = setvideomode( $DEFAULTMODE )

       END 


