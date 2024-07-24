main()      /* Example 6.1 */
{
   int *ptr1, xxx;
   int old, new;
   int *savptr;

   xxx = 9;
   ptr1 = &xxx;       /* ptr1 contains address of xxx */
   printf("ptr1 = %x \n",ptr1);

   /*  get the contents of what is pointed to by ptr1 */
   old = *ptr1;       /* old now has the value of xxx */
   printf("old = %d \n",old);

   new = *ptr1 + 1;   /* new contains xxx + 1 */
   printf("new = %d\n",new);

   savptr = ptr1;     /* save the old address */
   printf("savptr = %x\n",savptr);

   ptr1 = &new;       /* make ptr1 point to new */
   printf("ptr1 = %x\n",ptr1);

   old = *ptr1 + 1;   /* an updated old value */
   printf("old = %d\n",old);
}

