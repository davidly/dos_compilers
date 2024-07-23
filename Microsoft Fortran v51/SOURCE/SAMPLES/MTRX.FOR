      PROGRAM MATRIX
C
C  This program calculates the product of two matrices. The product
C  matrix has
C
C    - the same number of rows as the first matrix
C    - the same number of columns as the second matrix
C
C  The number of rows in the second matrix must equal the number of
C  columns in the first matrix. This is the number of products that are
C  summed for each element in the product matrix.
C

      REAL*8 a[ALLOCATABLE] (:,:), b[ALLOCATABLE] (:,:),
     +       c[ALLOCATABLE] (:,:)
      INTEGER*2 rows, cols, prods
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
      WRITE (*, *) 'Enter first  matrix'
      CALL GetMatrix (rows, prods, a)

      WRITE (*, *) 'Enter second matrix'
      CALL GetMatrix (prods, cols, b)
C
C  Multiply them
C
      CALL MultMatrices(rows, prods, cols, a, b, c )
C
C  Show results
C
      WRITE (*, *) 'First  matrix:'
      CALL ShowMatrix (rows, prods, a)

      WRITE (*, *) 'Second matrix:'
      CALL ShowMatrix (prods, cols, b)

      WRITE (*, *) 'Product matrix: '
      CALL ShowMatrix (rows, cols,  c)
      END

C
C Begin subroutines
C

C
C Get a matrix from the user
C
      SUBROUTINE GetMatrix(rows, cols, mtrx [REFERENCE])
      INTEGER*2 rows, cols, i, j
      REAL*8 mtrx (rows, cols)

      DO 1000, i = 1, rows

          WRITE (*, '(A \, I2 \, A \, I2 \, A \)')
     +          '       Row ', i, '   (', cols, ' values): '
          READ (*, *) (mtrx(i,j), j = 1, cols)
 1000 CONTINUE
      RETURN
      END

C
C Display the matrix
C
      SUBROUTINE ShowMatrix (rows, cols, mtrx)
      INTEGER*2 rows, cols, i, j
      REAL*8 mtrx (rows,cols)

      DO 2000, i = 1, rows
          WRITE (*, '(A\)') '    '
          DO 2100, j = 1, cols
              WRITE (*, '(A \, F6.1\)') '  ', mtrx (i, j)
 2100     CONTINUE
          WRITE (*, *) ' '
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
