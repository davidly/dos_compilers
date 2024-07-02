/* INTRO9.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <conio.h>

int main()
{
   int one_char;
   printf("Enter a character: ");
   one_char = getch();
   printf("\nThe character you entered was %c\n", one_char);
   printf("Its ASCII value is %d\n", one_char);

   return 0;
}
