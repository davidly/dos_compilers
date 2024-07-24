#include <stdio.h>
main()      /* Example 5.7 */
{
   int digit = 0, other = 0, space = 0;
   int charin;

   printf("\nThis program will count ");
   printf("occurrences of digits,\n");
   printf("whitespace and other characters\n");
   printf("Enter EOF to terminate the program\n");
   printf("Reading input ..........\n");
   while((charin = getchar()) != EOF)
      switch(charin) {
         case '0':
         case '1':
         case '2':
         case '3':
         case '4':
         case '5':
         case '6':
         case '7':
         case '8': case '9': digit++;
                   break;     /* exit switch */
         case '\t':
         case '\n':
         case ' ': space++;
                   break;     /* exit switch */
         default:  other++;
                   break;     /* exit switch */
      }
   printf("\n\n SUMMARY\n");
   printf("There were %d digits entered\n", digit);
   printf("Along with %d whitespace characters\n",
      space);
   printf(" and %d other characters.\n",other);
}         
