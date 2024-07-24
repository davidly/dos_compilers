#define MAX 10
main()      /* Example 6.6 */
{
  float count[MAX];
  float *ptr;
  int *iptr;
  int icount[MAX], i;

  /* initialize both arrays */
  for (i=0; i < MAX; i++)  {
     count[i] = 0.3;
     icount[i] = 1;
   }

  /* make ptr point to sixth element of array */
  ptr = &count[5];

  *ptr = 1.;              /* sets count[5] to 1. */
  *(ptr - 1) = .9;        /* sets count[4] to .9 */
  *(ptr + 1) = 1.1;       /* sets count[6] to 1.1 */

  iptr = &icount[5];
  *iptr = 0;              /* sets count[5] to 0 */
  *(iptr - 1) = -1;       /* sets count[4] to -1 */
  *(iptr + 1) = 2;        /* sets count[6] to 2 */

  for (i=0; i < MAX; i++)  {  /* print both arrays */
     printf("count[%d] = %f   ",i,*(count+i));
     printf("icount[%d] = %d\n",i,icount[i]);
  }
}
