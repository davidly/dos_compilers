      INCLUDE 'FLIB.FI'

      PROGRAM MTRX_W

      INCLUDE 'FLIB.FD'

      REAL*8 a[ALLOCATABLE] (:,:), b[ALLOCATABLE] (:,:),
     +       c[ALLOCATABLE] (:,:)
      INTEGER*2 rows, cols, prods, dummy

C
C  Set the About Box message
C
      dummy = ABOUTBOXQQ ('Matrix Multiplier\r    Version 1.0'C)
C
C  Get dimensions of matrices
C
      WRITE (*, '(A)'  ) ' This program multiplies two matrices.'
      WRITE (*, '(A \)')
     +      ' Enter dimensions of first matrix (rows, columns): '
      READ  (*, *) rows, prods

      WRITE (*, '(A, I2, A)') ' Second matrix has ', prods, ' rows.'
      WRITE (*, '(A \)') ' Enter number of columns: '
      READ (*, *) cols
C
C  Allocate matrices
C
      ALLOCATE (a(rows,  prods))
      ALLOCATE (b(prods, cols ))
      ALLOCATE (c(rows,  cols ))
C
C  Get matrix elements
C
      CALL YIELDQQ

      OPEN  (UNIT = 10, FILE = 'USER', TITLE = 'Matrix 1')
      WRITE (10, *) 'Enter first  matrix'
      CALL GetMatrix (rows, prods, a, 10)
      CLOSE (10, STATUS = 'KEEP')

      OPEN  (UNIT = 11, FILE = 'USER', TITLE = 'Matrix 2')
      WRITE (11, *) 'Enter second matrix'
      CALL GetMatrix (prods, cols, b, 11)
      CLOSE (11, STATUS = 'KEEP')
C
C  Multiply them
C
      CALL MultMatrices(rows, prods, cols, a, b, c )
C
C  Show results
C
      OPEN  (UNIT = 12, FILE = 'USER', TITLE = 'Product Matrix')
      WRITE (12, *) 'Product matrix: '
      CALL ShowMatrix (rows, cols,  c, 12)
      CLOSE (12, STATUS = 'KEEP')
      END

C
C Begin subroutines
C

C
C Get a matrix from the user
C
      SUBROUTINE GetMatrix(rows, cols, mtrx [REFERENCE], unitnum)
      INTEGER*2 rows, cols, i, j
      INTEGER unitnum
      REAL*8 mtrx (rows, cols)

      DO 1000, i = 1, rows

          WRITE (unitnum, '(A \, I2 \, A \, I2 \, A \)')
     +          '       Row ', i, '   (', cols, ' values): '
          READ (unitnum, *) (mtrx(i,j), j = 1, cols)
 1000 CONTINUE
      RETURN
      END

C
C Display the matrix
C
      SUBROUTINE ShowMatrix (rows, cols, mtrx, unitnum)
      INTEGER*2 rows, cols, i, j
      INTEGER unitnum
      REAL*8 mtrx (rows,cols)

      DO 2000, i = 1, rows
          WRITE (unitnum, '(A\)') '    '
          DO 2100, j = 1, cols
              WRITE (unitnum, '(A \, F6.1\)') '  ', mtrx (i, j)
 2100     CONTINUE
          WRITE (unitnum, *) ' '
 2000 CONTINUE
      RETURN
      END
C
C Multiply the matrices
C

      SUBROUTINE MultMatrices( rows, prods, cols, a, b, c [REFERENCE])

      INTEGER*2 i, j, k, rows, prods, cols
      REAL*8 a(rows, prods), b(prods, cols), c(rows, cols)

      DO 3000, j = 1, cols
          DO 3100, i = 1, rows
              c(i, j) = 0.0
              DO 3200, k = 1, prods
                  c(i, j) = c(i, j) + (a(i, k) * b(k, j))
 3200         CONTINUE
 3100     CONTINUE
 3000 CONTINUE
      RETURN
      END

