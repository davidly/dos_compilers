/* INTRO10.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   int first, second;
   printf("Input two numbers\n");
   gets(inbuf);
   sscanf(inbuf, "%d %d", &first, &second);
   printf("first > second has the value %d\n", first > second);
   printf("first < second has the value %d\n", first < second);
   printf("first == second has the value %d\n", first == second);

   return 0;
}
