/* INTRO22.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <string.h>
#include <conio.h>

int main()
{
   int pos;
   char text [40];

   printf("Type 'end' to quit\n");

   while (strcmp (gets(text), "end") != 0) {
      for (pos = 1; pos <= strlen(text); pos++)
         putch('-');
      printf("\n");
   }

   return 0;
}
