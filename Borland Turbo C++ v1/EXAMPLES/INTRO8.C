/* INTRO8.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char inbuf[130];
   char one_char;
   printf("Enter a character: ");
   gets(inbuf);
   sscanf(inbuf, "%c", &one_char);
   printf("The character you entered was %c\n", one_char);
   printf("Its ASCII value is %d\n", one_char);

   return 0;
}
