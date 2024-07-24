#define TRUE 1
main()         /* Example 3.8 */
{
   int sum, count, num;     /* declarations */
   int go = TRUE;

   printf("This program sums 5 integer numbers \n");
 /* initialize go so that we fall through loop at least once */

   while (go) {
      for (sum = 0,count=0 ; count < 5; count++) {
         printf("Enter a number : ");
         scanf("%d",&num);
         sum += num;
      }
      printf("Total of the five numbers = %d\n",sum);
      printf(
         "Do you have any more sets of 5 numbers to sum?\n");
      printf("Enter 1 for yes and 0 for no: ");
      scanf("%d",&go);
   }
}
