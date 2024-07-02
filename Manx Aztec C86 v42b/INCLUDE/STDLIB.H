/* Copyright Manx Software Systems, Inc. 1988.  All rights reserved */

typedef unsigned int size_t;

#ifndef __NOPROTO__
double atof(const char *nptr);
int atoi(const char *nptr);
long int atol(const char *nptr);
double strtod(const char *nptr, char *endptr);
long int strtol(char *nptr, char *endptr, int base);
unsigned long int stroul(char *nptr, char *endptr, int base);
int rand(void);
void srand(unsigned int seed);
void *calloc(size_t nmemb, size_t size);
void *malloc(size_t size);
void *realloc(void *ptr, size_t);
void abort(void);
int atexit(void (*func)(void));
int exit(int status);
char *getenv(const char *name);
int system(const char *string);
void *bsearch(const void *key, const void *base, size_t nmemb, size_t size,
			   int (*compar)(const void *, const void *));
int abs(int j);

#else

double atof();
int atoi();
long int atol();
double strtod();
long int strtol();
unsigned long stroul();
int rand();
void srand();
void *calloc(), *malloc(); 
void *realloc(), abort();
int atexit();
int exit();
char *getenv();
int system();
void *bsearch();
int abs();
#endif


#if __STDC__ != 1
char *stricmp(const char *string1, const char *string2);
#ifdef __NOPROTO__
char *strrev(const char *string1);
char *strlwr(const char *string1);
#else
char *strrev();
char *strlwr();
#endif
#endif

