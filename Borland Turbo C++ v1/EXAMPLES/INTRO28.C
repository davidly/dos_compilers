/* INTRO28.C--Example from Chapter 4 of User's Guide */

#include <stdio.h>
#include <string.h>

int main()
{
   char name[60];
   strcpy(name, "Bilbo ");
   strcat(name, "Baggins");
   puts(name);

   return 0;
}
