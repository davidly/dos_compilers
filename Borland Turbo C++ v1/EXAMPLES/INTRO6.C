/* INTRO6.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int i = 101, j = 59, k = 0;
   int m = 70,  n = 85, p = 5;
   int q = 39, r = 110, s = 11;

   printf("\tWon\tLost\tTied\n\n");
   printf("Eagles\t%3d\t%3d\t%3d\n", i, j, k);
   printf("Lions\t%3d\t%3d\t%3d\n", m, n, p);
   printf("Wombats\t%3d\t%3d\t%3d\n",  q, r, s);

   return 0;
}
