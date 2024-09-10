#define NOCCARGC  /* no argument count passing */
#include stdio.h
/*
** Cleared-memory allocation of n items of size bytes.
** n     = Number of items to allocate space for.
** size  = Size of the items in bytes.
** Returns the address of the allocated block,
** else NULL for failure.
*/
calloc(n, size) char *n, *size; {
  return (Ualloc(n*size, YES));
  }
