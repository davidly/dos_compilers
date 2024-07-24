main()      /* Example 2.5 */
{
   char c1, c2, c3;
   int  i1, i2, i3;
   float f1, f2, f3;
   long dl;

   /* char converts to int */
   c1 = 'c';
   i1 = c1 - 'a' + 'A';
   c3 = i1;       /* truncate to character */
   printf("c1 = %c, i1 = %d, c3 = %c\n", c1,i1,c3);
   i1 = 321;
   c2 = i1;       /* convert integer to char */
   c3 = i1 + 1;   /* truncates value */
   printf("i1 = %d, c2 = %c, c3 = %c\n",
      i1,c2,c3);

   /* automatic conversion from int to float */
   f1 = 200;      /* converted to float */
   f2 = 350 * f1; /* 350 converted to float */
   /* 7 converted to float- result truncated */
   i3 = 3.4 * 7;
   /* 350 converted to float - result truncated */
   i1 = f3 = f1 / 350;
   printf("f1 = %f, f2 = %f,\n",f1,f2);
   printf("i3 = %d, f3 = %f, i1 = %d\n",
      i3,f3,i1);
 /* values produced in the following
  assume a 16 bit integer */
   dl = 69631;    /* In hex 10FFF */
   i2 =dl;        /* truncates to 0FFF */
   printf("i2 = %d\n",i2);
}
