#include <stdio.h>
main()
{
   int i, done;
   printf ("table of squares (every sixth number)\n");
   printf ("\nfor loop\n");
   printf ("number\t\tsquare\n");
   for (i=0; i<= 20; i+=6)
      printf ("%d\t\t%d\n",i, i*i);
   printf ("\nwhile loop\n");
   printf ("number\t\tsquare\n");
   i = 0;
   while (i <= 20) {
      printf ("%d\t\t%d\n",i, i*i);
      i += 6;
   }
   printf ("\nwhile (nonzero test expression version)\n");
   printf ("number\t\tsquare\n");
   i = 0;
   done = 0;
   while (!done) {    /* will execute until done = 1 */
      printf ("%d\t\t%d\n",i, i*i);
      i += 6;
      if (i > 20)
         done = 1;
   }
}

