/* INTRO5.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int   int_num = 999;
   float float_num = 99.99895;
   long  double big_num = 1250500750.75;

   printf("12345678901234567890\n");
   printf("%d\n", int_num);
   printf("%6d\n", int_num);
   printf("%f\n", float_num);
   printf("%6.3f\n", float_num);
   printf("%e\n", big_num);
   printf("%Le\n", big_num);

   return 0;
}
