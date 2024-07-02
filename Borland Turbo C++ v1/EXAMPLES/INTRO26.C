/* INTRO26.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   float hours[52];
   int week;

   /* Initialize the array */
   for (week = 0; week < 52; week++)
      hours[week] = 0;

   /* Store four values in array */
   hours[0] = 32.5;
   hours[1] = 44.0;
   hours[2] = 40.5;
   hours[3] = 38.0;

   /* Retrieve values and show their addresses */
   printf("Elements\t\tValue\tAddress\n");
   for (week = 0; week < 4; week++)
      printf("hours[%d]\t\t%3.1f\t%p\n", week, hours[week],
             &hours[week]);

   return 0;
}
