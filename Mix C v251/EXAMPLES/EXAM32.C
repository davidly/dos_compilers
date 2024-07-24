main()                /* Example 3.2 */
{
   int birth_yr, cur_yr;

   printf("Enter the year of your birth: "); 
   scanf("%d",&birth_yr);
   if (birth_yr <= 0)
      printf(" Invalid year entered \n");
   printf("Enter the current year: ");
   scanf("%d",&cur_yr);
   if (cur_yr <= 0 )
      printf(" Invalid year entered \n");
   printf(" Your current age = %d \n",cur_yr - birth_yr);
}
