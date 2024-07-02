/* INTRO17.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int ascii_val;

   for (ascii_val = 32; ascii_val < 256; ascii_val++)
   {
      printf("\t%c", ascii_val);
      if (ascii_val % 9 == 0)
         printf("\n");
   }

   return 0;
}
