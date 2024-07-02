/* INTRO20.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

#define WARNING -1

int get_status(void)
{
   return WARNING;
}

int main()
{
   int count = 10;
   while (count-- > 1)
   {
      if (get_status() == WARNING)
         break;
      printf("%d\n", count);
   }
   if (count == 0)
      printf("Shuttle launched\n");
   else
   {
      printf("Warning received\n");
      printf("Count down held at t - %d", count);
   }

   return 0;
}
