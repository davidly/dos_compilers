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
   x = strlen2 (test_string);
   printf ("length (increment pointer method): %d\n",x);
   x = strlen3 (test_string);
   printf ("length (pointer subtraction method): %d\n",x);



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

/* pointer-incrementing version */
strlen2 (s)
char *s;
{
   int i;
   for (i=0; *s != '\0'; s++)  /* increment pointer variable s */
      i++;
   return (i);
}

/* pointer-subtraction version */
strlen3 (s)
char *s;
{
   char *p = s; /* set p to point to first character of s */
   while (*p != '\0')
      p++;            /* advance to next character */
   return (p-s);
}

