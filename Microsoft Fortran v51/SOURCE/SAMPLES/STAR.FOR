C  Program to draw star-shaped polygons

	   INCLUDE 'FGRAPH.FI'
	   INCLUDE 'FGRAPH.FD'

	   INTEGER*2              status, side, r, draw
	   INTEGER*2              offset, mode
	   REAL                   pi
	   DOUBLE PRECISION       rad
	   RECORD / xycoord /     poly [FAR] (5)
	   RECORD / xycoord /     oldorigin
	   RECORD / videoconfig / vc

	   DATA pi / 3.14159 /

C  Set graphics mode, find dimensions, set origin

	   status = setvideomode( $MAXRESMODE )
	   CALL getvideoconfig( vc )
	   CALL setvieworg( 0, vc.numypixels / 2, oldorigin )
	   offset = INT2( vc.numxpixels / 7 )

C  Calculate the points of the star (every 144 degrees)

	   r = 90

	   DO draw = 1, 5   ! Begin draw loop

	   DO side = 1, 5
		 rad = 144 * pi / 180
		 poly(side).xcoord = INT2( COS( side*rad ) *r ) + draw*offset
		 poly(side).ycoord = INT2( SIN( side*rad ) *r )
	   END DO

C        Set the write mode

		 IF (draw .EQ. 1) status = setwritemode( $GOR )
		 IF (draw .NE. 1) THEN
		   mode = getwritemode()
		   SELECT CASE ( mode )
			 CASE (0)
			   status = setwritemode( $GAND    )
			 CASE (1)
			   status = setwritemode( $GPRESET )
			 CASE (2)
			   status = setwritemode( $GPRSET  )
			 CASE (3)
			   status = setwritemode( $GXOR    )
		   END SELECT
		 END IF

C        Set a color and draw the polygon

		 status = setcolor( draw )
		 status = polygon( $GFILLINTERIOR, poly, 5 )

	   END DO        ! End draw loop

	   READ( *, * )  ! Wait for user to press ENTER

C  Exit the program

	   status = setvideomode( $DEFAULTMODE )

	   END
