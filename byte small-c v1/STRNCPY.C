/*
** copy n characters from sour to dest (null padding)
*/
strncpy(dest, sour, n) char *dest, *sour; int n; {
  char *d;
  d = dest;
  while(n-- > 0) {
    if(*d++ = *sour++) continue;
    while(n-- > 0) *d++ = 0;
    }
  *d = 0;
  return (dest);
  }
