C fortran version of proving you can't win at tic-tac-toe if the opponent is competent
C constants:
C    score win:   6
C    score tie:   5
C    score lose:  4
C    score max:   9
C    score min:   2
C    piece X:     1
C    piece O:     2
C    piece blank: 0

$include : 'forexec.inc'

      program ttt
      integer*4 moves
      integer*2 b(9), sp(10), sv(10), sa(10), sb(10), sm(10)
      integer*2 mc
      integer*2 alpha, beta, wi, st, sc, v, p, pm, m
      common /area/ b,sp,sv,sa,sb,sm,mc,alpha,beta,wi,st,sc,v,p,pm,m

      integer*2 system

      do 6 l = 1, 9, 1
          b( l ) = 0
 6    continue

      l = system('tm'c)
      moves = 0

      do 10 l = 1, 10, 1
C      do 10 l = 1, 1, 1
          mc = 0
          m = 1
          call runmm
          m = 2
          call runmm
          m = 5
          call runmm
          moves = moves + mc
 10   continue

      l = system('tm'c)
      write( *, 20 ) moves
 20   format( '  moves: ', I6 )
      end

 1000 subroutine runmm
      integer*2 b(9), sp(10), sv(10), sa(10), sb(10), sm(10)
      integer*2 mc
      integer*2 alpha, beta, wi, st, sc, v, p, pm, m
      common /area/ b,sp,sv,sa,sb,sm,mc,alpha,beta,wi,st,sc,v,p,pm,m

      alpha = 2
      beta = 9
      p = m
      b(m) = 1
      call minmax
      b(m) = 0
      return
      end

 2000 subroutine winner
      integer*2 b(9), sp(10), sv(10), sa(10), sb(10), sm(10)
      integer*2 mc
      integer*2 alpha, beta, wi, st, sc, v, p, pm, m
      common /area/ b,sp,sv,sa,sb,sm,mc,alpha,beta,wi,st,sc,v,p,pm,m

      wi = b( 1 )
      if ( 0 .eq. wi ) go to 2100
      if ( ( wi .eq. b( 2 ) ) .and. ( wi .eq. b( 3 ) ) ) return
      if ( ( wi .eq. b( 4 ) ) .and. ( wi .eq. b( 7 ) ) ) return
 2100 wi = b( 4 )
      if ( 0 .eq. wi ) go to 2200
      if ( ( wi .eq. b( 5 ) ) .and. ( wi .eq. b( 6 ) ) ) return
 2200 wi = b( 7 )
      if ( 0 .eq. wi ) go to 2300
      if ( ( wi .eq. b( 8 ) ) .and. ( wi .eq. b( 9 ) ) ) return
 2300 wi = b( 2 )
      if ( 0 .eq. wi ) go to 2400
      if ( ( wi .eq. b( 5 ) ) .and. ( wi .eq. b( 8 ) ) ) return
 2400 wi = b( 3 )
      if ( 0 .eq. wi ) go to 2500
      if ( ( wi .eq. b( 6 ) ) .and. ( wi .eq. b( 9 ) ) ) return
 2500 wi = b( 5 )
      if ( 0 .eq. wi ) return
      if ( ( wi .eq. b( 1 ) ) .and. ( wi .eq. b( 9 ) ) ) return
      if ( ( wi .eq. b( 3 ) ) .and. ( wi .eq. b( 7 ) ) ) return
      wi = 0
      end

 4000 subroutine minmax
      integer*2 b(9), sp(10), sv(10), sa(10), sb(10), sm(10)
      integer*2 mc
      integer*2 alpha, beta, wi, st, sc, v, p, pm, m
      common /area/ b,sp,sv,sa,sb,sm,mc,alpha,beta,wi,st,sc,v,p,pm,m

      st = 0
      v = 0
 4100 mc = mc + 1
      if ( st .lt. 4 ) go to 4150
