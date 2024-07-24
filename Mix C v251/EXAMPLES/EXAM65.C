#include <stdio.h>
#define MAXLINE 81   /* 80 characters plus NULL terminator */
main()               /* Example 6.5 */
{
   char line[MAXLINE];

   printf("File copy from stdin to stdout\n");
   printf("Input terminates with EOF");
   while(gets(line) != NULL) puts(line);
}
