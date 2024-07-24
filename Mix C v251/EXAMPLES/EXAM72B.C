int b1;       /* b1 is extern int */

next()        /* Example 7.2 - part B */
{
   char a1;   /* in next a1 is auto character */
   a1 = 'a';
   printf("a1 inside next function = '%c'\n",a1);
   b1  = 77;
   printf("b1 inside next function = %d\n",b1);
}

