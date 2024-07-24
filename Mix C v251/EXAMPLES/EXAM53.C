#include <stdio.h>

main ()         /*  Example 5.3  */
{
   /* copy a file from stdin to stdout */

   int charin;

   while ( (charin = getchar()) != EOF )
      putchar(charin);
}
