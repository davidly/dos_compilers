#ifndef __DIR_H
#define __DIR_H 1

#ifndef DIRSIZ
#define DIRSIZ 14
#endif

struct	direct
{
  unsigned short int d_ino;
  char d_name[DIRSIZ];
};

#endif /* __DIR_H */
