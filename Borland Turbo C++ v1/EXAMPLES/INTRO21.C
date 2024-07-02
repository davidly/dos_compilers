/* INTRO21.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int num = 0;
   while (num++ <= 10)
   {
      if (num % 2 != 0)
         continue;
      printf("%d\n", num);
   }

   return 0;
}
