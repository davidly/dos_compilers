#include "stdio.h"

#define DIGITS_TO_FIND 200 /*9009;*/
main() {
  int digits;
  int x ;
  int a[ DIGITS_TO_FIND ];
  int n;

  x = 0;
  digits = DIGITS_TO_FIND;
  n = digits - 1;

  while ( n > 0 )
  {
      n--;
      a[n] = 1;
  }

  a[1] = 2;
  a[0] = 0;
  while (digits > 9) {
      n = digits--;
      while (--n) {
          a[n] = x % n;

          x = 10 * a[n-1] + x/n;
      }
      printf("%d", x);
  }

  printf( "\ndone\n" );

  return 0;
}
