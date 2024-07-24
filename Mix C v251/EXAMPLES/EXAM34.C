main()         /* Example 3.4 */
{
   /*                   y                     */
   /*  calculate       x                      */
   /*                                         */
   /*  where x and y are integers and y >= 0  */

   int base, power;
   long result = 1;
   int counter = 0;

   printf("Enter the base number : ");
   scanf("%d",&base);
   printf("Enter the nth power to ");
   printf("which base will be raised:");
   scanf("%d",&power);

   while (counter++ < power)
         result = result * base;

   printf("The base of %d raised to",base);
   printf(" the %dth power is %ld\n",
      power,result);
}
