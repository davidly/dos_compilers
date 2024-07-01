/*   Copyright (c) Mix Software 1988    */

char *realloc(oldptr, newsize)
char *oldptr;
int  newsize;
{
   char *newptr, *malloc();
   if (oldptr == NULL) return malloc(newsize);
   if (newsize == 0) {
      free(newptr);
      return NULL;
      }
   if (newptr = malloc(newsize)) {
      if (oldptr == NULL) return newptr;
      memcpy(newptr, oldptr, newsize);
      free(oldptr);
      return newptr;
   }
   else return NULL;
}

