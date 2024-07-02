/* INTRO16.C--Example from Chapter 4 of User's Guide */

#include <conio.h>
#include <ctype.h>
#include <stdio.h>

int main()
{
   char cmd;

   do {
      printf("Chart desired: Pie  Bar  Scatter  Line  Three-D  Exit");
      printf("\nPress first letter of the chart you want: ");
      cmd = toupper(getch());
      printf("\n");

      switch (cmd)
      {
         case 'P': printf("Doing pie chart\n"); break;
         case 'B': printf("Doing bar chart\n"); break;
         case 'S': printf("Doing scatter chart\n"); break;
         case 'L': printf("Doing line chart\n"); break;
         case 'T': printf("Doing 3-D chart\n"); break;
         case 'E': break;
         default : printf("Invalid choice. Try again\n");
      }
   } while (cmd != 'E');

   return 0;
}
