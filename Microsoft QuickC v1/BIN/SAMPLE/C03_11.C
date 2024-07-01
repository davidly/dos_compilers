#include <stdio.h>
#include <ctype.h>
main()
{
   int number_compare ();
   int string_compare ();
   char s1[80], s2[80];
   printf ("generic test for equality\n");
   printf ("enter first item:\n");
   gets (s1);
   printf ("enter second item:\n");
   gets (s2);
   if (isalpha (*s1))
      compare (s1, s2, string_compare); /* pass address */
   else
      compare (s1, s2, number_compare); /* pass address */
}

compare (a, b, compare_function)
char *a, *b;
/* pointer to function that returns an int */
int (*compare_function) (); 
{
   /* use indirection operator 
      to invoke correct compare function */
   if ((*compare_function) (a,b))
      printf ("equal\n");
   else
      printf ("not equal\n");
}
number_compare (a,b)
char *a, *b;
{
   if (atoi (a) == atoi(b))
      return (1);
   else
      return (0);
}
string_compare (a,b)
char *a, *b;
{
if (strcmp(a,b))
   return (0);
else
   return (1);
}

