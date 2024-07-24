next1()    /* Example 7.2 - part C */
{
   extern int a1;
   float b1;    /* b1 is auto float */
   b1 = 19.3;
   printf("a1 inside next1 function = %d\n",a1);
   printf("b1 inside next1 function = %6.2f\n",b1);
   a1 = 13;
}
