/* Example 7.5 - part A */
#define TRUE  1
#define FALSE 0
#define MAX   100
static long bin[MAX];
static int bin_number = 0;
static int first = TRUE;

static init()
{
   int i;
   for(i=0; i < MAX; i++)
      bin[i] = -1;
   first = FALSE;
}

allocbin(partno)
long partno;
{
   if (first) init();
   if (bin_number < MAX)
      bin[bin_number++] = partno;
   else
      printf("Error - Out of Part Bins\n");
}

printbin()
{
   int i;
   for (i=0; i<MAX; i++)
      if (bin[i] != -1)
          printf("bin #%d = %ld\n", i, bin[i]);
}
