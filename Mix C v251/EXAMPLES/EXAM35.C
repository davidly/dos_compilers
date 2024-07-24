main()      /* Example 3.5 */
{
   int sum = 0;
   int number, ok = 1;
   /* try (ok = 1) */
   while (ok == 1) {
      printf("Enter a number to sum");
      printf("(zero will terminate): ");
      scanf("%d",&number);
      if (number == 0) ok = 0;
      else sum = sum + number;
   }
   printf("The total sum is %d\n",sum);
}
