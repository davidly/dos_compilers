main()     /* Example 7.3 - part B */
{
   int count;     /* test push, pop, & top_reset */
   int pop(),push(),stk_lst(),top_reset();

   top_reset();   /* start off with fresh stack */
   stk_lst();     /* see if stack is empty */
   for(count=0; push(count)> -1; count++) ;
   stk_lst();     /* list current contents */
   while (pop() > -1);
   stk_lst();     /* see if stack empty */
}
