#include <stdio.h>       /* include standard header file */
typedef char * string;   /* rename a char * type to string */

int strlen1 (string);     /* function prototype */

/* declare & initialize test character array (string) */

char test_string [] = "This is a C string";

main()
{
   int x;
   x = strlen1 (test_string);
   printf ("length (array method): %d\n",x);
}

 /* array & subscript version */

strlen1 (s)
char s[];
{
   int i = 0;
   while (s[i] != '\0')
      i++;
   return (i);
}

