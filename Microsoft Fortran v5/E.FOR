      program e
      integer*2 high, n, x
      integer*2 a(200)

      high = 200
      x = 0
      n = high - 1

  150 if ( n .le. 0 ) goto 200
      a( n + 1 ) = 1
      n = n - 1
      goto 150

  200 a( 2 ) = 2
      a( 1 ) = 0
  220 if ( high .le. 9 ) goto 400
      high = high - 1
      n = high
  240 if ( n .eq. 0 ) goto 300
      a( n + 1 ) = MOD( x, n )
      x = ( 10 * a( n ) ) + ( x / n )
      n = n - 1
      goto 240
  300 if ( x .ge. 10 ) goto 320
      write( *, 2000 ) x
      goto 220
  320 write( *, 2001 ) x
      goto 220
  400 write( *, 2010 )
 2000 format( '+', I1 )
 2001 format( '+', I2 )
 2010 format( '  done' )
      end



