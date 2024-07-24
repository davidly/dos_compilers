int a1 = 1;   /* global variable a1 */

main()        /* Example 7.2 - part A */
{
   a1 = 2;    /* changes the global value */
   printf("a1 inside main function = %d\n",a1);
   next();
   printf("After call to next, a1 = %d\n",a1);
   next1();
   printf("After call to next1, a1 = %d\n",a1);
}
