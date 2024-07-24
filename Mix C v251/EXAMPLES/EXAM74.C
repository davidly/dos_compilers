#define MAX 5

main()     /* Example 7.4 */
{
   int count;

   printf("Please enter 5 numbers to be summed:\n");
   for (count = 0; count < MAX; count++)
      sumit();
   printf("Program completed\n");
}

sumit()
{
   static sum;
   int num;

   printf("Enter a number:\n");
   scanf("%d",&num);
   sum += num;
   printf("The total is %d \n",sum);
}   
