#define TAB 8       /*  Example 5.5 */
#include <stdio.h>
main ()
{
   /* Convert tab characters to blanks
      The tab character is generated
      from the keyboard by Ctrl I */
   int c,i;
   while((c = getchar()) != EOF) {
      if ( c == '\t') {
         for ( i = 0; i < TAB; i++) putchar(' ');
         continue;
      }
      putchar(c);
   }
}