C the computed goto is about 20% faster than calling winner
C      call winner
      go to ( 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090 ), p
 4110 if ( wi .eq. 0 ) go to 4140
      if ( wi .ne. 1 ) go to 4130
      sc = 6
      go to 4280
 4130 sc = 4
      go to 4280
 4140 if ( st .ne. 8 ) go to 4150
      sc = 5
      go to 4280
 4150 if ( b( p ) .eq. 1 ) go to 4160
      v = 2
      pm = 1
      go to 4170
 4160 v = 9
      pm = 2
 4170 p = 1
 4180 if ( b( p ) .ne. 0 ) go to 4500
      b( p ) = pm
 4182 st = st + 1
      sp( st ) = p
      sv( st ) = v
      sa( st ) = alpha
      sb( st ) = beta
      sm( st ) = pm
      go to 4100
 4280 p = sp( st )
      v = sv( st )
      alpha = sa( st )
      beta = sb( st )
      pm = sm( st )
      st = st - 1
      b( p ) = 0
      if ( pm .eq. 1 ) go to 4340
      if ( sc .eq. 4 ) go to 4530
      if ( sc .lt.  v ) v = sc
      if ( v .lt. beta ) beta = v
      if ( beta .le. alpha ) go to 4520
      go to 4500
 4340 if ( sc .eq. 6 ) go to 4530
      if ( sc .gt. v ) v = sc
      if ( v .gt. alpha ) alpha = v
      if ( alpha .ge. beta ) go to 4520
 4500 p = p + 1
      if ( p .lt. 10 ) go to 4180
 4520 sc = v
 4530 if ( st .eq. 0 ) return
      go to 4280

 5010 wi = b(1)
      if ( ( wi .eq. b(2) ) .and. ( wi .eq. b(3) ) ) goto 4110
      if ( ( wi .eq. b(4) ) .and. ( wi .eq. b(7) ) ) goto 4110
      if ( ( wi .eq. b(5) ) .and. ( wi .eq. b(9) ) ) goto 4110
      wi = 0
      go to 4110

 5020 wi = b(2)
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(3) ) ) goto 4110
      if ( ( wi .eq. b(5) ) .and. ( wi .eq. b(8) ) ) goto 4110
      wi = 0
      go to 4110

 5030 wi = b(3)
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(2) ) ) goto 4110
      if ( ( wi .eq. b(6) ) .and. ( wi .eq. b(9) ) ) goto 4110
      if ( ( wi .eq. b(5) ) .and. ( wi .eq. b(7) ) ) goto 4110
      wi = 0
      go to 4110

 5040 wi = b(4)
      if ( ( wi .eq. b(5) ) .and. ( wi .eq. b(6) ) ) goto 4110
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(7) ) ) goto 4110
      wi = 0
      go to 4110

 5050 wi = b(5)
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(9) ) ) goto 4110
      if ( ( wi .eq. b(3) ) .and. ( wi .eq. b(7) ) ) goto 4110
      if ( ( wi .eq. b(2) ) .and. ( wi .eq. b(8) ) ) goto 4110
      if ( ( wi .eq. b(4) ) .and. ( wi .eq. b(6) ) ) goto 4110
      wi = 0
      go to 4110

 5060 wi = b(6)
      if ( ( wi .eq. b(4) ) .and. ( wi .eq. b(5) ) ) goto 4110
      if ( ( wi .eq. b(3) ) .and. ( wi .eq. b(9) ) ) goto 4110
      wi = 0
      go to 4110

 5070 wi = b(7)
      if ( ( wi .eq. b(8) ) .and. ( wi .eq. b(9) ) ) goto 4110
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(4) ) ) goto 4110
      if ( ( wi .eq. b(5) ) .and. ( wi .eq. b(3) ) ) goto 4110
      wi = 0
      go to 4110

 5080 wi = b(8)
      if ( ( wi .eq. b(7) ) .and. ( wi .eq. b(9) ) ) goto 4110
      if ( ( wi .eq. b(2) ) .and. ( wi .eq. b(5) ) ) goto 4110
      wi = 0
      go to 4110

 5090 wi = b(9)
      if ( ( wi .eq. b(7) ) .and. ( wi .eq. b(8) ) ) goto 4110
      if ( ( wi .eq. b(3) ) .and. ( wi .eq. b(6) ) ) goto 4110
      if ( ( wi .eq. b(1) ) .and. ( wi .eq. b(5) ) ) goto 4110
      wi = 0
      go to 4110

      end


