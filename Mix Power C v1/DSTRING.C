/* Dynamic string conversion */
/*   Copyright (c) Mix Software 1988    */

STRING *stods(s)                    /* convert string to dynamic string */
char    *s;                         /* s is a normal C string */
{
   int    length;
   STRING *ptr;
   STRING *calloc();
   int    strlen();                 /* get length of string */
   length = strlen(s);
   ptr = malloc(sizeof(int) + length);
   if (ptr != NULL) {
      ptr->length = length;
      movmem(s, ptr->string, length);
   }
   return ptr;
}

dstos(ptr,s)                 /* convert dynamic string into normal C string */
STRING  *ptr;                /* pointer to dynamic string */
char    *s;                  /* normal string */
{
   movmem(ptr->string, s, ptr->length);
   *(s + ptr->length) = '\0';
}

