C
C ANNUITY1.FOR - Generates annuity table. Contains intentional errors.
C                Use with PWB section of "Environment & Tools" manual.
      REAL*8      Pv, Rate, Pmt, RatePct
      ONTEGER     Nper, ActNper

C
C     Get input from the user.
C
      WRITE ( *, '(1X, A \)' ) 'Enter Present Value: '
      READ ( *, * ) Pv
      WRITE ( *, '(1X, A \)' ) 'Enter Interest Rate in Percent: '
      READ ( *, * ) Rate
      WRITE ( *, '(1X, A \)' ) 'Enter Number of Periods in Years:
      READ ( *, * ) Nper

C
C     Calculate periodic percentage as a fraction (RatePct),
C     number of periods in months (ActNper). Then, calculate
C     the monthly payment (Pmt).
C
      RatePct = Rate / 1200.0
      ActNper = Nper * 12
      Pmt = Pv * (RatePct / (1.0 - (1.0 / ((1.0 + RatePct) **
     +      ActNper))))

C
C     Write a summary of the annuity to the screen (*) device.
C
      WRITE( *,
     +'( 1X, /,
     +1X, 10HPrincipal:, T20, F13.2, /,
     +1X, 14HInterest Rate:, T20, F13.2, /,
     +1X, 16HNumber of Years:, T20, I13, /,
     +1X, 16HMonthly Payment:, T20, F13.2, /,
     +1X, 15HTotal Payments:, T20, F13.2, /
     +1X, 15HTotal Interest:, T20, F13.2 )' )
     +Pv, Rate, Nper, Pmt, Pmt * Nper * 12.0,
     +Pmt * Nper * 12.0 - Pv

C
C     Write headings for an amortization table to the screen
C
      WRITE( *, '(1X, /, 1X, 6HPeriod, 2X, 6H  Year, 2X, 9HPrincipal, 2X,
     +                  9H Interest,
     +                /, 1X, 6H------, 2X, 6H  ----, 2X, 9H---------, 2X,
     +                  9H -------- )' )

C
C     Loop for the actual number of periods printing the period, year,
C     interest portion and principal portion of the payment
C
      DO iPeriod = 1, ActNper
      PerInterest = Pv * RatePct
      PerPrin = Pmt - PerInterest
      WRITE( *, '(1X, I6, 2X, I6, 2X, F9.2, 2X, F9.2 )' )
     +iPeriod,
     +iPeriod / 12,
     +PerPrin,
     +PerInterest
      Pv = Pv - PerPrin
      END DO

      END
