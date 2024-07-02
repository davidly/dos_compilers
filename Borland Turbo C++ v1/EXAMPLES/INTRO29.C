/* INTRO29.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   enum workday {mon, tues, wed, thurs, fri};
   int day;

   for (day = mon; day <= fri; day++)
      printf("%d\n", day);

   return 0;
}
