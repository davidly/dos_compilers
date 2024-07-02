/* INTRO23.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

void showval(void);

int main()
{
   int mainvar = 100;
   showval();
   printf("%d\n", funcvar);

   return 0;
}

void showval(void)
{
   int funcvar = 10;
   printf("%d\n", funcvar);
   printf("%d\n", mainvar);
}
