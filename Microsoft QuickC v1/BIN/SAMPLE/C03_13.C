#include <stdio.h>
typedef char * string;
main()
{
   char c, j;
   int i;
   string item1[10], item2[10];
   float x;
   printf ("please enter a single character:\n");
   c = getchar();
   printf ("\tthe character just input was -- %c\n",c);
   printf ("\nenter a digit, a string, a float, and a string: ");
   scanf ("%d %s %f %s", &i, item1, &x, item2);
   printf ("\n\ayou entered\n");
   printf ("%d\n%s\n%f\n%s", i, item1, x, item2);
   printf ("\n\nexample of conversion specifications:\n");
   printf ("decimal\toctal\thex\tcharacter\n");
   for (j = 65; j<=70; j++)
      printf ("%d\t%o\t%x\t%c\n", j,j,j,j);
}

