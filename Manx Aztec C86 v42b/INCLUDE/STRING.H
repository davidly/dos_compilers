/* Copyright Manx Software Systems, Inc. 1987.  All rights reserved */

#ifndef __NOPROTO__
void *memcpy(void *s1, const void *s2, unsigned int n);
void *memmove(void *s1, const void *s2, unsigned int n);
char *strcpy(char *s1, const char *s2);
char *strncpy(char *s1, const char *s2, unsigned int n);
char *strcat(char *s1, const char *s2);
char *strncat(char *s1, const char *s2, unsigned int n);
int memcmp(const void *s1, const void *s2, unsigned int n);
int strcmp(const char *s1, const char *s2);
int strcoll(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, unsigned int n);
unsigned int strxfrm(char *s1, const char *s2, unsigned int n);
void *memchr(const void *s, int c, unsigned int n);
char *strchr(const char *s, int c);
unsigned int strcspn(const char *s1, const char *s2);
char *strpbrk(const char *s1, const char *s2);
char *strrchr(const char *s, int c);
unsigned int strspn(const char *s1, const char *s2);
char *strstr(const char *s1, const char *s2);
char *strtok(char *s1, const char *s2);
void *memset(void *s, int c, unsigned int n);
char *strerror(int errnum);
unsigned int strlen(const char *s);

#else
void *memcpy();
void *memmove();
char *strcpy();
char *strncpy();
char *strcat();
char *strncat();
int memcmp();
int strcmp();
int strncmp();
void *memchr();
char *strchr();
unsigned int strcspn();
char *strpbrk();
char *strrchr();
unsigned int strspn();
char *strstr();
char *strtok();
void *memset();
char *strerror();
unsigned int strlen();
#endif
