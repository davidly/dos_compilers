/* INTRO13.C--Example from Chapter 4 of User's Guide */

#include <conio.h>
#include <stdio.h>
#include <ctype.h>

int main()
{
   char cmd;

   printf("Chart desired: Pie  Bar  Scatter  Line  Three-D");
   printf("\nPress first letter of the chart you want: ");
   cmd = toupper(getch());
   printf("\n");

   if (cmd == 'P')
      printf("Doing pie chart\n");
   else if (cmd == 'B')
      printf("Doing bar chart\n");
   else if (cmd == 'S')
      printf("Doing scatter chart\n");
   else if (cmd == 'L')
      printf("Doing line chart\n");
   else if (cmd == 'T')
      printf("Doing 3-D chart\n");
   else printf("Invalid choice.\n");

   return 0;
}
