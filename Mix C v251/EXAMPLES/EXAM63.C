#define MAX 10 /* bound of the array */

#include <stdio.h>   /* standard header file */
main()               /* Example 6.3 */
{
   /* Counts occurrences of numbers in input */

   int digit_count[MAX], i;
   int char_in;  /* What happens if this is type char? */

   /* initialize the array to zeros */
   
   for(i = 0; i < MAX; i++)
      digit_count[i] = 0;   

   /* find digits in input and count occurrences */

   while ( (char_in = getchar()) != EOF)  {
      if (char_in >= '0' && char_in <= '9')
         digit_count[char_in - '0']++;
   }
   
   /*  print out information collected */

   for(i = 0; i < MAX; i++)
      printf(
        "There are %d occurrences of %d in the input\n",
         digit_count[i],i);
}
