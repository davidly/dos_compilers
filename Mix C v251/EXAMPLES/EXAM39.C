main()          /* Example 3.9 */
{
   int sum, count, num;
   int go;
   printf("This program sums 5 integer numbers \n");
   do {
      for (sum = 0,count=0 ; count < 5; count++) {
         printf("Enter a number : ");
         scanf("%d",&num);
         sum += num;
      }
      printf("Total of the five numbers = %d\n",sum);
      printf("Do you have any more sets of 5");
      printf(" numbers to sum?\n");
      printf("Enter 1 for yes and 0 for no\n");
      scanf("%d",&go);
   } while (go);
}
