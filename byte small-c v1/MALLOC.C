#define NOCCARGC  /* no argument count passing */
#include stdio.h
/*
** Memory allocation of size bytes.
** size  = Size of the block in bytes.
** Returns the address of the allocated block,
** else NULL for failure.
*/
malloc(size) char *size; {
  return (Ualloc(size, NO));
  }
