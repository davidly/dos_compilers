/* INTRO27.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char string[80];              /* Has 79 usable elements */
   char number[10];
   int pos, num_chars;

   printf("Enter a string for the character array: ");
   gets(string);
   printf("How many characters do you want to extract? ");
   gets(number);
   sscanf(number, "%d", &num_chars);

   for (pos = 0; pos < num_chars; pos++)
      printf("%c", string[pos]);
   printf("\n");

   return 0;
}
