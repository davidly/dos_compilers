C     should tend towards 1.61803398874989484820458683436563811772030
      program phi
      real*8 d, d1, d2
      integer*4 prev2, prev1, next
      integer i

      write( *, 1005 )
      prev2 = 1
      prev1 = 1

      do 10 i = 1, 40, 1
          next = prev1 + prev2
          prev2 = prev1
          prev1 = next

          d2 = prev2
          d1 = prev1
          d = d1 / d2

          write( *, 1000 ) i, d
10    continue

      write( *, 1003 )
1000  format( 5X, 'iteration ', I4, '  r8: ', F18.16 )
1003  format( ' complete' )
1005  format( ' should tend towards 1.61803398874989484820458683436563
     c811772030' )
      end

