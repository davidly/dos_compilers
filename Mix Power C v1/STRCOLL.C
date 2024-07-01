/*   Copyright (c) Mix Software 1988    */

/*
   Convert a string for collating sequence.
   The string is converted to a form suitable for comparison
   by strcmp or memcmp.  The resulting string is at most twice
   as long as the original string.  For standard ascii, no
   conversion is performed.  Conversion may be desireable when
   European characters are used and you wish to collate accented
   characters with their unaccented counterparts.
   */

size_t strcoll(to, maxsize, from)
   char *to;
   size_t maxsize;
   char *from;
{
   int size;
   size = strlen(from);
   if (size >= maxsize) return 0;
   memcpy(to,from,size);
   return size;
   }
