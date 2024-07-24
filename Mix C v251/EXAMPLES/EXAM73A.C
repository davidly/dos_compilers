/* Example 7.3 - part A */

#define STKMAX  20      /* maximum size of the stack */

static topptr = 0;      /* stack pointer */
static stack[STKMAX];   /* the stack itself */

push(val1)              /* push value onto stack */
int val1;
{
   if (topptr < STKMAX)
      return( stack[topptr++] = val1);
   else {
      printf("Error - stack overflow\n");
      return(-1);
   }
}

pop ()
{
   if (topptr > 0)
      return(stack[--topptr]);
   else {
      printf("Error - stack empty\n");
      return(-1);
   }
}

top_reset()   /* reset stack */
{
   topptr = 0;
}

stk_lst()
{
   int count;

   printf("\nThe stack contains the following");
   printf(", starting at the top:\n");
   if (topptr == 0) printf("empty\n");
   else for(count = topptr - 1; count > -1; count--)
      printf("stack[%d] = %d\n",count,stack[count]);
}

