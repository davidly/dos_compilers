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

