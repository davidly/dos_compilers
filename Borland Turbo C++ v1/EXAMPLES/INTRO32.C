/* INTRO32.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>

int main()
{
   char name[40];
   char number[10];
   char *str_ptr = name;
   int pos, num_chars;

   printf("Enter a string for the character array: ");
   gets(name);
   printf("How many characters do you want to extract? ");
   gets(number);
   sscanf(number, "%d", &num_chars);

   for (pos = 0; pos < num_chars; pos++)
      printf("%c", *str_ptr++);
   printf("\n");

   return 0;
}
