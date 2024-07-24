#include <stdio.h>
main()          /* Example 5.4a */
{
   int count = 0, charin;
   int digit = 0, other = 0;
   int alpha = 0, space = 0;

   printf("\nThis program will count ");
   printf("occurrences of digits,\n");
   printf("alphabetic characters, and whitespace\n");
   printf("Enter EOF to terminate the program\n");
   printf("Reading input.......\n");
   for(count=0;;++count) {
      charin = getchar();
      if (isalpha(charin)) alpha++;
      else if (isdigit(charin)) digit++;
      else if (isspace(charin)) space++;
      else if (charin == EOF)  break;
      else other++;
   }
   printf("\nSUMMARY\n");
   printf("\nThere were %d digits entered\n",digit);
   printf("Along with %d alphabetic characters,\n",alpha);
   printf(" %d whitespace characters,\n",space);
   printf("and %d other characters.\n",other);
   printf("For a total of %d characters read.\n",count);
}
