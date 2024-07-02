/* INTRO12.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   int  your_number;
   printf("Enter a whole number: ");
   gets(inbuf);
   sscanf(inbuf, "%d", &your_number);

   if (your_number % 2 == 0)
      printf("Your number is even\n");
   else {
      printf("Your number is odd.\n");
      printf("Are you odd, too?\n");
   }
   printf("That's all, folks!\n");

   return 0;
}
