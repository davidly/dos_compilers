/* INTRO33.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

void swap(int *, int *);   /* This is swap's prototype */

int main()
{
   int x = 5, y = 7;
   swap(&x, &y);
   printf("x is now %d and y is now %d\n", x, y);

   return 0;
}

void swap(int *a, int *b)    /* swap is actually defined here */
{
   int temp;
   temp = *a;
   *a = *b;
   *b = temp;
}
