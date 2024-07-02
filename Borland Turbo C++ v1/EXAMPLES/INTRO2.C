/* INTRO2.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char  inbuf[130];
   float num, denom;     /* numerator and denominator of fraction */
   float value;          /* value of fraction as decimal */

   printf("Convert a fraction to a decimal\n");
   printf("Numerator: ");
   gets(inbuf);
   sscanf(inbuf, "%f", &num);
   printf("Denominator: ");
   gets(inbuf);
   sscanf(inbuf, "%f", &denom);

   value = num / denom;  /* convert fraction to decimal */

   printf("\n %f / %f  = %f", num, denom, value);

   return 0;
}
