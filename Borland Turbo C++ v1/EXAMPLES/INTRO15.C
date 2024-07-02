/* INTRO15.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   int  number;            /* Number entered by user */
   int  total = 0;         /* Total of numbers entered so far */
   int  count = 1;         /* Count of numbers entered */

   printf("Enter 0 to quit\n");
   /* Priming statement puts a value into number */
   gets(inbuf);
   sscanf(inbuf, "%d", &number);

   while (number != 0)
   {
      total += number;
      gets(inbuf);
      sscanf(inbuf, "%d", &number);
      if(number == 0)
         printf("Thank you. Ending routine.\n");
      else count++;
   }
   printf("Total is %d\n", total);
   printf("Average is %d\n", total / count);

   return 0;
}
