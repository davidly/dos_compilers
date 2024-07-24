main ()         /* Example 5.6 */
{
   int largest, i1, i2;

   printf("Enter 2 integer numbers: ");
   scanf("%d%d",&i1,&i2);
   largest = i1 > i2 ? i1 : i2;
   printf("The largest number is %d",largest);
}
