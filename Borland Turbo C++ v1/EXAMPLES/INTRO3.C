/* INTRO3.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   int  number = 10;
   printf("Address of variable number = %ld\n", &number);
   printf("Value stored at variable number = %d\n", number);	
   printf("Enter a new value for the variable: ");
   gets(inbuf);
   sscanf(inbuf, "%d", &number);
   printf("New value stored at variable number = %d\n", number);

   return 0;
}
