/* INTRO31.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int intvar = 10;
   int *intptr;
   intptr = &intvar;

   printf("Location of intvar: %p\n", &intvar);
   printf("Contents of intvar: %d\n", intvar);
   printf("Location of intptr: %p\n", &intptr);
   printf("Contents of intptr: %p\n", intptr);
   printf("The value that intptr points to: %d\n", *intptr);

   return 0;
} 
