main()      /* Example 3.7 */
{
   int sum, count, num;
   printf("This program sums 5 integer numbers \n");
   sum = 0;
   for (count=0; count < 5; count++) {
      printf("Enter a number : ");
      scanf("%d",&num);
      sum += num;
   }
   printf("Total of the five numbers = %d\n",sum);
}
