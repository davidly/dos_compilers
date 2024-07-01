/* Searching and sorting */
/*   Copyright (c) Mix Software 1988    */

char *bsearch(key, base, num, width, compare)
   char *key;              /* search key */
   char *base;             /* start of array */
   unsigned num;           /* number of elements */
   unsigned width;         /* size of an element */
   int (*compare)();       /* function to compare two elements */
{
   char *here;
   int  cmp;
   int  i, j, k;

   i = 0;
   j = num-1;
   do {
      k = (j+i)>>1;
      here = base + width*k;
      cmp = (*compare)(key,here);
      if (cmp == 0) { /* found - now scan down for first */
         while ((here > base) && ((*compare)(key,here-width) == 0))
            here -= width;
         return here;
         }
      if (cmp < 0) j = k-1; else i=k+1;
      }
   while (j >= i);

   return NULL;
}  /* bsearch */

/* ------------------------------------------------------------ */

void qsort(base, num, width, compare)
   char *base;             /* start of array */
   unsigned num;           /* number of elements */
   unsigned width;         /* size of an element */
   int (*compare)();       /* function to compare two elements */
{
   char *key;
   char *first, *last, *max;
   int  memswap();

   last = max = base+(num-1)*width;
   first = base;
   key = base + width*(num >> 1);
   do {
      while ((*compare)(first,key,width) < 0) first += width;
      while ((*compare)(key,last,width) < 0) last -= width;
      if (first <= last) {
         if (first != last) {
            memswap(first,last,width);
            if (first == key) key = last;
            else if (last == key) key = first;
            }
         first += width;
         last -= width;
         }
      }
   while (first <= last);
   if (base < last) qsort(base,(last-base)/width+1,width,compare);
   if (first < max) qsort(first,(max-first)/width+1,width,compare);
   }

/* ------------------------------------------------------------ */

char *lsearch(key, base, num, width, compare)
   char *key;              /* search key */
   char *base;             /* start of array */
   unsigned *num;          /* number of elements */
   unsigned width;         /* size of an element */
   int (*compare)();       /* function to compare two elements */
{
   char *result;
   result = lfind(key,base,num,width,compare);
   if (result == NULL) {
      result = base+(*num)*width;
      memcpy(result,key,width);
      (*num)++;
      }
   return result;
}  /* lsearch */

/* ------------------------------------------------------------ */

char *lfind(key, base, num, width, compare)
   char *key;              /* search key */
   char *base;             /* start of array */
   unsigned *num;          /* number of elements */
   unsigned width;         /* size of an element */
   int (*compare)();       /* function to compare two elements */
{
   unsigned number = *num;
   while (number != 0) {
      if ((*compare)(key,base) == 0) return base;
      else {
         if (--number == 0) return NULL;
         else base += width;
         }
      }
   return NULL;
}  /* lfind */

