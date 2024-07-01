#include <stdio.h>
#include <ctype.h>  /* needed to use conversion function toupper */
main()
 {
char response [10];
char test_char;
printf ("Please enter your response (yes/no/quit): ");
scanf ("%s", response);      /* formatted input into a string */
if (toupper(response[0]) == 'Q') {    /* test for q */
   printf ("program exit\n");  /* execute if equal to q */
   exit(1);
   }
switch (response[0]) { /* switch based on first character */
   case 'y':           /* multiple case labels */
   case 'n':
     printf ("lowercase y or n as first letter\n");
     break;
   default:
     printf ("not a lowercase y or n as first letter\n");
     break;
   }
test_char = toupper(response[0]);   /* convert to uppercase */
switch (test_char) {
   case 'Y':
       printf ("Response is yes\n");
       break;
   case 'N':
       printf ("Response is no\n");
       break;
   default:
       printf ("Please enter a yes or no\n");
   }
}

