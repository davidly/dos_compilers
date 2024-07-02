/* INTRO1.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   int   bushels;
   float dollars, rate;
   char  inbuf [130];
   printf("How many dollars did you get? ");
   gets(inbuf);
   sscanf(inbuf, "%f", &dollars);
   printf("For how many bushels? ");
   gets(inbuf);
   sscanf(inbuf, "%d", &bushels);
   rate = dollars / bushels;
   printf("You got %f dollars for each bushel\n", rate);

   return 0;
}
