main()      /* Example 6.2 */
{
   int var1, var2;

   var1 = 25;
   var2 = 99;
   printf("Variables before swap,");
   printf("var1 = %d , var2 = %d\n",var1,var2);

   swap(&var1,&var2);  /* swap these variables */
   printf("Variables after swap,");
   printf("var1 = %d, var2 = %d\n",var1,var2);
}

swap(ptr1,ptr2)
   int *ptr1,*ptr2;    /* arguments passed by reference */
{
      int temp;
      temp = *ptr1;    /* save value of 1st argument */
      *ptr1 = *ptr2;   /* 1st argument gets value of 2nd */
      *ptr2 = temp;    /* 2nd argument gets value of 1st */
}
