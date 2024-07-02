/* INTRO18.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int number, total;
   for (number = 1, total = 0; number < 11; total += number,
	number++);
   printf("Total of numbers from 1 to 10 is %d\n", total);

   return 0;
}
