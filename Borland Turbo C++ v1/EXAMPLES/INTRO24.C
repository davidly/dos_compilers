/* INTRO24.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <conio.h>

void tally(void);

int main()
{
   while ( getch() != 'q')
      tally();

   return 0;
}

void tally(void)
{
   static int called = 0;
   called++;
   printf("Function tally called %d times\n", called);
}
