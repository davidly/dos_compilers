CC  SIEVE.FOR - Prime number sieve program (INTEGER*4 version)
CC
CC  References:  A High-Level Language Benchmark,
CC               Byte Magazine, September, 1981
CC

      INTEGER*4 i, n_iterate, count, largest
      REAL*8    begin_time, end_time, dif_time, secnds

      WRITE (*,9000) ' Enter number of iterations:  '
      READ  (*,*) n_iterate
      begin_time = secnds()

      DO i = 1, n_iterate
         CALL sieve( count, largest )
      END DO

      end_time = secnds()
      dif_time = end_time - begin_time
      WRITE (*,9100) count
      WRITE (*,9200) largest
      WRITE (*,9300) dif_time
      WRITE (*,9400) n_iterate / dif_time

 9000 FORMAT( // A \ )
 9100 FORMAT( '0Primes calculated: ', I10 )
 9200 FORMAT( ' Largest prime:     ', I10 )
 9300 FORMAT( ' Elapsed time:      ', F12.1, ' seconds' )
 9400 FORMAT( ' Average time:      ', F12.1, ' iterations per second' )
      END



CC  SIEVE - Determines prime numbers between 0 and 2*SIZE.
CC          Uses prior knowledge that:
CC          -  0, 1, 2, and 3 are first four prime numbers
CC          -  All other even numbers are not prime
CC          -  All multiples of prime numbers are not prime
CC
CC  Params:  count   -  number of primes found
CC           largest -  largest prime
CC

      SUBROUTINE sieve( count, largest )
      INTEGER*4  count, largest

      INTEGER*4  SIZE, i, prime, k
      PARAMETER  ( SIZE = 8191 )
      LOGICAL    flags (SIZE)

      DO i = 1, SIZE
         flags (i) = .TRUE.
      END DO

      count = 0
      DO i = 1, SIZE
         IF( flags (i) ) THEN
            prime = i + i + 1
            DO k = i + prime, SIZE, prime
               flags(k) = .FALSE.
            END DO
            count = count + 1
         END IF
      END DO

      largest = prime
      RETURN
      END



CC  SECNDS - Calls GETTIM function to find current time.
CC
CC  Return:  Number of seconds since midnight.
CC

      REAL*8 FUNCTION  secnds()

      INTEGER*2 hour, minute, second, hundredth

      CALL GETTIM( hour, minute, second, hundredth )
      secnds = ((DBLE( hour ) * 3600.0) + (DBLE( minute) * 60.0) +
     +           DBLE( second) + (DBLE( hundredth ) / 100.0))
      END
