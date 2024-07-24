int a1 = 1; /* global variable a1 */

main()              /* Example 7.1 */
{
   a1 = 2;          /* changes the global value */
   printf("a1 inside main function = %d\n",a1);
   next();
   printf("After call to next, a1 = %d\n",a1);
   next1();
   printf("After call to next1, a1 = %d\n",a1);
}

int b1;             /*  b1 is extern int */

next()
{
   char a1;         /* in next a1 is auto character */
   a1 = 'a';
   printf("a1 inside next function = %c\n",a1);
   b1  = 77;
   printf("b1 inside next function = %d\n",b1);
}

next1()
{
   float b1;        /* b1 is auto char */
   b1 = 19.3;
   printf("a1 inside next1 function = %d\n",a1);
   printf("b1 inside next1 function = %6.2f\n",b1);
   a1 = 13;
}
