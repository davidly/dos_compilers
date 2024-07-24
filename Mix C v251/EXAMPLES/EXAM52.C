/*include standard I/O header file */
#include <stdio.h>

main ()         /* Example 5.2 */
{
  /* this program reads characters from stdin
     and writes them to stdout */

   int charin;

   /* Type Ctrl Z to terminate the program */

   while ( (charin = getc(stdin)) != EOF )
      putc(charin, stdout);
}
