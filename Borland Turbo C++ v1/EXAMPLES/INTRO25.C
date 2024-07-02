/* INTRO25.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

#define EVEN(value) (((value) % 2 == 0) ? (value) : ((value) + 1))

int main()
{
   char inbuf[130];
   int  num;
   printf("Enter a number: ");
   gets(inbuf);
   sscanf(inbuf, "%d", &num);
   printf("\n%d", EVEN(num));

   return 0;
}
