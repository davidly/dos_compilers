#include <stdio.h>

#define DIGITS_TO_FIND 200 /*9009*/

int main() {

  int N = DIGITS_TO_FIND;
  int x = 0;
  int a[ DIGITS_TO_FIND ];
  int n;

  for (n = N - 1; n > 0; --n) {
      a[n] = 1;
  }

  a[1] = 2, a[0] = 0;
  while (N > 9) {
      n = N--;
      while (--n) {
          a[n] = x % n;

          if ( a[ n - 1 ] > 20000 )
              printf( "overflow coming\n" );

          x = 10 * a[n-1] + x/n;
      }
      printf("%d", x);
  }

  printf( "\ndone\n" );

  return 0;
}
