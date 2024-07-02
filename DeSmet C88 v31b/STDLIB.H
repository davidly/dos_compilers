extern int errno;

#define ERANGE	34

#define	HUGE_VAL	1.797693134862316E+308

#define	RAND_MAX	32767

extern unsigned environ;

extern unsigned _psp;

extern char _osmajor, _osminor;

int abs(int);
char *getenv(char *, char *, ...);
char *itoa(int, char *, int);
long labs(long);
char *ltoa(long, char *, int);
int putenv(char *, char *);
int rand(void);
void srand(int);
double strtod(const char *, char **);
long strtol(const char *, char **, int);

#ifndef tolower
int tolower(int);
#endif

#ifndef toupper
int toupper(int);
#endif

#define atoi(c)	(int)strtol((c), (char**)0, 0)
#define atol(c)	     strtol((c), (char**)0, 0)
#define atof(c)		 strtod((c), (char**)0);
