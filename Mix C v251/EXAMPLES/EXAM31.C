main()                        /* Example 3.1 */
{
   int mph,time,distance;     /* figure distance traveled */
   printf("Enter your speed in miles per hour: ");
   scanf("%d",&mph);
   printf(
     "Enter the number of hours you traveled the above speed: ");
   scanf("%d",&time);
   distance = mph * time;
   printf("Miles traveled = %d  \n",distance);
}
