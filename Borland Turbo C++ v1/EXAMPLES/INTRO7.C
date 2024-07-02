/* INTRO7.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   float result;
   result = 1.0 + 2.0 * 3.0 / 4.0;
   printf("%f\n", result);
   result = 1.0 / 2.0 + 3.0;
   printf("%f\n", result);
   result = (1.0 + 2.0) / 3.0;
   printf("%f\n", result);
   result = (1.0 + 2.0 / 3.0) + 4.0;
   printf("%f\n", result);

   return 0;
}
